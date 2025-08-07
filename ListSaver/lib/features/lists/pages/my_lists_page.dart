import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // A única importação do Supabase necessária
import 'package:listsaver/features/auth/providers/auth_provider.dart';
import 'dart:async';
import 'package:listsaver/features/lists/pages/list_detail_page.dart';

// **REMOVIDO:** A importação do serviço antigo foi apagada.
// import 'package:listsaver/core/services/supabase_service.dart';

class MyListsPage extends StatefulWidget {
  const MyListsPage({super.key});

  @override
  State<MyListsPage> createState() => _MyListsPageState();
}

class _MyListsPageState extends State<MyListsPage> {
  List<Map<String, dynamic>> _userLists = [];
  bool _isLoading = true;
  StreamSubscription<List<Map<String, dynamic>>>? _listSubscription;

  @override
  void initState() {
    super.initState();
    _setupRealtimeListener();
  }

  @override
  void dispose() {
    _listSubscription?.cancel();
    super.dispose();
  }

  void _setupRealtimeListener() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      setState(() {
        _isLoading = false;
        _userLists = [];
      });
      return;
    }

    _listSubscription?.cancel();

    // **CORRIGIDO:** Usa a instância correta e autenticada do Supabase.
    _listSubscription = Supabase.instance.client
        .from('lista_compras')
        .stream(primaryKey: ['id_lista'])
        .eq('id_usuario', userId)
        .order('created_at', ascending: false)
        .listen((data) {
      if (mounted) {
        setState(() {
          _userLists = data;
          _isLoading = false;
        });
      }
    }, onError: (error) {
      print('Erro na stream de listas: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _deleteList(String listId, String listName) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Você tem certeza que deseja excluir a lista "$listName"? Esta ação não pode ser desfeita.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    // --- ADICIONE ESTA LINHA AQUI ---
    print('--- TESTE DE EXCLUSÃO ---');
    print('Tentando excluir como usuário: ${Supabase.instance.client.auth.currentUser?.id}');
    print('-------------------------');
    // -------------------------------

    final index = _userLists.indexWhere((list) => list['id_lista'] == listId);
    if (index == -1) return;

    final listToRemove = _userLists[index];

    setState(() {
      _userLists.removeAt(index);
    });

    try {
      // **CORRIGIDO:** Usa a instância correta e autenticada do Supabase.
      await Supabase.instance.client
          .from('lista_compras')
          .delete()
          .eq('id_lista', listId);

    } catch (e) {
      print('FALHA AO EXCLUIR LISTA: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir a lista. Restaurando...'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _userLists.insert(index, listToRemove);
        });
      }
    }
  }

  String _formatCreationDate(dynamic dateValue) {
    if (dateValue == null) return 'Data Inválida';
    try {
      return DateTime.parse(dateValue.toString()).toLocal().toString().split(' ')[0];
    } catch (e) {
      return 'Data Inválida';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userLists.isEmpty) {
      return const Center(
        child: Text(
          'Você ainda não tem nenhuma lista.\nCrie sua primeira lista!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _userLists.length,
        itemBuilder: (context, index) {
          final list = _userLists[index];
          final String listId = list['id_lista']?.toString() ?? '';
          final String listName = list['nome_lista']?.toString() ?? 'Lista Sem Nome';

          return Dismissible(
            key: ValueKey(listId),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _deleteList(listId, listName);
            },
            background: Container(
              color: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerRight,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text(
                  listName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 36, 91, 79)),
                ),
                subtitle: Text(
                  'Criada em: ${_formatCreationDate(list['data_criacao'])}',
                  style: const TextStyle(color: Color.fromARGB(255, 36, 91, 79)),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  if (listId.isEmpty) {
                    return;
                  }
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
            ),
          );
        },
      );
    }
  }
}

