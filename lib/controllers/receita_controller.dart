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

  Future<void> salvarFavorito(int receitaId) async {
    await _receitaService.salvarFavorito(receitaId);
    await carregarReceitas();
  }

  Future<void> removerFavorito(int receitaId) async {
    await _receitaService.removerFavorito(receitaId);
    await carregarReceitas();
  }
}
