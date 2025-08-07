import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:listsaver/features/auth/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Importe seu AuthProvider

// ListCreatePage é o widget para criar uma nova lista.
class ListCreatePage extends StatefulWidget {
  const ListCreatePage({super.key});

  @override
  State<ListCreatePage> createState() => _ListCreatePageState();
}

class _ListCreatePageState extends State<ListCreatePage> {
  // Controlador para o campo de texto do nome da lista.
  final TextEditingController _listNameController = TextEditingController();
  // Chave global para o formulário, usada para validação.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Estado de carregamento para o botão de salvar.
  bool _isLoading = false;

  @override
  void dispose() {
    // Descarte o controlador quando o widget for removido para evitar vazamentos de memória.
    _listNameController.dispose();
    super.dispose();
  }

  // Função assíncrona para salvar a nova lista no Supabase.
  Future<void> _saveList() async {
    // Valida o formulário. Se não for válido, não prossegue.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Define o estado de carregamento para true.
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    final listName = _listNameController.text.trim(); // Obtém o nome da lista e remove espaços em branco.

    // Adicione este print para depuração:
    print('Tentando salvar lista. User ID: $userId, Nome da Lista: $listName');


    if (userId == null || listName.isEmpty) {
      // Exibe uma mensagem de erro se o usuário não estiver logado ou o nome da lista estiver vazio.
      _showSnackBar('Erro: Usuário não logado ou nome da lista vazio.', Colors.red);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Insere a nova lista na tabela 'lista_compras' do Supabase.
      // Corrigido: 'nome' para 'nome_lista'
      await Supabase.instance.client.from('lista_compras').insert({
        'nome_lista': listName, // <--- NOME DA COLUNA CORRIGIDO AQUI!
        'id_usuario': userId,
        // 'created_at' será preenchido automaticamente pelo Supabase se configurado.
      });

      // Exibe uma mensagem de sucesso.
      _showSnackBar('Lista "$listName" criada com sucesso!', Colors.green);

      // Volta para a tela anterior (HomePage) após salvar.
      Navigator.of(context).pop();
    } catch (e) {
      // Em caso de erro, exibe uma mensagem de erro.
      // Adicione este print para depuração:
      print('Erro detalhado ao criar lista: $e');
      _showSnackBar('Erro ao criar lista. Tente novamente.', Colors.red);
    } finally {
      // Define o estado de carregamento para false, independentemente do resultado.
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Função auxiliar para exibir mensagens SnackBar.
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Nova Lista',
          style: TextStyle(
            color: Color.fromARGB(255, 36, 91, 79)
          ),
        ), // Título da barra superior
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Associa a chave global ao formulário.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Estica os filhos horizontalmente.
            children: [
              TextFormField(
                controller: _listNameController, // Associa o controlador ao campo de texto.
                decoration: const InputDecoration(
                  labelText: 'Nome da Lista',
                  hintText: 'Ex: Compras do Supermercado',
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 36, 91, 79),
                    fontWeight: FontWeight.bold
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  prefixIcon: Icon(Icons.list),
                ),
                validator: (value) {
                  // Validação: o nome da lista não pode ser vazio.
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira um nome para a lista.';
                  }
                  return null; // Retorna null se a validação for bem-sucedida.
                },
              ),
              const SizedBox(height: 20), // Espaçamento
              ElevatedButton(
                onPressed: _isLoading ? null : _saveList, // Desabilita o botão se estiver carregando.
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white) // Mostra loading se estiver carregando.
                    : const Text(
                  'Salvar Lista',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
