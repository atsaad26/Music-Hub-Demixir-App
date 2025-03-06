import 'package:demixr_app/components/buttons.dart';
import 'package:demixr_app/components/extended_widgets.dart';
import 'package:demixr_app/constants.dart';
import 'package:demixr_app/providers/player_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StemSelection extends StatefulWidget {
  const StemSelection({Key? key}) : super(key: key);

  @override
  _StemSelectionState createState() => _StemSelectionState();
}

class _StemSelectionState extends State<StemSelection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(35);
    return FadeTransition(
      opacity: _controller,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(radius),
          border: Border.all(width: 2, color: ColorPalette.surfaceVariant),
        ),
        child: Padding(
          padding:
          const EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 10),
          child: Column(
            children: const [
              AnimatedStemButton(Stem.vocals),
              AnimatedStemButton(Stem.bass),
              AnimatedStemButton(Stem.drums),
              AnimatedStemButton(Stem.other),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedStemButton extends StatefulWidget {
  final Stem stem;

  const AnimatedStemButton(this.stem, {Key? key}) : super(key: key);

  @override
  _AnimatedStemButtonState createState() => _AnimatedStemButtonState();
}

class _AnimatedStemButtonState extends State<AnimatedStemButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, player, child) {
        final icon =
        player.isStemMute(widget.stem) ? Icons.headset_off : Icons.headset;

        return GestureDetector(
          onTapDown: (_) => _controller.reverse(),
          onTapUp: (_) {
            _controller.forward();
            player.toggleStem(widget.stem);
          },
          onTapCancel: () => _controller.forward(),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SpacedRow(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white),
                  SizedBox(
                    width: 125,
                    child: Button(
                      widget.stem.name,
                      color: Colors.transparent,
                      textColor: Colors.white,
                      textSize: 16,
                      radius: 12,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
