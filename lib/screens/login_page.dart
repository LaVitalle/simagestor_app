import 'package:flutter/material.dart';
import 'package:simagestor_app/themes/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController companyController = TextEditingController();

  void handleLogin() {
    if (_formKey.currentState!.validate()) {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      String company = companyController.text.trim();

      // Aqui entra a lógica de autenticação
      debugPrint("Email: $email");
      debugPrint("Senha: $password");
      debugPrint("Empresa: $company");

      // Exemplo: navegação se válido
      // Navigator.pushNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                const Text(
                  "Simagestor",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 40),
                _buildTextField("E-mail", false, emailController, (value) {
                  if (value == null || value.isEmpty) {
                    return "Digite seu e-mail";
                  }
                  if (!value.contains("@")) {
                    return "E-mail inválido";
                  }
                  return null;
                }),
                const SizedBox(height: 15),
                _buildTextField("Senha", true, passwordController, (value) {
                  if (value == null || value.isEmpty) {
                    return "Digite sua senha";
                  }
                  if (value.length < 6) {
                    return "Senha deve ter ao menos 6 caracteres";
                  }
                  return null;
                }),
                const SizedBox(height: 15),
                _buildTextField("Empresa", false, companyController, (value) {
                  if (value == null || value.isEmpty) {
                    return "Digite o nome da empresa";
                  }
                  return null;
                }),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: handleLogin,
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: AppColors.textButton,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    bool obscure,
    TextEditingController controller,
    String? Function(String?) validator,
  ) {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.textInput,
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }
}
