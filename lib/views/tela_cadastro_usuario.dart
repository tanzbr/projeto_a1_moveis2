import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../theme/cores.dart';
import '../theme/espacos.dart';

class TelaCadastroUsuario extends StatefulWidget {
  const TelaCadastroUsuario({super.key});

  @override
  State<TelaCadastroUsuario> createState() => _TelaCadastroUsuarioState();
}

class _TelaCadastroUsuarioState extends State<TelaCadastroUsuario> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmaCtrl = TextEditingController();
  final _auth = AuthController.instance;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmaCtrl.dispose();
    super.dispose();
  }

  // validacao simples no estilo do projeto (sem pacote de form)
  String? _validar(String email, String senha, String confirma) {
    if (email.isEmpty || senha.isEmpty || confirma.isEmpty) {
      return 'Preencha todos os campos.';
    }
    if (!email.contains('@')) return 'Email invalido.';
    if (senha.length < 6) return 'A senha precisa ter pelo menos 6 caracteres.';
    if (senha != confirma) return 'As senhas nao conferem.';
    return null;
  }

  Future<void> _cadastrar() async {
    final email = _emailCtrl.text.trim();
    final senha = _senhaCtrl.text;
    final confirma = _confirmaCtrl.text;

    final problema = _validar(email, senha, confirma);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (problema != null) {
      messenger.showSnackBar(SnackBar(content: Text(problema)));
      return;
    }

    final ok = await _auth.cadastrar(email, senha);
    if (!mounted) return;
    if (ok) {
      navigator.pop(true);
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(_auth.erro ?? 'Falha no cadastro.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: ListenableBuilder(
        listenable: _auth,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(Espacos.padPadrao),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Icon(Icons.person_add_outlined,
                    size: 64, color: Cores.primariaEscura),
                const SizedBox(height: 16),
                const Text(
                  'Crie sua conta',
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
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmaCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar senha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_reset),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _auth.carregando ? null : _cadastrar,
                  icon: _auth.carregando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.person_add),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Cadastrar'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
