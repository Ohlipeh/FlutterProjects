/*import 'package:flutter/material.dart';

/// O AddItemForm é um widget de formulário focado para adicionar o nome de um item.
/// Ele é projetado para ser reutilizável e fácil de entender.
class AddItemForm extends StatelessWidget {
  /// Controlador para gerenciar o texto digitado no campo.
  final TextEditingController itemNameController;

  /// Chave global para o formulário, usada para validar os campos.
  final GlobalKey<FormState> formKey;

  /// Booleano que indica se a operação de adicionar item está em andamento.
  /// Usado para mostrar um indicador de progresso no botão.
  final bool isAddingItem;

  /// Callback para a função que adiciona um item ao banco de dados.
  /// É chamado quando o usuário clica no botão de adicionar ou pressiona Enter.
  final VoidCallback onAddItem;

  /// NOVO: Callback para a função que cancela/limpa o campo de texto.
  /// É chamado ao clicar no ícone de 'cancelar'.
  final VoidCallback? onCancel;

  const AddItemForm({
    super.key,
    required this.itemNameController,
    required this.formKey,
    required this.isAddingItem,
    required this.onAddItem,
    this.onCancel, // O callback de cancelar agora é opcional
  });

  // Cor inspirada no azul do Facebook para um design moderno e marcante.
  static const Color facebookBlue = Color(0xFF1877F2);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: TextFormField(
        controller: itemNameController,
        decoration: InputDecoration(
          labelText: 'Nome do Item',
          hintText: 'Ex: Arroz branco',
          // Estilo da borda com cantos arredondados.
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: facebookBlue),
          ),
          // Borda quando o campo está focado.
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: facebookBlue, width: 2),
          ),
          // Ícone na frente do campo de texto.
          prefixIcon: const Icon(Icons.shopping_bag_outlined, color: facebookBlue),
          // Ícone na parte de trás do campo de texto, que muda de acordo com o estado.
          suffixIcon: isAddingItem
              ? const Padding(
            padding: EdgeInsets.all(10),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: facebookBlue, // Cor do indicador de progresso.
              ),
            ),
          )
              : (itemNameController.text.isNotEmpty && onCancel != null)
              ? IconButton(
            icon: const Icon(Icons.cancel, color: Colors.grey),
            onPressed: onCancel, // Chama o callback de cancelar
          )
              : IconButton(
            icon: const Icon(Icons.add_circle, color: facebookBlue),
            onPressed: onAddItem, // Chama o callback para adicionar item
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
        // Adiciona um listener para mostrar/esconder o ícone de cancelar
        onChanged: (_) {
          // A função setState não é chamada aqui, pois este widget é StatelessWidget.
          // A mudança de ícone será tratada pelo widget pai que reconstrói este widget.
        },
      ),
    );
  }
}*/

