import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final TextStyle? highlightStyle;
  final bool selectable;
  final Function()? onTap;

  const HighlightedText({
    required this.text,
    required this.query,
    required this.style,
    this.highlightStyle,
    this.selectable = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return selectable
          ? SelectableText(text, style: style, onTap: onTap)
          : Text(text, style: style);
    }

    final spans = _buildTextSpans(text, query, style, highlightStyle ??
        TextStyle(
          backgroundColor: Colors.yellow,
          fontWeight: FontWeight.bold,
          color: style.color,
        ));

    return selectable
        ? SelectableText.rich(TextSpan(children: spans), onTap: onTap)
        : RichText(text: TextSpan(children: spans));
  }

  List<TextSpan> _buildTextSpans(
      String text,
      String query,
      TextStyle style,
      TextStyle highlightStyle,
      ) {
    if (query.isEmpty) {
      return [TextSpan(text: text, style: style)];
    }

    final lowercaseText = text.toLowerCase();
    final lowercaseQuery = query.toLowerCase();

    final spans = <TextSpan>[];
    var currentIndex = 0;

    while (true) {
      final matchIndex = lowercaseText.indexOf(lowercaseQuery, currentIndex);
      if (matchIndex == -1) {
        if (currentIndex < text.length) {
          spans.add(TextSpan(
            text: text.substring(currentIndex),
            style: style,
          ));
        }
        break;
      }
      if (matchIndex > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, matchIndex),
          style: style,
        ));
      }
      spans.add(TextSpan(
        text: text.substring(matchIndex, matchIndex + query.length),
        style: highlightStyle,
      ));

      currentIndex = matchIndex + query.length;
    }

    return spans;
  }
}