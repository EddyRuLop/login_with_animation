import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
//3.1 Importar  libreria para Timer
import 'dart:async';

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

  //2.1 Variable para recorrido de la mirada
  SMINumber? numLook; //0.80 en tu asset

  //--------------------- Segunda unidad----------------------------

  // 1er paso: Crear las variables para controlar la animación
  //FocusNode: Para detectar cuando se enfoca o desenfoca el campo de texto
  final emailFocus = FocusNode();
  final passFocus = FocusNode();

  //3.2 Timer para detener la mirada al dejar de teclear
  Timer? _typingDebounce;

  //4.1 Controllers
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  //4.2 Errores para mostrar en la UI
  String? emailError;
  String? passError;

  // 4.3 Validadores
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass) {
    // mínimo 8, una mayúscula, una minúscula, un dígito y un especial
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }

  //4.4 Darle acción al boton
  void _onLogin() {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    //Recalcular errores
    final eError = isValidEmail(email) ? null : "APRENDE A LEER";
    final pError = isValidPassword(pass)
        ? null
        : "Minimo 8 caracteres, 1 mayuscula, 1 minuscula, 1 numero y 1 caracter especial";

    //4.5 Para avisar que hubo un cambio
    setState(() {
      emailError = eError;
      passError = pError;
    });

    //4.6 Cerrar teclado y bajar las manos
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    isChecking?.change(false);
    isHandsUp?.change(false);
    numLook?.value = 50.0; //Mirada neutral

    //4.7 Activar triggers
    if (eError == null && pError == null) {
      trigSuccess?.fire();
    } else {
      trigFail?.fire();
    }
  }

  //2dp paso: Listeners(oyentes): Para detectar cuando se enfoca o desenfoca el campo de texto
  @override
  void initState() {
    super.initState();
    emailFocus.addListener(() {
      if (emailFocus.hasFocus) {
        //Manos abajo en email
        isHandsUp?.change(false);
        //Pas0 2.2 Mirada neutral el enfocar
        numLook?.value = 50.0;
        isHandsUp?.change(false);
      }
    });
    passFocus.addListener(() {
      //Manos arriba en password
      isHandsUp?.change(passFocus.hasFocus);
    });
  }

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
                    //2.3 Enlazar variable con la animación
                    numLook = controller!.findSMI("numLook");
                  }, //clamp
                ),
              ),

              //Espacio entre el oso y el texto
              const SizedBox(height: 10),
              //Campo de texto del email
              TextField(
                //1.3 Asignas el focusNode al campo de texto (TextField)
                //Llamas a tu familia chismosa
                focusNode: emailFocus,

                //4.8 Enlazar controller al TextField
                controller: emailCtrl,

                onChanged: (value) {
                  //Activa modo chismoso/seguimiento
                  isChecking!.change(true);
                },

                //Para que aparezca @ en moviles
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  //4.8 Mostrar el texto del error
                  errorText: emailError,
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
                //Asignas el focusNode al campo de texto (TextField)
                focusNode: passFocus,
                controller: passCtrl,
                onChanged: (value) {
                  if (isChecking != null) {
                    //No tapar los ojos al escribir email
                    // isChecking!.change(false);
                  }
                  if (isHandsUp == null) return;
                  //Activa modo chismoso/seguimiento
                  isHandsUp!.change(true);
                },
                // Se alterna según el estado
                obscureText: _obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  //4.9 Mostrar el texto del error
                  errorText: passError,
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

                  //4.10 Llamar a la función de login
                  onPressed: _onLogin,
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

  @override
  void dispose() {
    // 1.4 Limpia los focus nodes cuando el widget se elimine
    //4.11 Limpieza de los controllers
    emailCtrl.dispose();
    passCtrl.dispose();
    emailFocus.dispose();
    passFocus.dispose();
    _typingDebounce?.cancel(); //Cancelar el timer si está activo
    super.dispose();
  }
}
