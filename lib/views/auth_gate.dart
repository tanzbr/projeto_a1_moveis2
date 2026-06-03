import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'tela_login.dart';

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
