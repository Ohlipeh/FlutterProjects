import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../lists/pages/list_detail_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${auth.apelido ?? 'usuário'} 👋',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 36, 91, 79)
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout,
              color: Color.fromARGB(255, 36, 91, 79),
            ),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nomeListaController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da nova lista',
                      labelStyle: TextStyle(
                          color: Color.fromARGB(255, 36, 91, 79)
                      ),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 36, 91, 79), // Cor da borda quando desabilitado
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 36, 91, 79), // Cor da borda quando focado
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _criarLista,
                  child: const FaIcon(FontAwesomeIcons.cartPlus,
                    color: Color.fromARGB(255, 36, 91, 79),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _listas.isEmpty
                ? const Center(
              child: Text('Nenhuma lista criada ainda.'),
            )
                : ListView.builder(
              itemCount: _listas.length,
              itemBuilder: (context, index) {
                final lista = _listas[index];
                return ListTile(
                  title: Text(lista['nome_lista'] ?? 'Sem nome',
                    style: TextStyle(
                      color: Color.fromARGB(255, 36, 91, 79),
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  subtitle: Text('Criada em: ${_formatarData(lista['data_criacao'])}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 36, 91, 79)
                    ),
                  ),
                  trailing: const FaIcon(FontAwesomeIcons.basketShopping,
                    color: Color.fromARGB(255, 36, 91, 79),
                  ),
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
