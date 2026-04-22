import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart' show databaseFactory;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'screens/tela_navegacao.dart';
import 'theme/cores.dart';

Future<void> main() async {
  // necessário antes de chamar plugins async (sqflite) fora do runApp
  WidgetsFlutterBinding.ensureInitialized();

  // sqflite no navegador precisa do factory FFI sem web worker
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWebNoWebWorker;
  }

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReceitasRápidas',
      // tema único e centralizado — evita repetir estilo em cada tela
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorSchemeSeed: Cores.primaria,
        scaffoldBackgroundColor: Cores.fundoTela,
        appBarTheme: AppBarTheme(
          backgroundColor: Cores.primaria,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      // permite arrastar com o mouse (útil ao rodar no Chrome)
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      home: const TelaNavegacao(),
    ),
  );
}
