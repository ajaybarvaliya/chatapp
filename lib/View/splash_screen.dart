import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chatapp/Widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'Auth/login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final box = GetStorage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(
      const Duration(seconds: 3),
      () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => box.read("uid") == null
                ? const LoginScreen()
                : const HomeScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorCode.primeryColor,
      body: Center(
        child: SizedBox(
          width: 250.0,
          child: TextLiquidFill(
            text: 'Groupie',
            waveColor: Colors.white,
            boxBackgroundColor: colorCode.primeryColor,
            textStyle: const TextStyle(
              fontSize: 50.0,
              fontWeight: FontWeight.bold,
            ),
            boxHeight: 300.0,
            loadDuration: const Duration(seconds: 3),
          ),
        ),
      ),
    );
  }
}
