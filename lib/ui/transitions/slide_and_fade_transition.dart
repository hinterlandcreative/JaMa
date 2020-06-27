import 'package:flutter/material.dart';

class SlideAndFadeTransition extends StatefulWidget {
  /// The [child] to animate.
  final Widget child;

  /// The amount of [delay] in milliseconds.
  final int delay;

  /// A unique value to [id] the child widget (for preventing the animation from reloading).
  final String id;

  /// The [curve] to use in the animation. Defaults to `Curves.decelarate`.
  final Curve curve;

  /// The [direction] for the slide to occur from. Defaults to `AxisDirection.up`.
  final AxisDirection direction;

  /// The [offset] from which to begin the animation. Defaults to `0.25`.
  final double offset;

  SlideAndFadeTransition({@required this.child, @required this.id, this.delay, this.curve = Curves.decelerate, this.direction = AxisDirection.up, this.offset = 0.25});

  @override
  SlideAndFadeTransitionState createState() => SlideAndFadeTransitionState();
}

class SlideAndFadeTransitionState extends State<SlideAndFadeTransition> with TickerProviderStateMixin {
  AnimationController _animController;
  Animation<Offset> _animOffset;

  @override
  void initState() {
    super.initState();
    Map<AxisDirection, Offset> directionToOffsetMap = {
      AxisDirection.up: Offset(0.0, widget.offset),
      AxisDirection.down: Offset(0.0, widget.offset * -1),
      AxisDirection.right: Offset(widget.offset, 0.0),
      AxisDirection.left: Offset(widget.offset * -1, 0.0)
    };

    

    _animController = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    final _curve = CurvedAnimation(curve: widget.curve != null ? widget.curve : Curves.decelerate, parent: _animController);
    _animOffset = Tween<Offset>(begin: directionToOffsetMap[widget.direction], end: Offset.zero).animate(_curve);

    if (widget.delay == null) {
      _animController.forward();
    } else {
      _animController.reset();
      Future.delayed(Duration(milliseconds: widget.delay), () {
        _animController.forward();
      });
    }
  }

  @override
  void didUpdateWidget(SlideAndFadeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.id != oldWidget.id) {
      _animController.reset();
      Future.delayed(Duration(milliseconds: widget.delay), () {
        _animController.forward();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _animController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      child: SlideTransition(position: _animOffset, child: widget.child),
      opacity: _animController,
    );
  }
}