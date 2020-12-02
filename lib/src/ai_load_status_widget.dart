import 'package:ai_load_status/src/ai_step_load_text_widget.dart';
import 'package:flutter/material.dart';

///
/// AiLoadStatusWidget
class AiLoadStatusWidget extends StatefulWidget {
  Widget _child;
  bool _isLoading;
  bool _isLoop;
  bool _isReverse;
  bool _showCursor;
  Widget _labelChild;
  String _stepLoadData;
  AiLoadStatusWidget.defaultStyle({
    @required Widget child,
    bool isLoading = false,
    bool isLoop = false,
    bool isReverse = false,
    bool showCursor = true,
    Widget labelChild,
    String stepLoadData,
  }) {
    _child = child;
    _isLoading = isLoading;
    _isLoop = isLoop;
    _isReverse = isReverse;
    _showCursor = showCursor;
    _labelChild = labelChild;
    _stepLoadData = stepLoadData;
  }
  @override
  _AiLoadStatusWidgetState createState() => _AiLoadStatusWidgetState();
}

class _AiLoadStatusWidgetState extends State<AiLoadStatusWidget> {
  WriteTextController _textController;
  @override
  void initState() {
    super.initState();
    _textController = WriteTextController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _textController.start();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _textController.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IgnorePointer(
          ignoring: widget._isLoading ? true : false,
          child: widget._child,
        ),
        widget._isLoading ? _loadingWidget() : Container(),
      ],
    );
  }

  Widget _loadingWidget() {
    return InkWell(
      child: Container(
        child: Container(
          color: Colors.black45,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget._labelChild ??
                      Text(
                        "努力加载中",
                        style: Theme.of(context)
                            .primaryTextTheme
                            .bodyText1
                            .copyWith(
                              color: Colors.white,
                            ),
                      ),
                  AiStepLoadTextWidget(
                    controller: _textController,
                    loop: widget._isLoop,
                    reverse: widget._isReverse,
                    showCursor: widget._showCursor,
                    data: "${widget._stepLoadData}",
                    textStyle:
                        Theme.of(context).primaryTextTheme.bodyText1.copyWith(
                              color: Colors.white,
                            ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
