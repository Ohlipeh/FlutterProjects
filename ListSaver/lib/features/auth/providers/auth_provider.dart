import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  User? currentUser;
  String? apelido;
  bool isLoading = false;
  String? errorMessage;

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
    } on AuthException catch (e) {
      errorMessage = 'Erro ao registrar: ${e.message}';
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
      currentUser = response.user;

      // Carrega o apelido do usuário
      if (currentUser != null) {
        final perfil = await Supabase.instance.client
            .from('perfil_usuario')
            .select()
            .eq('id_usuario', currentUser!.id)
            .single();

        apelido = perfil['apelido'];
      }
    } on AuthException catch (e) {
      errorMessage = 'Erro ao entrar: ${e.message}';
    } catch (e) {
      errorMessage = 'Erro ao entrar: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);

      // Registra a solicitação no banco (opcional)
      await Supabase.instance.client.from('password_resets').insert({
        'email': email,
        'requested_at': DateTime.now().toIso8601String(),
      });

    } on AuthException catch (e) {
      errorMessage = 'Erro ao enviar email: ${e.message}';
    } catch (e) {
      errorMessage = 'Ocorreu um erro inesperado';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    currentUser = null;
    apelido = null;
    notifyListeners();
  }
}