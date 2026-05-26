import 'package:flutter/foundation.dart';

import '../repositories/users_repository.dart';
import 'app_user.dart';

class AuthModel extends ChangeNotifier {
  final UsersRepository usersRepository;

  AppUser? _currentUser;
  bool isLoading = false;
  String? errorMessage;

  AuthModel({required this.usersRepository});

  AppUser? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  bool get isAdmin => _currentUser?.role == UserRole.admin;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = await usersRepository.validateLogin(
        email: email,
        password: password,
      );

      if (user == null) {
        errorMessage = 'Email ou senha invalidos.';
        return false;
      }

      _currentUser = user;
      return true;
    } catch (_) {
      errorMessage = 'Nao foi possivel entrar. Tente novamente.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String nome,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await usersRepository.createUser(
        nome: nome,
        email: email,
        password: password,
      );
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    errorMessage = null;
    notifyListeners();
  }
}
