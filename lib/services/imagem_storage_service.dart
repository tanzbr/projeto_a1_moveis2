import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class ImagemStorageService {
  static const String _bucket = 'receitas-imagens';

  Future<String> enviarImagemReceita(
    String usuarioId,
    Uint8List bytes, {
    String extensao = 'jpg',
  }) async {
    final agora = DateTime.now().millisecondsSinceEpoch;
    final caminho = '$usuarioId/$agora.$extensao';

    await SupabaseService.client.storage.from(_bucket).uploadBinary(
          caminho,
          bytes,
          fileOptions: FileOptions(
            contentType: 'image/$extensao',
            upsert: false,
          ),
        );
    return obterUrlPublica(caminho);
  }

  String obterUrlPublica(String caminho) {
    return SupabaseService.client.storage.from(_bucket).getPublicUrl(caminho);
  }

  Future<void> removerImagem(String url) async {
    final caminho = _caminhoDaUrlPublica(url);
    if (caminho == null) return;
    try {
      await SupabaseService.client.storage.from(_bucket).remove([caminho]);
    } catch (_) {
      // Falha de remocao nao deve impedir a edicao da receita.
    }
  }

  bool ehUrlDoStorage(String url) => _caminhoDaUrlPublica(url) != null;

  String? _caminhoDaUrlPublica(String url) {
    const marcador = '/object/public/$_bucket/';
    final idx = url.indexOf(marcador);
    if (idx < 0) return null;
    return url.substring(idx + marcador.length);
  }
}
