import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60), // Adjust space from top

              // Logo
              Image.asset('assets/images/logo/logo.png', height: 200),
              const SizedBox(height: 20),
              Text("AIMS",style: GoogleFonts.roboto(color: MyColors.maroon,fontSize: 36,letterSpacing: 5),),
              const SizedBox(height: 20),

              // Email Input
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: GoogleFonts.roboto(fontSize: 18,color: MyColors.maroon),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyColors.maroon),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyColors.maroon, width: 2),
                  ),
                  prefixIcon: Icon(Icons.email, color: MyColors.maroon),
                ),
              ),
              const SizedBox(height: 10),

              // Password Input with toggle
              TextField(
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: GoogleFonts.roboto(fontSize: 18,color: MyColors.maroon),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyColors.maroon),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyColors.maroon, width: 2),
                  ),
                  prefixIcon: Icon(Icons.lock, color: MyColors.maroon),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: MyColors.maroon,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(MyColors.maroon),
                  ),
                  onPressed: () {},
                  child: const Text('Forgot Password?'),
                ),
              ),

              // Login Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  border: Border.all(color: MyColors.maroon, width: 2),
                  color: MyColors.orangeGold,
                ),
                child: TextButton(
                  onPressed: () {
                    Get.to(() => const HomeScreen());
                  },
                  child: Text(
                    'Login',
                    style: GoogleFonts.roboto(color: MyColors.maroon,fontSize: 18,),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: const Center(child: Text('Welcome to Home Screen!')),
    );
  }
}
