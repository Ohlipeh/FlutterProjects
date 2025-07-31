import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/supabase_service.dart';
import '../auth/providers/auth_provider.dart';
import '../auth/pages/login_page.dart'; // Importe sua LoginPage para navegação de logout
import '../lists/pages/my_lists_page.dart'; // Importe MyListsPage
import 'package:listsaver/features/lists/pages/list_create_page.dart'; // Importa a tela de criação de lista

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
            onPressed: () async {
              await authProvider.signOut();
              // Navega para a LoginPage após o logout, removendo todas as rotas anteriores.
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: const MyListsPage(), // CORRIGIDO: Não passa listId e listName aqui
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navega para a tela de criação de lista quando o botão é pressionado.
          // Usamos MaterialPageRoute para criar uma nova rota.
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ListCreatePage(), // A tela que vamos criar
            ),
          );
        },
        child: const Icon(Icons.add), // Ícone de adição
        tooltip: 'Criar nova lista', // Dica de ferramenta de ferramenta para acessibilidade
      ),
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
