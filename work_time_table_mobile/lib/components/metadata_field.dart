import 'package:flutter/material.dart';

class MetadataField extends StatelessWidget {
  const MetadataField({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              '$title:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      );
}
