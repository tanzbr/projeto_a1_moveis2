import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Centraliza a inicializacao e o acesso ao cliente Supabase.
// As credenciais (URL + anon key) vem do arquivo .env carregado no main.
class SupabaseService {
  static String get _url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get _anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // chamado uma unica vez no main, depois do dotenv.load.
  // Lanca erro claro quando faltam as variaveis: o app depende do Supabase.
  static Future<void> inicializar() async {
    if (_url.isEmpty || _anonKey.isEmpty) {
      throw StateError(
        'SUPABASE_URL e SUPABASE_ANON_KEY nao foram definidos. '
        'Copie .env.example para .env e preencha com os valores do seu projeto.',
      );
    }
    await Supabase.initialize(url: _url, anonKey: _anonKey);
  }

  // atalho para o client Supabase usado pelos services
  static SupabaseClient get client => Supabase.instance.client;
}
