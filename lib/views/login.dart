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
    final userController = TextEditingController();
    final passController = TextEditingController();

    return BlocProvider(
      create: (_) => LoginBloc(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: BlocConsumer<LoginBloc, LoginState>(
              listener: (context, state) {
                if (state is LoginSuccess) {
                  if (state.user.role == "agente") {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AgenteMainView(),
                      ),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MainScreen(),
                      ),
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
                  children: [
                    const Icon(Icons.call, size: 120, color: AppColors.primary),
                    const SizedBox(height: 30),
                    TextField(
                      controller: userController,
                      decoration: InputDecoration(
                        labelText: "Usuario",
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Contraseña",
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                        ),
                        elevation: 6,
                      ),
                      onPressed: state is LoginLoading
                          ? null
                          : () {
                              bloc.add(LoginSubmitted(
                                userController.text.trim(),
                                passController.text.trim(),
                              ));
                            },
                      child: state is LoginLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Iniciar sesión",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
