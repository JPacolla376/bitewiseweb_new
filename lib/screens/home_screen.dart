import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../global_state.dart'; // CORREÇÃO: Apenas um nível acima (..)
import '../theme.dart';
import 'tabs/create_tab.dart';
import 'tabs/profile_placeholder.dart';
import 'tabs/saved_tab.dart';
import 'tabs/profile_tab.dart';
import 'notification_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return ValueListenableBuilder<UserAuth>(
      valueListenable: authNotifier,
      builder: (context, auth, child) {
        final isLoggedIn = auth.isAuthenticated;

        final List<Widget> tabs = [
          const CreateTab(),
          isLoggedIn ? const SavedTab() : const ProfilePlaceholder(),
          isLoggedIn
              ? ProfileTab(onLogout: () async {
            await authNotifier.logout();
            planNotifier.cancel();
            savedRecipesNotifier.value = [];
            tabNotifier.goToCreate();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Você saiu da conta.")));
          })
              : const ProfilePlaceholder(),
        ];

        return ValueListenableBuilder<int>(
          valueListenable: tabNotifier,
          builder: (context, selectedIndex, _) {

            return PopScope(
              canPop: selectedIndex == 0,
              onPopInvoked: (didPop) {
                if (didPop) return;
                tabNotifier.goToCreate();
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWebLayout = constraints.maxWidth > 800;

                  return Scaffold(
                    appBar: isWebLayout
                        ? null
                        : AppBar(
                      toolbarHeight: 70,
                      centerTitle: true,
                      backgroundColor: cs.surface,
                      elevation: 0,
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/images/logo.png', height: 32),
                          const SizedBox(width: 8),
                          Text("BiteWise", style: GoogleFonts.poppins(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.terracotta)),
                        ],
                      ),
                      actions: [
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              builder: (context) => const NotificationSheet(),
                            );
                          },
                          icon: Icon(Icons.notifications_outlined, color: cs.onSurface.withOpacity(0.7)),
                          tooltip: "Notificações",
                        ),
                        IconButton(
                          onPressed: () => themeNotifier.toggleTheme(),
                          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: cs.primary),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),

                    body: Row(
                      children: [
                        if (isWebLayout)
                          Container(
                            width: 250,
                            color: cs.surface,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 40),
                                  width: double.infinity,
                                  color: AppColors.terracotta.withOpacity(0.1),
                                  child: Column(
                                    children: [
                                      Image.asset('assets/images/logo.png', height: 80),
                                      const SizedBox(height: 16),
                                      Text("BiteWise", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.terracotta, letterSpacing: 1.5)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                _buildWebNavItem(0, "Criar", Icons.soup_kitchen_outlined, Icons.soup_kitchen, selectedIndex, cs),
                                _buildWebNavItem(1, "Receitas", Icons.bookmark_border, Icons.bookmark, selectedIndex, cs),
                                _buildWebNavItem(2, "Seu Perfil", Icons.person_outline, Icons.person, selectedIndex, cs),

                                const Spacer(),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor: Colors.transparent,
                                        isScrollControlled: true,
                                        builder: (context) => const NotificationSheet(),
                                      );
                                    },
                                    icon: Icon(Icons.notifications_outlined, size: 20, color: cs.onSurface),
                                    label: Text("Notificações", style: GoogleFonts.poppins(color: cs.onSurface, fontWeight: FontWeight.w600)),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: cs.onSurface.withOpacity(0.2)),
                                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                      alignment: Alignment.centerLeft,
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                                  child: OutlinedButton.icon(
                                    onPressed: () => themeNotifier.toggleTheme(),
                                    icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 20),
                                    label: Text(isDark ? "Modo Claro" : "Modo Escuro", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: cs.onSurface,
                                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                      alignment: Alignment.centerLeft,
                                      side: BorderSide(color: cs.onSurface.withOpacity(0.2)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (isWebLayout)
                          VerticalDivider(thickness: 1, width: 1, color: Colors.grey.withOpacity(0.1)),

                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 900),
                              child: tabs[selectedIndex],
                            ),
                          ),
                        ),
                      ],
                    ),

                    bottomNavigationBar: isWebLayout
                        ? null
                        : NavigationBar(
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (index) => tabNotifier.value = index,
                      backgroundColor: cs.surface,
                      elevation: 10,
                      indicatorColor: AppColors.terracotta.withOpacity(0.15),
                      destinations: const [
                        NavigationDestination(icon: Icon(Icons.soup_kitchen_outlined), selectedIcon: Icon(Icons.soup_kitchen, color: AppColors.terracotta), label: 'Criar'),
                        NavigationDestination(icon: Icon(Icons.bookmark_border), selectedIcon: Icon(Icons.bookmark, color: AppColors.terracotta), label: 'Receitas'),
                        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: AppColors.terracotta), label: 'Você'),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWebNavItem(int index, String label, IconData iconOff, IconData iconOn, int selectedIndex, ColorScheme cs) {
    final isSelected = index == selectedIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: isSelected ? AppColors.terracotta.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => tabNotifier.value = index,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Icon(isSelected ? iconOn : iconOff, color: isSelected ? AppColors.terracotta : Colors.grey, size: 26),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AppColors.terracotta : cs.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}