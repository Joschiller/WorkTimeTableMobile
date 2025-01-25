import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/main.dart';

void displaySnackbar(String text) =>
    MyApp.scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(text)),
    );
