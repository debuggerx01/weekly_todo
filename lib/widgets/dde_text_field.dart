import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:weekly_todo/constants.dart';
import 'package:weekly_todo/widgets/markdown_preview.dart';

class DTextField extends StatefulWidget {
  final TextStyle style;
  final String? initText;
  final String? hint;
  final bool Function(String value) onComplete;

  const DTextField({
    super.key,
    required this.style,
    this.initText,
    this.hint,
    required this.onComplete,
  });

  @override
  DTextFieldState createState() => DTextFieldState();
}

class DTextFieldState extends State<DTextField> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _focusNode.addListener(_handleFocusChange);
    _controller.text = widget.initText ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      var ok = widget.onComplete(_controller.text);
      if (!ok) {
        _focusNode.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: Builder(builder: (context) {
        if (Focus.of(context).hasFocus && !_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
        return GestureDetector(
          onTap: () {
            _focusNode.requestFocus();
            Focus.of(context).requestFocus();
            Future.microtask(() {
              setState(() {});
            });
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: DRadius.borderRadiusMedium,
              color: Colors.grey.withOpacity(.3),
              border: Border.all(
                width: 2,
                color: Focus.of(context).hasFocus ? DColors.activeColor : const Color(0xff565656),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: DSize.widgetPadding, horizontal: DSize.defaultPadding / 2),
              child: Focus.of(context).hasFocus
                  ? TextField(
                      style: widget.style,
                      focusNode: _focusNode,
                      cursorColor: DColors.activeColor,
                      decoration: InputDecoration.collapsed(hintText: widget.hint),
                      controller: _controller,
                      expands: true,
                      maxLines: null,
                    )
                  : MdPreview(
                      text: _controller.text,
                      widgetImage: (imageUrl) => Container(),
                      onCodeCopied: () {},
                      onTapLink: (link) async {
                        if (await canLaunchUrlString(link)) {
                          launchUrlString(link);
                        }
                      },
                    ),
            ),
          ),
        );
      }),
    );
  }
}
