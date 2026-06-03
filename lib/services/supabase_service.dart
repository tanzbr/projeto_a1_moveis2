import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static String get _url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get _anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static Future<void> inicializar() async {
    if (_url.isEmpty || _anonKey.isEmpty) {
      throw StateError(
        'SUPABASE_URL e SUPABASE_ANON_KEY nao foram definidos. '
        'Copie .env.example para .env e preencha com os valores do seu projeto.',
      );
    }
    await Supabase.initialize(url: _url, anonKey: _anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
