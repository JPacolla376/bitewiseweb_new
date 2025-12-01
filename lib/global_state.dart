import 'package:flutter/material.dart';
import 'services/api_service.dart';

// --- 1. TEMA ---
class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);
  void toggleTheme() => value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
}
final themeNotifier = ThemeNotifier();

// --- 2. AUTENTICAÇÃO COM JWT ---
class UserAuth {
  final bool isAuthenticated;
  final String? email;
  final String? token;
  final bool isLoading;
  final String? error;

  UserAuth({
    this.isAuthenticated = false,
    this.email,
    this.token,
    this.isLoading = false,
    this.error,
  });

  UserAuth copyWith({
    bool? isAuthenticated,
    String? email,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return UserAuth(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      email: email ?? this.email,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends ValueNotifier<UserAuth> {
  AuthNotifier() : super(UserAuth()) {
    _initializeAuth();
  }

  /// Inicializa a autenticação verificando token armazenado
  Future<void> _initializeAuth() async {
    try {
      final isAuth = await apiService.isAuthenticated();
      if (isAuth) {
        final email = await apiService.getUserEmail();
        final token = await apiService.getToken();
        value = value.copyWith(
          isAuthenticated: true,
          email: email,
          token: token,
        );
      }
    } catch (e) {
      // Token inválido, limpa a autenticação
      await apiService.logout();
    }
  }

  /// Faz registro de novo usuário
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    value = value.copyWith(isLoading: true, error: null);
    try {
      await apiService.register(
        name: name,
        email: email,
        password: password,
      );
      value = value.copyWith(isLoading: false);
    } catch (e) {
      value = value.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Faz login
  Future<void> login({required String email, required String password}) async {
    value = value.copyWith(isLoading: true, error: null);
    try {
      final response = await apiService.login(email: email, password: password);
      final token = response['token'] ?? response['accessToken'];
      
      value = value.copyWith(
        isAuthenticated: true,
        email: email,
        token: token,
        isLoading: false,
      );
    } catch (e) {
      value = value.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Faz logout
  Future<void> logout() async {
    await apiService.logout();
    value = UserAuth();
  }
}

final authNotifier = AuthNotifier();

// --- 3. PLANOS ---
class PlanNotifier extends ValueNotifier<bool> {
  PlanNotifier() : super(false);
  void upgrade() => value = true;
  void cancel() => value = false;
}
final planNotifier = PlanNotifier();

// --- 4. RECEITAS SALVAS ---
class SavedRecipesNotifier extends ValueNotifier<List<Map<String, dynamic>>> {
  SavedRecipesNotifier() : super([]);

  void saveRecipe(Map<String, dynamic> recipe) {
    if (!value.any((r) => r['title'] == recipe['title'])) {
      value = [recipe, ...value];
    }
  }

  Map<String, dynamic> removeRecipe(int index) {
    final newList = [...value];
    final removedItem = newList.removeAt(index);
    value = newList;
    return removedItem;
  }

  void restoreRecipe(int index, Map<String, dynamic> recipe) {
    final newList = [...value];
    newList.insert(index, recipe);
    value = newList;
  }
}
final savedRecipesNotifier = SavedRecipesNotifier();

// --- 5. PREFERÊNCIAS ---
class PreferencesState {
  final String selectedAI;
  final Set<String> dietFilters;

  PreferencesState({this.selectedAI = 'Gemini', this.dietFilters = const {}});

  PreferencesState copyWith({String? selectedAI, Set<String>? dietFilters}) {
    return PreferencesState(
      selectedAI: selectedAI ?? this.selectedAI,
      dietFilters: dietFilters ?? this.dietFilters,
    );
  }
}

class PreferencesNotifier extends ValueNotifier<PreferencesState> {
  PreferencesNotifier() : super(PreferencesState());

  void setAI(String aiName) => value = value.copyWith(selectedAI: aiName);

  void toggleFilter(String filter) {
    final newFilters = Set<String>.from(value.dietFilters);
    if (newFilters.contains(filter)) {
      newFilters.remove(filter);
    } else {
      newFilters.add(filter);
    }
    value = value.copyWith(dietFilters: newFilters);
  }

  void clearFilters() {
    value = value.copyWith(dietFilters: {});
  }
}
final preferencesNotifier = PreferencesNotifier();

// --- 6. CONTROLE DE ABAS ---
class TabNotifier extends ValueNotifier<int> {
  TabNotifier() : super(0);
  void goToCreate() => value = 0;
  void goToSaved() => value = 1;
  void goToProfile() => value = 2;
}
final tabNotifier = TabNotifier();

// --- 7. NOTIFICAÇÕES (NOVO!) ---
class NotificationNotifier extends ValueNotifier<List<Map<String, dynamic>>> {
  NotificationNotifier() : super([
    {
      "id": "1",
      "title": "Bem-vindo ao BiteWise! 🍳",
      "body": "Que tal criar sua primeira receita hoje? Clique aqui para começar a mágica na sua cozinha.",
      "time": "Agora",
      "icon": Icons.auto_awesome,
      "color": Colors.amber,
      "read": false,
    },
    {
      "id": "2",
      "title": "Dica do Chef",
      "body": "Salvar suas receitas favoritas ajuda a organizar sua semana. Toque no ícone de bandeira na receita.",
      "time": "Há 2h",
      "icon": Icons.tips_and_updates,
      "color": Colors.blue,
      "read": true,
    },
    {
      "id": "3",
      "title": "Novidade no Premium",
      "body": "Agora você pode gerar cardápios completos para a semana toda. Aproveite o desconto!",
      "time": "Ontem",
      "icon": Icons.star,
      "color": const Color(0xFFD35400),
      "read": true,
    },
  ]);

  void markAsRead(int index) {
    final newList = [...value];
    newList[index]['read'] = true;
    value = newList;
  }

  void removeNotification(int index) {
    final newList = [...value];
    newList.removeAt(index);
    value = newList;
  }
}
final notificationNotifier = NotificationNotifier();