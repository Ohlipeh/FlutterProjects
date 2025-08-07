import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async'; // Importado para o StreamSubscription

import '../auth/providers/auth_provider.dart';
import '../lists/pages/list_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Cores do tema
  static const Color facebookBlue = Color(0xFF1877F2);
  static const Color facebookWhite = Colors.white;
  static const Color facebookLightGray = Color(0xFFF0F2F5);
  static const Color facebookTextGray = Color(0xFF65676B);

  List<Map<String, dynamic>> _listas = [];
  final _nomeListaController = TextEditingController();
  bool _carregando = true;
  StreamSubscription<List<Map<String, dynamic>>>? _listasSubscription;

  @override
  void initState() {
    super.initState();
    // **MELHORIA:** Agora usamos um listener em tempo real para as listas.
    // Isso significa que qualquer mudança (criação, exclusão) aparecerá instantaneamente
    // sem precisar recarregar a página manualmente.
    _setupRealtimeListener();
  }

  @override
  void dispose() {
    // É crucial cancelar o listener para evitar vazamentos de memória.
    _listasSubscription?.cancel();
    _nomeListaController.dispose();
    super.dispose();
  }

  /// **NOVO:** Listener em tempo real para a tabela 'lista_compras'.
  void _setupRealtimeListener() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) setState(() => _carregando = false);
      return;
    }

    _listasSubscription = Supabase.instance.client
        .from('lista_compras')
        .stream(primaryKey: ['id_lista'])
        .eq('id_usuario', userId)
        .order('data_criacao', ascending: false)
        .listen((data) {
      if (mounted) {
        setState(() {
          _listas = data;
          _carregando = false;
        });
      }
    }, onError: (error) {
      if (mounted) setState(() => _carregando = false);
      print('Erro ao carregar listas: $error');
    });
  }

  /// **CORRIGIDO:** A função de criar lista agora é mais simples.
  /// Ela apenas insere no banco, e o listener em tempo real cuida de atualizar a UI.
  Future<void> _criarLista() async {
    final nome = _nomeListaController.text.trim();
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (nome.isEmpty || userId == null) return;

    try {
      await Supabase.instance.client.from('lista_compras').insert({
        'id_usuario': userId,
        'nome_lista': nome,
      });
      _nomeListaController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar lista: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// **CORRIGIDO:** Lógica de exclusão de lista segura e otimizada.
  Future<void> _excluirLista(int index) async {
    // Guarda o item que será removido e o contexto do Scaffold ANTES de qualquer operação assíncrona.
    final listaParaRemover = _listas[index];
    final listId = listaParaRemover['id_lista'];
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // ATUALIZAÇÃO OTIMISTA: Remove o item da UI imediatamente.
    setState(() {
      _listas.removeAt(index);
    });

    try {
      // Tenta apagar no banco de dados em segundo plano.
      await Supabase.instance.client
          .from('lista_compras')
          .delete()
          .eq('id_lista', listId);

      // Se der certo, usa o scaffoldMessenger que guardamos para mostrar a mensagem de sucesso.
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Lista excluída com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // ROLLBACK: Se a exclusão no banco falhar...
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Falha ao excluir: $e. Restaurando...'),
          backgroundColor: Colors.red,
        ),
      );
      // ...colocamos o item de volta na lista e atualizamos a UI.
      if (mounted) {
        setState(() {
          _listas.insert(index, listaParaRemover);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: facebookLightGray,
      appBar: AppBar(
        title: Text('Olá, ${auth.apelido ?? 'usuário'} 👋',
            style: const TextStyle(fontWeight: FontWeight.bold, color: facebookWhite)),
        backgroundColor: facebookBlue,
        elevation: 1,
        iconTheme: const IconThemeData(color: facebookWhite),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: facebookWhite,
            onPressed: () async {
              // É bom esperar o signOut antes de navegar.
              await auth.signOut();
              // A navegação agora deve ser feita de forma segura.
              // O listener no AppWidget vai reconstruir a árvore e mostrar a LoginPage.
            },
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Card de criação de nova lista (sem alterações na aparência)
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.all(12),
                    ),
                    onPressed: _criarLista,
                    child: const FaIcon(FontAwesomeIcons.cartPlus, color: facebookWhite),
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
                  Icon(Icons.shopping_basket_outlined, size: 60, color: facebookTextGray),
                  const SizedBox(height: 16),
                  Text('Nenhuma lista criada ainda', style: TextStyle(color: facebookTextGray, fontSize: 16)),
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
                  // **CORRIGIDO:** A lógica de confirmação agora chama a função _excluirLista.
                  confirmDismiss: (direction) async {
                    final bool? confirmado = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmar exclusão'),
                        content: const Text('Tem certeza que deseja excluir esta lista?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    // Se o usuário confirmou, a função de exclusão é chamada.
                    if (confirmado == true) {
                      _excluirLista(index);
                    }
                    // Retorna false para que o Dismissible não tente apagar o item por conta própria.
                    return false;
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 1,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: facebookBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FaIcon(FontAwesomeIcons.basketShopping, color: facebookBlue),
                      ),
                      title: Text(lista['nome_lista'] ?? 'Sem nome', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Criada em: ${_formatarData(lista['data_criacao'])}', style: TextStyle(color: facebookTextGray)),
                      trailing: const Icon(Icons.chevron_right, color: facebookTextGray),
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
