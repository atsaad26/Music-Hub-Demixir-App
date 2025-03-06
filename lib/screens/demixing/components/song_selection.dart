import 'package:auto_size_text/auto_size_text.dart';
import 'package:demixr_app/components/buttons.dart';
import 'package:demixr_app/components/extended_widgets.dart';
import 'package:demixr_app/components/song_widget.dart';
import 'package:demixr_app/constants.dart';
import 'package:demixr_app/models/song.dart';
import 'package:demixr_app/models/song_download.dart';
import 'package:demixr_app/providers/song_provider.dart';
import 'package:demixr_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';

class SongSelection extends StatelessWidget {
  const SongSelection({Key? key}) : super(key: key);

  Widget buildButtons(SongProvider provider, BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // FittedBox(
          //   child: Button(
          //     'Search Youtube',
          //     icon: SvgPicture.asset(
          //       getAssetPath('youtube', AssetType.icon),
          //     ),
          //     textSize: 14,
          //     onPressed: () =>
          //         Get.toNamed('/demixing/youtube', arguments: provider),
          //     padding: const EdgeInsets.only(
          //         left: 15, top: 10, right: 15, bottom: 10),
          //   ),
          // ),
          FittedBox(
            child: Button(
              'Browse files',
              icon: const Icon(
                Icons.file_upload,
                color: ColorPalette.onPrimary,
                size: 18,
              ),
              textSize: 14,
              onPressed: provider.loadFromDevice,
              padding: const EdgeInsets.only(
                  left: 15, top: 10, right: 15, bottom: 10),
            ),
          ),
        ],
      );

  Widget buildSelectionCard(SongProvider provider, BuildContext context) =>
      Card(
        color: ColorPalette.surfaceVariant,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: SpacedColumn(
            spacing: 30,
            children: [
              const ListTile(
                title: AutoSizeText(
                  'Song selection',
                  style: TextStyle(
                      color: ColorPalette.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
              const AutoSizeText(
                'You can select a song from your device ',
                //'You can select a song from your device or directly from Youtube.',
                style: TextStyle(
                    color: ColorPalette.onSurfaceVariant, fontSize: 16),
                textAlign: TextAlign.center,
                maxLines: 2,
                minFontSize: 10,
              ),
              buildButtons(provider, context),
            ],
          ),
        ),
      );

  Widget buildSelectedSongCard(Song song, {VoidCallback? onRemovePressed}) =>
      Card(
        color: ColorPalette.surfaceVariant,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SongWidget(
            title: song.title,
            artists: song.artists,
            coverPath: song.albumCover,
            onRemovePressed: onRemovePressed,
          ),
        ),
      );

  Widget buildDownloadSongCard(SongDownload song) => Card(
        color: ColorPalette.surfaceVariant,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SongWidget(
            title: song.title,
            artists: song.artists,
            coverPath: song.albumCover,
            download: true,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Consumer<SongProvider>(
      builder: (context, songProvider, child) {
        List<Widget> children = [buildSelectionCard(songProvider, context)];

        // Add the download song card if a download is in progress
        songProvider.songDownload.fold(
          (failure) => null,
          (song) => children.add(buildDownloadSongCard(song)),
        );

        // Add the song card if a song is selected
        songProvider.song.fold(
          (failure) => null,
          (song) => children.add(
            buildSelectedSongCard(
              song,
              onRemovePressed: () => songProvider.removeSelectedSong(),
            ),
          ),
        );

        return Column(
          children: children,
        );
      },
    );
  }
}
