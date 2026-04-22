import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/database_helper.dart';
import '../models/receita.dart';
import '../theme/cores.dart';
import '../theme/espacos.dart';
import '../widgets/imagem_receita.dart';

class TelaCadastroReceita extends StatefulWidget {
  // se vier preenchido, a tela funciona em modo edição (mesmo formulário)
  final Receita? receita;
  const TelaCadastroReceita({super.key, this.receita});

  @override
  State<TelaCadastroReceita> createState() => _TelaCadastroReceitaState();
}

class _TelaCadastroReceitaState extends State<TelaCadastroReceita> {
  // um controller por campo de texto (precisam de dispose no fim)
  final _nomeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tempoCtrl = TextEditingController();
  final _porcoesCtrl = TextEditingController();
  final _ingredientesCtrl = TextEditingController();
  final _preparoCtrl = TextEditingController();

  String _dificuldade = 'Fácil';
  String _categoria = 'Almoço';
  // imagem pode vir de 3 fontes: galeria (bytes/base64) ou asset do seed
  Uint8List? _imagemBytes;
  String? _imagemDataUri;
  String? _imagemAsset;
  bool _destaque = false;
  bool _salvando = false; // trava o botão p/ evitar duplo clique

  bool get _editando => widget.receita != null;

  // monta a string que vai p/ o widget de pré-visualização da imagem
  String _urlPreview() {
    if (_imagemBytes != null) return bytesToDataUri(_imagemBytes!);
    if (_imagemAsset != null) return _imagemAsset!;
    return '';
  }

  @override
  void initState() {
    super.initState();
    final r = widget.receita;
    // pré-preenche os campos quando estamos editando
    if (r != null) {
      _nomeCtrl.text = r.nome;
      _descCtrl.text = r.descricao;
      _tempoCtrl.text = r.tempoMinutos.toString();
      _porcoesCtrl.text = r.porcoes.toString();
      // ingredientes viram texto livre no formato "nome|quantidade" por linha
      _ingredientesCtrl.text =
          r.ingredientes.map((i) => '${i.nome}|${i.quantidade}').join('\n');
      _preparoCtrl.text = r.modoPreparo.join('\n');
      _dificuldade = r.dificuldade;
      _categoria = r.categoria;
      _destaque = r.destaque;
      if (r.imagemUrl.isNotEmpty) {
        // diferencia foto da galeria (base64) de imagem do seed (asset)
        if (isBase64Image(r.imagemUrl)) {
          _imagemDataUri = r.imagemUrl;
          _imagemBytes = base64ToBytes(r.imagemUrl);
        } else {
          _imagemAsset = r.imagemUrl;
        }
      }
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descCtrl.dispose();
    _tempoCtrl.dispose();
    _porcoesCtrl.dispose();
    _ingredientesCtrl.dispose();
    _preparoCtrl.dispose();
    super.dispose();
  }

  // Foto escolhida pela galeria vira string base64 e fica direto na coluna
  // `imagemUrl` do SQLite — evita ter que gerenciar arquivos no disco.
  Future<void> _escolherImagem() async {
    final picker = ImagePicker();
    // limita largura/qualidade p/ não estourar o tamanho da linha no banco
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (xfile == null) return; // usuário cancelou
    final bytes = await xfile.readAsBytes();
    setState(() {
      _imagemBytes = bytes;
      _imagemDataUri = bytesToDataUri(bytes);
      _imagemAsset = null; // troca de imagem invalida o asset anterior
    });
  }

  Future<void> _salvar() async {
    if (_salvando) return; // proteção contra duplo toque no botão
    final nome = _nomeCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    // tryParse devolve null se o usuário digitou algo inválido → vira 0
    final tempo = int.tryParse(_tempoCtrl.text.trim()) ?? 0;
    final porcoes = int.tryParse(_porcoesCtrl.text.trim()) ?? 0;

    // validação manual simples — projeto não usa pacote de form
    if (nome.isEmpty || tempo <= 0 || porcoes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha nome, tempo e porções.')),
      );
      return;
    }

    // converte texto livre em lista de Ingrediente (formato "nome|qtd")
    final ingredientes = _ingredientesCtrl.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .map((l) {
      final partes = l.split('|');
      return Ingrediente(
        nome: partes[0].trim(),
        quantidade: partes.length > 1 ? partes[1].trim() : '',
      );
    }).toList();

    // cada linha do textarea vira um passo do modo de preparo
    final preparo = _preparoCtrl.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (ingredientes.isEmpty || preparo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Informe ingredientes e modo de preparo.')),
      );
      return;
    }

    setState(() => _salvando = true);
    final receita = Receita(
      // id 0 só serve p/ satisfazer o construtor — é descartado no insert
      id: _editando ? widget.receita!.id : 0,
      nome: nome,
      descricao: desc,
      imagemUrl: _imagemDataUri ?? _imagemAsset ?? '',
      tempoMinutos: tempo,
      porcoes: porcoes,
      dificuldade: _dificuldade,
      categoria: _categoria,
      ingredientes: ingredientes,
      modoPreparo: preparo,
      destaque: _destaque,
    );

    // mesmo formulário cobre INSERT e UPDATE conforme o modo
    final int idResultado;
    if (_editando) {
      await DatabaseHelper.atualizarReceita(receita);
      idResultado = receita.id;
    } else {
      idResultado = await DatabaseHelper.inserirReceita(receita);
    }
    if (!mounted) return;
    // devolve o id p/ a tela anterior saber qual receita foi salva
    Navigator.pop(context, idResultado);
  }

  // confirma com diálogo antes de remover do banco (ação irreversível)
  Future<void> _excluir() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir receita'),
        content: Text('Deseja excluir "${widget.receita!.nome}"?\nEssa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    await DatabaseHelper.excluirReceita(widget.receita!.id);
    if (!mounted) return;
    // -1 sinaliza p/ a Detalhes que a receita não existe mais
    Navigator.pop(context, -1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar Receita' : 'Nova Receita'),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(Espacos.padPadrao),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // área inteira da imagem é clicável p/ abrir a galeria
              GestureDetector(
                onTap: _escolherImagem,
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: ImagemReceita(
                    url: _urlPreview(),
                    raio: Espacos.raioCard,
                    iconePlaceholder: Icons.add_a_photo,
                    tamanhoIcone: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nomeCtrl,
                decoration:
                    const InputDecoration(labelText: 'Nome da receita'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descCtrl,
                decoration:
                    const InputDecoration(labelText: 'Descrição'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tempoCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Tempo (min)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _porcoesCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Porções'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _dificuldade,
                decoration:
                    const InputDecoration(labelText: 'Dificuldade'),
                items: const ['Fácil', 'Médio', 'Difícil']
                    .map((v) =>
                        DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _dificuldade = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _categoria,
                decoration:
                    const InputDecoration(labelText: 'Categoria'),
                items: const [
                  'Café da Manhã',
                  'Almoço',
                  'Jantar',
                  'Lanches'
                ]
                    .map((v) =>
                        DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) => setState(() => _categoria = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ingredientesCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText:
                      'Ingredientes (um por linha: nome | quantidade)',
                  hintText: 'Farinha|200g\nOvo|2 unidades',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _preparoCtrl,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Modo de preparo (um passo por linha)',
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Cores.fundoSuave,
                  borderRadius: BorderRadius.circular(Espacos.raioCard),
                ),
                child: SwitchListTile(
                  title: const Text('Receita em destaque'),
                  subtitle: const Text(
                    'Aparece no carrossel da tela inicial',
                    style: TextStyle(fontSize: 12),
                  ),
                  secondary: Icon(
                    _destaque ? Icons.star : Icons.star_border,
                    color: Cores.primariaEscura,
                  ),
                  activeThumbColor: Cores.primariaEscura,
                  value: _destaque,
                  onChanged: (v) => setState(() => _destaque = v),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _salvando ? null : _salvar,
                child: _salvando
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Salvar receita'),
              ),
              if (_editando) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _excluir,
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  label: const Text(
                    'Excluir receita',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ],
          ),
        ),
    );
  }
}
