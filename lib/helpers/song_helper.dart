import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' show get;
import 'package:image/image.dart';

import '../models/song.dart';
import '../models/song_download.dart';
import '../models/exceptions/conversion_exception.dart';
import '../models/failure/failure.dart';
import '../models/failure/no_internet_connection.dart';
import '../models/failure/song_conversion_failure.dart';
import '../models/failure/song_download_failure.dart';
import '../models/failure/song_load_failure.dart';
import '../models/failure/song_not_found_on_youtube.dart';
import '../services/song_loader.dart';
import '../constants.dart';
import '../utils.dart';

/// Helper handling the loading of the songs.
///
/// Uses the service [SongLoader] to load from the device and [YoutubeExplode]
/// to download from Youtube and retrieve the song informations.
class SongHelper {
  final _service = SongLoader();

  /// Loads a song from the device and retrieve it's title, artists and cover.
  Future<Either<Failure, Song>> loadFromDevice() async {
    Either<Failure, PlatformFile> file = await _service.getFromDevice();

    return file.fold((failure) => Left(failure), (file) async {
      if (file.path == null) return Left(SongLoadFailure());

      File path = File(file.path!);
      var metadata = await MetadataRetriever.fromFile(path);

      Tuple2<String, List<String>> songInfos = _getSongInfos(
        metadata.trackName,
        metadata.trackArtistNames,
        p.basename(path.path).removeExtension(),
      );

      String? coverPath = await _saveCover(path.path, songInfos.value1);

      String newPath;
      try {
        newPath = await convertToWav(file.path!);
      } on ConversionException {
        return Left(SongConversionFailure());
      }

      return Right(
        Song(
          title: songInfos.value1,
          artists: songInfos.value2,
          path: newPath,
          coverPath: coverPath,
          duration: Duration(milliseconds: metadata.trackDuration ?? 0),
        ),
      );
    });
  }

  /// Saves the song cover from the metadata to the app cache.
  Future<String?> _saveCover(String songPath, String title) async {
    var metadata = await MetadataRetriever.fromFile(File(songPath));
    final albumCover = metadata.albumArt;

    if (albumCover == null) return null;

    Image? image = decodeImage(albumCover);
    if (image == null) return null;

    final tempDir = await getAppTemp();
    final filePath = p.join(tempDir, '${title}_cover.jpg');

    File file = File(filePath);
    file.writeAsBytesSync(encodeJpg(image));

    return file.path;
  }

  /// Gets the informations from the song at the given Youtube [url].
  ///
  /// Finds the song title, artists and download the thumbnail.
  Future<Either<Failure, SongDownload>> getSongInfosFromYoutube(
      String url) async {
    final yt = YoutubeExplode();

    Video video;
    try {
      video = await yt.videos.get(url);
    } on ArgumentError {
      return Left(SongNotFoundOnYoutube());
    } on SocketException {
      return Left(NoInternetConnection());
    }

    String? coverPath;
    try {
      coverPath =
          await _downloadThumbnail(video.thumbnails.mediumResUrl, video.title);
    } catch (e) {
      coverPath = null;
    }

    yt.close();

    return Right(SongDownload(
      title: video.title,
      artists: [video.author],
      url: url,
      coverPath: coverPath,
      duration: video.duration ?? Duration.zero,
    ));
  }

  /// Downloads the given [song] from Youtube with [YoutubeExplode].
  Future<Either<Failure, Song>> downloadFromYoutube(SongDownload song) async {
    final yt = YoutubeExplode();

    File file;
    try {
      final manifest = await yt.videos.streamsClient.getManifest(song.url);
      final streamInfo = manifest.audioOnly.withHighestBitrate();

      // Get the actual stream
      final stream = yt.videos.streamsClient.get(streamInfo);

      file = File(p.join(await getAppTemp(), song.title));
      final fileStream = file.openWrite();

      // Pipe all the content of the stream into the file.
      await stream.pipe(fileStream);

      // Close the file.
      await fileStream.flush();
      await fileStream.close();
    } catch (_) {
      return Left(SongDownloadFailure());
    }

    yt.close();

    String newPath;
    try {
      newPath = await convertToWav(file.path);
    } on ConversionException {
      return Left(SongConversionFailure());
    }

    return Right(Song.fromDownload(song, newPath));
  }

  /// Download the Youtube video thumbnail at the given [url] to the cache.
  Future<String> _downloadThumbnail(String url, String title) async {
    final response = await get(Uri.parse(url));
    final tempDir = await getAppTemp();
    final filePath = p.join(tempDir, '${title}_cover.jpg');

    File file = File(filePath);
    file.writeAsBytesSync(response.bodyBytes);

    return file.path;
  }

  /// Determines a song informations either from the subscripted [title]
  /// and [artists] or from the [filename].
  Tuple2<String, List<String>> _getSongInfos(
    String? title,
    List<String>? artists,
    String filename,
  ) {
    const separator = songArtistTitleSeparator;
    var splitedFilename = filename.split(separator);
    var titleFromFilename = splitedFilename.length == 1
        ? splitedFilename[0].trim()
        : splitedFilename.sublist(1).join(separator).trim();

    title ??= titleFromFilename;
    artists ??= [splitedFilename[0].trim()];

    return Tuple2(title, artists);
  }
}

/// Converts the song at the given [path] to the Waveform format (`wav`).
///
/// Uses FFmpeg via [FFmpegKit] to retrieve the format of the current file and
/// convert it if needed.
/// Throws a [ConvertionException] if the format could not be found, or if the
/// convertion failed.
Future<String> convertToWav(String path) async {
  final session = await FFprobeKit.getMediaInformation(path);
  final information = session.getMediaInformation();

  String? format = information?.getProperties('format_name');

  if (format == null) {
    throw ConversionException('SongLoader: Failed to get the file format');
  } else if (format != 'wav') {
    final outputPath = '${p.withoutExtension(path)}.wav';
    File(outputPath).deleteIfExists();

    final convertSession =
        await FFmpegKit.execute('-i "$path" -acodec pcm_u8 "$outputPath"');
    final convertRc = await convertSession.getReturnCode();

    if (ReturnCode.isSuccess(convertRc)) {
      path = outputPath;
    } else {
      throw ConversionException(
          'SongLoader: Failed to convert audio file to wav');
    }
  }

  return path;
}
