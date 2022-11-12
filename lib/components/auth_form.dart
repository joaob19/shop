import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/auth_exception.dart';
import 'package:shop/models/auth.dart';
import 'package:shop/utils/app_routes.dart';

enum AuthMode { signUp, login }

class AuthForm extends StatefulWidget {
  const AuthForm({Key? key}) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  AuthMode _authMode = AuthMode.login;
  final _authData = <String, String>{
    'email': '',
    'password': '',
  };

  bool get _isLogin => _authMode == AuthMode.login;

  bool get _isSignUp => _authMode == AuthMode.signUp;

  void _toggleLoadingIndicator() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  void _switchAuthMode() {
    setState(() {
      _authMode = _isLogin ? AuthMode.signUp : AuthMode.login;
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        _toggleLoadingIndicator();

        _formKey.currentState?.save();
        final auth = Provider.of<Auth>(
          context,
          listen: false,
        );

        if (_isLogin) {
          await auth.login(
            _authData['email']!,
            _authData['password']!,
          );
        } else {
          await auth.signUp(
            _authData['email']!,
            _authData['password']!,
          );
        }

        if(mounted){
          Navigator.of(context).pushNamed(AppRoutes.authOrHome);
        }
      } on AuthException catch (error) {
        _showDialog(error.toString());
      } catch (error) {
        _showDialog('Ocorreu um erro inesperado.');
      } finally {
        _toggleLoadingIndicator();
      }
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ocorreu um erro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: _isLogin ? 310 : 400,
        width: deviceSize.width * 0.75,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                ),
                onSaved: (email) {
                  _authData['email'] = email ?? '';
                },
                validator: (value) {
                  final email = value ?? '';
                  if (email.trim().isEmpty || !email.contains('@')) {
                    return 'Informe um e-mail válido';
                  }

                  return null;
                },
              ),
              TextFormField(
                obscureText: true,
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                ),
                onSaved: (password) {
                  _authData['password'] = password ?? '';
                },
                validator: (value) {
                  final password = value ?? '';
                  if (password.isEmpty || password.length < 5) {
                    return 'Informe uma senha válida.';
                  }

                  return null;
                },
              ),
              if (_isSignUp)
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar senha',
                  ),
                  validator: _isLogin
                      ? null
                      : (value) {
                          final password = value ?? '';
                          if (password != _passwordController.text) {
                            return 'As senhas informadas não conferem.';
                          }

                          return null;
                        },
                ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _submit(),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        _authMode == AuthMode.login ? 'Entrar' : 'Registrar',
                      ),
                    ),
              const Spacer(),
              TextButton(
                onPressed: _switchAuthMode,
                child:
                    Text(_isLogin ? 'Deseja registrar?' : 'Já possui conta?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
