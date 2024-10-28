import 'package:flutter/material.dart';

class SelectableCard extends StatelessWidget {
  const SelectableCard({
    super.key,
    required this.selected,
    required this.child,
  });

  final bool selected;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
        shape: selected
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(
                  color: Colors.grey,
                  width: 2,
                ),
              )
            : null,
        color: selected ? Colors.blueGrey.shade100 : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: child,
        ),
      );
}
