import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final nicknameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Criar Conta',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 36, 91, 79)
        ),
      )),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome completo',
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 36, 91, 79)
                  ),
                ),
              ),
              TextField(
                controller: nicknameController,
                decoration: const InputDecoration(labelText: 'Apelido',
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 36, 91, 79)
                  ),
                ),
              ),
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
                  await auth.signUp(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                    nome: nameController.text.trim(),
                    apelido: nicknameController.text.trim(),
                  );
                  if (auth.currentUser != null) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Cadastrar',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 36, 91, 79)
                  ),
                ),
              ),
              if (auth.errorMessage != null)
                Text(auth.errorMessage!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 36, 91, 79)
                    )),
            ],
          ),
        ),
      ),
    );
  }
}