import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/supabase_service.dart';
import 'views/tela_navegacao.dart';
import 'theme/cores.dart';

Future<void> main() async {
  // necessário antes de chamar plugins async (Supabase) fora do runApp
  WidgetsFlutterBinding.ensureInitialized();

  // carrega .env (declarado como asset no pubspec.yaml) antes do Supabase
  await dotenv.load(fileName: '.env');
  await SupabaseService.inicializar();

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
