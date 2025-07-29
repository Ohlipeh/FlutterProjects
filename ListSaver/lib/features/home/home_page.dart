import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/supabase_service.dart';
import '../auth/providers/auth_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: _getUserProfile(authProvider.currentUser?.id ?? ''),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final apelido = snapshot.data?['apelido'];
              return Text(apelido != null ? 'Olá, $apelido!' : 'Minhas Listas');
            }
            return const Text('Minhas Listas');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: const Center(child: Text('Conteúdo principal')),
    );
  }

  Future<Map<String, dynamic>?> _getUserProfile(String userId) async {
    if (userId.isEmpty) return null;
    final response = await SupabaseService.client
        .from('perfil_usuario')
        .select()
        .eq('id_usuario', userId)
        .maybeSingle();
    return response;
  }
}