import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rasid_test/Config/routes/routes_config.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData().copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      onGenerateRoute: (settings) => AppRoutes.onGenerate(settings),
    );
  }
}
