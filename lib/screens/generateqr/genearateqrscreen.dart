import 'package:flutter/material.dart';
import 'package:aims/utils/colors.dart';

class GenerateQRCodeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Generate QR Code"),
        backgroundColor: MyColors.red,
      ),
      body: Center(
        child: Text(
          "QR Code Generator",
          style: TextStyle(fontSize: 20, color: MyColors.red),
        ),
      ),
    );
  }
}
