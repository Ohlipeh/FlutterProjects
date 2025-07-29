import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/pages/login_page.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/home/home_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

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
        home: Consumer<AuthProvider>(
          builder: (context, auth, child) {
            if (auth.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
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