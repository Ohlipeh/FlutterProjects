import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Necessário para o StreamSubscription

// AINDA PRECISAMOS DO app_links para que o app receba o link do sistema operacional.
import 'package:app_links/app_links.dart';
// NOVO: Importamos o supabase_flutter para acessar o listener de autenticação.
import 'package:supabase_flutter/supabase_flutter.dart';

// Importações das suas pastas e arquivos
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/pages/login_page.dart';
import 'features/home/home_page.dart';
import 'features/auth/pages/reset_password_page.dart';

class AppWidget extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const AppWidget({super.key, required this.navigatorKey});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  // Listener para o estado de autenticação do Supabase.
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Inicia a escuta por eventos de autenticação assim que o app é inicializado.
    _handleAuthEvents();
  }

  @override
  void dispose() {
    // Cancela a inscrição quando o widget é descartado para evitar vazamentos de memória.
    _authSubscription?.cancel();
    super.dispose();
  }

  /// **_handleAuthEvents**: Configura o listener que reage a eventos do Supabase Auth.
  void _handleAuthEvents() {
    // Escuta a "corrente" de eventos de autenticação do Supabase.
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;

      // Se o evento for de RECUPERAÇÃO DE SENHA...
      if (event == AuthChangeEvent.passwordRecovery) {
        // Isso significa que o Supabase processou o link com sucesso e a sessão é válida.
        // AGORA é o momento seguro para navegar para a tela de redefinição.
        widget.navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Lista de Compras',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        navigatorKey: widget.navigatorKey,
        debugShowCheckedModeBanner: false,
        home: Consumer<AuthProvider>(
          builder: (context, auth, child) {
            if (auth.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            // A lógica de exibir HomePage ou LoginPage continua a mesma.
            // O listener de auth vai cuidar do redirecionamento para o reset de senha
            // independentemente da tela que estiver sendo exibida.
            return auth.currentUser != null ? const HomePage() : const LoginPage();
          },
        ),
        routes: {
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}