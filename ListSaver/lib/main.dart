import 'package:flutter/material.dart';
import 'app_widget.dart';
import 'core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Inicialize o Supabase
    await SupabaseService.initialize();
    print('Conexão com Supabase inicializada com sucesso!');

    // 2. Teste simples de conexão - Listar uma tabela que existe
    final response = await SupabaseService.client
        .from('lista_compras') // Use o nome de uma tabela que você criou
        .select()
        .limit(1);

    print('Teste de consulta bem-sucedido! Resultados: ${response.length}');

    runApp(const AppWidget());
  } catch (e) {
    print('ERRO na conexão com Supabase: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Erro na conexão: ${e.toString()}'),
        ),
      ),
      debugShowCheckedModeBanner: false,
    ));
  }
}