import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/home_page.dart';
import '../providers/auth_provider.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 🔰 LOGO no topo
                Image.asset(
                  'imagem/logo_login1.png',
                  width: 180,
                  height: 180,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email',
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 36, 91, 79)
                    ),
                  ),
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha',
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 36, 91, 79)
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: auth.isLoading
                      ? null
                      : () async {
                    await auth.signIn(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );
                    if (auth.currentUser != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    }
                  },
                  child: const Text('Entrar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 36, 91, 79)
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SignupPage()));
                  },
                  child: const Text('Criar conta',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 36, 91, 79),
                    ),
                  )
                ),
                if (auth.errorMessage != null)
                  Text(auth.errorMessage!,
                      style: const TextStyle(color: Color.fromARGB(255, 36, 91, 79))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}