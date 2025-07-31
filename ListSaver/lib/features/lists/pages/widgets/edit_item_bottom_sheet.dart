/*import 'package:flutter/material.dart';

typedef UpdateItemCallback = Future<void> Function(
    String itemId,
    double quantity,
    double price,
    bool comprado,
    );

class EditItemBottomSheet extends StatefulWidget {
  final Map<String, dynamic> item;
  final UpdateItemCallback onUpdate;

  const EditItemBottomSheet({
    super.key,
    required this.item,
    required this.onUpdate,
  });

  @override
  State<EditItemBottomSheet> createState() => _EditItemBottomSheetState();
}

class _EditItemBottomSheetState extends State<EditItemBottomSheet> {
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late bool _isComprado;
  final GlobalKey<FormState> _editFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
        text: (widget.item['quantidade'] as num? ?? 0).toString());
    _priceController = TextEditingController(
        text: (widget.item['preco_unitario_registrado'] as num? ?? 0).toString());
    _isComprado = widget.item['comprado'] as bool? ?? false;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24.0,
        left: 24.0,
        right: 24.0,
      ),
      child: Form(
        key: _editFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Editar: ${widget.item['nome_item_personalizado']}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade',
                      prefixIcon: Icon(Icons.format_list_numbered),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final parsed = double.tryParse(value ?? '');
                      if (parsed == null || parsed < 0) {
                        return 'Quantidade inválida';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Preço Unitário',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final parsed = double.tryParse(value ?? '');
                      if (parsed == null || parsed < 0) {
                        return 'Preço inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Comprado'),
              value: _isComprado,
              onChanged: (bool? newValue) {
                setState(() {
                  _isComprado = newValue ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_editFormKey.currentState!.validate()) {
                      await widget.onUpdate(
                        widget.item['id_item_lista'],
                        double.parse(_quantityController.text),
                        double.parse(_priceController.text),
                        _isComprado,
                      );
                      Navigator.of(context).pop(); // Só fecha após salvar
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
} */
