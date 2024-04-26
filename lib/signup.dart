import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food/Auth_gate.dart';
import 'package:food/constant.dart';
import 'package:food/login.dart';
import 'package:lottie/lottie.dart';

late bool _passwordVisible;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  final FirebaseAuthService _auth = FirebaseAuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _signUp() async {
    try {
      String email = _emailController.text;
      String password = _passwordController.text;

      if(_formKey.currentState!.validate())
        {
          User? user = await _auth.signUpWithEmailAndPassword(email, password);

          if(user != null)
            {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Row(
                  children: [
                    Icon(
                      Icons.accessible_forward,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Signup Successfull",
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
              ),);
              Navigator.pop(context);
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
                          "Some error found!",
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
        }// Navigate back to login page after signing up
    } catch (e) {
      print("Sign-up failed: $e");    }
  }

  @override
  void initState() {
    super.initState();
    _passwordVisible = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Logo(context),
            const Text(
              'DIETNAVI',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Form(
                    key: _formKey,
                      child: Column(
                    children: [
                      Email_TextField(),
                      const SizedBox(height: 20),
                      Password_TextField(),
                      const SizedBox(height: 20),
                      Button(),
                      const SizedBox(height: 10),
                      Text_Button(context),
                    ],
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding Logo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Container(
        height: MediaQuery.of(context).size.height / 3,
        width: MediaQuery.of(context).size.width,
        child: Lottie.asset(
          'assets/signup.json',
          width: 150,
          height: 150,
        ),
      ),
    );
  }

  TextButton Text_Button(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      },
      child: const Text(
        'Already have an account? Log in',
        style: TextStyle(color: Colors.blue),
      ),
    );
  }

  ElevatedButton Button() {
    return ElevatedButton(
      onPressed: _signUp,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue, // text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      ),
      child: const Text(
        'Sign Up',
        style: TextStyle(fontSize: 18),
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
