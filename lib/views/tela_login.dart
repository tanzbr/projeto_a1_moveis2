import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../theme/cores.dart';
import '../theme/espacos.dart';
import 'tela_cadastro_usuario.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _auth = AuthController.instance;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final email = _emailCtrl.text.trim();
    final senha = _senhaCtrl.text;
    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha email e senha.')),
      );
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await _auth.entrar(email, senha);
    if (!mounted) return;
    if (ok) {
      navigator.pop(true);
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(_auth.erro ?? 'Falha no login.')),
      );
    }
  }

  Future<void> _irParaCadastro() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TelaCadastroUsuario()),
    );
    if (ok == true && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: ListenableBuilder(
        listenable: _auth,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(Espacos.padPadrao),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Icon(Icons.lock_outline,
                    size: 64, color: Cores.primariaEscura),
                const SizedBox(height: 16),
                const Text(
                  'Acesse sua conta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Cores.textoEscuro,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _senhaCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _auth.carregando ? null : _entrar,
                  icon: _auth.carregando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.login),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Entrar'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _auth.carregando ? null : _irParaCadastro,
                  child: const Text('Nao tem conta? Cadastre-se'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
