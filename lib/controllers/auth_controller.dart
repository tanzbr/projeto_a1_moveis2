import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/usuario_app.dart';
import '../services/auth_service.dart';

// Controller global de autenticacao. Singleton: a sessao precisa ser
// compartilhada entre todas as telas (FAB nova receita, favoritar, perfil...).
class AuthController extends ChangeNotifier {
  static final AuthController instance = AuthController._();

  AuthController._() {
    _usuario = _service.usuarioAtual;
    // mantem o controller sincronizado com login/logout vindos do Supabase
    _inscricao = _service.mudancasDeSessao.listen((u) {
      _usuario = u;
      notifyListeners();
    });
  }

  final AuthService _service = AuthService();
  StreamSubscription<UsuarioApp?>? _inscricao;

  UsuarioApp? _usuario;
  UsuarioApp? get usuario => _usuario;
  bool get estaLogado => _usuario != null;

  bool _carregando = false;
  bool get carregando => _carregando;

  String? _erro;
  String? get erro => _erro;

  Future<bool> entrar(String email, String senha) async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      _usuario = await _service.entrarComEmailSenha(email.trim(), senha);
      return true;
    } catch (e) {
      _erro = _mensagemErro(e);
      return false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<bool> cadastrar(String email, String senha) async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      _usuario = await _service.cadastrarComEmailSenha(email.trim(), senha);
      return true;
    } catch (e) {
      _erro = _mensagemErro(e);
      return false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> sair() async {
    await _service.sair();
    _usuario = null;
    notifyListeners();
  }

  // mensagens cruas do Supabase nao sao amigaveis; mostramos a string direta
  // mas damos um fallback generico quando nao da pra extrair nada util
  String _mensagemErro(Object e) {
    final texto = e.toString();
    if (texto.isEmpty) return 'Falha na autenticacao.';
    return texto.replaceFirst('Exception: ', '');
  }

  @override
  void dispose() {
    _inscricao?.cancel();
    super.dispose();
  }
}
