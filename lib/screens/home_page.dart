import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:simagestor_app/services/service_local_database.dart';
import 'package:simagestor_app/themes/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  Timer? _tokenValidationTimer;

  @override
  void initState() {
    super.initState();
    _validateToken();
    _startPeriodicValidation();
  }

  @override
  void dispose() {
    _tokenValidationTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicValidation() {
    _tokenValidationTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _validateToken();
    });
  }

  Future<void> _validateToken() async {
    final database = ServiceLocalDatabase.instance;
    final isValid = await database.isTokenValid();
    
    if (!isValid && mounted) {
      _tokenValidationTimer?.cancel(); // Para o timer antes de redirecionar
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void handleAbastecimento() {
    Navigator.pushNamed(context, '/fuel');
  }

  void handleDespesas() {
    debugPrint("Navegar para Controle de Despesas");
    Navigator.pushNamed(context, '/despesas');
  }

  void handleChecklist() {
    debugPrint("Navegar para Checklist do Veículo");
    // Exemplo: Navigator.pushNamed(context, '/checklist');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: handleAbastecimento,
                  child: const Text(
                    "Controle de abastecimento",
                    style: TextStyle(
                      color: AppColors.textButton,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: handleDespesas,
                  child: const Text(
                    "Controle de despesas",
                    style: TextStyle(
                      color: AppColors.textButton,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: handleChecklist,
                  child: const Text(
                    "Checklist do Veículo",
                    style: TextStyle(
                      color: AppColors.textButton,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
