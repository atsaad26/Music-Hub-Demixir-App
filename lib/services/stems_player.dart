import 'package:audioplayers/audioplayers.dart';
import 'package:demixr_app/models/unmixed_song.dart';

import '../constants.dart';

enum StemState {
  mute,
  unmute,
}

class StemsPlayer {
  Map<Stem, AudioPlayer> players = {};
  Map<Stem, StemState> stemStates = {};
  bool mixtureOn = false;
  int duration = 0;

  StemsPlayer() {
    players = {
      Stem.mixture: AudioPlayer()..mute(),
      Stem.vocals: AudioPlayer(),
      Stem.drums: AudioPlayer(),
      Stem.bass: AudioPlayer(),
      Stem.other: AudioPlayer(),
    };

    stemStates = {
      Stem.vocals: StemState.unmute,
      Stem.drums: StemState.unmute,
      Stem.bass: StemState.unmute,
      Stem.other: StemState.unmute,
    };

    toggleStem(Stem.vocals);
  }

  AudioPlayer get aPlayer => players[Stem.vocals]!;

  // Updated stream getters
  Stream<Duration> get onAudioPositionChanged => aPlayer.onPositionChanged;

  Stream<void> get onPlayerCompletion => aPlayer.onPlayerComplete;

  StemState getStemState(Stem stem) => stemStates[stem] ?? StemState.mute;

  bool get allStemsUnmute {
    return stemStates.values.every((element) => element == StemState.unmute);
  }

  Future<void> setUrls(UnmixedSong song) async {
    for (var stem in players.keys) {
      final player = players[stem]!;
      final stemPath = song.getStem(stem);
      if (stemPath != null) {
        // Determine if the source is local or remote
        // Here, assuming all stems are local files
        await player.setSource(DeviceFileSource(stemPath));
      }
    }
  }

  void pause() {
    players.forEach((stem, player) => player.pause());
  }

  void resume() {
    players.forEach((stem, player) => player.resume());
  }

  void stop() {
    players.forEach((stem, player) => player.stop());
  }

  void seek(Duration position) {
    players.forEach((stem, player) => player.seek(position));
  }

  void muteAll() {
    players.forEach((stem, player) => player.mute());
  }

  void unmuteAll() {
    players.forEach((stem, player) => player.unMute());
  }

  Future<void> toggleStem(Stem stem) async {
    if (mixtureOn) {
      mixtureOn = false;
      unmuteAll();
      await players[Stem.mixture]?.mute();
    }

    final state = getStemState(stem);
    await players[stem]?.muteToggle(state);

    stemStates[stem] = state.toggle();

    if (allStemsUnmute) {
      mixtureOn = true;
      muteAll();
      await players[Stem.mixture]?.unMute();
    }
  }
}

extension StemStateToggle on StemState {
  StemState toggle() {
    return this == StemState.mute ? StemState.unmute : StemState.mute;
  }
}

extension AudioPlayerMute on AudioPlayer {
  Future<void> mute() async {
    await setVolume(0.0);
  }

  Future<void> unMute() async {
    await setVolume(1.0);
  }

  Future<void> muteToggle(StemState currentState) async {
    if (currentState == StemState.mute) {
      await unMute();
    } else {
      await mute();
    }
  }
}
