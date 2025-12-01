import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../global_state.dart';
import '../theme.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  // ===================================================================================================
  // LÓGICAS
  // ===================================================================================================

  // --- 1. FLUXO DE ASSINATURA (UPGRADE) - MANTIDO IGUAL ---
  void _handleUpgrade(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 100, child: Lottie.network('https://assets2.lottiefiles.com/packages/lf20_w51pcehl.json')),
              const SizedBox(height: 16),
              Text("Processando...", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: cs.onSurface)),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Fecha Loading
      planNotifier.upgrade(); // Atualiza Estado

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(24)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.network('https://assets10.lottiefiles.com/packages/lf20_qmfs6c3i.json', height: 120),
                  const SizedBox(height: 16),
                  Text("Bem-vindo à Elite!", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.terracotta)),
                  const SizedBox(height: 8),
                  Text("Todas as funções foram desbloqueadas.", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.grey)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Fecha dialog
                        Navigator.pop(context); // Fecha tela de planos
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.terracotta),
                      child: const Text("COMEÇAR A COZINHAR", style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }
    });
  }

  // --- 2. MODAL DE RETENÇÃO (SAD UI) - MANTIDO IGUAL, PEQUENA CORREÇÃO NO CONTEXTO DO BUILDER ---
  void _showCancellationConfirmation(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      // importante: não usar o nome 'context' no builder para não sobrescrever o contexto externo
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            SizedBox(
              height: 120,
              child: Lottie.network(
                'https://lottie.host/991a2066-8387-4530-9875-548c9c061828/7W6F1x1c0e.json',
                errorBuilder: (c, e, s) => const Icon(Icons.sentiment_dissatisfied, size: 80, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Tem certeza? 🥺",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22, color: cs.onSurface),
            ),
          ],
        ),
        content: Text(
          "Ao voltar para o plano Básico, você perderá acesso a receitas ilimitadas e cardápios semanais imediatamente.",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 14, color: cs.onSurface.withOpacity(0.8), height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsOverflowButtonSpacing: 12,
        actions: [
          TextButton(
            onPressed: () {
              // Fecha apenas o AlertDialog atual (usa dialogContext)
              Navigator.pop(dialogContext);
              // E inicia o processamento de cancelamento usando o contexto externo (garante que está montado)
              _processCancellation(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: Text("Sim, quero cancelar", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
            child: Text("NÃO! MANTER MEU PRO", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- 3. PROCESSAMENTO DO CANCELAMENTO (CORRIGIDO E BLINDADO) ---
  Future<void> _processCancellation(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;

    // 1. MOSTRA LOADING
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.redAccent),
              const SizedBox(height: 16),
              Text("Cancelando...", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: cs.onSurface)),
            ],
          ),
        ),
      ),
    );

    // 2. AGUARDA 2 SEGUNDOS (Simulação)
    await Future.delayed(const Duration(seconds: 2));

    // Verifica se o widget ainda existe para evitar crash
    if (!context.mounted) return;

    // 3. FECHA O LOADING
    Navigator.of(context).pop();

    // 4. EXECUTA A LÓGICA
    planNotifier.cancel(); // Downgrade para Free

    // 5. FECHA A TELA DE PLANOS (Volta para o Perfil)
    if (context.mounted) {
      Navigator.of(context).pop();

      // Feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Assinatura cancelada. Você voltou ao plano Gratuito.", style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: const Color(0xFF333333),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // ===================================================================================================
  // UI E VISUAL (MANTIDO PERFEITO)
  // ===================================================================================================

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ValueListenableBuilder<bool>(
      valueListenable: planNotifier,
      builder: (context, isPremium, _) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              isPremium ? "Gerenciar Assinatura" : "Upgrade",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: isPremium ? _buildActiveState(context, cs) : _buildSalesPage(context, cs),
        );
      },
    );
  }

  // --- TELA DE VENDA ---
  Widget _buildSalesPage(BuildContext context, ColorScheme cs) {
    return Stack(
      children: [
        Container(
          height: 400,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.coffee, AppColors.terracotta],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
          child: Column(
            children: [
              Text("Desbloqueie seu\nPotencial na Cozinha", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
              const SizedBox(height: 12),
              Text("Junte-se a mais de 10.000 chefs caseiros que economizam tempo e dinheiro.", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.9))),
              const SizedBox(height: 40),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 15))], border: Border.all(color: AppColors.terracotta, width: 2)),
                    child: Column(children: [
                      const SizedBox(height: 16),
                      Text("BiteWise PRO", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.terracotta)),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text("R\$", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)), Text("19,90", style: GoogleFonts.poppins(fontSize: 42, fontWeight: FontWeight.w900, color: cs.onSurface)), Text("/mês", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500))]),
                      const SizedBox(height: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(20)), child: Text("Menos que um delivery 🍕", style: GoogleFonts.poppins(fontSize: 12, color: Colors.green[700], fontWeight: FontWeight.bold))),
                      const SizedBox(height: 32),
                      _buildFeatureItem("Receitas Ilimitadas", true, cs),
                      _buildFeatureItem("Ingredientes Ilimitados", true, cs),
                      _buildFeatureItem("Zero Anúncios", true, cs),
                      _buildFeatureItem("Cardápios Semanais", true, cs),
                      const SizedBox(height: 32),
                      SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: () => _handleUpgrade(context), style: ElevatedButton.styleFrom(backgroundColor: AppColors.terracotta, foregroundColor: Colors.white, elevation: 8, shadowColor: AppColors.terracotta.withOpacity(0.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text("TESTAR AGORA", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800)))),
                      const SizedBox(height: 12),
                      Text("Cancele a qualquer momento.", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey))
                    ]),
                  ),
                  Positioned(top: -16, left: 0, right: 0, child: Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star, color: Colors.white, size: 16), const SizedBox(width: 6), Text("RECOMENDADO", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))])))),
                ],
              ),
              const SizedBox(height: 40),
              Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: cs.surface.withOpacity(0.5), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.withOpacity(0.2))), child: Column(children: [Text("Plano Básico", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)), const SizedBox(height: 16), _buildFeatureItem("Apenas 3 Ingredientes", false, cs), _buildFeatureItem("10 Receitas/mês", false, cs), _buildFeatureItem("Com Anúncios", false, cs), const SizedBox(height: 16), Text("Você já está neste plano.", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey))])),
            ],
          ),
        ),
      ],
    );
  }

  // --- TELA ATIVA (GERENCIAMENTO) ---
  Widget _buildActiveState(BuildContext context, ColorScheme cs) {
    const goldColor = Color(0xFFFFD700);
    const darkCardBg = Color(0xFF1E1E1E);
    const dangerColor = Color(0xFFE53935);

    return Stack(
      children: [
        // Fundo Dark Premium
        Container(color: const Color(0xFF121212)),
        Positioned(top: -100, right: -100, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.terracotta.withOpacity(0.08), boxShadow: [BoxShadow(color: AppColors.terracotta.withOpacity(0.1), blurRadius: 100, spreadRadius: 50)]))),

        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Status
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: darkCardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: goldColor.withOpacity(0.3)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      height: 60, width: 60,
                      child: Lottie.network('https://lottie.host/26462616-3ad5-4184-8c0a-c72f784ead4d/jYbnEU6nDD.json', fit: BoxFit.contain),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Status da Assinatura", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400])),
                          const SizedBox(height: 4),
                          Text("Membro Elite Ativo", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: goldColor)),
                          const SizedBox(height: 4),
                          Text("Renova em: 24/12/2025", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text("Seus Superpoderes Ativos", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 16),

              // 2. Lista Benefícios
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: darkCardBg.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _buildActiveFeatureItem("Criação Ilimitada de Receitas", Icons.all_inclusive, goldColor),
                    _buildActiveFeatureItem("Acesso a IAs Avançadas (Gemini, OpenAI)", Icons.psychology, goldColor),
                    _buildActiveFeatureItem("Planejador de Cardápio Semanal", Icons.calendar_month, goldColor),
                    _buildActiveFeatureItem("Navegação 100% sem anúncios", Icons.block, goldColor),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text("Zona de Perigo", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: dangerColor)),
              ),
              const SizedBox(height: 16),

              // 3. Zona Cancelamento
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: dangerColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: dangerColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: dangerColor, size: 28),
                        const SizedBox(width: 12),
                        Expanded(child: Text("Voltar ao Plano Básico", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: dangerColor))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Ao cancelar, você perderá acesso imediato a todos os benefícios listados acima e voltará a ter limites de uso.",
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400], height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _showCancellationConfirmation(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: dangerColor),
                          foregroundColor: dangerColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("CONFIRMAR CANCELAMENTO"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text, bool isIncluded, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(isIncluded ? Icons.check_circle : Icons.cancel, color: isIncluded ? AppColors.terracotta : Colors.grey[300], size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 14, color: isIncluded ? cs.onSurface : Colors.grey, fontWeight: isIncluded ? FontWeight.w500 : FontWeight.normal, decoration: isIncluded ? null : TextDecoration.lineThrough))),
        ],
      ),
    );
  }

  Widget _buildActiveFeatureItem(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
