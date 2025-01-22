import 'package:aims/screens/stockroom/stockroom.dart';
import 'package:aims/screens/treatmentarea/treatmentareascreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aims/utils/colors.dart';

import 'generateqr/genearateqrscreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool hasNotification = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: MyColors.red,
          automaticallyImplyLeading: false,
          title: Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.white, size: 28),
                onPressed: () {
                  setState(() {
                    hasNotification = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Notifications Checked")),
                  );
                },
              ),
              if (hasNotification)
                Positioned(
                  right: 11,
                  top: 12,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white
                      ),
                      color: MyColors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Logged Out")));
              },
            ),
          ],
        ),
        backgroundColor: MyColors.white,
        body: Center(
          child: Column(
            children: [
              SizedBox(height: 40),

              // Logo
              Image.asset(
                'assets/images/logo/logo.png',
                height: 200,
              ),
              SizedBox(height: 40),

              // Stock Room Button
              buildButton("STOCK ROOM", MyColors.orange, MyColors.red, () {
                Get.to(() => StockRoomScreen()); // Navigate to Stock Room
              }),

              SizedBox(height: 20),

              // Treatment Area Button
              buildButton("TREATMENT AREA", MyColors.orange, MyColors.red, () {
                Get.to(() => TreatmentAreaScreen()); // Navigate to Treatment Area
              }),

              SizedBox(height: 20),

              // Generate QR Code Button
              buildButton("GENERATE QR CODE", MyColors.orange, MyColors.red, () {
                Get.to(() => GenerateQRCodeScreen()); // Navigate to QR Code
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Custom button builder function
  Widget buildButton(String text, Color textColor, Color borderColor, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: MyColors.red,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
        child: Text(text, style: TextStyle(fontSize: 20, color: textColor,fontWeight: FontWeight.bold)),
      ),
    );
  }
}
