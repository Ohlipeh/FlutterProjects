import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:listsaver/core/services/supabase_service.dart'; // Importe seu SupabaseService
import 'package:listsaver/features/auth/providers/auth_provider.dart'; // Importe seu AuthProvider
import 'dart:async'; // Importe para usar StreamSubscription
import 'package:listsaver/features/lists/pages/list_detail_page.dart'; // Importe a tela de detalhes da lista

// MyListsPage é o widget responsável por exibir as listas do usuário.
class MyListsPage extends StatefulWidget {
  // Removi os parâmetros listId e listName, pois esta página exibe TODAS as listas.
  const MyListsPage({super.key});

  @override
  State<MyListsPage> createState() => _MyListsPageState();
}

class _MyListsPageState extends State<MyListsPage> {
  // Lista para armazenar os dados das listas de compras.
  List<Map<String, dynamic>> _userLists = [];
  // Estado de carregamento inicial.
  bool _isLoading = true;
  // Objeto para gerenciar a inscrição em tempo real do Supabase.
  StreamSubscription<List<Map<String, dynamic>>>? _listSubscription;

  @override
  void initState() {
    super.initState();
    // Inicia a escuta de listas em tempo real quando o widget é inicializado.
    _setupRealtimeListener();
  }

  @override
  void dispose() {
    // Cancela a inscrição em tempo real quando o widget é descartado
    // para evitar vazamentos de memória e chamadas desnecessárias.
    _listSubscription?.cancel();
    super.dispose();
  }

  // Configura o listener de tempo real para a tabela 'lista_compras'.
  void _setupRealtimeListener() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      // Se não houver userId, define como não carregando e lista vazia.
      setState(() {
        _isLoading = false;
        _userLists = [];
      });
      return;
    }

    // Cancela qualquer inscrição anterior para evitar duplicação.
    _listSubscription?.cancel();

    // Cria uma stream para ouvir as mudanças na tabela 'lista_compras'.
    // Filtra por 'id_usuario' para obter apenas as listas do usuário logado.
    // Ordena por 'created_at' em ordem decrescente.
    _listSubscription = SupabaseService.client
        .from('lista_compras')
        .stream(primaryKey: ['id_lista']) // Use a chave primária da sua tabela
        .eq('id_usuario', userId)
        .order('created_at', ascending: false) // Mantendo 'created_at' para ordenação por enquanto
        .listen((data) {
      // Quando novos dados chegam (ou dados são alterados/removidos),
      // atualiza o estado do widget com a nova lista.
      setState(() {
        _userLists = data;
        _isLoading = false; // Define como não carregando após receber os dados.
      });
    }, onError: (error) {
      // Lida com erros na stream.
      print('Erro na stream de listas: $error');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar listas: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  // Função auxiliar para formatar a data de criação.
  String _formatCreationDate(dynamic dateValue) {
    if (dateValue == null) {
      return 'Data Indisponível';
    }

    DateTime dateTime;
    if (dateValue is String) {
      // Tenta parsear como String (formato ISO 8601)
      try {
        dateTime = DateTime.parse(dateValue);
      } catch (e) {
        print('Erro ao parsear data como String: $e');
        return 'Formato Inválido';
      }
    } else if (dateValue is int) {
      // Se for int, assume que é um timestamp em milissegundos
      dateTime = DateTime.fromMillisecondsSinceEpoch(dateValue);
    } else {
      return 'Tipo de Data Inválido';
    }
    return dateTime.toLocal().toString().split(' ')[0]; // Retorna apenas a parte da data
  }

  @override
  Widget build(BuildContext context) {
    // Se estiver carregando, exibe um indicador de progresso.
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Se não houver listas, exibe a mensagem para criar a primeira lista.
    if (_userLists.isEmpty) {
      return const Center(
        child: Text(
          'Você ainda não tem nenhuma lista.\nCrie sua primeira lista!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    } else {
      // Se houver listas, exibe-as em um ListView.
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _userLists.length,
        itemBuilder: (context, index) {
          final list = _userLists[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                (list['nome_lista']?.toString() ?? 'Lista Sem Nome'), // Converte explicitamente para String
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 36, 91, 79)
                ),
              ),
              subtitle: Text(
                'Criada em: ${_formatCreationDate(list['data_criacao'])}',
                style: const TextStyle(color: Color.fromARGB(255, 36, 91, 79)),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Garante que id_lista e nome_lista são Strings antes de passar
                final String listId = list['id_lista']?.toString() ?? '';
                final String listName = (list['nome_lista']?.toString() ?? 'Lista Sem Nome');

                if (listId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erro: ID da lista não encontrado.'),
                      backgroundColor: Color.fromARGB(255, 36, 91, 79),
                    ),
                  );
                  return;
                }

                // CORRIGIDO: Navega para ListDetailPage, não para MyListsPage
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ListDetailPage(
                      listId: listId,
                      listName: listName,
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    }
  }
}
