import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/api_service.dart';

class RecipeGeneratorService {
  /// Gera receita a partir de ingredientes
  static Future<Map<String, dynamic>> generateRecipe({
    required List<String> ingredients,
    required String aiModel,
  }) async {
    try {
      final response = await apiService.generateRecipe(
        ingredients: ingredients,
        aiModel: aiModel,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Mostra diálogo de erro
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Mostra diálogo de carregamento
  static void showLoadingDialog(
    BuildContext context, {
    String message = "Gerando receita...",
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.terracotta),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
