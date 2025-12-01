import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../global_state.dart';
import '../../theme.dart';
import 'login_modal.dart';

class NotificationSheet extends StatelessWidget {
  const NotificationSheet({super.key});

  void _showDetails(BuildContext context, Map<String, dynamic> n, int index) {
    notificationNotifier.markAsRead(index);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: (n['color'] as Color).withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(n['icon'] as IconData, color: n['color'] as Color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(n['title'], style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(n['body'], style: GoogleFonts.poppins(fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () {
              notificationNotifier.removeNotification(index);
              Navigator.pop(context);
            },
            child: Text("EXCLUIR", style: TextStyle(color: Colors.red[400])),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ValueListenableBuilder<UserAuth>(
        valueListenable: authNotifier,
        builder: (context, auth, _) {
          final isLoggedIn = auth.isAuthenticated;
          return Container(
            height: MediaQuery.of(context).size.height * 0.75, // Altura fixa confortável
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 25)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Notificações", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface)),
                    if (isLoggedIn)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        tooltip: "Fechar",
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: isLoggedIn ? _buildNotificationsList(cs) : _buildLoginPrompt(context, cs),
                ),
              ],
            ),
          );
        }
    );
  }

  Widget _buildNotificationsList(ColorScheme cs) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: notificationNotifier,
      builder: (context, notifications, _) {
        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text("Sem novas notificações", style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w500)),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: notifications.length,
          padding: const EdgeInsets.only(bottom: 40),
          separatorBuilder: (c, i) => Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
          itemBuilder: (context, index) {
            final n = notifications[index];
            final isRead = n['read'] as bool;

            return Dismissible(
              key: Key(n['id'] + index.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.redAccent,
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              onDismissed: (direction) {
                notificationNotifier.removeNotification(index);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Notificação removida")));
              },
              child: InkWell(
                onTap: () => _showDetails(context, n, index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ícone
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (n['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(n['icon'] as IconData, color: n['color'] as Color, size: 22),
                      ),
                      const SizedBox(width: 16),

                      // Texto
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                      n['title'],
                                      style: GoogleFonts.poppins(
                                          fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                          fontSize: 15,
                                          color: cs.onSurface
                                      )
                                  ),
                                ),
                                if (!isRead)
                                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.terracotta, shape: BoxShape.circle)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                                n['body'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(fontSize: 13, color: cs.onSurface.withOpacity(0.6))
                            ),
                            const SizedBox(height: 8),
                            Text(n['time'], style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoginPrompt(BuildContext context, ColorScheme cs) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.terracotta.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_off_outlined, size: 48, color: AppColors.terracotta),
          ),
          const SizedBox(height: 24),
          Text(
            "Não perca nada!",
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "Receba dicas de economia, alertas de preços e novidades exclusivas fazendo login.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600], height: 1.5),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const LoginModal(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.terracotta,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text("ENTRAR AGORA", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}