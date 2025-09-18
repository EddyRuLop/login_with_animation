import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required String title});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controla si la contraseña se oculta o se muestra
  bool _obscurePassword = true;

  //Cerebro de la lógica de animaciones
  StateMachineController? controller;
  //State Machine Input
  SMIBool? isChecking; //Sigue lo que escribes
  SMIBool? isHandsUp; //Se tapa los ojos
  SMITrigger? trigSuccess; // Animación de éxito
  SMITrigger? trigFail; // Animación de fracaso

  @override
  Widget build(BuildContext context) {
    //Para obtener el tamaño del dispositivo
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      //Evita notch o cámaras frontales
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  "assets/animated_login_character.riv",
                  stateMachines: ["Login Machine"],
                  //Al iniciar la animación
                  onInit: (artboard) {
                    controller = StateMachineController.fromArtboard(
                        artboard, "Login Machine");

                    //Verificar que inicio bien
                    if (controller == null) return;
                    artboard.addController(controller!);
                    isChecking = controller!.findSMI("isChecking");
                    isHandsUp = controller!.findSMI("isHandsUp");
                    trigSuccess = controller!.findSMI("trigSuccess");
                    trigFail = controller!.findSMI("trigFail");
                  },
                ),
              ),
              //Espacio entre el oso y el texto

              const SizedBox(height: 10),
              //Campo de texto del email
              TextField(
                onChanged: (value) {
                  if (isHandsUp != null) {
                    //No tapar los ojos al escribir email
                    isHandsUp!.change(false);
                  }
                  if (isChecking == null) return;
                  //Activa modo chismoso/seguimiento
                  isChecking!.change(true);
                },

                //Para que aparezca @ en moviles
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    //Esquinas redondeadas
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              //Espacio entre los campos
              const SizedBox(height: 10),

              //Campo de texto de contraseña con ojito
              TextField(
                onChanged: (value) {
                  if (isChecking != null) {
                    //No tapar los ojos al escribir email
                    isChecking!.change(false);
                  }
                  if (isHandsUp == null) return;
                  //Activa modo chismoso/seguimiento
                  isHandsUp!.change(true);
                },
                // Se alterna según el estado
                obscureText: _obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    //Esquinas redondeadas
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                  width: size.width,
                  child: const Text("Forgot Password?",
                      //Alinear a la derecha
                      textAlign: TextAlign.right,
                      style: TextStyle(decoration: TextDecoration.underline))),

              //Boton de de login
              const SizedBox(height: 10),
              //boton estilo android
              MaterialButton(
                  minWidth: size.width,
                  height: 50,
                  color: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onPressed: () {
                    //TODO:
                  },
                  child: const Text("Login",
                      style: TextStyle(color: Colors.white))),
              const SizedBox(height: 10),
              SizedBox(
                width: size.width,
                child: Row(
                  children: [
                    const Text("Don 't have an account?"),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          color: Colors.black,
                          //en negritas
                          fontWeight: FontWeight.bold,
                          //Subrayado
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
