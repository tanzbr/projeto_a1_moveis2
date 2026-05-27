import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

// Camada que conversa com o Supabase Storage para imagens das receitas.
// Arquivos vivem em receitas-imagens/<usuarioId>/<timestamp>.jpg
// (prefixo com o uid e' o que as policies de Storage usam para autorizacao).
class ImagemStorageService {
  static const String _bucket = 'receitas-imagens';

  // Envia bytes da imagem e devolve a URL publica para salvar em imagem_url.
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

  // Best-effort: se a URL nao for do bucket ou o dono nao for o usuario atual,
  // a remocao falha silenciosamente (no maximo deixa um arquivo orfao).
  Future<void> removerImagem(String url) async {
    final caminho = _caminhoDaUrlPublica(url);
    if (caminho == null) return;
    try {
      await SupabaseService.client.storage.from(_bucket).remove([caminho]);
    } catch (_) {
      // ignora: pode ser RLS negando ou rede instavel
    }
  }

  // Identifica se a string e' uma URL gerada por este service (e nao asset
  // local ou base64 antigo) — usado para decidir se vale tentar remover.
  bool ehUrlDoStorage(String url) => _caminhoDaUrlPublica(url) != null;

  String? _caminhoDaUrlPublica(String url) {
    const marcador = '/object/public/$_bucket/';
    final idx = url.indexOf(marcador);
    if (idx < 0) return null;
    return url.substring(idx + marcador.length);
  }
}
