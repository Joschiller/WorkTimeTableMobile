import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/metadata_field.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    super.key,
    required this.title,
    required this.onTap,
    this.metadata,
    required this.metadataTitleWeight,
    required this.metadataValueWeight,
    bool? showMetadataVertical,
  }) : showMetadataVertical = showMetadataVertical ?? false;

  final String title;
  final void Function() onTap;
  final Map<String, String>? metadata;
  final int metadataTitleWeight;
  final int metadataValueWeight;
  final bool showMetadataVertical;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    const Icon(Icons.edit),
                  ],
                ),
                const Divider(
                  height: 24,
                  thickness: 1,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: (metadata ?? {})
                          .entries
                          .map(
                            (e) => showMetadataVertical
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${e.key}:',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      Text(e.value),
                                    ],
                                  )
                                : MetadataField(
                                    title: e.key,
                                    value: e.value,
                                    metadataTitleWeight: metadataTitleWeight,
                                    metadataValueWeight: metadataValueWeight,
                                  ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
