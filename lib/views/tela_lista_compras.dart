import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/lista_compras_controller.dart';
import '../models/item_lista_compras.dart';
import '../models/receita.dart';
import '../theme/cores.dart';
import '../theme/espacos.dart';
import 'auth_gate.dart';
import 'tela_selecionar_receitas.dart';

class TelaListaCompras extends StatefulWidget {
  const TelaListaCompras({super.key});

  @override
  State<TelaListaCompras> createState() => _TelaListaComprasState();
}

class _TelaListaComprasState extends State<TelaListaCompras> {
  final ListaComprasController _controller = ListaComprasController.instance;

  Future<void> _adicionarReceitas() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final autenticado = await exigirLogin(context);
    if (!mounted || !autenticado) return;
    final escolhidas = await navigator.push<List<Receita>>(
      MaterialPageRoute(builder: (_) => const TelaSelecionarReceitas()),
    );
    if (!mounted || escolhidas == null || escolhidas.isEmpty) return;
    await _controller.adicionarReceitas(escolhidas);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          escolhidas.length == 1
              ? 'Ingredientes adicionados!'
              : 'Ingredientes de ${escolhidas.length} receitas adicionados!',
        ),
      ),
    );
  }

  Future<void> _confirmarLimpar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar lista'),
        content: const Text('Remover todos os itens da lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _controller.limpar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
        actions: [
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              final temItens = _controller.itens.isNotEmpty;
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Limpar lista',
                onPressed: temItens ? _confirmarLimpar : null,
              );
            },
          ),
        ],
      ),
      // heroTag unico para nao colidir com outros FABs do app
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_lista_compras_add',
        onPressed: _adicionarReceitas,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Adicionar receitas'),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([_controller, AuthController.instance]),
        builder: (context, _) {
          if (!AuthController.instance.estaLogado) return _semLogin();
          if (_controller.carregando && _controller.itens.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final itens = _controller.itens;
          if (itens.isEmpty) return _vazio();

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(Espacos.padPadrao),
                  itemCount: itens.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) => _cardItem(itens[index]),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                color: Cores.fundoSuave,
                child: Text(
                  '${_controller.totalPendentes} pendente(s) de ${_controller.totalItens}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Cores.primariaEscura,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _cardItem(ItemListaCompras item) {
    return Dismissible(
      key: ValueKey('item-${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(Espacos.raioCard),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _controller.removerItem(item.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Espacos.raioCard),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CheckboxListTile(
          value: item.comprado,
          onChanged: (_) => _controller.alternarComprado(item),
          activeColor: Cores.primariaEscura,
          title: Text(
            item.nome,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Cores.textoEscuro,
              // riscado quando ja foi comprado, padrao de checklist
              decoration: item.comprado ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: item.quantidades.isEmpty
              ? null
              : Text(
                  item.quantidadeFormatada,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Cores.textoCinza,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _semLogin() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Espacos.padPadrao),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline,
                size: 64, color: Cores.primariaEscura),
            const SizedBox(height: 12),
            const Text(
              'Entre para usar sua lista de compras.',
              style: TextStyle(fontSize: 16, color: Cores.textoEscuro),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Entrar'),
              onPressed: () => exigirLogin(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vazio() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Cores.primaria),
          SizedBox(height: 16),
          Text(
            'Sua lista esta vazia.',
            style: TextStyle(fontSize: 16, color: Cores.textoCinza),
          ),
          SizedBox(height: 8),
          Text(
            'Use o botao "+" para adicionar ingredientes de receitas.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
