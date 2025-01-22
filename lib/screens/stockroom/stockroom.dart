import 'package:aims/screens/stockroom/inventory_screen.dart';
import 'package:aims/screens/stockroom/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aims/utils/colors.dart';

class StockRoomScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          automaticallyImplyLeading: false,
          backgroundColor: MyColors.red,
          centerTitle: true,
          title: Text(
            "STOCK ROOM",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1), // Adjust the distance from the top
      
            // QR Scanner Container
            Center(
              child: GestureDetector(
                onTap: () {

                  Get.to(() => QRScannerScreen());
                  // Add functionality for QR Scanner
                },
                child: Column(
                  children: [
                    Container(

                      width: 180, // Button width
                      height: 180, // Button height
                      decoration: BoxDecoration(
                        border: Border.all(color: MyColors.red, width: 3),
                        color: MyColors.orange,

                      ),
                      child: Center(
                        child: Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                          size: 120, // Bigger icon for better visibility
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "QR SCANNER",
                      style: TextStyle(fontSize: 20, color: MyColors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30), // Space between buttons
      
            // Inventory Container
            Center(
              child: GestureDetector(
                onTap: () {
                  Get.to(() => InventoryScreen());
                  // Add functionality for Inventory
                },
                child: Column(
                  children: [
                    Container(
                      width: 180, // Button width
                      height: 180, // Button height
                      decoration: BoxDecoration(
                        border: Border.all(color: MyColors.red, width: 3),
                        color: MyColors.orange,

                      ),
                      child: Center(
                        child: Icon(
                          Icons.inventory,
                          color: Colors.white,
                          size: 120, // Bigger icon for better visibility
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "INVENTORY",
                      style: TextStyle(fontSize: 20, color: MyColors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: 70,
            width: 70,
            child: FloatingActionButton(

              onPressed: () {
                Get.back();
              },
              backgroundColor: MyColors.red,
              child: Icon(Icons.arrow_back, color: Colors.white,size: 30,),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
