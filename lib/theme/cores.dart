import 'package:flutter/material.dart';

// paleta única do app — qualquer mudança de cor reflete em todas as telas
class Cores {
  Cores._(); // construtor privado: classe usada só p/ acessar as constantes

  static const primaria = Color.fromARGB(255, 245, 124, 0);
  static const primariaEscura = Color.fromARGB(255, 191, 54, 12);
  static const primariaClara = Color.fromARGB(255, 255, 204, 128);
  static const fundoSuave = Color.fromARGB(255, 255, 243, 224);
  static const fundoTela = Color.fromARGB(255, 255, 251, 245);
  static const textoEscuro = Color.fromARGB(255, 62, 39, 35);
  static const textoCinza = Color.fromARGB(255, 141, 110, 99);
}
