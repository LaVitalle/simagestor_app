import 'package:flutter/material.dart';
import 'package:simagestor_app/screens/login_page.dart';
import 'package:simagestor_app/screens/home_page.dart';
import 'package:simagestor_app/screens/despesa/despesas_page.dart';
import 'package:simagestor_app/screens/despesa/form_despesas_page.dart';
import 'package:simagestor_app/screens/despesa/detalhes_despesa_page.dart';

void main() {
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
        '/home': (context) => const HomePage(),
        '/despesas': (context) => const DespesasPage(),
        '/form-despesas': (context) => const FormDespesasPage(),
        '/detalhes-despesa': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final idDespesa = args?['idDespesa'] as int? ?? 0;
          return DetalhesDespesaPage(idDespesa: idDespesa);
        },
      },
    );
  }
}
