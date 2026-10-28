import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/app_state.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/home/screens/main_navigation_screen.dart';

void main() {
  runApp(const VelesbitApp());
}

class VelesbitApp extends StatefulWidget {
  const VelesbitApp({super.key});

  @override
  State<VelesbitApp> createState() => _VelesbitAppState();
}

class _VelesbitAppState extends State<VelesbitApp> {
  final AppState _appState = AppState();

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velesbit - Bisiklet Sürüş & Topluluk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: ListenableBuilder(
        listenable: _appState,
        builder: (context, child) {
          if (!_appState.isLoggedIn) {
            return AuthNavigator(appState: _appState);
          }
          return MainNavigationScreen(appState: _appState);
        },
      ),
    );
  }
}

class AuthNavigator extends StatelessWidget {
  final AppState appState;

  const AuthNavigator({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      initialEmail: appState.savedEmail,
      initialPassword: appState.savedPassword,
      initialRememberMe: appState.rememberMe,
      onLogin: (email, password, rememberMe) {
        return appState.login(email, password, rememberMe: rememberMe);
      },
      onNavigateToRegister: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterScreen(
              onRegister: ({
                required fullName,
                required email,
                required phone,
                required bloodGroup,
                required bikeTypes,
                required password,
                required confirmPassword,
              }) {
                return appState.register(
                  fullName: fullName,
                  email: email,
                  phone: phone,
                  bloodGroup: bloodGroup,
                  bikeTypes: bikeTypes,
                  password: password,
                  confirmPassword: confirmPassword,
                );
              },
            ),
          ),
        );
      },
      onNavigateToForgotPassword: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ForgotPasswordScreen(
              onResetPassword: (email) {
                return appState.forgotPassword(email);
              },
            ),
          ),
        );
      },
    );
  }
}
