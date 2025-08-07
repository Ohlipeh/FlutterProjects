import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// **AuthProvider** gerencia todo o estado de autenticação do usuário no aplicativo.
/// Ele usa o `ChangeNotifier` para notificar os widgets quando o estado (como o usuário logado) muda.
class AuthProvider extends ChangeNotifier {
  User? currentUser;
  String? apelido;
  bool isLoading = false;
  String? errorMessage;

  /// **NOVO: Construtor do AuthProvider**
  /// Este código é executado assim que o provider é criado.
  AuthProvider() {
    // Inicia a sincronização com o estado de autenticação do Supabase.
    _initialize();
  }

  /// **NOVO: Método de Inicialização**
  /// Garante que o provider sempre saiba quem está logado.
  void _initialize() {
    // Primeiro, verifica se já existe uma sessão ativa quando o app abre.
    final initialSession = Supabase.instance.client.auth.currentSession;
    if (initialSession != null) {
      currentUser = initialSession.user;
      // Carrega o perfil do usuário se ele já estiver logado.
      _loadUserProfile(currentUser!.id);
    }

    // Depois, cria um "listener" que reage a QUALQUER mudança no estado de autenticação.
    // Isso inclui login, logout, recuperação de senha, etc.
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final Session? session = data.session;
      // Se a sessão não for nula, significa que um usuário está logado.
      if (session != null) {
        currentUser = session.user;
        // Carrega o perfil sempre que o usuário mudar.
        _loadUserProfile(currentUser!.id);
      } else {
        // Se a sessão for nula, significa que o usuário fez logout.
        currentUser = null;
        apelido = null;
      }
      // Notifica todos os widgets que estão ouvindo que o estado de autenticação mudou.
      notifyListeners();
    });
  }

  /// **NOVO: Método Auxiliar para Carregar o Perfil**
  /// Centraliza a lógica de buscar o apelido do usuário para evitar repetição de código.
  Future<void> _loadUserProfile(String userId) async {
    try {
      final perfil = await Supabase.instance.client
          .from('perfil_usuario')
          .select('apelido')
          .eq('id_usuario', userId)
          .single();
      apelido = perfil['apelido'];
    } catch (e) {
      // Se houver um erro (ex: perfil ainda não criado), apenas registra no console.
      print("Erro ao carregar perfil do usuário: $e");
      apelido = null;
    }
    // Notifica a UI com o novo apelido.
    notifyListeners();
  }

  /// **signUp**: Registra um novo usuário.
  Future<void> signUp({
    required String email,
    required String password,
    required String nome,
    required String apelido,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user != null) {
        await Supabase.instance.client.from('perfil_usuario').insert({
          'id_usuario': user.id,
          'nome_usuario': nome,
          'apelido': apelido,
          'data_criacao': DateTime.now().toIso8601String(),
        });
        // O listener onAuthStateChange já vai cuidar de atualizar o currentUser e o apelido.
      }
    } on AuthException catch (e) {
      errorMessage = 'Erro ao registrar: ${e.message}';
    } catch (e) {
      errorMessage = 'Erro ao registrar: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// **signIn**: Autentica um usuário existente.
  Future<void> signIn(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // O listener onAuthStateChange já vai cuidar de atualizar o currentUser e o apelido.
    } on AuthException catch (e) {
      errorMessage = 'Erro ao entrar: ${e.message}';
    } catch (e) {
      errorMessage = 'Erro ao entrar: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// **resetPassword**: Envia o e-mail de redefinição de senha.
  Future<void> resetPassword(String email) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      errorMessage = 'Erro ao enviar email: ${e.message}';
    } catch (e) {
      errorMessage = 'Ocorreu um erro inesperado. Tente novamente.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// **signOut**: Desconecta o usuário do aplicativo.
  Future<void> signOut() async {
    // Apenas chama a função de signOut.
    // O listener onAuthStateChange vai detectar a mudança e limpar o currentUser e o apelido automaticamente.
    await Supabase.instance.client.auth.signOut();
  }
}