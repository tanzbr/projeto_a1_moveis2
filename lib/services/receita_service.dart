import '../models/receita.dart';
import 'database_service.dart';

class ReceitaService {
  final DatabaseService _dbService = DatabaseService.instance;

  Future<List<Receita>> obterReceitas() async {
    return await _dbService.listarReceitas();
  }

  Future<Receita?> buscarReceita(int id) async {
    return await _dbService.buscarReceita(id);
  }

  Future<int> adicionarReceita(Receita receita) async {
    return await _dbService.inserirReceita(receita);
  }

  Future<int> atualizarReceita(Receita receita) async {
    return await _dbService.atualizarReceita(receita);
  }

  Future<void> salvarFavorito(int receitaId) async {
    await _dbService.salvarFavorito(receitaId);
  }

  Future<void> removerFavorito(int receitaId) async {
    await _dbService.removerFavorito(receitaId);
  }

  Future<void> excluirReceita(int id) async {
    await _dbService.excluirReceita(id);
  }
}
