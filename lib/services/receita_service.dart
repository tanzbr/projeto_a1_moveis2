import '../models/receita.dart';
import 'receita_remote_service.dart';

class ReceitaService {
  final ReceitaRemoteService _remoteService = ReceitaRemoteService();

  Future<List<Receita>> obterReceitas() async {
    return _remoteService.listarReceitas();
  }

  Future<List<Receita>> obterReceitasPublicas() async {
    return _remoteService.listarReceitasPublicas();
  }

  Future<List<Receita>> obterMinhasReceitas(String usuarioId) async {
    return _remoteService.listarMinhasReceitas(usuarioId);
  }

  Future<Receita?> buscarReceita(int id) async {
    return _remoteService.buscarReceita(id);
  }

  Future<int> adicionarReceita(Receita receita) async {
    return _remoteService.inserirReceita(receita);
  }

  Future<void> atualizarReceita(Receita receita) async {
    await _remoteService.atualizarReceita(receita);
  }

  Future<void> excluirReceita(int id) async {
    await _remoteService.excluirReceita(id);
  }
}
