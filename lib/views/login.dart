import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_constants.dart';
import '../blocs/login_bloc.dart';
import '../views/agente/agente_view.dart';
import '../main.dart'; // Para MainScreen

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (_) => LoginBloc(),
      child: const _LoginForm(),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({Key? key}) : super(key: key);

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: BlocConsumer<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is LoginSuccess) {
                if (state.user.role == "agente") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AgenteMainView()),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                  );
                }
                } else if (state is LoginFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
            },
            builder: (context, state) {
              final bloc = context.read<LoginBloc>();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo fuera del rectángulo
                  Container(
                    margin: const EdgeInsets.only(bottom: 35),
                      child: const CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.background,
                      child: Icon(
                        Icons.phone_in_talk,
                        size: 70,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(255, 35, 45, 77),
                            blurRadius: 10,
                            offset: Offset(5, 5),
                          ),
                          BoxShadow(
                            color: Color.fromARGB(255, 35, 45, 77),
                            blurRadius: 5,
                            offset: Offset(10, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Título y subtítulo
                            const Text(
                              "Iniciar Sesión",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "call center",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Campo usuario
                            TextFormField(
                          controller: _userController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El usuario es requerido';
                            }
                            return null;
                          },
                          decoration: AppInputDecorations.textField(
                            label: "Usuario",
                            icon: Icons.person_2_outlined,
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Campo contraseña con ojito
                        TextFormField(
                          controller: _passController,
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La contraseña es requerida';
                            }
                            return null;
                          },
                          decoration: AppInputDecorations.textField(
                            label: "Contraseña",
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // ¿Olvidó su contraseña?
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/recuperar');
                            },
                            child: const Text(
                              "¿Olvidó su contraseña?",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        // Botón iniciar sesión
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConfig.borderRadius,
                                ),
                              ),
                              elevation: 6,
                            ),
                            onPressed: state is LoginLoading
                                ? null
                                : () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      bloc.add(
                                        LoginSubmitted(
                                          _userController.text.trim(),
                                          _passController.text.trim(),
                                        ),
                                      );
                                    }
                                  },
                            child: state is LoginLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Iniciar sesión",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  ),
);
  }
}
