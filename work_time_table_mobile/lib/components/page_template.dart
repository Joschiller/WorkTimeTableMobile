import 'package:flutter/material.dart';

class PageTemplate extends StatelessWidget {
  const PageTemplate({super.key, required this.title, required this.content});

  final String title;
  final Widget content;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(title),
        ),
        body: SafeArea(child: content),
      );
}
