import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../auth/providers/auth_provider.dart';
import '../lists/pages/list_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Cores do tema Facebook
  static const Color facebookBlue = Color(0xFF1877F2);
  static const Color facebookWhite = Colors.white;
  static const Color facebookDarkBlue = Color(0xFF0A4A9E);
  static const Color facebookLightGray = Color(0xFFF0F2F5);
  static const Color facebookTextGray = Color(0xFF65676B);

  List<Map<String, dynamic>> _listas = [];
  final _nomeListaController = TextEditingController();
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarListas();
  }

  Future<void> _carregarListas() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final response = await Supabase.instance.client
        .from('lista_compras')
        .select()
        .eq('id_usuario', userId)
        .order('data_criacao', ascending: false);

    setState(() {
      _listas = response;
      _carregando = false;
    });
  }

  Future<void> _criarLista() async {
    final nome = _nomeListaController.text.trim();
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (nome.isEmpty || userId == null) return;

    await Supabase.instance.client.from('lista_compras').insert({
      'id_usuario': userId,
      'nome_lista': nome,
    });

    _nomeListaController.clear();
    _carregarListas();
  }

  Future<void> _excluirLista(String listId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir esta lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Supabase.instance.client
                    .from('lista_compras')
                    .delete()
                    .eq('id_lista', listId);

                // Atualiza a lista local sem precisar recarregar tudo
                setState(() {
                  _listas.removeWhere((lista) => lista['id_lista'] == listId);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lista excluída com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao excluir: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: facebookLightGray,
      appBar: AppBar(
        title: Text('Olá, ${auth.apelido ?? 'usuário'} 👋',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: facebookWhite,
            fontSize: 18,
          ),
        ),
        backgroundColor: facebookBlue,
        elevation: 1,
        iconTheme: const IconThemeData(color: facebookWhite),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: facebookWhite,
            onPressed: () {
              auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Card de criação de nova lista
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nomeListaController,
                      decoration: InputDecoration(
                        labelText: 'Nome da nova lista',
                        labelStyle: const TextStyle(color: facebookTextGray),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: facebookTextGray),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: facebookBlue, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: facebookBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                    onPressed: _criarLista,
                    child: const FaIcon(FontAwesomeIcons.cartPlus,
                      color: facebookWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lista de compras
          Expanded(
            child: _listas.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_basket_outlined,
                      size: 60, color: facebookTextGray),
                  const SizedBox(height: 16),
                  Text('Nenhuma lista criada ainda',
                      style: TextStyle(
                          color: facebookTextGray, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Clique no botão + para começar',
                      style: TextStyle(
                          color: facebookTextGray, fontSize: 14)),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _listas.length,
              itemBuilder: (context, index) {
                final lista = _listas[index];
                return Dismissible(
                  key: Key(lista['id_lista'].toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmar exclusão'),
                        content: const Text('Tem certeza que deseja excluir esta lista?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {

                    // 1. Fazemos uma cópia do item que será removido
                    final Map<String, dynamic> listaRemovida = _listas[index];

                    // 2. Removemos da lista local imediatamente
                    setState(() {

                      // Remove da lista local primeiro
                      _listas.removeAt(index);
                    });


                      try {

                      // Tenta excluir no Supabase
                      await Supabase.instance.client
                          .from('lista_compras')
                          .delete()
                          .eq('id_lista', lista['id_lista']);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lista excluída com sucesso!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      // Se falhar, recoloca o item na lista
                      _listas.insert(index, listaRemovida);
                      setState(() {});

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Falha ao excluir: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    elevation: 1,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: facebookBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FaIcon(FontAwesomeIcons.basketShopping,
                            color: facebookBlue),
                      ),
                      title: Text(lista['nome_lista'] ?? 'Sem nome',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          'Criada em: ${_formatarData(lista['data_criacao'])}',
                          style: TextStyle(color: facebookTextGray)),
                      trailing: const Icon(Icons.chevron_right,
                          color: facebookTextGray),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ListDetailPage(
                              listId: lista['id_lista'].toString(),
                              listName: lista['nome_lista'] ?? 'Sem nome',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatarData(String? dataIso) {
    if (dataIso == null) return '';
    final date = DateTime.parse(dataIso).toLocal();
    return '${date.day}/${date.month}/${date.year}';
  }
}
