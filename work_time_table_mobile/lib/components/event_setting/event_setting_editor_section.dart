import 'package:flutter/material.dart';

class EventSettingEditorSection extends StatelessWidget {
  const EventSettingEditorSection({
    super.key,
    required this.header,
    required this.child,
  });

  final String header;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.grey.shade300,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                header,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              child,
            ],
          ),
        ),
      );
}
