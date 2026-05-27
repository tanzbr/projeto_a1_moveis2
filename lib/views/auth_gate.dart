import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'tela_login.dart';

// Porta de entrada para acoes protegidas (criar/editar/favoritar receita).
// Se ja ha sessao, libera direto. Senao, abre a tela de login e devolve true
// somente quando o usuario se autenticar com sucesso.
Future<bool> exigirLogin(BuildContext context) async {
  if (AuthController.instance.estaLogado) return true;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Entre para continuar.')),
  );
  final ok = await Navigator.push<bool>(
    context,
    MaterialPageRoute(builder: (_) => const TelaLogin()),
  );
  return ok == true;
}
