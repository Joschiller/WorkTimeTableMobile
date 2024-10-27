import 'package:flutter/material.dart';

class PageTemplate extends StatelessWidget {
  const PageTemplate({
    super.key,
    required this.title,
    required this.content,
    this.floatingButton,
  });

  final String title;
  final Widget content;
  final ({Icon icon, void Function() onPressed})? floatingButton;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(title),
        ),
        body: SafeArea(child: content),
        floatingActionButton: floatingButton != null
            ? FloatingActionButton(
                onPressed: floatingButton!.onPressed,
                child: floatingButton!.icon,
              )
            : null,
      );
}
