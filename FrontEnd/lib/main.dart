import 'dart:io';
import 'package:app/views/chat_screen.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  if (Platform.isWindows) {
    WindowManager.instance.setMinimumSize(const Size(600, 0));
    WindowManager.instance.setTitle('Questify');
    WindowManager.instance.setIcon(
        r'C:\Users\adwai\Documents\Program-Code\Questify\app\lib\assets\image.ico');
  }
  runApp(const MyApp());
}
