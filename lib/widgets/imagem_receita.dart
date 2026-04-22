import 'package:flutter/material.dart';
import '../models/receita.dart';
import '../theme/espacos.dart';

// widget único pra exibir imagem de qualquer origem (asset, base64, URL)
// — concentra a lógica num lugar só pra todas as telas reutilizarem
class ImagemReceita extends StatelessWidget {
  final String url;
  final double? largura;
  final double? altura;
  final double raio;
  final BoxFit fit;
  final IconData iconePlaceholder;
  final double tamanhoIcone;
  final String? heroTag; // se passado, embrulha em Hero p/ animação

  const ImagemReceita({
    super.key,
    required this.url,
    this.largura,
    this.altura,
    this.raio = Espacos.raioCard,
    this.fit = BoxFit.cover,
    this.iconePlaceholder = Icons.restaurant,
    this.tamanhoIcone = 30,
    this.heroTag,
  });

  // mostrado quando não tem imagem ou ela falha em carregar
  Widget _placeholder() {
    return Container(
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: Icon(iconePlaceholder, size: tamanhoIcone, color: Colors.grey),
    );
  }

  // decide o widget de imagem certo conforme o formato da string url
  Widget _conteudo() {
    if (url.isEmpty) return _placeholder();
    // imagem do bundle (receitas do seed)
    if (isAssetImage(url)) {
      return Image.asset(url, fit: fit);
    }
    // foto cadastrada pelo usuário, salva como base64 no banco
    if (isBase64Image(url)) {
      final bytes = base64ToBytes(url);
      if (bytes == null) return _placeholder();
      return Image.memory(bytes, fit: fit);
    }
    // fallback: trata como URL normal de internet
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ClipRRect aplica o cantinho arredondado em qualquer tipo de imagem
    Widget filho = ClipRRect(
      borderRadius: BorderRadius.circular(raio),
      child: SizedBox(
        width: largura,
        height: altura,
        child: _conteudo(),
      ),
    );

    // Hero conecta esta imagem com a da próxima tela usando o mesmo tag
    if (heroTag != null) {
      filho = Hero(tag: heroTag!, child: filho);
    }
    return filho;
  }
}
