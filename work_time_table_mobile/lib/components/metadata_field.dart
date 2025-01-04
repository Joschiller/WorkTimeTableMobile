import 'package:flutter/material.dart';

class MetadataField extends StatelessWidget {
  const MetadataField({
    super.key,
    required this.title,
    required this.value,
    required this.metadataTitleWeight,
    required this.metadataValueWeight,
  });

  final String title;
  final String value;

  final int metadataTitleWeight;
  final int metadataValueWeight;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: metadataTitleWeight,
            child: Text(
              '$title:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: metadataValueWeight,
            child: Text(value),
          ),
        ],
      );
}
