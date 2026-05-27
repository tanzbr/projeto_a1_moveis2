import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../theme/cores.dart';
import '../theme/espacos.dart';
import 'tela_login.dart';

class TelaPerfil extends StatelessWidget {
  const TelaPerfil({super.key});

  Future<void> _entrar(BuildContext context) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TelaLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListenableBuilder(
        listenable: auth,
        builder: (context, _) {
          final usuario = auth.usuario;
          if (usuario == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(Espacos.padPadrao),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_outline,
                        size: 64, color: Cores.primariaEscura),
                    const SizedBox(height: 12),
                    const Text(
                      'Voce ainda nao esta logado.',
                      style: TextStyle(fontSize: 16, color: Cores.textoEscuro),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text('Entrar'),
                      onPressed: () => _entrar(context),
                    ),
                  ],
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(Espacos.padPadrao),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Cores.primariaClara,
                  child: Icon(Icons.person, size: 40, color: Cores.primariaEscura),
                ),
                const SizedBox(height: 16),
                Text(
                  usuario.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Cores.textoEscuro,
                  ),
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Sair'),
                  onPressed: auth.sair,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
