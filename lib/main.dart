import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/workspace/presentation/screens/workspace_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'FlowBoard',
          theme: ThemeData(
            useMaterial3: true,
            textTheme: GoogleFonts.interTextTheme(
              Theme.of(context).textTheme,
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0079BF),
              primary: const Color(0xFF0079BF),
            ),
          ),
          home: const WorkspaceScreen(),
        );
      },
    );
  }
}
