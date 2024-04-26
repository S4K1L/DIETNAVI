import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food/Auth_gate.dart';
import 'package:food/constant.dart';
import 'package:food/home.dart';
import 'package:food/signup.dart';

import 'bottom_bar.dart';

late bool _passwordVisible;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuthService _auth = FirebaseAuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordVisible = true;
  }

  Future<void> _signIn(BuildContext context) async {
    try {
      String email = _emailController.text;
      String password = _passwordController.text;

      if(_formKey.currentState!.validate())
        {
          User? user = await _auth.signInWithEmailAndPassword(email, password);

          if(user != null)
            {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Row(
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Login Successful",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.blue,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3), // Adjust the duration as needed
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 6,
                //margin: EdgeInsets.all(20),
              ),
              );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Bottom()),
              );
            }else
              {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Email or Password Incorrect",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 3), // Adjust the duration as needed
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 6,
                  //margin: EdgeInsets.all(20),
                ),);
              }
        }
    } catch (e) {
      print("Sign-up failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Logo(context),
              const Text(
                'DIETNAVI',
                style: TextStyle(fontSize: 24, color: Colors.black),
              ),
              Login_Form(context),
            ],
          ),
        ),
      ),
    );
  }

  Padding Logo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 2.5,
        child: Image.asset(
          'assets/logo.png',
          width: 350,
          height: 350,
        ),
      ),
    );
  }

  Padding Login_Form(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Form(
            key: _formKey,
              child: Column(
            children: [
              Email_TextField(),
              const SizedBox(height: 20),
              Password_TextField(),
              const SizedBox(height: 20),
              Forget_Password(),
              const SizedBox(height: 20),
              Login_Button(context),
              const SizedBox(height: 10),
              Text_Button(context),
            ],
          )),
        ],
      ),
    );
  }

  TextButton Text_Button(BuildContext context) {
    return TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignUpPage()),
              );
            },
            child: Text(
              'Don\'t have an account? Sign up',
              style: TextStyle(color: Colors.blue, fontSize: 15),
            ),
          );
  }

  ElevatedButton Login_Button(BuildContext context) {
    return ElevatedButton(
            onPressed: () => _signIn(context),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue, // text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text(
              'Login',
              style: TextStyle(fontSize: 18),
            ),
          );
  }

  InkWell Forget_Password() {
    return InkWell(
            onTap: () {},
            child: Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "Forget Password?",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.blue,
                ),
              ),
            ),
          );
  }

  TextFormField Email_TextField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white70,
      ),
      validator: (value) {
        RegExp regExp = RegExp(emailPattern);
        if (value == null || value!.isEmpty) {
          return 'Please enter some text';
        } else if (!regExp.hasMatch(value)) {
          return 'Please enter a valid address';
        }
      },
    );
  }

  TextFormField Password_TextField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _passwordVisible,
      textAlign: TextAlign.start,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white70,
        isDense: true,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
          icon: Icon(
            _passwordVisible
                ? Icons.visibility_off_outlined
                : Icons.remove_red_eye_outlined,
          ),
        ),
      ),
      validator: (value) {
        if (value!.length < 5) {
          return 'Must be more then 5 character';
        }
      },
    );
  }
}
