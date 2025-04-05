
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/colors.dart';
import '../../../utils/version.dart';

import '../../utils/user_storage.dart';

import '../authentication_repository.dart';
import '../homescreen.dart';
import 'forgotpasswordscreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthenticationRepository _authRepo = AuthenticationRepository();

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Email and password cannot be empty.",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }


    try {
      UserCredential? userCredential = await _authRepo.loginWithEmailAndPassword(email, password);

      if (userCredential != null) {
        User user = userCredential.user!;
        print("✅ User logged in: ${user.uid}");

        bool isNurse = await _checkIfUserIsNurse(user);

        if (!isNurse) {
          Get.back();
          Get.snackbar("Access Denied", "This account is not registered as a nurse.",
              backgroundColor: Colors.red, colorText: Colors.white);
          await FirebaseAuth.instance.signOut();
          return;
        }

        await LocalStorage.saveUserId(user.uid);
        await LocalStorage.saveFCMToken();

        Get.back();
        Get.offAll(() => HomeScreen());
        Get.snackbar("Login Successful", "Welcome Nurse!",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.back();
        Get.snackbar("Login Failed", "Invalid credentials or user not found.",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Login Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<bool> _checkIfUserIsNurse(User user) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final role = doc.data()?['role'] ?? '';
        return role.toString().toLowerCase() == 'nurse'; // case-insensitive match
      }
      return false;
    } catch (e) {
      print("🔥 Error checking nurse role: $e");
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () => _showExitDialog(context),
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Container(
            width: double.infinity,
            height: screenHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_background/AIMS_LOGIN_BACKGROUND.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100), // ← Apply radius here
                        child: Image.asset(
                          'assets/images/logo/AIMS LOGO.jpg',
                          height: 180,
                          fit: BoxFit.cover, // Optional: ensures image fills the shape
                        ),
                      ),

                      SizedBox(height: 20),
                      Text(
                        "AIMS",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: MyColors.white,
                          fontSize: 36,
                          letterSpacing: 5,
                        ),
                      ),

                      SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        style: TextStyle(color: MyColors.white),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(fontSize: 18, color: MyColors.orange, fontWeight: FontWeight.bold),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: MyColors.orange),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: MyColors.white, width: 2),
                          ),
                          prefixIcon: Icon(Icons.email, color: MyColors.white),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        style: TextStyle(color: MyColors.white),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(fontSize: 18, color: MyColors.orange, fontWeight: FontWeight.bold),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: MyColors.orange),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: MyColors.white, width: 2),
                          ),
                          prefixIcon: Icon(Icons.lock, color: MyColors.white),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                              color: MyColors.white,
                            ),
                            onPressed: () => setState(() => _obscureText = !_obscureText),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all(MyColors.white),
                          ),
                          onPressed: () {
                            // Navigate to the Forgot Password screen
                            Get.to(ForgotPasswordScreen());
                          },
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                      Container(
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          border: Border.all(color: MyColors.red, width: 2),
                          color: MyColors.orange,
                        ),
                        child: TextButton(
                          onPressed: _login,
                          child: Text(
                            'LOG IN',
                            style: TextStyle(
                              color: MyColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                // Positioned widget for version text at the bottom
                Positioned(
                  bottom: 20,  // Ensures it’s positioned at the bottom
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20), // Adds some padding for better spacing
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Version: ${AppVersion.version} (Build: ${AppVersion.build})",
                          style: const TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Exit App",
            style: TextStyle(color: MyColors.red, fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Exit"),
          ),
        ],
      ),
    ) ??
        false;
  }
}
