import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../theme.dart';
import '../../global_state.dart';
import '../../services/api_service.dart';
import '../recipe_result_screen.dart';
import '../plans_screen.dart';

class CreateTab extends StatefulWidget {
  const CreateTab({super.key});

  @override
  State<CreateTab> createState() => _CreateTabState();
}

class _CreateTabState extends State<CreateTab> {
  final TextEditingController _ingredientController = TextEditingController();
  final List<String> _ingredients = [];

  // --- 1. BANCO DE DADOS ROBUSTO (Muitas opções para nunca ficar vazio) ---
  final List<Map<String, dynamic>> _allIngredientsDb = [
    // Básicos
    {"name": "Arroz", "cat": "Básicos", "tags": ["carb", "vegan", "gf"]},
    {"name": "Feijão", "cat": "Básicos", "tags": ["carb", "vegan", "gf", "protein"]},
    {"name": "Ovo", "cat": "Básicos", "tags": ["protein", "animal", "gf", "keto", "low_carb"]},
    {"name": "Macarrão", "cat": "Básicos", "tags": ["carb", "vegan"]},
    {"name": "Pão", "cat": "Básicos", "tags": ["carb", "vegan"]},
    {"name": "Tapioca", "cat": "Básicos", "tags": ["carb", "vegan", "gf", "paleo"]},
    {"name": "Cuscuz", "cat": "Básicos", "tags": ["carb", "vegan", "gf"]},
    {"name": "Aveia", "cat": "Básicos", "tags": ["carb", "vegan"]},
    {"name": "Queijo", "cat": "Básicos", "tags": ["protein", "fat", "animal", "gf", "keto", "low_carb"]},
    {"name": "Azeite", "cat": "Básicos", "tags": ["fat", "vegan", "gf", "keto", "low_carb", "paleo"]},
    {"name": "Manteiga", "cat": "Básicos", "tags": ["fat", "animal", "gf", "keto", "low_carb", "paleo"]},

    // Proteínas
    {"name": "Frango", "cat": "Proteínas", "tags": ["protein", "animal", "meat", "gf", "keto", "low_carb", "paleo"]},
    {"name": "Carne Moída", "cat": "Proteínas", "tags": ["protein", "animal", "meat", "gf", "keto", "low_carb", "paleo"]},
    {"name": "Bife", "cat": "Proteínas", "tags": ["protein", "animal", "meat", "gf", "keto", "low_carb", "paleo"]},
    {"name": "Peixe", "cat": "Proteínas", "tags": ["protein", "animal", "meat", "gf", "keto", "low_carb", "paleo"]},
    {"name": "Bacon", "cat": "Proteínas", "tags": ["protein", "fat", "animal", "meat", "gf", "keto", "low_carb", "paleo"]},
    {"name": "Atum", "cat": "Proteínas", "tags": ["protein", "animal", "meat", "gf", "keto", "low_carb", "paleo"]},
    {"name": "Tofu", "cat": "Proteínas", "tags": ["protein", "vegan", "gf", "keto", "low_carb"]},
    {"name": "Grão de Bico", "cat": "Proteínas", "tags": ["protein", "vegan", "gf", "carb"]},
    {"name": "Lentilha", "cat": "Proteínas", "tags": ["protein", "vegan", "gf", "carb"]},
    {"name": "Soja", "cat": "Proteínas", "tags": ["protein", "vegan", "gf", "low_carb"]},

    // Vegetais
    {"name": "Tomate", "cat": "Vegetais", "tags": ["vegan", "gf", "low_carb", "keto", "paleo"]},
    {"name": "Cenoura", "cat": "Vegetais", "tags": ["vegan", "gf", "carb", "paleo"]},
    {"name": "Batata", "cat": "Vegetais", "tags": ["vegan", "gf", "carb", "paleo"]},
    {"name": "Cebola", "cat": "Vegetais", "tags": ["vegan", "gf", "low_carb", "paleo"]},
    {"name": "Brócolis", "cat": "Vegetais", "tags": ["vegan", "gf", "low_carb", "keto", "paleo"]},
    {"name": "Couve-flor", "cat": "Vegetais", "tags": ["vegan", "gf", "low_carb", "keto", "paleo"]},
    {"name": "Abobrinha", "cat": "Vegetais", "tags": ["vegan", "gf", "low_carb", "keto", "paleo"]},
    {"name": "Espinafre", "cat": "Vegetais", "tags": ["vegan", "gf", "low_carb", "keto", "paleo"]},
    {"name": "Pimentão", "cat": "Vegetais", "tags": ["vegan", "gf", "low_carb", "keto", "paleo"]},
    {"name": "Abóbora", "cat": "Vegetais", "tags": ["vegan", "gf", "carb", "paleo"]},
  ];

  // --- LÓGICA DE FILTRAGEM ---
  Map<String, List<String>> _getSmartSuggestions(Set<String> filters) {
    Map<String, List<String>> result = {"Básicos": [], "Proteínas": [], "Vegetais": []};

    for (var item in _allIngredientsDb) {
      bool isAllowed = true;
      final tags = item['tags'] as List;

      // Filtros
      if (filters.contains("Vegano") && tags.contains("animal")) isAllowed = false;
      if (filters.contains("Vegetariano") && tags.contains("meat")) isAllowed = false;
      if (filters.contains("Sem Glúten") && !tags.contains("gf")) isAllowed = false;
      if (filters.contains("Sem Lactose") && (item['name'] == "Queijo" || item['name'] == "Manteiga" || item['name'] == "Iogurte")) isAllowed = false;
      if (filters.contains("Low Carb") && tags.contains("carb") && !tags.contains("low_carb")) isAllowed = false;

      if (isAllowed) {
        result[item['cat']]!.add(item['name']);
      }
    }

    // Garante que mostre no máximo 8 itens para não poluir, mas mantém a variedade
    result.forEach((key, list) {
      if (list.length > 10) result[key] = list.sublist(0, 10);
    });

    return result;
  }

  void _addIngredient(String text) {
    if (text.trim().isEmpty) return;
    final List<String> newItems = text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    setState(() {
      for (var item in newItems) {
        String formatted = item[0].toUpperCase() + item.substring(1);
        if (!_ingredients.contains(formatted)) _ingredients.add(formatted);
      }
      _ingredientController.clear();
    });
  }

  void _removeIngredient(String ingredient) => setState(() => _ingredients.remove(ingredient));

  Future<void> _generateRecipe(String selectedAI, Set<String> diets) async {
    // Verifica autenticação
    if (!authNotifier.value.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Faça login para gerar receitas',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Mostra loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 150,
                child: Lottie.network(
                  'https://lottie.host/d52ad3b9-6b2d-4d46-8211-e2a2a61189a0/6LNQtfLEkA.json',
                  errorBuilder: (c, e, s) => Icon(Icons.soup_kitchen,
                      size: 80, color: AppColors.terracotta),
                ),
              ),
              const SizedBox(height: 16),
              Text("Chef $selectedAI cozinhando...",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              if (diets.isNotEmpty)
                Text("Considerando: ${diets.join(', ')}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: AppColors.terracotta,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );

    try {
      // Mapeia o nome da IA para o código esperado pelo backend
      // Cada modelo é enviado com seu código específico:
      // - 'OpenAI' → 'gpt' (ChatGPT)
      // - 'Gemini' → 'gemini' (Google Gemini)
      // - 'Llama' → 'gemini' (por enquanto usa Gemini)
      String aiModel;
      if (selectedAI.toLowerCase() == 'openai') {
        aiModel = 'gpt';
      } else if (selectedAI.toLowerCase() == 'gemini') {
        aiModel = 'gemini';
      } else if (selectedAI.toLowerCase() == 'llama') {
        aiModel = 'gemini'; // Por enquanto, usa gemini para Llama
      } else {
        aiModel = 'gemini'; // Default
      }

      print('🤖 [CREATE_TAB] IA selecionada: $selectedAI');
      print('🎯 [CREATE_TAB] Modelo enviado: $aiModel');
      print('📋 [CREATE_TAB] Ingredientes: $_ingredients');

      // O token JWT é enviado automaticamente pelo interceptador do Dio
      // (recuperado do FlutterSecureStorage no método getToken())
      final response = await apiService.generateRecipe(
        ingredients: _ingredients,
        aiModel: aiModel,
      );

      print('✅ [CREATE_TAB] Resposta recebida da API');
      print('📊 [CREATE_TAB] Tipo de resposta: ${response.runtimeType}');
      print('📦 [CREATE_TAB] Resposta completa: $response');
      print('🔑 [CREATE_TAB] Chaves da resposta: ${response.keys.toList()}');

      if (!mounted) return;
      Navigator.pop(context); // Fecha loading

      // Navega para a tela de resultado com os dados da IA
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeResultScreen(
            userIngredients: _ingredients,
            recipeData: response,
          ),
        ),
      );
    } catch (e, stackTrace) {
      print('❌ [CREATE_TAB] Erro ao gerar receita');
      print('💥 [CREATE_TAB] Tipo de erro: ${e.runtimeType}');
      print('⚠️  [CREATE_TAB] Mensagem: ${e.toString()}');
      print('📍 [CREATE_TAB] Stack trace: $stackTrace');
      
      if (!mounted) return;
      Navigator.pop(context); // Fecha loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao gerar receita: ${e.toString()}',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // --- 2. MODAL DE DOWNLOAD INTELIGENTE (Lógica Desktop vs Mobile Restaurada) ---
  void _showDownloadModal(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDesktop = MediaQuery.of(context).size.width > 600; // Lógica para saber onde está

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone Mobile
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.terracotta.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.install_mobile, size: 48, color: AppColors.terracotta),
            ),
            const SizedBox(height: 24),

            Text(
              "Leve o BiteWise no bolso",
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // UX WRITING: Texto muda se for PC ou Celular
            Text(
              isDesktop
                  ? "Para instalar o aplicativo Android, acesse este site diretamente pelo navegador do seu celular."
                  : "Instale o aplicativo oficial para Android e tenha suas receitas sempre à mão.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey, height: 1.5, fontSize: 15),
            ),

            const SizedBox(height: 32),

            // BOTÃO DINÂMICO
            if (isDesktop)
            // Desktop: Botão "Entendi" (apenas fecha)
              SizedBox(
                  width: double.infinity,
                  child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("ENTENDI", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.terracotta))
                  )
              )
            else
            // Mobile: Botão "Baixar Agora" (Simulação de Download)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Iniciando download...")));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.terracotta,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.download),
                    label: const Text("BAIXAR AGORA")
                ),
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool canGenerate = _ingredients.length >= 3;

    return ValueListenableBuilder<PreferencesState>(
        valueListenable: preferencesNotifier,
        builder: (context, prefs, _) {
          final smartSuggestions = _getSmartSuggestions(prefs.dietFilters);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                children: [
                  // --- Banner ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.terracotta, AppColors.coffee], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: AppColors.terracotta.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Olá, Chef! 👨‍🍳", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text(
                            prefs.dietFilters.isEmpty
                                ? "Digite o que você tem e nós criamos a mágica."
                                : "Modo ${prefs.dietFilters.join(' + ')} ativado.",
                            style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9))
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- Seletor IA ---
                  Text("Escolha sua IA", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                  const SizedBox(height: 12),
                  Container(
                    height: 45,
                    decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.primary.withOpacity(0.1))),
                    child: Row(
                      children: ["Gemini", "OpenAI", "Llama"].map((ai) {
                        final isSelected = prefs.selectedAI == ai;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => preferencesNotifier.setAI(ai),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.terracotta.withOpacity(0.15) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected ? Border.all(color: AppColors.terracotta, width: 1.5) : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(ai, style: GoogleFonts.poppins(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppColors.terracotta : Colors.grey, fontSize: 13)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- Input ---
                  Text("Seus Ingredientes", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ingredientController,
                    onSubmitted: (val) => _addIngredient(val),
                    style: TextStyle(color: cs.onSurface),
                    decoration: InputDecoration(
                      hintText: "Ex: ${smartSuggestions['Proteínas']?.first ?? '...'}, ${smartSuggestions['Vegetais']?.first ?? '...'}...",
                      prefixIcon: const Icon(Icons.add_circle, color: AppColors.terracotta),
                      suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward), onPressed: () => _addIngredient(_ingredientController.text)),
                    ),
                  ),

                  if (_ingredients.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(spacing: 8, runSpacing: 8, children: _ingredients.map((ing) => Chip(label: Text(ing, style: TextStyle(color: cs.onSurface)), backgroundColor: cs.primary.withOpacity(0.1), deleteIcon: Icon(Icons.close, size: 16, color: cs.onSurface.withOpacity(0.6)), onDeleted: () => _removeIngredient(ing))).toList()),
                  ],

                  const SizedBox(height: 32),

                  // --- Sugestões (CATEGORIZADAS E PREENCHIDAS) ---
                  if (_ingredients.length < 3) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Sugestões para sua Dieta:", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
                        if (prefs.dietFilters.isNotEmpty) Icon(Icons.check_circle, size: 16, color: AppColors.olive),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...smartSuggestions.entries.map((entry) {
                      if (entry.value.isEmpty) return const SizedBox.shrink();
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(entry.key, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: cs.primary, fontSize: 15)), const SizedBox(height: 8), Wrap(spacing: 10, runSpacing: 10, children: entry.value.map((item) => ActionChip(label: Text(item, style: TextStyle(color: cs.onSurface)), onPressed: () => _addIngredient(item), backgroundColor: cs.surface, elevation: 1, side: BorderSide(color: Colors.grey.withOpacity(0.2)), padding: const EdgeInsets.all(8))).toList()), const SizedBox(height: 24)]);
                    }).toList(),
                  ],

                  const SizedBox(height: 20),

                  // --- Botão Gerar ---
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: canGenerate ? () => _generateRecipe(prefs.selectedAI, prefs.dietFilters) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.terracotta,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: cs.onSurface.withOpacity(0.12),
                        disabledForegroundColor: cs.onSurface.withOpacity(0.38),
                        elevation: canGenerate ? 4 : 0,
                      ),
                      child: Text(
                        canGenerate ? "GERAR COM ${prefs.selectedAI.toUpperCase()}" : "ADICIONE ${3 - _ingredients.length} INGREDIENTES",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // --- SEÇÃO COMO FUNCIONA (MANTIDA) ---
                  Text("Como o BiteWise funciona?", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      children: [
                        _buildStepCard(context, "01", "Seus Itens", "Você nos diz o que tem na geladeira.", Icons.kitchen, AppColors.terracotta),
                        const SizedBox(width: 16),
                        _buildStepCard(context, "02", "Mágica", "A IA cria receitas únicas para você.", Icons.auto_awesome, Colors.purple),
                        const SizedBox(width: 16),
                        _buildStepCard(context, "03", "Economia", "Evite desperdício e economize.", Icons.savings, Colors.green),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  // --- PREMIUM E DOWNLOAD ---
                  ValueListenableBuilder<bool>(
                      valueListenable: planNotifier,
                      builder: (context, isPremium, _) {
                        return Column(
                          children: [
                            if (!isPremium)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 40),
                                child: GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PlansScreen())),
                                  child: Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.coffee, borderRadius: BorderRadius.circular(24)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.terracotta, borderRadius: BorderRadius.circular(8)), child: Text("OFERTA ESPECIAL", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white))), const SizedBox(height: 12), Text("Seja Premium", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)), const SizedBox(height: 4), Text("Receitas ilimitadas e cardápios semanais.", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13))])), Container(width: 50, height: 50, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(Icons.arrow_forward, color: AppColors.coffee))])),
                                ),
                              ),

                            // SEÇÃO DOWNLOAD (COM O MOCKUP DE CELULAR QUE VOCÊ GOSTOU)
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                  color: cs.surface,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: cs.primary.withOpacity(0.1)),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]
                              ),
                              child: Row(
                                  children: [
                                    // Mockup
                                    Container(
                                        width: 70, height: 130,
                                        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4))]),
                                        padding: const EdgeInsets.all(3),
                                        child: Container(
                                            decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(9)),
                                            child: Center(child: Image.asset('assets/images/logo.png', height: 30, fit: BoxFit.contain))
                                        )
                                    ),
                                    const SizedBox(width: 24),
                                    // Texto + Botão
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Leve o BiteWise", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: cs.primary)),
                                              const SizedBox(height: 4),
                                              Text("Tenha suas receitas sempre à mão.", style: GoogleFonts.poppins(color: cs.onSurface.withOpacity(0.7), fontSize: 13)),
                                              const SizedBox(height: 16),
                                              SizedBox(
                                                  width: double.infinity,
                                                  child: OutlinedButton.icon(
                                                      onPressed: () => _showDownloadModal(context), // Chama o modal inteligente
                                                      style: OutlinedButton.styleFrom(
                                                          side: const BorderSide(color: AppColors.terracotta),
                                                          foregroundColor: AppColors.terracotta,
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                                                      ),
                                                      icon: const Icon(Icons.download_rounded, size: 20),
                                                      label: const Text("BAIXAR APK")
                                                  )
                                              )
                                            ]
                                        )
                                    )
                                  ]
                              ),
                            ),
                          ],
                        );
                      }
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  Widget _buildStepCard(BuildContext context, String number, String title, String desc, IconData icon, Color accentColor) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDark ? Colors.grey.withOpacity(0.2) : Colors.transparent), boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: accentColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: accentColor, size: 20)), Text(number, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w900, color: cs.primary.withOpacity(0.4)))]), const Spacer(), Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface)), const SizedBox(height: 4), Text(desc, style: GoogleFonts.poppins(fontSize: 12, color: cs.onSurface.withOpacity(0.6), height: 1.4))]),
    );
  }
}