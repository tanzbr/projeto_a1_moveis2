import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritosScreen extends StatelessWidget {
  const FavoritosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 64, color: Color.fromARGB(255, 155, 142, 193)),
          const SizedBox(height: 16),
          Text(
            'Favoritos em breve...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color.fromARGB(255, 117, 117, 117),
            ),
          ),
        ],
      ),
    );
  }
}
