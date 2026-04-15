import 'dart:convert';
import 'dart:typed_data';

/// Retorna true se a string parece ser uma data URI base64 de imagem.
bool isBase64Image(String s) => s.startsWith('data:image');

/// Converte data URI base64 em bytes. Retorna null se inválido.
Uint8List? base64ToBytes(String dataUri) {
  final idx = dataUri.indexOf('base64,');
  if (idx < 0) return null;
  try {
    return base64Decode(dataUri.substring(idx + 7));
  } catch (_) {
    return null;
  }
}

/// Monta data URI a partir de bytes e mime (default image/jpeg).
String bytesToDataUri(Uint8List bytes, {String mime = 'image/jpeg'}) {
  return 'data:$mime;base64,${base64Encode(bytes)}';
}
