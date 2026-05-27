import '../models/receita.dart';
import 'receita_remote_service.dart';

// Service de receitas consumido pelo controller.
// Toda persistencia roda no Supabase (ver ReceitaRemoteService).
class ReceitaService {
  final ReceitaRemoteService _remoteService = ReceitaRemoteService();

  // Tudo que a RLS deixa enxergar (publicas + minhas).
  Future<List<Receita>> obterReceitas() async {
    return _remoteService.listarReceitas();
  }

  // Receitas marcadas como publicas (Home/Explorar).
  Future<List<Receita>> obterReceitasPublicas() async {
    return _remoteService.listarReceitasPublicas();
  }

  // Receitas que o usuario logado criou.
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
