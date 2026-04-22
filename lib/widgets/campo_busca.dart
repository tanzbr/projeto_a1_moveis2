import 'package:flutter/material.dart';
import '../theme/cores.dart';
import '../theme/espacos.dart';

// TextField padronizado para busca — evita repetir o mesmo estilo nas telas
class CampoBusca extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  const CampoBusca({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: Cores.primaria),
        filled: true,
        fillColor: Cores.fundoSuave,
        // borderSide.none deixa só o fundo colorido, sem linha em volta
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Espacos.raioCard),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
    );
  }
}
