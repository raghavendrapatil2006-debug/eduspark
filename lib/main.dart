import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'firebase_options.dart';
import 'app.dart';
import 'core/services/user_profile_service.dart';
import 'core/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ignore: deprecated_member_use
  await FirebaseAppCheck.instance.activate(
    // ignore: deprecated_member_use
    webProvider: WebDebugProvider(
      debugToken: '86bde81c-cbc7-479e-b913-2554beb1036f',
    ),
    // ignore: deprecated_member_use
    androidProvider: AndroidProvider.debug,
    // ignore: deprecated_member_use
    appleProvider: AppleProvider.debug,
  );

  await UserProfileService.instance.init();
  await AuthService.instance.init();

  runApp(const ProviderScope(child: EduSparkApp()));
}
