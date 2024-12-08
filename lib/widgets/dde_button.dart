import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:weekly_todo/constants.dart';

class DButton extends StatefulWidget {
  final double width;
  final double height;
  final Widget child;
  final GestureTapCallback? onTap;
  final EdgeInsets? padding;
  final Color? activeBorderColor;
  final Color? backgroundColor;

  const DButton({
    super.key,
    required this.width,
    this.height = DSize.button,
    required this.child,
    this.onTap,
    this.padding,
    this.activeBorderColor,
    this.backgroundColor,
  });

  @override
  State<DButton> createState() => _DButtonState();

  factory DButton.save({
    Key? key,
    GestureTapCallback? onTap,
    required double width,
  }) =>
      DButton(
        key: key,
        width: width,
        onTap: onTap,
        backgroundColor: Colors.blue,
        child: const Text(
          '保存',
          style: DTextStyle.normal,
        ),
      );

  factory DButton.confirm({
    Key? key,
    GestureTapCallback? onTap,
    required double width,
  }) =>
      DButton(
        key: key,
        width: width,
        onTap: onTap,
        backgroundColor: Colors.blue,
        child: const Text(
          '确认',
          style: DTextStyle.normal,
        ),
      );

  factory DButton.cancel({
    Key? key,
    GestureTapCallback? onTap,
    required double width,
  }) =>
      DButton(
        key: key,
        width: width,
        onTap: onTap,
        child: const Text(
          '取消',
          style: DTextStyle.normal,
        ),
      );
}

class _DButtonState extends State<DButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.child is DropdownButton ? (widget.child as DropdownButton).onTap : widget.onTap,
      child: GlassContainer(
        padding: widget.padding,
        width: widget.width,
        height: widget.height,
        gradient: LinearGradient(
          colors: [
            widget.backgroundColor?.withOpacity(_hovering ? 0.9 : 1) ?? Colors.white.withOpacity(_hovering ? 0.1 : 0.15),
            widget.backgroundColor ?? Colors.white.withOpacity(0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderColor: widget.backgroundColor ?? const Color(0xff565656),
        borderWidth: 2,
        borderRadius: DRadius.borderRadiusSmall,
        child: MouseRegion(
          onEnter: (event) => setState(() {
            _hovering = true;
          }),
          onExit: (event) => setState(() {
            _hovering = false;
          }),
          cursor: SystemMouseCursors.click,
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
