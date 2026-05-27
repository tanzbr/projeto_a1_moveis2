import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario_app.dart';
import 'supabase_service.dart';

// Unica camada que conversa com Supabase Auth.
// O controller consome este service e expoe o estado para as views.
class AuthService {
  SupabaseClient get _client => SupabaseService.client;

  UsuarioApp? get usuarioAtual {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return UsuarioApp(id: user.id, email: user.email ?? '');
  }

  // emite a cada mudanca de sessao (login, logout, refresh)
  Stream<UsuarioApp?> get mudancasDeSessao {
    return _client.auth.onAuthStateChange.map((evento) {
      final user = evento.session?.user;
      if (user == null) return null;
      return UsuarioApp(id: user.id, email: user.email ?? '');
    });
  }

  Future<UsuarioApp> entrarComEmailSenha(String email, String senha) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: senha,
    );
    final user = res.user;
    if (user == null) {
      throw const AuthException('Nao foi possivel entrar.');
    }
    return UsuarioApp(id: user.id, email: user.email ?? '');
  }

  Future<UsuarioApp> cadastrarComEmailSenha(String email, String senha) async {
    final res = await _client.auth.signUp(email: email, password: senha);
    final user = res.user;
    if (user == null) {
      throw const AuthException('Nao foi possivel cadastrar.');
    }
    return UsuarioApp(id: user.id, email: user.email ?? '');
  }

  Future<void> sair() async {
    await _client.auth.signOut();
  }
}
