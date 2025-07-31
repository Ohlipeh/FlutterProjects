import 'package:flutter/material.dart';

// Widget para o Card de Item da Lista com edição inline.
class ListItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  // Callback para atualizar os detalhes do item no Supabase
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
  late FocusNode _quantityFocusNode; // Para detectar quando o campo perde o foco
  late FocusNode _priceFocusNode;   // Para detectar quando o campo perde o foco

  @override
  void initState() {
    super.initState();
    // Inicializa controladores com os valores atuais do item
    _quantityController = TextEditingController(text: (widget.item['quantidade'] as num? ?? 0.0).toString());
    _priceController = TextEditingController(text: (widget.item['preco_unitario_registrado'] as num? ?? 0.0).toString());
    _isComprado = widget.item['comprado'] as bool? ?? false;

    _quantityFocusNode = FocusNode();
    _priceFocusNode = FocusNode();

    // Adiciona listeners para salvar quando os campos perdem o foco
    _quantityFocusNode.addListener(_onFocusChange);
    _priceFocusNode.addListener(_onFocusChange);
  }

  // Detecta quando um dos campos de texto perde o foco para salvar
  void _onFocusChange() {
    if (!mounted) return; // Evita chamar setState se o widget já foi descartado
    // Se nenhum dos campos de texto tem foco, significa que o usuário saiu deles
    if (!_quantityFocusNode.hasFocus && !_priceFocusNode.hasFocus) {
      _saveDetails();
    }
  }

  // Salva os detalhes do item no Supabase via callback
  void _saveDetails() {
    if (!mounted) return; // Evita chamar setState se o widget já foi descartado

    final newQuantity = double.tryParse(_quantityController.text) ?? 0.0;
    final newPrice = double.tryParse(_priceController.text) ?? 0.0;
    final newComprado = _isComprado;

    // Só chama a atualização se houver alguma mudança real
    if (newQuantity != (widget.item['quantidade'] as num? ?? 0.0).toDouble() ||
        newPrice != (widget.item['preco_unitario_registrado'] as num? ?? 0.0).toDouble() ||
        newComprado != (widget.item['comprado'] as bool? ?? false)) {
      print('ListItemCard: Salvando detalhes do item: ${widget.item['nome_item_personalizado']}');
      widget.onUpdateDetails(widget.item['id_item_lista'], newQuantity, newPrice, newComprado);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _quantityFocusNode.removeListener(_onFocusChange); // Remover listener antes de descartar
    _priceFocusNode.removeListener(_onFocusChange);   // Remover listener antes de descartar
    _quantityFocusNode.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calcula o total com base nos valores ATUAIS dos controladores
    final double currentQuantity = double.tryParse(_quantityController.text) ?? 0.0;
    final double currentPrice = double.tryParse(_priceController.text) ?? 0.0;
    final double total = currentQuantity * currentPrice;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3, // Elevação um pouco maior para destaque
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Cantos mais arredondados
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Checkbox para marcar como comprado
                Checkbox(
                  value: _isComprado,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _isComprado = newValue ?? false;
                    });
                    _saveDetails(); // Salva os detalhes quando o checkbox é alterado
                  },
                ),
                Expanded(
                  child: Text(
                    widget.item['nome_item_personalizado'] ?? 'Item Sem Nome',
                    style: TextStyle(
                      fontWeight: FontWeight.w600, // Um pouco mais negrito
                      fontSize: 16,
                      decoration: _isComprado ? TextDecoration.lineThrough : null, // Risca se comprado
                      color: _isComprado ? Colors.grey : null,
                    ),
                    overflow: TextOverflow.ellipsis, // Evita que o texto transborde
                  ),
                ),
                const SizedBox(width: 16),
                // Exibe o total do item
                Text(
                  'R\$ ${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8), // Espaçamento entre o nome e os campos de valor
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    focusNode: _quantityFocusNode, // Associa o FocusNode
                    decoration: const InputDecoration(
                      labelText: 'Qtd.',
                      isDense: true, // Torna o campo mais compacto
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Ajusta o padding interno
                    ),
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (_) => _saveDetails(), // Salva ao pressionar Enter
                  ),
                ),
                const SizedBox(width: 8), // Espaçamento entre os campos de quantidade e preço
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    focusNode: _priceFocusNode, // Associa o FocusNode
                    decoration: const InputDecoration(
                      labelText: 'Preço',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    ),
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (_) => _saveDetails(), // Salva ao pressionar Enter
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

