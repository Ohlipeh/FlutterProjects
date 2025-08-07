import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart'; // A única importação do Supabase necessária

// A importação do serviço antigo foi REMOVIDA
import 'package:listsaver/features/auth/providers/auth_provider.dart';
import 'package:listsaver/features/lists/pages/widgets/add_item_form.dart';

const Color facebookBlue = Color(0xFF1877F2);

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
    _setupRealtimeListener();
  }

  @override
  void dispose() {
    _itemsSubscription?.cancel();
    _itemNameController.dispose();
    super.dispose();
  }

  /// **CORRIGIDO:** Agora usa a instância correta e autenticada do Supabase.
  void _setupRealtimeListener() {
    _itemsSubscription?.cancel();
    _itemsSubscription = Supabase.instance.client
        .from('item_lista')
        .stream(primaryKey: ['id_item_lista'])
        .eq('id_lista', widget.listId)
        .order('data_adicao', ascending: true)
        .listen(
          (data) {
        if (mounted) {
          setState(() {
            _listItems = data;
            _isLoading = false;
            _calculateTotalPrice();
          });
        }
      },
      onError: (error) {
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  // O resto do arquivo continua igual, pois já estava usando a instância correta.

  double _getConvertedQuantity(double quantity, String unit) {
    switch (unit) {
      case 'g': return quantity / 1000;
      case 'ml': return quantity / 1000;
      default: return quantity;
    }
  }

  void _calculateTotalPrice() {
    double total = 0.0;
    for (var item in _listItems) {
      final quantity = (item['quantidade'] as num?)?.toDouble() ?? 0.0;
      final price = (item['preco_unitario_registrado'] as num?)?.toDouble() ?? 0.0;
      final unit = item['unidade_medida'] as String? ?? 'un';
      total += _getConvertedQuantity(quantity, unit) * price;
    }
    setState(() => _totalPrice = total);
  }

  Future<void> _addNewItem() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isAddingItem = true);
    final itemName = _itemNameController.text.trim();

    try {
      await Supabase.instance.client.from('item_lista').insert({
        'id_lista': widget.listId,
        'nome_item_personalizado': itemName,
        'quantidade': 1.0,
        'preco_unitario_registrado': 0.0,
        'comprado': false,
        'unidade_medida': 'un',
      });
      _itemNameController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      //...
    } finally {
      if (mounted) setState(() => _isAddingItem = false);
    }
  }

  Future<void> _updateItemDetails(String itemId, double quantity, double price, bool comprado, String unit) async {
    try {
      await Supabase.instance.client.from('item_lista').update({
        'quantidade': quantity,
        'preco_unitario_registrado': price,
        'comprado': comprado,
        'unidade_medida': unit,
        'data_adicao': DateTime.now().toIso8601String(),
      }).eq('id_item_lista', itemId);
    } catch (e) {
      //...
    }
  }

  // Dentro da sua classe _ListDetailPageState

  Future<void> _deleteItem(String itemId, String itemName) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Você tem certeza que deseja excluir o item "$itemName"?'),
          actions: <Widget>[
            TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(context).pop(false)),
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

    final index = _listItems.indexWhere((item) => item['id_item_lista'].toString() == itemId);
    if (index == -1) return;

    final itemToRemove = _listItems[index];

    setState(() {
      _listItems.removeAt(index);
      _calculateTotalPrice();
    });

    try {
      // **MUDANÇA PRINCIPAL AQUI**
      // Em vez de .delete(), agora chamamos a nossa função de banco de dados (RPC).
      await Supabase.instance.client.rpc(
        'delete_item', // O nome da função que criámos no Supabase.
        params: {
          // O nome do parâmetro deve ser exatamente igual ao da função SQL.
          'item_id_to_delete': int.parse(itemId)
        },
      );
      // Se não houver erro, a exclusão foi bem-sucedida.

    } catch (e) {
      // Se a função RPC der um erro (ex: permissão negada), ele será capturado aqui.
      print('ERRO AO EXECUTAR RPC delete_item: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir item. Restaurando...'), backgroundColor: Colors.red),
        );
        setState(() {
          _listItems.insert(index, itemToRemove);
          _calculateTotalPrice();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: facebookBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: facebookBlue))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: AddItemForm(
              itemNameController: _itemNameController,
              formKey: _formKey,
              isAddingItem: _isAddingItem,
              onAddItem: _addNewItem,
            ),
          ),
          Expanded(
            child: _listItems.isEmpty
                ? const Center(
              child: Text('Esta lista está vazia.\nAdicione seu primeiro item!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: _listItems.length,
              itemBuilder: (context, index) {
                final item = _listItems[index];
                return ListItemCard(
                  key: ValueKey(item['id_item_lista']),
                  item: item,
                  onUpdateDetails: _updateItemDetails,
                  onDeleteItem: () => _deleteItem(
                    item['id_item_lista'].toString(),
                    item['nome_item_personalizado'] ?? 'Item sem nome',
                  ),
                );
              },
            ),
          ),
          TotalPriceFooter(totalPrice: _totalPrice),
        ],
      ),
    );
  }
}

class ListItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final Future<void> Function(String itemId, double quantity, double price, bool isComprado, String unit) onUpdateDetails;
  final VoidCallback onDeleteItem;

  const ListItemCard({
    super.key,
    required this.item,
    required this.onUpdateDetails,
    required this.onDeleteItem,
  });

  @override
  State<ListItemCard> createState() => _ListItemCardState();
}

class _ListItemCardState extends State<ListItemCard> {
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late bool _isComprado;
  late String _selectedUnit;
  late FocusNode _quantityFocusNode;
  late FocusNode _priceFocusNode;

  final List<String> _units = ['un', 'kg', 'g', 'L', 'ml', 'dz'];

  String _formatQuantity(num quantity) {
    if (quantity == quantity.round()) {
      return quantity.round().toString();
    }
    return quantity.toString();
  }

  double _getConvertedItemQuantity(double quantity, String unit) {
    switch (unit) {
      case 'g': return quantity / 1000;
      case 'ml': return quantity / 1000;
      default: return quantity;
    }
  }

  @override
  void initState() {
    super.initState();
    final initialQuantity = (widget.item['quantidade'] as num? ?? 0.0);
    _quantityController = TextEditingController(text: _formatQuantity(initialQuantity));
    _priceController = TextEditingController(text: (widget.item['preco_unitario_registrado'] as num? ?? 0.0).toString());
    _isComprado = widget.item['comprado'] as bool? ?? false;
    _selectedUnit = widget.item['unidade_medida'] as String? ?? 'un';
    if (!_units.contains(_selectedUnit)) {
      _selectedUnit = 'un';
    }
    _quantityFocusNode = FocusNode();
    _priceFocusNode = FocusNode();
    _quantityFocusNode.addListener(_onFocusChange);
    _priceFocusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant ListItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item != oldWidget.item) {
      if (!mounted) return;
      final newQuantity = (widget.item['quantidade'] as num? ?? 0.0);
      _quantityController.text = _formatQuantity(newQuantity);
      _priceController.text = (widget.item['preco_unitario_registrado'] as num? ?? 0.0).toString();
      _isComprado = widget.item['comprado'] as bool? ?? false;
      _selectedUnit = widget.item['unidade_medida'] as String? ?? 'un';
      if (!_units.contains(_selectedUnit)) {
        _selectedUnit = 'un';
      }
    }
  }

  void _onFocusChange() {
    if (!mounted) return;
    if (!_quantityFocusNode.hasFocus && !_priceFocusNode.hasFocus) {
      _saveDetails();
    }
  }

  void _saveDetails() {
    if (!mounted) return;
    final newQuantity = double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 0.0;
    final newPrice = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;

    final originalQuantity = (widget.item['quantidade'] as num? ?? 0.0).toDouble();
    final originalPrice = (widget.item['preco_unitario_registrado'] as num? ?? 0.0).toDouble();
    final originalComprado = (widget.item['comprado'] as bool? ?? false);
    final originalUnit = widget.item['unidade_medida'] as String? ?? 'un';

    if (newQuantity != originalQuantity ||
        newPrice != originalPrice ||
        _isComprado != originalComprado ||
        _selectedUnit != originalUnit) {
      widget.onUpdateDetails(
          widget.item['id_item_lista'].toString(), newQuantity, newPrice, _isComprado, _selectedUnit);
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
    final currentQuantity = double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 0.0;
    final currentPrice = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;
    final double totalItemPrice = _getConvertedItemQuantity(currentQuantity, _selectedUnit) * currentPrice;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: _isComprado,
                  activeColor: facebookBlue,
                  onChanged: (bool? newValue) {
                    setState(() => _isComprado = newValue ?? false);
                    _saveDetails();
                  },
                ),
                Expanded(
                  child: Text(
                    widget.item['nome_item_personalizado'] ?? 'Item Sem Nome',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      decoration: _isComprado ? TextDecoration.lineThrough : null,
                      color: _isComprado ? Colors.grey.shade600 : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: widget.onDeleteItem,
                  tooltip: 'Excluir item',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  child: _buildTextField('Qtd.', _quantityController, _quantityFocusNode),
                ),
                const SizedBox(width: 8),
                _buildUnitDropdown(),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField('Preço/kg ou L', _priceController, _priceFocusNode),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      'R\$ ${totalItemPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: facebookBlue),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, FocusNode focusNode) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: facebookBlue),
        isDense: true,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: facebookBlue, width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(8))
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onFieldSubmitted: (_) => _saveDetails(),
    );
  }

  Widget _buildUnitDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade400, width: 1),
      ),
      child: DropdownButton<String>(
        value: _selectedUnit,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: facebookBlue),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedUnit = newValue;
            });
            _saveDetails();
          }
        },
        items: _units.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(fontSize: 14)),
          );
        }).toList(),
      ),
    );
  }
}

class TotalPriceFooter extends StatelessWidget {
  final double totalPrice;

  const TotalPriceFooter({super.key, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total da Lista:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            Text(
              'R\$ ${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: facebookBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}






