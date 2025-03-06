import 'package:demixr_app/models/model.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class ColorPalette {
  // Primary color: Amber
  static const Color primary = Color(0xFFFFC107); // Amber[500]

  // Color used on primary color: Black
  static const Color onPrimary = Colors.black;

  // Surface color: Black
  static const Color surface = Colors.black;

  // Color used on surface: White
  static const Color onSurface = Colors.white;

  // Surface variant: Dark Grey
  static const Color surfaceVariant = Color(0xFF424242); // Grey[800]

  // Color used on surface variant: Light Grey
  static const Color onSurfaceVariant = Color(0xFFBDBDBD); // Grey[300]

  // Tertiary color: Deeper Amber
  static const Color tertiary = Color(0xFFFFA000); // Amber[700]

  // Color used on tertiary: Black
  static const Color onTertiary = Colors.black;

  // Error container: Dark Red
  static const Color errorContainer = Color(0xFFD32F2F); // Red[700]

  // Color used on error: White
  static const Color onError = Colors.white;

  // Inverse surface: White
  static const Color inverseSurface = Colors.white;

  // Inverse primary: Lighter Amber
  static const Color inversePrimary = Color(0xFFFFE082); // Amber[200]

  // Link color: Amber shade
  static final Color link = Colors.amber.shade300;

  // Primary gradient: Two Amber shades
  static const List<Color> primaryGradient = [
    Color(0xFFFFC107), // Amber[500]
    Color(0xFFFFA000), // Amber[700]
  ];

  // Primary faded gradient: Two Amber shades with 25% opacity
  static const List<Color> primaryFadedGradient = [
    Color.fromRGBO(255, 193, 7, 0.25),   // Amber[500] with 25% opacity
    Color.fromRGBO(255, 160, 0, 0.25),   // Amber[700] with 25% opacity
  ];

  // Indicator colors: Primary gradient plus error container
  static List<Color> indicatorColors = [
    primaryGradient[0],
    primaryGradient[1],
    errorContainer,
  ];
}


// class ColorPalette {
//   static const Color primary = Color.fromRGBO(255, 181, 157, 1);
//   static const Color onPrimary = Color.fromRGBO(93, 23, 1, 1);
//   static const Color surface = Color.fromRGBO(33, 26, 24, 1);
//   static const Color onSurface = Color.fromRGBO(237, 224, 221, 1);
//   static const Color surfaceVariant = Color.fromRGBO(83, 67, 63, 1);
//   static const Color onSurfaceVariant = Color.fromRGBO(216, 194, 188, 1);
//   static const Color tertiary = Color.fromRGBO(245, 226, 167, 1);
//   static const Color onTertiary = Color.fromRGBO(58, 47, 4, 1);
//   static const Color errorContainer = Color.fromRGBO(147, 0, 6, 1);
//   static const Color onError = Color.fromRGBO(255, 218, 212, 1);
//   static const Color inverseSurface = Color.fromRGBO(237, 224, 221, 1);
//   static const Color inversePrimary = Color.fromRGBO(155, 68, 41, 1);
//   static final Color link = Colors.blue.shade300;
//   static const List<Color> primaryGradient = [
//     Color.fromRGBO(250, 184, 196, 1),
//     Color.fromRGBO(89, 86, 233, 1),
//   ];
//   static const List<Color> primaryFadedGradient = [
//     Color.fromRGBO(250, 184, 196, 0.25),
//     Color.fromRGBO(89, 86, 233, 0.25),
//   ];
//   static const List<Color> indicatorColors = [
//     ...ColorPalette.primaryGradient,
//     ColorPalette.errorContainer,
//   ];
// }

class Paths {
  static const images = 'assets/images/';
  static const icons = 'assets/icons/';
  static const animations = 'assets/animations/';
}

const songArtistTitleSeparator = '-';

class BoxesNames {
  static const library = 'library';
  static const preferences = 'preferences';
}

class Models {
  static const openUnmixInfosUrl = 'https://sigsep.github.io/open-unmix/';

  static const fileExtension = '.plt';

  static const umxhq = Model(
    name: 'umxhq',
    description:
        'Model trained on the MUSDB18-HQ dataset.\nFaster separation (~ length of the song).\n(140 MB)',
    url:
        'https://github.com/demixr/openunmix-torchscript/releases/latest/download/umxhq.ptl',
    isDefault: true,
  );
  static const umxl = Model(
    name: 'umxl',
    description:
        'Model trained on extra data. Longer separation, but improved performance.\n(290 MB)',
    url:
        'https://github.com/demixr/openunmix-torchscript/releases/latest/download/umxl.ptl',
  );

  static Model fromName(String name) {
    if (name == umxhq.name) return umxhq;
    if (name == umxl.name) return umxl;

    throw ArgumentError('Models: The given model name does not exist');
  }

  static const List<Model> all = [Models.umxhq, Models.umxl];
}

enum Stem {
  mixture,
  vocals,
  drums,
  bass,
  other,
}

extension StemsName on Stem {
  String get name {
    switch (this) {
      case Stem.mixture:
        return 'Mixture';
      case Stem.vocals:
        return 'Vocals';
      case Stem.drums:
        return 'Drums';
      case Stem.bass:
        return 'Bass';
      case Stem.other:
        return 'Other';
    }
  }

  String get value => name.toLowerCase();
}

class Preferences {
  static const model = 'model';
}

class PlatformChannels {
  static const demixing = 'demixing';
  static const demixingProgress = 'demixing/progress';
}
