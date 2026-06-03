import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario_app.dart';
import '../services/auth_service.dart';

const _erroCredenciaisInvalidas = 'Email ou senha incorretos.';
const _erroAutenticacaoGenerico =
    'Nao foi possivel autenticar. Tente novamente.';

String mensagemErroAutenticacao(Object erro) {
  if (erro is AuthException) {
    final codigo = erro.code?.toLowerCase();
    final mensagem = erro.message.toLowerCase();

    if (codigo == 'invalid_credentials' ||
        mensagem.contains('invalid login credentials')) {
      return _erroCredenciaisInvalidas;
    }

    return _erroAutenticacaoGenerico;
  }

  final texto = erro.toString().toLowerCase();
  if (texto.contains('invalid_credentials') ||
      texto.contains('invalid login credentials')) {
    return _erroCredenciaisInvalidas;
  }

  return _erroAutenticacaoGenerico;
}

class AuthController extends ChangeNotifier {
  static final AuthController instance = AuthController._();

  AuthController._() {
    _usuario = _service.usuarioAtual;
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

  String _mensagemErro(Object e) {
    return mensagemErroAutenticacao(e);
  }

  @override
  void dispose() {
    _inscricao?.cancel();
    super.dispose();
  }
}
