import 'package:flutter/material.dart';
import '../models/receita.dart';
import '../services/receita_service.dart';

class ReceitaController extends ChangeNotifier {
  final ReceitaService _receitaService = ReceitaService();

  List<Receita> _receitas = [];
  List<Receita> get receitas => _receitas;

  bool _carregando = false;
  bool get carregando => _carregando;

  bool _foiDescartado = false;

  @override
  void dispose() {
    _foiDescartado = true;
    super.dispose();
  }

  void _notificar() {
    if (!_foiDescartado) {
      notifyListeners();
    }
  }

  Future<void> carregarReceitas() async {
    _carregando = true;
    _notificar();

    final receitas = await _receitaService.obterReceitas();
    if (_foiDescartado) return;

    _receitas = receitas;
    _carregando = false;
    _notificar();
  }

  // Home/Explorar mostram so' publicas — privadas sao' isoladas em "Minhas".
  Future<void> carregarReceitasPublicas() async {
    _carregando = true;
    _notificar();

    final receitas = await _receitaService.obterReceitasPublicas();
    if (_foiDescartado) return;

    _receitas = receitas;
    _carregando = false;
    _notificar();
  }

  // Tela "Minhas Receitas": so' as criadas pelo usuario logado.
  Future<void> carregarMinhasReceitas(String usuarioId) async {
    _carregando = true;
    _notificar();

    final receitas = await _receitaService.obterMinhasReceitas(usuarioId);
    if (_foiDescartado) return;

    _receitas = receitas;
    _carregando = false;
    _notificar();
  }

  Future<Receita?> buscarReceita(int id) async {
    return await _receitaService.buscarReceita(id);
  }

  Future<int> adicionarReceita(Receita receita) async {
    final id = await _receitaService.adicionarReceita(receita);
    await carregarReceitas();
    return id;
  }

  Future<void> atualizarReceita(Receita receita) async {
    await _receitaService.atualizarReceita(receita);
    await carregarReceitas();
  }

  Future<void> excluirReceita(int id) async {
    await _receitaService.excluirReceita(id);
    await carregarReceitas();
  }
}
