import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listsaver/app_widget.dart';
import 'package:listsaver/core/constants/app_constants.dart';

// Cria uma chave global para o Navigator.
// Isso nos permite controlar a navegação de qualquer lugar do aplicativo,
// o que é essencial para o listener de deep links funcionar corretamente.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Garante que os componentes do Flutter estejam prontos antes de qualquer outra coisa.
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializa o Supabase diretamente, usando as suas constantes.
    // Esta é a única inicialização necessária para todo o aplicativo.
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseKey,
    );

    // Se a inicialização for bem-sucedida, inicia o widget principal do seu aplicativo.
    runApp(AppWidget(navigatorKey: navigatorKey));

  } catch (e) {
    // Se ocorrer um erro DURANTE a inicialização do Supabase,
    // o aplicativo mostrará uma tela de erro simples.
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Erro fatal na inicialização: $e'),
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
