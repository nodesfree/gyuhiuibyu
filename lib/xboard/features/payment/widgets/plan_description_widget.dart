import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PlanDescriptionWidget extends StatelessWidget {
  final String content;
  const PlanDescriptionWidget({
    super.key,
    required this.content,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: MarkdownBody(
        data: content,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
            height: 1.5,
          ),
          textAlign: WrapAlignment.center,
        ),
      ),
    );
  }
}