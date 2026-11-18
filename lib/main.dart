import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/catatan_repository.dart';
import 'data/database_helper.dart';
import 'data/report_local_source.dart';
import 'data/report_repository.dart';
import 'data/profil_repository.dart';
import 'routes.dart';
import 'services/device_services.dart';
import 'services/report_api_service.dart';
import 'viewmodels/catatan_view_model.dart';
import 'viewmodels/report_view_model.dart';
import 'viewmodels/profil_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = DatabaseHelper.instance;
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => DeviceServices()),
        ChangeNotifierProvider(
          create: (_) => CatatanViewModel(CatatanRepository(db))..muatCatatan(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfilViewModel(ProfilRepository(db))..muat(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReportViewModel(
            ReportRepository(ReportLocalSource(db), ReportApiService(apiBaseUrl)),
          )..initialize(),
        ),
      ],
      child: const StudyLogApp(),
    ),
  );
}

class StudyLogApp extends StatelessWidget {
  const StudyLogApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'StudyLog',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF4158D0),
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        initialRoute: AppRoutes.beranda,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      );
}
