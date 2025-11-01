import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:simagestor_app/services/service_local_database.dart';
import 'package:simagestor_app/services/service_connection.dart';
import 'package:simagestor_app/services/service_sync.dart';
import 'package:simagestor_app/enum/model_enum.dart';
import 'package:simagestor_app/themes/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  Timer? _tokenValidationTimer;
  Timer? _dataSyncTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _validateToken();
    _startPeriodicValidation();
    _startPeriodicDataSync();
    _syncData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Sincroniza quando o app volta para o foreground
    if (state == AppLifecycleState.resumed) {
      _syncData();
    }
  }

  Future<void> _syncData() async {
    try {
      // Verifica se há conexão com internet antes de sincronizar
      final hasInternet = await ServiceConnection.hasInternetConnection();
      if (!hasInternet) {
        debugPrint('Sem conexão com internet. Sincronização adiada.');
        return;
      }

      final database = ServiceLocalDatabase.instance;
      await database.syncVeiculosEMotoristasFromAPI();
      debugPrint('Veículos e motoristas sincronizados com sucesso');
      
      // Verifica e sincroniza checklists pendentes
      final checklistsPendentes = await database.getDadosNaoSincronizados('checklist');
      if (checklistsPendentes.isNotEmpty) {
        debugPrint('Encontradas ${checklistsPendentes.length} checklists pendentes de sincronização');
        final serviceSync = ServiceSync();
        await serviceSync.syncModel(Model.checklist);
      } else {
        debugPrint('Nenhuma checklist pendente de sincronização');
      }
    } catch (e) {
      debugPrint('Erro ao sincronizar dados: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tokenValidationTimer?.cancel();
    _dataSyncTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicValidation() {
    _tokenValidationTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _validateToken();
    });
  }

  void _startPeriodicDataSync() {
    // Sincroniza dados a cada 30 minutos
    _dataSyncTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _syncData();
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
    Navigator.pushNamed(context, '/checklists');
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
