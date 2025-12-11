import 'dart:io';
import 'package:flutter/services.dart';
import 'utils/icon_generator.dart';

void main() async {
  print('Generating app icon...');
  await IconGenerator.generateAppIcon();
  print('Icon generation complete!');
  exit(0);
}