import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';

class EduSparkApp extends StatelessWidget {
  const EduSparkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EduSpark',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
