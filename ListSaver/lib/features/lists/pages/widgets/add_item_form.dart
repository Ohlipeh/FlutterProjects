// Importa o pacote principal do Flutter para usar os widgets da Material Design.
import 'package:flutter/material.dart';

// Define a cor azul do Facebook como uma constante para ser reutilizada facilmente.
const Color facebookBlue = Color(0xFF1877F2);

/// AddItemForm é um widget reutilizável e estilizado para adicionar um novo item.
/// Ele é "Stateless" porque não gerencia seu próprio estado; ele recebe tudo o que precisa
/// de seu widget pai (no caso, a ListDetailPage).
class AddItemForm extends StatelessWidget {
  // Controlador para o campo de texto, para ler e limpar o texto digitado.
  final TextEditingController itemNameController;
  // Chave global para o formulário, usada para validar o campo de texto.
  final GlobalKey<FormState> formKey;
  // Flag booleana para mostrar um indicador de carregamento enquanto um item está sendo adicionado.
  final bool isAddingItem;
  // Função de callback que é chamada quando o usuário pressiona o botão de adicionar.
  final VoidCallback onAddItem;

  // Construtor do widget, que exige todos os parâmetros necessários.
  const AddItemForm({
    super.key,
    required this.itemNameController,
    required this.formKey,
    required this.isAddingItem,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    // O widget Form agrupa campos de formulário e permite a validação.
    return Form(
      key: formKey, // Associa a chave global ao formulário.
      child: TextFormField(
        controller: itemNameController, // Associa o controlador ao campo de texto.
        // Decoração e estilo do campo de entrada.
        decoration: InputDecoration(
          labelText: 'Nome do Item',
          labelStyle: const TextStyle(
            color: facebookBlue, // Cor do texto do rótulo.
          ),
          hintText: 'Ex: Arroz, Feijão, etc.',
          // Borda arredondada e moderna para o campo.
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // Estilo da borda quando o campo não está focado.
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
            ),
          ),
          // Estilo da borda quando o campo está focado (mais grossa e azul).
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: facebookBlue,
              width: 2.0,
            ),
          ),
          // Ícone no início do campo de texto.
          prefixIcon: const Icon(
            Icons.shopping_bag_outlined,
            color: facebookBlue,
          ),
          // Ícone no final do campo de texto.
          suffixIcon: isAddingItem
          // Se estiver adicionando, mostra um indicador de progresso circular.
              ? const Padding(
            padding: EdgeInsets.all(12.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: facebookBlue,
              ),
            ),
          )
          // Se não, mostra um botão de ícone para adicionar o item.
              : IconButton(
            icon: const Icon(
              Icons.add_circle,
              color: facebookBlue,
              size: 28,
            ),
            onPressed: onAddItem, // Chama a função de callback ao ser pressionado.
          ),
        ),
        // Validador que verifica se o campo de texto não está vazio.
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Por favor, insira o nome do item.';
          }
          return null; // Retorna null se a validação passar.
        },
        // Ação a ser executada quando o usuário pressiona "enter" no teclado.
        onFieldSubmitted: (value) {
          // Valida o formulário e, se for válido, chama a função para adicionar o item.
          if (formKey.currentState!.validate()) {
            onAddItem();
          }
        },
      ),
    );
  }
}