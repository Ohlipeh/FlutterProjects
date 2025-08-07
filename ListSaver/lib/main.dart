import 'package:flutter/material.dart';
import 'app_widget.dart';
import 'core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SupabaseService.initialize();
    runApp(const AppWidget());
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Erro: $e')),
      ),
      debugShowCheckedModeBanner: false,
    ));
  }
}