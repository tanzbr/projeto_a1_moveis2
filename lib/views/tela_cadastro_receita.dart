import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/auth_controller.dart';
import '../controllers/receita_controller.dart';
import '../models/receita.dart';
import '../services/imagem_storage_service.dart';
import '../theme/cores.dart';
import '../theme/espacos.dart';
import '../widgets/imagem_receita.dart';

class TelaCadastroReceita extends StatefulWidget {
  final Receita? receita;
  const TelaCadastroReceita({super.key, this.receita});

  @override
  State<TelaCadastroReceita> createState() => _TelaCadastroReceitaState();
}

class _TelaCadastroReceitaState extends State<TelaCadastroReceita> {
  final ReceitaController _controller = ReceitaController();
  final ImagemStorageService _storageService = ImagemStorageService();
  final _nomeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tempoCtrl = TextEditingController();
  final _porcoesCtrl = TextEditingController();
  final _preparoCtrl = TextEditingController();
  final List<_IngredienteCampo> _camposIngredientes = [];

  String _dificuldade = 'Fácil';
  String _categoria = 'Almoço';
  Uint8List? _imagemBytes;
  String? _imagemDataUri;
  String? _imagemAsset;
  String? _imagemUrlOriginal;
  bool _destaque = false;
  bool _publica = false;
  bool _salvando = false;

  bool get _editando => widget.receita != null;

  String _urlPreview() {
    if (_imagemBytes != null) return bytesToDataUri(_imagemBytes!);
    if (_imagemDataUri != null) return _imagemDataUri!;
    if (_imagemAsset != null) return _imagemAsset!;
    return '';
  }

  @override
  void initState() {
    super.initState();
    final r = widget.receita;
    if (r != null) {
      _nomeCtrl.text = r.nome;
      _descCtrl.text = r.descricao;
      _tempoCtrl.text = r.tempoMinutos.toString();
      _porcoesCtrl.text = r.porcoes.toString();
      _camposIngredientes.addAll(
        r.ingredientes.map(
          (i) => _IngredienteCampo(nome: i.nome, quantidade: i.quantidade),
        ),
      );
      _preparoCtrl.text = r.modoPreparo.join('\n');
      _dificuldade = r.dificuldade;
      _categoria = r.categoria;
      _destaque = r.destaque;
      _publica = r.publica;
      _imagemUrlOriginal = r.imagemUrl.isEmpty ? null : r.imagemUrl;
      if (r.imagemUrl.isNotEmpty) {
        if (isBase64Image(r.imagemUrl)) {
          _imagemDataUri = r.imagemUrl;
        } else {
          _imagemAsset = r.imagemUrl;
        }
      }
    }
    if (_camposIngredientes.isEmpty) {
      _camposIngredientes.add(_IngredienteCampo());
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descCtrl.dispose();
    _tempoCtrl.dispose();
    _porcoesCtrl.dispose();
    _preparoCtrl.dispose();
    for (final campo in _camposIngredientes) {
      campo.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  Future<void> _escolherImagem(ImageSource source) async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    setState(() {
      _imagemBytes = bytes;
      _imagemDataUri = null;
      _imagemAsset = null;
    });
  }

  Future<void> _mostrarOpcoesImagem() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar foto'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    await _escolherImagem(source);
  }

  void _adicionarIngrediente() {
    setState(() {
      _camposIngredientes.add(_IngredienteCampo());
    });
  }

  void _removerIngrediente(int i) {
    if (_camposIngredientes.length <= 1) return;
    setState(() {
      final campo = _camposIngredientes.removeAt(i);
      campo.dispose();
    });
  }

  Future<void> _salvar() async {
    if (_salvando) return;
    final nome = _nomeCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final tempo = int.tryParse(_tempoCtrl.text.trim()) ?? 0;
    final porcoes = int.tryParse(_porcoesCtrl.text.trim()) ?? 0;

    if (nome.isEmpty || tempo <= 0 || porcoes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha nome, tempo e porções.')),
      );
      return;
    }

    final ingredientes = _camposIngredientes
        .map((campo) {
          final nomeIngrediente = campo.nomeCtrl.text.trim();
          if (nomeIngrediente.isEmpty) return null;
          return Ingrediente(
            nome: nomeIngrediente,
            quantidade: campo.quantidadeCtrl.text.trim(),
          );
        })
        .whereType<Ingrediente>()
        .toList();

    final preparo = _preparoCtrl.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (ingredientes.isEmpty || preparo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe ingredientes e modo de preparo.'),
        ),
      );
      return;
    }

    setState(() => _salvando = true);
    final usuarioId = _editando
        ? widget.receita!.usuarioId
        : AuthController.instance.usuario?.id;

    String imagemUrl;
    final donoUploadId = AuthController.instance.usuario?.id;
    if (_imagemBytes != null && donoUploadId != null) {
      imagemUrl = await _storageService.enviarImagemReceita(
        donoUploadId,
        _imagemBytes!,
      );
      final antiga = _imagemUrlOriginal;
      if (_editando &&
          antiga != null &&
          antiga != imagemUrl &&
          _storageService.ehUrlDoStorage(antiga)) {
        await _storageService.removerImagem(antiga);
      }
    } else {
      imagemUrl = _imagemDataUri ?? _imagemAsset ?? '';
    }

    final receita = Receita(
      id: _editando ? widget.receita!.id : 0,
      nome: nome,
      descricao: desc,
      imagemUrl: imagemUrl,
      tempoMinutos: tempo,
      porcoes: porcoes,
      dificuldade: _dificuldade,
      categoria: _categoria,
      ingredientes: ingredientes,
      modoPreparo: preparo,
      destaque: _destaque,
      usuarioId: usuarioId,
      publica: _publica,
    );

    final int idResultado;
    if (_editando) {
      await _controller.atualizarReceita(receita);
      idResultado = receita.id;
    } else {
      idResultado = await _controller.adicionarReceita(receita);
    }
    if (!mounted) return;
    Navigator.pop(context, idResultado);
  }

  Future<void> _excluir() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir receita'),
        content: Text(
          'Deseja excluir "${widget.receita!.nome}"?\nEssa ação não pode ser desfeita.',
        ),
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
    await _controller.excluirReceita(widget.receita!.id);
    if (!mounted) return;
    Navigator.pop(context, -1);
  }

  Widget _tituloSecao(String texto) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Cores.textoEscuro,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
            _tituloSecao('Dados principais'),
            GestureDetector(
              onTap: _mostrarOpcoesImagem,
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
              decoration: const InputDecoration(labelText: 'Nome da receita'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            _tituloSecao('Detalhes'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tempoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Tempo (min)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _porcoesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Porções'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _dificuldade,
              decoration: const InputDecoration(labelText: 'Dificuldade'),
              items: const [
                'Fácil',
                'Médio',
                'Difícil',
              ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => setState(() => _dificuldade = v!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _categoria,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: const [
                'Café da Manhã',
                'Almoço',
                'Jantar',
                'Lanches',
              ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => setState(() => _categoria = v!),
            ),
            const SizedBox(height: 20),
            _tituloSecao('Ingredientes'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < _camposIngredientes.length; i++) ...[
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _camposIngredientes[i].nomeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Ingrediente',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _camposIngredientes[i].quantidadeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Quantidade',
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: _camposIngredientes.length == 1
                            ? null
                            : () => _removerIngrediente(i),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _adicionarIngrediente,
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar ingrediente'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _tituloSecao('Modo de preparo'),
            TextField(
              controller: _preparoCtrl,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Modo de preparo (um passo por linha)',
              ),
            ),
            const SizedBox(height: 20),
            _tituloSecao('Publicação'),
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
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Cores.fundoSuave,
                borderRadius: BorderRadius.circular(Espacos.raioCard),
              ),
              child: SwitchListTile(
                title: const Text('Tornar pública'),
                subtitle: const Text(
                  'Se desligado, só você verá esta receita',
                  style: TextStyle(fontSize: 12),
                ),
                secondary: Icon(
                  _publica ? Icons.public : Icons.lock_outline,
                  color: Cores.primariaEscura,
                ),
                activeThumbColor: Cores.primariaEscura,
                value: _publica,
                onChanged: (v) => setState(() => _publica = v),
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
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
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

class _IngredienteCampo {
  final TextEditingController nomeCtrl;
  final TextEditingController quantidadeCtrl;

  _IngredienteCampo({String nome = '', String quantidade = ''})
    : nomeCtrl = TextEditingController(text: nome),
      quantidadeCtrl = TextEditingController(text: quantidade);

  void dispose() {
    nomeCtrl.dispose();
    quantidadeCtrl.dispose();
  }
}
