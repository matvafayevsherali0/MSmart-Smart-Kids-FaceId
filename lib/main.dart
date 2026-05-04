import 'package:flutter/material.dart';

import 'app.dart';
import 'core/storage/storage.dart';
import 'core/utils/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageRepository.getInstance();
  await setUpLocator();

  runApp(const MSmartKidsFaceId());
}
