import 'package:flutter/material.dart';

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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.shopping_bag_outlined),
          suffixIcon: isAddingItem
              ? const Padding(
            padding: EdgeInsets.all(10),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
              : IconButton(
            icon: const Icon(Icons.add),
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