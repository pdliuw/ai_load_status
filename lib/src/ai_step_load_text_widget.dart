import 'package:flutter/material.dart';

///
/// 字符间隔默认时长
///
const int _kDefaultMillSeconds = 300;

///
/// 默认光标
///
const Widget _kDefaultCursor = const _DefaultCursor();

///
/// desc: WriteText 是逐步显示文本的动画组件，像手写一样的效果。
///
class AiStepLoadTextWidget extends StatefulWidget {
  ///
  /// 数据
  ///
  final String data;

  ///
  /// 是否显示光标
  ///
  final bool showCursor;

  ///
  /// 光标组件
  ///
  final Widget cursor;

  ///
  /// 字符间隔时长
  ///
  final int perMillSeconds;

  ///
  /// 激活状态文本的样式
  ///
  final TextStyle textStyle;

  ///
  /// 是否自动启动
  ///
  final bool autoStart;

  ///
  /// 是否循环
  final bool loop;

  final bool reverse;

  ///
  /// 控制器
  ///
  final WriteTextController controller;

  const AiStepLoadTextWidget({
    Key key,
    @required this.data,
    this.controller,
    this.showCursor = true,
    this.cursor = _kDefaultCursor,
    this.perMillSeconds = _kDefaultMillSeconds,
    this.textStyle,
    this.autoStart = true,
    this.loop = false,
    this.reverse = false,
  })  : assert(data != null, 'data cannot be null'),
        assert(perMillSeconds != null, 'perDuration cannot be null'),
        super(key: key);

  @override
  _AiStepLoadTextWidgetState createState() => _AiStepLoadTextWidgetState();
}

class _AiStepLoadTextWidgetState extends State<AiStepLoadTextWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this,
        duration:
            Duration(milliseconds: widget.perMillSeconds * widget.data.length));
    _animationController.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.completed:
          if (widget.loop) {
            if (widget.reverse) {
              reverse();
            } else {
              reset();
              start();
            }
          }
          break;
        case AnimationStatus.dismissed:
          if (widget.loop) {
            start();
          }
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
      }
    });
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _animationController.forward();
      });
    }
    if (widget.controller != null) {
      widget.controller._setStepTextState(this);
    }
  }

  ///
  /// 启动
  ///
  start() {
    _animationController.forward();
  }

  ///
  /// 停止
  ///
  stop() {
    _animationController.stop();
  }

  reverse() {
    _animationController.reverse();
  }

  reset() {
    _animationController?.reset();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget child) {
        int endIndex =
            (widget.data.length * _animationController.value).floor();
        var text = widget.data.substring(0, endIndex);
        return RichText(
          text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: <InlineSpan>[
                TextSpan(
                    text: '$text ', style: widget.textStyle ?? TextStyle()),
                if (widget.showCursor)
                  WidgetSpan(
                      child: StepTextCursor(
                    cursor: widget.cursor ?? _kDefaultCursor,
                  )),
              ]),
        );
      },
    );
  }
}

class StepTextCursor extends StatefulWidget {
  final Widget cursor;

  const StepTextCursor({Key key, this.cursor}) : super(key: key);

  @override
  _StepTextCursorState createState() => _StepTextCursorState();
}

class _StepTextCursorState extends State<StepTextCursor>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _controller.reverse();
            } else if (status == AnimationStatus.dismissed) {
              _controller.forward();
            }
          });
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget child) {
          return Opacity(
            opacity: _controller.value,
            child: widget.cursor,
          );
        });
  }
}

class _DefaultCursor extends StatelessWidget {
  const _DefaultCursor();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 1,
      color: Theme.of(context).primaryColor,
    );
  }
}

class WriteTextController {
  _AiStepLoadTextWidgetState _stepTextState;

  void _setStepTextState(_AiStepLoadTextWidgetState __stepTextState) {
    this._stepTextState = __stepTextState;
  }

  start() {
    _stepTextState.start();
  }

  stop() {
    _stepTextState.stop();
  }
}
