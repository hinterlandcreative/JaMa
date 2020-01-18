import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:jama/ui/app_styles.dart';

class StepperTouch extends StatefulWidget {
  const StepperTouch(
      {Key key,
      this.initialValue,
      this.onChanged,
      this.direction = Axis.horizontal,
      this.withSpring = true,
      this.minValue = 0})
      : super(key: key);

  /// the orientation of the stepper its horizontal or vertical.
  final Axis direction;

  /// the initial value of the stepper
  final int initialValue;

  /// called whenever the value of the stepper changed
  final ValueChanged<int> onChanged;

  /// if you want a springSimulation to happens the the user let go the stepper
  /// defaults to true
  final bool withSpring;

  final int minValue;

  @override
  _Stepper2State createState() => _Stepper2State();
}

class _Stepper2State extends State<StepperTouch>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;
  int _value;
  double _startAnimationPosX;
  double _startAnimationPosY;

  double _startY;
  int _initialDragValue;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue ?? 0;
    if (_value < widget.minValue) {
      ArgumentError("initial value can't be less than minValue.");
    }

    _controller =
        AnimationController(vsync: this, lowerBound: -0.5, upperBound: 0.5);
    _controller.value = 0.0;
    _controller.addListener(() {});

    if (widget.direction == Axis.horizontal) {
      _animation = Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(1.5, 0.0))
          .animate(_controller);
    } else {
      _animation = Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(0.0, 1.5))
          .animate(_controller);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.direction == Axis.horizontal) {
      _animation = Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(1.5, 0.0))
          .animate(_controller);
    } else {
      _animation = Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(0.0, 1.5))
          .animate(_controller);
    }
  }

  // !test = init();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
        child: Container(
      width: widget.direction == Axis.horizontal ? 280.0 : 120.0,
      height: widget.direction == Axis.horizontal ? 120.0 : 280.0,
      child: Material(
        type: MaterialType.canvas,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(60.0),
        color: Colors.white.withOpacity(0.2),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              left: widget.direction == Axis.horizontal ? 10.0 : null,
              bottom: widget.direction == Axis.horizontal ? null : 10.0,
              child: Icon(Icons.remove, size: 40.0, color: Colors.white),
            ),
            Positioned(
              right: widget.direction == Axis.horizontal ? 10.0 : null,
              top: widget.direction == Axis.horizontal ? null : 10.0,
              child: Icon(Icons.add, size: 40.0, color: Colors.white),
            ),
            Center(
              child: Text(
                "$_value",
                style: AppStyles.heading4.copyWith(
                    fontSize: 56, color: AppStyles.secondaryTextColor),
              ),
            ),
            GestureDetector(
              onHorizontalDragStart: _onPanStart,
              onHorizontalDragUpdate: _onPanUpdate,
              onHorizontalDragEnd: _onPanEnd,
              child: SlideTransition(
                position: _animation,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 5.0,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return ScaleTransition(child: child, scale: animation);
                      },
                      child: Text(
                        '$_value',
                        key: ValueKey<int>(_value),
                        style:
                            TextStyle(color: Color(0xFF6D72FF), fontSize: 56.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              width: 120.0,
              height: 80.0,
              child: GestureDetector(
                  onTap: () => setState(() => _incrementValue()),
                  child: Container(color: Colors.transparent))),
            Positioned(
              bottom: 0,
              width: 120.0,
              height: 80.0,
              child: GestureDetector(
                  onTap: () => _decrementValue(),
                  child: Container(color: Colors.transparent))),
          ],
        ),
      ),
    ));
  }

  double offsetFromGlobalPos(Offset globalPosition) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset local = box.globalToLocal(globalPosition);
    _startAnimationPosX = ((local.dx * 0.75) / box.size.width) - 0.4;
    _startAnimationPosY = ((local.dy * 0.75) / box.size.height) - 0.4;
    if (widget.direction == Axis.horizontal) {
      return ((local.dx * 0.75) / box.size.width) - 0.4;
    } else {
      double dy = 0;
      double orientation = 1;
      if (globalPosition.dy < _startY) {
        dy = _startY - globalPosition.dy;
      } else {
        orientation = -1;
        dy = globalPosition.dy - _startY;
      }
      var unitsOfChange = (dy ~/ box.size.height) * orientation;

      if(_value + unitsOfChange >= widget.minValue) {
        setState(() => _setValue(_initialDragValue + unitsOfChange.toInt()));
      }
      return ((local.dy * 0.75) / box.size.height) - 0.4;
    }
  }

  void _onPanStart(DragStartDetails details) {
    _startY = details.globalPosition.dy;
    _initialDragValue = _value;
    _controller.stop();
    _controller.value = offsetFromGlobalPos(details.globalPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _controller.value = offsetFromGlobalPos(details.globalPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    _controller.stop();
    if (widget.withSpring) {
      final SpringDescription _kDefaultSpring =
          new SpringDescription.withDampingRatio(
        mass: 0.9,
        stiffness: 250.0,
        ratio: 0.6,
      );
      if (widget.direction == Axis.horizontal) {
        _controller.animateWith(
            SpringSimulation(_kDefaultSpring, _startAnimationPosX, 0.0, 0.0));
      } else {
        _controller.animateWith(
            SpringSimulation(_kDefaultSpring, _startAnimationPosY, 0.0, 0.0));
      }
    } else {
      _controller.animateTo(0.0,
          curve: Curves.bounceOut, duration: Duration(milliseconds: 500));
    }
  }

  void _setValue(int value) {
    if(_value != value) {
      _value = value;
      if(widget.onChanged != null) {
        widget.onChanged(_value);
      }
    }
  }

  void _incrementValue() {
    _setValue(_value + 1);
  }

  void _decrementValue() {
    if(_value - 1 >= widget.minValue) {
      _setValue(_value - 1);
    }
  }
}
