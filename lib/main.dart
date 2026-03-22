import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/codes_provider.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const NamesOfLightApp());
}

class NamesOfLightApp extends StatelessWidget {
  const NamesOfLightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CodesProvider()..loadCodes(),
      child: MaterialApp(
        title: '72 Names of Light',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0A0A1A),
          cardColor: const Color(0xFF12122A),
          colorScheme: const ColorScheme.dark(
            surface: Color(0xFF0A0A1A),
            primary: Color(0xFF6B8EFF),
          ),
          fontFamily: 'NotoSansHebrew',
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
