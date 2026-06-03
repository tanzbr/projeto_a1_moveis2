import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/supabase_service.dart';
import 'views/tela_navegacao.dart';
import 'theme/cores.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await SupabaseService.inicializar();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReceitasRápidas',
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
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      home: const TelaNavegacao(),
    ),
  );
}
