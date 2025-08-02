import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  User? currentUser;
  String? apelido;

  Future<void> signUp({
    required String email,
    required String password,
    required String nome,
    required String apelido,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user != null) {
        await Supabase.instance.client.from('perfil_usuario').insert({
          'id_usuario': user.id,
          'nome_usuario': nome,
          'apelido': apelido,
          'data_criacao': DateTime.now().toIso8601String(),
        });
        this.apelido = apelido;
        currentUser = user;
      }
    } catch (e) {
      errorMessage = 'Erro ao registrar: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user != null) {
        currentUser = user;
        final data = await Supabase.instance.client
            .from('perfil_usuario')
            .select('apelido')
            .eq('id_usuario', user.id)
            .single();
        apelido = data['apelido'];
      }
    } catch (e) {
      errorMessage = 'Erro ao fazer login: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void signOut() {
    Supabase.instance.client.auth.signOut();
    currentUser = null;
    apelido = null;
    notifyListeners();
  }
}