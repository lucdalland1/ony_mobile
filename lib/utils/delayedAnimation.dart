import 'package:flutter/cupertino.dart';

class DelayedAnimation extends StatefulWidget {
  final Widget child;
  final int delay; // Durée de l'animation en millisecondes
  final bool choix; // true = horizontal, false = vertical
  final bool gauche; // true = de gauche, false = de droite (utilisé seulement si horizontal)

  const DelayedAnimation({
    super.key,
    required this.child,
    required this.delay,
    required this.choix,
    this.gauche = false,
  });

  @override
  State<DelayedAnimation> createState() => _DelayedAnimationState();
}

class _DelayedAnimationState extends State<DelayedAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.delay),
    );

    _animation = _createAnimation();

    // Démarre l'animation après le premier frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  /// Crée une animation Slide selon les paramètres
  Animation<Offset> _createAnimation() {
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutExpo,
    );

    // Choix = true → animation horizontale
    // Sinon → animation verticale (du haut vers le bas)
    return Tween<Offset>(
      begin: widget.choix
          ? (widget.gauche ? const Offset(-0.5, 0) : const Offset(0.5, 0))
          : const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(curve);
  }

  @override
  void didUpdateWidget(covariant DelayedAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Ne redémarre l'animation que si les paramètres changent
    if (widget.choix != oldWidget.choix ||
        widget.gauche != oldWidget.gauche ||
        widget.delay != oldWidget.delay ||
        widget.child.key != oldWidget.child.key) {
      _animation = _createAnimation();
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: _animation,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
