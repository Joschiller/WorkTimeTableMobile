import 'package:flutter/material.dart';

class NotEnoughDataWarning extends StatelessWidget {
  const NotEnoughDataWarning({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Not enough data',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Data for at least half a year is needed to provide sufficient statistics.',
                ),
              ],
            ),
          ),
        ),
      );
}
