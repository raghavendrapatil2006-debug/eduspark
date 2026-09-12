#!/bin/bash
set -e

echo "=== Vercel Flutter Web Build Starting ==="

if [ ! -d "$HOME/flutter" ]; then
  echo "Cloning Flutter SDK (stable channel)..."
  git clone --depth 1 https://github.com/flutter/flutter.git -b stable $HOME/flutter
fi

export PATH="$PATH:$HOME/flutter/bin"

if [ ! -f "lib/firebase_options.dart" ]; then
  echo "Generating cloud CI/CD stub for firebase_options.dart..."
  cat << 'EOF' > lib/firebase_options.dart
// Generated stub for cloud CI/CD
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => web;
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSy_CLOUD_BUILD_PLACEHOLDER',
    appId: '1:838288892730:web:4c8fc549f7e2e5b153a603',
    messagingSenderId: '838288892730',
    projectId: 'eduspark-8bf63',
    authDomain: 'eduspark-8bf63.firebaseapp.com',
    storageBucket: 'eduspark-8bf63.firebasestorage.app',
  );
  static const FirebaseOptions android = web;
  static const FirebaseOptions ios = web;
  static const FirebaseOptions macos = web;
  static const FirebaseOptions windows = web;
}
EOF
fi

flutter config --no-analytics
echo "Compiling Flutter Web..."
flutter build web --release

echo "=== Vercel Flutter Web Build Succeeded ==="