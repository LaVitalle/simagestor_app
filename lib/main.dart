import 'package:flutter/material.dart';
import 'package:simagestor_app/screens/checklist/checklists_page.dart';
import 'package:simagestor_app/screens/checklist/detalhes_checklist_page.dart';
import 'package:simagestor_app/screens/checklist/form_checklist_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:simagestor_app/screens/login_page.dart';
import 'package:simagestor_app/screens/home_page.dart';
import 'package:simagestor_app/screens/fuel_pages/fuel_page.dart';
import 'package:simagestor_app/screens/fuel_pages/new_fueling_page.dart';
import 'package:simagestor_app/screens/fuel_pages/fuel_detail_page.dart';
import 'package:simagestor_app/models/fuel.dart';
import 'package:simagestor_app/screens/despesa/despesas_page.dart';
import 'package:simagestor_app/screens/despesa/form_despesas_page.dart';
import 'package:simagestor_app/screens/despesa/detalhes_despesa_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {
        '/': (context) => const LoginPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/fuel': (context) => const FuelPage(),
        '/new-fueling': (context) => const NewFuelingPage(),
        '/fuel-detail': (context) {
          final fuelRecord = ModalRoute.of(context)!.settings.arguments as FuelModel;
          return FuelDetailPage(fuelRecord: fuelRecord);
        },
        '/despesas': (context) => const DespesasPage(),
        '/form-despesas': (context) => const FormDespesasPage(),
        '/detalhes-despesa': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final idDespesa = args?['idDespesa'] as int? ?? 0;
          return DetalhesDespesaPage(idDespesa: idDespesa);
        },
        '/checklists': (context) => ChecklistPage(),
        '/detalhes-checklist': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final idChecklist = args?['idChecklist'] as int? ?? 0;
          return DetalhesChecklistPage(idChecklist: idChecklist);
        },
        '/form-checklist': (context) => FormChecklistPage(),
      },
    );
  }
}