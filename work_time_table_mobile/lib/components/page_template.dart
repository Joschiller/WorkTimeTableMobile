import 'package:flutter/material.dart';

class PageTemplate extends StatelessWidget {
  const PageTemplate({
    super.key,
    required this.title,
    required this.content,
    this.menuButtons,
    this.floatingButton,
  });

  final String title;
  final Widget content;
  final List<({Icon icon, void Function() onPressed})>? menuButtons;
  final ({Icon icon, void Function() onPressed})? floatingButton;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(title),
          actions: menuButtons
              ?.map(
                (e) => IconButton(
                  onPressed: e.onPressed,
                  icon: e.icon,
                ),
              )
              .toList(),
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
