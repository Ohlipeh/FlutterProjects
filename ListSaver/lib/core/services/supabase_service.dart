import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  // Método para reset de senha (corrigido)
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      // 1. Registrar na tabela de resets (opcional)
      await client.from('password_resets').upsert({
        'email': email,
        'requested_at': DateTime.now().toIso8601String(),
        'used': false,
      });

      // 2. Enviar email com deep link (correto)
      await client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'listsaver://reset-password', // Deep link do seu app
      );
    } catch (e) {
      throw Exception('Erro ao enviar email: ${e.toString()}');
    }
  }

  // Método para verificar token (atualizado)
  static Future<bool> isResetTokenValid(String token) async {
    final response = await client
        .from('password_resets')
        .select()
        .eq('token', token)
        .eq('used', false)
        .maybeSingle();

    return response != null;
  }
}