import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required String title});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      //Evita notch o cámaras frontales
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
              child: RiveAnimation.asset("assets/animated_login_character.riv"))
        ],
      )),
    );
  }
}
