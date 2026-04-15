import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/database_helper.dart';
import '../data/receitas_data.dart' as dados;
import '../models/receita.dart';
import '../utils/image_utils.dart';

class TelaCadastroReceita extends StatefulWidget {
  final Receita? receita;
  const TelaCadastroReceita({super.key, this.receita});

  @override
  State<TelaCadastroReceita> createState() => _TelaCadastroReceitaState();
}

class _TelaCadastroReceitaState extends State<TelaCadastroReceita> {
  final _nomeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tempoCtrl = TextEditingController();
  final _porcoesCtrl = TextEditingController();
  final _ingredientesCtrl = TextEditingController();
  final _preparoCtrl = TextEditingController();

  String _dificuldade = 'Fácil';
  String _categoria = 'Almoço';
  Uint8List? _imagemBytes;
  String? _imagemDataUri;
  bool _salvando = false;

  bool get _editando => widget.receita != null;

  @override
  void initState() {
    super.initState();
    final r = widget.receita;
    if (r != null) {
      _nomeCtrl.text = r.nome;
      _descCtrl.text = r.descricao;
      _tempoCtrl.text = r.tempoMinutos.toString();
      _porcoesCtrl.text = r.porcoes.toString();
      _ingredientesCtrl.text = r.ingredientes
          .map((i) => '${i.nome}|${i.quantidade}')
          .join('\n');
      _preparoCtrl.text = r.modoPreparo.join('\n');
      _dificuldade = r.dificuldade;
      _categoria = r.categoria;
      if (r.imagemUrl.isNotEmpty && isBase64Image(r.imagemUrl)) {
        _imagemDataUri = r.imagemUrl;
        _imagemBytes = base64ToBytes(r.imagemUrl);
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

  Future<void> _escolherImagem() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    setState(() {
      _imagemBytes = bytes;
      _imagemDataUri = bytesToDataUri(bytes);
    });
  }

  Future<void> _salvar() async {
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
        })
        .toList();

    final preparo = _preparoCtrl.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (ingredientes.isEmpty || preparo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe ingredientes e modo de preparo.')),
      );
      return;
    }

    setState(() => _salvando = true);
    final receita = Receita(
      id: _editando ? widget.receita!.id : 0,
      nome: nome,
      descricao: desc,
      imagemUrl: _imagemDataUri ?? '',
      tempoMinutos: tempo,
      porcoes: porcoes,
      dificuldade: _dificuldade,
      categoria: _categoria,
      ingredientes: ingredientes,
      modoPreparo: preparo,
      destaque: _editando ? widget.receita!.destaque : false,
    );
    final int idResultado;
    if (_editando) {
      await DatabaseHelper.instance.atualizarReceita(receita);
      idResultado = receita.id;
    } else {
      idResultado = await DatabaseHelper.instance.inserirReceita(receita);
    }
    dados.listaReceitas = await DatabaseHelper.instance.listarReceitas();
    if (!mounted) return;
    Navigator.pop(context, idResultado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar Receita' : 'Nova Receita'),
      ),
      body: AbsorbPointer(
        absorbing: _salvando,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _escolherImagem,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    image: _imagemBytes != null
                        ? DecorationImage(
                            image: MemoryImage(_imagemBytes!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imagemBytes == null
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_a_photo, size: 40),
                              SizedBox(height: 8),
                              Text('Toque para escolher imagem'),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(labelText: 'Nome da receita'),
              ),
              TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 2,
              ),
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
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _dificuldade,
                decoration: const InputDecoration(labelText: 'Dificuldade'),
                items: const ['Fácil', 'Médio', 'Difícil']
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) => setState(() => _dificuldade = v!),
              ),
              DropdownButtonFormField<String>(
                initialValue: _categoria,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: const ['Café da Manhã', 'Almoço', 'Jantar', 'Lanches']
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) => setState(() => _categoria = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ingredientesCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Ingredientes (um por linha: nome|quantidade)',
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
            ],
          ),
        ),
      ),
    );
  }
}
