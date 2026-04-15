import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart' show databaseFactory;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'screens/tela_navegacao.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWebNoWebWorker;
  }

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReceitasRápidas',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorSchemeSeed: const Color.fromARGB(255, 155, 142, 193),
        scaffoldBackgroundColor: const Color.fromARGB(255, 250, 248, 252),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 155, 142, 193),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      home: const TelaNavegacao(),
    ),
  );
}
