import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;

  AuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    SupabaseService.client.auth.onAuthStateChange.listen((event) {
      _currentUser = event.session?.user;
      notifyListeners();
    });
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _createUserProfile(response.user!.id, name);
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro desconhecido: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createUserProfile(String userId, String name) async {
    await SupabaseService.client
        .from('perfil_usuario')
        .upsert({
      'id_usuario': userId,
      'nome_usuario': name,
      'ultimo_login': DateTime.now().toIso8601String(),
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro desconhecido: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await SupabaseService.client.auth.signOut();
  }
}