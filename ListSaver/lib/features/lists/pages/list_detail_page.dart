import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:listsaver/core/services/supabase_service.dart'; // Importe seu SupabaseService
import 'package:listsaver/features/auth/providers/auth_provider.dart'; // Importe seu AuthProvider
import 'dart:async'; // Importe para usar StreamSubscription
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Importe os novos widgets separados
import 'package:listsaver/features/lists/pages/widgets/add_item_form.dart';
import 'package:listsaver/features/lists/pages/widgets/list_item_card.dart';
import 'package:listsaver/features/lists/pages/widgets/total_price_footer.dart';

// ListDetailPage é a tela para visualizar e gerenciar os itens de uma lista específica.
class ListDetailPage extends StatefulWidget {
  final String listId;
  final String listName;

  const ListDetailPage({
    super.key,
    required this.listId,
    required this.listName,
  });

  @override
  State<ListDetailPage> createState() => _ListDetailPageState();
}

class _ListDetailPageState extends State<ListDetailPage> {
  List<Map<String, dynamic>> _listItems = [];
  bool _isLoading = true;
  StreamSubscription<List<Map<String, dynamic>>>? _itemsSubscription;

  final TextEditingController _itemNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  double _totalPrice = 0.0;
  bool _isAddingItem = false;

  @override
  void initState() {
    super.initState();
    print('ListDetailPageState: initState chamado para listId: ${widget.listId}');
    _setupRealtimeListener();
  }

  @override
  void dispose() {
    print('ListDetailPageState: dispose chamado para listId: ${widget.listId}');
    _itemsSubscription?.cancel();
    _itemNameController.dispose();
    super.dispose();
  }

  void _setupRealtimeListener() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    print('ListDetailPageState: _setupRealtimeListener chamado. userId: $userId');

    if (userId == null) {
      setState(() {
        _isLoading = false;
        _listItems = [];
      });
      print('ListDetailPageState: userId é nulo, limpando lista e parando configuração do listener.');
      return;
    }

    _itemsSubscription?.cancel();
    print('ListDetailPageState: Iniciando escuta de stream para item_lista com id_lista: ${widget.listId}');

    _itemsSubscription = SupabaseService.client
        .from('item_lista')
        .stream(primaryKey: ['id_item_lista'])
        .eq('id_lista', widget.listId)
        .order('data_adicao', ascending: true)
        .listen((data) {
      print('ListDetailPageState: Dados em tempo real recebidos. Quantidade de itens: ${data.length}.');
      for (var item in data) {
        print('  - Item ID: ${item['id_item_lista']}, Nome: ${item['nome_item_personalizado']}, Comprado: ${item['comprado']}, Qtd: ${item['quantidade']}, Preço: ${item['preco_unitario_registrado']}'); // Adicionado Qtd e Preço para depuração
      }
      setState(() {
        _listItems = data;
        _isLoading = false;
        _calculateTotalPrice();
      });
    }, onError: (error) {
      print('ListDetailPageState: Erro na stream em tempo real: $error');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar itens: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _calculateTotalPrice() {
    double total = 0.0;
    for (var item in _listItems) {
      final quantity = (item['quantidade'] as num?)?.toDouble() ?? 0.0;
      final price = (item['preco_unitario_registrado'] as num?)?.toDouble() ?? 0.0;
      total += quantity * price;
    }
    setState(() {
      _totalPrice = total;
    });
  }

  Future<void> _addNewItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isAddingItem = true;
    });

    final itemName = _itemNameController.text.trim();

    print('ListDetailPageState: Tentando adicionar novo item (apenas nome): Nome: $itemName, ID da Lista: ${widget.listId}');

    if (itemName.isEmpty) {
      setState(() {
        _isAddingItem = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira o nome do item.'),
          backgroundColor: Color.fromARGB(255, 36, 91, 79),
        ),
      );
      return;
    }

    try {
      final response = await SupabaseService.client.from('item_lista',).insert({ // Adicionado response
        'id_lista': widget.listId,
        'nome_item_personalizado': itemName,
        'quantidade': 0.0,
        'preco_unitario_registrado': 0.0,
        'comprado': false,
      }).select(); // Adicionado .select() para obter a resposta

      print('ListDetailPageState: Resposta da inserção do Supabase: $response'); // NOVO PRINT

      _itemNameController.clear();

      print('ListDetailPageState: Item adicionado com sucesso ao Supabase!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item adicionado com sucesso!'),
          backgroundColor: Color.fromARGB(255, 36, 91, 79),
        ),
      );
    } catch (e) {
      print('ListDetailPageState: Erro ao adicionar item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao adicionar item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isAddingItem = false;
      });
    }
  }

  // Função para atualizar um item existente na lista (chamada pelo ListItemCard).
  Future<void> _updateItemDetails(String itemId, double quantity, double price, bool comprado) async {
    print('ListDetailPageState: DEBUG - === ENTROU EM _updateItemDetails ==='); // NOVO PRINT CRÍTICO
    print('ListDetailPageState: Recebendo atualização de item ID: $itemId, Qtd: $quantity, Preço: $price, Comprado: $comprado');

    try {
      print('ListDetailPageState: DEBUG - Antes do await Supabase update para item ID: $itemId'); // NOVO PRINT
      final response = await SupabaseService.client.from('item_lista').update({
        'quantidade': quantity,
        'preco_unitario_registrado': price,
        'comprado': comprado,
        'data_adicao': DateTime.now().toIso8601String(), // Usando data_adicao para atualização
      }).eq('id_item_lista', itemId).select(); // Adicionado .select() para obter a resposta

      print('ListDetailPageState: Resposta da atualização do Supabase: $response'); // NOVO PRINT

      if (response != null && response.isNotEmpty) {
        print('ListDetailPageState: Item ID $itemId atualizado com sucesso no Supabase!');
      } else {
        print('ListDetailPageState: Item ID $itemId atualizado, mas resposta vazia ou nula.');
      }
      // A UI será atualizada automaticamente pelo real-time listener
    } catch (e) {
      print('ListDetailPageState: ERRO CRÍTICO ao atualizar item ID $itemId: $e'); // NOVO PRINT
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Formulário de Adição de Item no Topo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AddItemForm( // Usando o widget separado
              itemNameController: _itemNameController,
              formKey: _formKey,
              isAddingItem: _isAddingItem,
              onAddItem: _addNewItem,
            ),
          ),
          // Lista de Itens (Expandida para ocupar o espaço restante)
          Expanded(
            child: _listItems.isEmpty
                ? const Center(
              child: Text(
                'Esta lista está vazia.\nAdicione seu primeiro item!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 36, 91, 79)),
              ),
            )
                : ListView.builder(
              // REMOVIDO: shrinkWrap e physics não são necessários quando dentro de Expanded
              padding: const EdgeInsets.all(16.0),
              itemCount: _listItems.length,
              itemBuilder: (context, index) {
                final item = _listItems[index];
                return ListItemCard( // Usando o widget separado
                  item: item,
                  onUpdateDetails: _updateItemDetails, // Passa a função de atualização inline
                );
              },
            ),
          ),
          // Seção de Total da Lista (Fixa na Parte Inferior)
          TotalPriceFooter(totalPrice: _totalPrice), // Usando o widget separado
        ],
      ),
    );
  }
}

// Widget Separado para o Formulário de Adição de Item
class AddItemForm extends StatelessWidget {
  final TextEditingController itemNameController;
  final GlobalKey<FormState> formKey;
  final bool isAddingItem;
  final VoidCallback onAddItem;

  const AddItemForm({
    super.key,
    required this.itemNameController,
    required this.formKey,
    required this.isAddingItem,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: TextFormField(
        controller: itemNameController,
        decoration: InputDecoration(
          labelText: 'Nome do Item',
          hintText: 'Ex: Arroz branco',
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 36, 91, 79),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
          prefixIcon: const Icon(Icons.add_shopping_cart_rounded,
            color: Color.fromARGB(255, 36, 91, 79),
          ),
          suffixIcon: isAddingItem
              ? const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : IconButton(
            icon: const FaIcon(FontAwesomeIcons.plus,
              color: Color.fromARGB(255, 36, 91, 79),
            ),
            onPressed: onAddItem,
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Por favor, insira o nome do item.';
          }
          return null;
        },
        onFieldSubmitted: (value) {
          if (formKey.currentState!.validate()) {
            onAddItem();
          }
        },
      ),
    );
  }
}

// Widget Separado para o Card de Item da Lista
class ListItemCard extends StatefulWidget { // Mudado para StatefulWidget
  final Map<String, dynamic> item;
  final Future<void> Function(String itemId, double quantity, double price, bool isComprado) onUpdateDetails;

  const ListItemCard({
    super.key,
    required this.item,
    required this.onUpdateDetails,
  });

  @override
  State<ListItemCard> createState() => _ListItemCardState();
}

class _ListItemCardState extends State<ListItemCard> {
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late bool _isComprado;
  late FocusNode _quantityFocusNode;
  late FocusNode _priceFocusNode;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: (widget.item['quantidade'] as num? ?? 0.0).toString());
    _priceController = TextEditingController(text: (widget.item['preco_unitario_registrado'] as num? ?? 0.0).toString());
    _isComprado = widget.item['comprado'] as bool? ?? false;

    _quantityFocusNode = FocusNode();
    _priceFocusNode = FocusNode();

    _quantityFocusNode.addListener(_onFocusChange);
    _priceFocusNode.addListener(_onFocusChange);
  }

  // Atualiza os controladores e o checkbox quando o item muda (via real-time)
  @override
  void didUpdateWidget(covariant ListItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item != oldWidget.item) {
      print('ListItemCard: didUpdateWidget - Item ${widget.item['nome_item_personalizado']} foi atualizado via stream. Atualizando controladores.'); // NOVO PRINT
      _quantityController.text = (widget.item['quantidade'] as num? ?? 0.0).toString();
      _priceController.text = (widget.item['preco_unitario_registrado'] as num? ?? 0.0).toString();
      _isComprado = widget.item['comprado'] as bool? ?? false;
    }
  }

  void _onFocusChange() {
    if (!mounted) return;
    if (!_quantityFocusNode.hasFocus && !_priceFocusNode.hasFocus) {
      print('ListItemCard: Focus perdido em ambos os campos. Chamando _saveDetails.'); // NOVO PRINT
      _saveDetails();
    }
  }

  void _saveDetails() {
    if (!mounted) return;

    final newQuantity = double.tryParse(_quantityController.text) ?? 0.0;
    final newPrice = double.tryParse(_priceController.text) ?? 0.0;
    final newComprado = _isComprado;

    // Só chama a atualização se houver alguma mudança real
    if (newQuantity != (widget.item['quantidade'] as num? ?? 0.0).toDouble() ||
        newPrice != (widget.item['preco_unitario_registrado'] as num? ?? 0.0).toDouble() ||
        newComprado != (widget.item['comprado'] as bool? ?? false)) {
      print('ListItemCard: Detectada mudança. Preparando para chamar onUpdateDetails para ${widget.item['nome_item_personalizado']} (ID: ${widget.item['id_item_lista']}).'); // NOVO PRINT CRÍTICO
      // CORREÇÃO AQUI: Converte o ID do item para String
      widget.onUpdateDetails(widget.item['id_item_lista'].toString(), newQuantity, newPrice, newComprado);
    } else {
      print('ListItemCard: Nenhuma mudança detectada para ${widget.item['nome_item_personalizado']}. Não salvando.'); // NOVO PRINT
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _quantityFocusNode.removeListener(_onFocusChange);
    _priceFocusNode.removeListener(_onFocusChange);
    _quantityFocusNode.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double currentQuantity = double.tryParse(_quantityController.text) ?? 0.0;
    final double currentPrice = double.tryParse(_priceController.text) ?? 0.0;
    final double total = currentQuantity * currentPrice;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _isComprado,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _isComprado = newValue ?? false;
                    });
                    _saveDetails();
                  },
                ),
                Expanded(
                  child: Text(
                    widget.item['nome_item_personalizado'] ?? 'Item Sem Nome',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      decoration: _isComprado ? TextDecoration.lineThrough : null,
                      color: _isComprado ? Color.fromARGB(255, 36, 91, 79) : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'R\$ ${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color.fromARGB(255, 36, 91, 79)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    focusNode: _quantityFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Qtd.',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 36, 91, 79)
                      ),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    ),
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (_) => _saveDetails(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    focusNode: _priceFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Preço',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 36, 91, 79)
                      ),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    ),
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (_) => _saveDetails(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Separado para o Container do Total da Lista
class TotalPriceFooter extends StatelessWidget {
  final double totalPrice;

  const TotalPriceFooter({super.key, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Color.fromARGB(255, 36, 91, 79))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total da Lista:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 36, 91, 79)
            ),
          ),
          Text(
            'R\$ ${totalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 36, 91, 79),
            ),
          ),
        ],
      ),
    );
  }
}






