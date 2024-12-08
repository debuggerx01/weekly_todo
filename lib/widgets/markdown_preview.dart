import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:weekly_todo/constants.dart';

class MdPreview extends StatefulWidget {
  const MdPreview({
    super.key,
    required this.text,
    this.padding = const EdgeInsets.all(0.0),
    this.onTapLink,
    required this.widgetImage,
    required this.onCodeCopied,
    this.textStyle,
    this.richTap,
  });

  final String text;
  final EdgeInsetsGeometry padding;
  final WidgetImage widgetImage;
  final TextStyle? textStyle;

  final Function onCodeCopied;

  /// Call this method when it tap link of markdown.
  /// If [onTapLink] is null,it will open the link with your default browser.
  final TapLinkCallback? onTapLink;

  final VoidCallback? richTap;

  @override
  State<StatefulWidget> createState() => MdPreviewState();
}

class MdPreviewState extends State<MdPreview> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Padding(
        padding: widget.padding,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Markdown(
              data: widget.text,
              maxWidth: constraints.maxWidth,
              linkTap: (link) {
                debugPrint(link);
                if (widget.onTapLink != null) {
                  widget.onTapLink!(link);
                }
              },
              image: widget.widgetImage,
              textStyle: widget.textStyle,
              onCodeCopied: widget.onCodeCopied,
              richTap: widget.richTap,
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

typedef TapLinkCallback = void Function(String link);

class Markdown extends StatefulWidget {
  const Markdown({
    super.key,
    required this.data,
    required this.linkTap,
    required this.image,
    required this.onCodeCopied,
    this.maxWidth,
    this.textStyle,
    this.richTap,
  });

  final String data;

  final LinkTap linkTap;

  final WidgetImage image;

  final double? maxWidth;

  final TextStyle? textStyle;

  final Function onCodeCopied;

  final VoidCallback? richTap;

  @override
  MarkdownState createState() => MarkdownState();
}

class MarkdownState extends State<Markdown> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _parseMarkdown(),
    );
  }

  List<Widget> _parseMarkdown() {
    // debugPrint(markdownToHtml(
    //   widget.data,
    //   extensionSet: ExtensionSet.gi法inaltHubWeb,
    // ));
    final List<String> lines = widget.data.split(RegExp(r'\r?\n'));
    final nodes = md.Document(
      extensionSet: md.ExtensionSet.gitHubWeb,
    ).parseLines(lines);
    return MarkdownBuilder(
      context,
      widget.linkTap,
      widget.image,
      widget.maxWidth ?? MediaQuery.of(context).size.width,
      widget.textStyle ?? DTextStyle.normal,
      onCodeCopied: widget.onCodeCopied,
      richTap: widget.richTap,
    ).build(nodes);
  }
}

/// 递归解析标签
/// [_elementList] 每个标签依次放入该集合
/// 在[visitElementBefore]时添加
/// 在[visitElementAfter]时将其移除

class MarkdownBuilder implements md.NodeVisitor {
  MarkdownBuilder(
    this.context,
    this.linkTap,
    this.widgetImage,
    this.maxWidth,
    this.defaultTextStyle, {
    this.tagTextStyle = defaultTagTextStyle,
    required this.onCodeCopied,
    this.richTap,
  });

  final _widgets = <Widget>[];

  // int _level = 0;
  final List<_Element> _elementList = <_Element>[];

  final TextStyle defaultTextStyle;
  final TagTextStyle tagTextStyle;

  final BuildContext context;
  final LinkTap linkTap;
  final VoidCallback? richTap;
  final WidgetImage widgetImage;
  final double maxWidth;
  final Function onCodeCopied;

  @override
  bool visitElementBefore(md.Element element) {
    // _level++;
    // debugPrint('visitElementBefore $_level ${element.textContent}');

    String lastTag = '';
    if (_elementList.isNotEmpty) {
      lastTag = _elementList.last.tag;
    }

    var textStyle = tagTextStyle(
      lastTag,
      element.tag,
      _elementList.isNotEmpty ? _elementList.last.textStyle : defaultTextStyle,
    );

    _elementList.add(_Element(
      element.tag,
      textStyle,
      element.attributes,
    ));

    return true;
  }

  @override
  void visitText(md.Text text) {
    // debugPrint('text ${text.text}');

    if (_elementList.isEmpty) return;
    var last = _elementList.last;
    last.textSpans ??= [];

    // 替换特定字符串
    var content = text.text.replaceAll('&gt;', '>');
    content = content.replaceAll('&lt;', '<');

    if (last.tag == 'a') {
      last.textSpans?.add(TextSpan(
        text: content,
        style: last.textStyle,
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            debugPrint(last.attributes.toString());
            linkTap(last.attributes['href'] ?? '');
          },
      ));
      return;
    }

    last.textSpans?.add(TextSpan(
      text: content,
      style: last.textStyle,
    ));
  }

  final padding = const EdgeInsets.fromLTRB(0, 5, 0, 5);

  String getTextFromElement(dynamic element) {
    String result = '';
    if (element is List) {
      result = element.map(getTextFromElement).join('\n');
    } else if (element is md.Element) {
      result = result = element.children?.map(getTextFromElement).join('\n') ?? '';
    } else {
      result = element.text;
    }
    return result;
  }

  @override
  void visitElementAfter(md.Element element) {
    // debugPrint('visitElementAfter $_level ${element.tag}');
    // _level--;

    if (_elementList.isEmpty) return;
    var last = _elementList.last;
    _elementList.removeLast();
    dynamic tempWidget;
    if (kTextTags.contains(element.tag)) {
      if (_elementList.isNotEmpty && kTextParentTags.contains(_elementList.last.tag)) {
        // 内联标签处理
        _elementList.last.textSpans ??= [];
        _elementList.last.textSpans?.addAll(last.textSpans ?? []);
      } else {
        if (last.textSpans?.isNotEmpty ?? false) {
          tempWidget = Text.rich(
            TextSpan(
              children: last.textSpans,
              style: last.textStyle,
            ),
          );
        }
      }
    } else if ('li' == element.tag) {
      tempWidget = _resolveToLi(last);
    } else if ('pre' == element.tag) {
      var preCode = HtmlUnescape().convert(getTextFromElement(element.children));
      tempWidget = _resolveToPre(last, preCode);
    } else if ('blockquote' == element.tag) {
      tempWidget = _resolveToBlockquote(last);
    } else if ('img' == element.tag) {
      if (_elementList.isNotEmpty && (_elementList.last.textSpans?.isNotEmpty ?? false)) {
        _widgets.add(
          Padding(
            padding: padding,
            child: RichText(
              text: TextSpan(
                children: _elementList.last.textSpans,
                style: _elementList.last.textStyle,
              ),
            ),
          ),
        );
        _elementList.last.textSpans = null;
      }
      // debugPrint(element.attributes.toString());
      //_elementList.clear();
      _widgets.add(
        Padding(
          padding: padding,
          child: widgetImage(element.attributes['src'] ?? ''),
        ),
      );
    } else if (last.widgets?.isNotEmpty ?? false) {
      if (last.widgets?.length == 1) {
        tempWidget = last.widgets?[0];
      } else {
        tempWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: last.widgets ?? [],
        );
      }
    }

    if (tempWidget != null) {
      if (_elementList.isEmpty) {
        _widgets.add(
          Padding(
            padding: padding,
            child: tempWidget,
          ),
        );
      } else {
        _elementList.last.widgets ??= [];
        if (tempWidget is List<Widget>) {
          _elementList.last.widgets?.addAll(tempWidget);
        } else {
          _elementList.last.widgets?.add(tempWidget);
        }
      }
    }
  }

  List<Widget> build(List<md.Node> nodes) {
    _widgets.clear();

    for (md.Node node in nodes) {
      // _level = 0;
      _elementList.clear();

      node.accept(this);
    }
    return _widgets;
  }

  dynamic _resolveToLi(_Element last) {
    int liNum = 1;
    for (var element in _elementList) {
      if (element.tag == 'li') liNum++;
    }
    List<Widget> widgets = last.widgets ?? [];
    List<InlineSpan> spans = [];
    spans.addAll(last.textSpans ?? []);
    widgets.insert(
        0,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(
                8,
                ((last.textStyle.fontSize ?? 0) * 2 - 10) / 2.2,
                8,
                0,
              ),
              child: Icon(
                Icons.circle,
                size: 10,
                color: last.textStyle.color,
              ),
            ),
            SizedBox(
              width: maxWidth - (26 * liNum),
              child: RichText(
                strutStyle: StrutStyle(
                  height: 1,
                  fontSize: last.textStyle.fontSize,
                  forceStrutHeight: true,
                  leading: 1,
                ),
                // textAlign: TextAlign.center,
                text: TextSpan(
                  children: spans,
                  style: last.textStyle,
                ),
              ),
            )
          ],
        ));

    /// 如果是顶层，返回column
    if (liNum == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: widgets,
      );
    } else {
      return widgets;
    }
  }

  Widget _resolveToPre(_Element last, String preCode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 15, 5),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xff111111) : const Color(0xffeeeeee),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: last.widgets ?? [],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: IconButton(
                icon: const Icon(Icons.copy_outlined),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: preCode)).then((_) {
                    onCodeCopied();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resolveToBlockquote(_Element last) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 7,
            height: double.infinity,
            color: Colors.grey.shade400,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: last.widgets ?? [],
            ),
          ),
        ],
      ),
    );
  }
}

class _Element {
  _Element(
    this.tag,
    this.textStyle,
    this.attributes,
  );

  final String tag;
  List<Widget>? widgets;
  List<TextSpan>? textSpans;
  TextStyle textStyle;
  Map<String, String> attributes;
}

/// 链接点击
typedef LinkTap = void Function(String link);

typedef WidgetImage = Widget Function(String imageUrl);

typedef TagTextStyle = TextStyle Function(String lastTag, String tag, TextStyle textStyle);

TextStyle defaultTagTextStyle(String lastTag, String tag, TextStyle textStyle) {
  switch (tag) {
    case 'h1':
      textStyle = textStyle.copyWith(
        fontSize: (textStyle.fontSize ?? 0) + 9,
      );
      break;
    case 'h2':
      textStyle = textStyle.copyWith(
        fontSize: (textStyle.fontSize ?? 0) + 6,
      );
      break;
    case 'h3':
      textStyle = textStyle.copyWith(
        fontSize: (textStyle.fontSize ?? 0) + 4,
      );
      break;
    case 'h4':
      textStyle = textStyle.copyWith(
        fontSize: (textStyle.fontSize ?? 0) + 3,
      );
      break;
    case 'h5':
      textStyle = textStyle.copyWith(
        fontSize: (textStyle.fontSize ?? 0) + 2,
      );
      break;
    case 'h6':
      textStyle = textStyle.copyWith(
        fontSize: (textStyle.fontSize ?? 0) + 1,
      );
      break;
    case 'p':
      break;
    case 'li':
      break;
    case 'code':
      textStyle = textStyle.copyWith(
        fontSize: (textStyle.fontSize ?? 0) - 3,
        color: textStyle.color?.withAlpha(200),
      );
      if (lastTag == 'p') {
        textStyle = textStyle.copyWith(
          color: Colors.red.shade800,
        );
      }

      break;
    case 'strong':
      textStyle = textStyle.copyWith(
        fontWeight: FontWeight.bold,
      );
      break;
    case 'em':
      textStyle = textStyle.copyWith(
        fontStyle: FontStyle.italic,
      );
      break;
    case 'del':
      textStyle = textStyle.copyWith(
        decoration: TextDecoration.lineThrough,
      );
      break;
    case 'a':
      textStyle = textStyle.copyWith(
        color: Colors.blue,
      );
      break;
  }
  return textStyle;
}

const List<String> kTextTags = <String>[
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'p',
  'code',
  'strong',
  'em',
  'del',
  'a',
];

const List<String> kTextParentTags = <String>[
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'p',
  'li',
];
