import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/core/network/dio_client.dart';
import 'package:gestparc/core/routes/app_router.dart';
import 'package:gestparc/core/theme/app_theme.dart';
import 'package:gestparc/core/theme/theme_provider.dart';
import 'package:gestparc/features/auth/providers/auth_provider.dart';
import 'package:gestparc/features/auth/services/auth_service.dart';
import 'package:gestparc/features/eleve/providers/eleve_provider.dart';
import 'package:gestparc/features/eleve/services/eleve_service.dart';
import 'package:gestparc/features/parent/providers/parent_provider.dart';
import 'package:gestparc/features/parent/services/parent_service.dart';

import 'package:gestparc/features/notifications/providers/notification_provider.dart';
import 'package:gestparc/features/notifications/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Core Services
  final dioClient = DioClient();
  final authService = AuthService(dioClient);
  final authProvider = AuthProvider(authService);
  // Initialize Feature Services
  final eleveService = EleveService(dioClient);
  final parentService = ParentService(dioClient);

  final notificationService = NotificationService(dioClient);

  final appRouter = AppRouter(authProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<DioClient>.value(value: dioClient),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => EleveProvider(eleveService)),
        ChangeNotifierProvider(create: (_) => ParentProvider(parentService)),

        ChangeNotifierProvider(create: (_) => NotificationProvider(notificationService)),
      ],
      child: MyApp(appRouter: appRouter),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;

  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return MaterialApp.router(
      title: 'GEST\'PARC',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: appRouter.router,
    );
  }
}
