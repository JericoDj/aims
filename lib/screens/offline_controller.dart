import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../utils/user_storage.dart';

class ConnectToOfflineController extends GetxController {
  var serverData = <Map<String, dynamic>>[].obs; // Observable list of server data
  var isLoading = false.obs;
  var serverStatus = ''.obs;
  var isConnected = false.obs;

  // TextController to control the TextField input for the server IP address
  TextEditingController serverIpController = TextEditingController();

  // TextController to control the TextField input for the server IP address

  final TextEditingController storageCodeController = TextEditingController();
  final TextEditingController serialNoController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController expirationDateController = TextEditingController();
  final TextEditingController unitMeasurementController = TextEditingController();
  final TextEditingController specificationController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();


  void clearFormFields() {
    storageCodeController.clear();
    serialNoController.clear();
    itemNameController.clear();
    brandController.clear();
    expirationDateController.clear();
    unitMeasurementController.clear();
    specificationController.clear();
    quantityController.clear();
  }





  // function in aims update but upon entering we need to save it to local storage the ip.. okay?
  Future<bool> updateItemQuantity(int id, int newQuantity) async {
    print("🚀 Starting updateItemQuantity()");

    // ✅ Get the saved IP from local storage
    final serverIp = LocalStorage.getServerIp(); // Already includes :8080
    print('🌐 Retrieved Server IP: ${serverIp ?? "null"}');

    if (serverIp == null || serverIp.trim().isEmpty) {
      serverStatus.value = "❌ Server IP not found in local storage";
      print("❌ No server IP saved.");
      return false;
    }

    try {
      final url = 'http://$serverIp/items/$id';
      final body = jsonEncode({'quantity': newQuantity});

      print('🔄 Attempting quantity update...');
      print('📤 URL: $url');
      print('📦 Request Body: $body');

      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 5));

      print('📥 Received response:');
      print('🎚️ Status Code: ${response.statusCode}');
      print('📭 Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        serverStatus.value = "✅ Quantity updated successfully";
        await fetchData();
        return true;
      }

      final errorMessage = switch (response.statusCode) {
        400 => 'Invalid request format',
        404 => 'Item not found',
        500 => 'Server internal error',
        _ => 'Unknown error',
      };

      serverStatus.value = "❌ Update failed: $errorMessage (${response.statusCode})";
      return false;

    } catch (e, stackTrace) {
      print('💥 Unexpected error: $e');
      print('🔍 Stack trace: $stackTrace');
      serverStatus.value = "❌ Unexpected error: ${e.toString()}";
      return false;
    }
  }

  // Update data method
  Future<void> updateData(Map<String, dynamic> updatedData) async {
    final String serverUrl = "http://$updatedData['serverIp']:8080/update";

    try {
      final response = await http.put(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        serverStatus.value = "✅ Data Updated Successfully";
        await fetchData(); // Refresh data list
      } else {
        serverStatus.value = "❌ Failed to Update Data";
      }
    } catch (e) {
      serverStatus.value = "❌ Error: $e";
    }
  }





// In ConnectToOfflineController
// Change all endpoints from '/data' to '/items'

// Update connectToOfflineServer
  Future<void> connectToOfflineServer() async {
    final serverIp = serverIpController.text;
    if (serverIp.isEmpty) {
      serverStatus.value = "Please enter server IP";
      return;
    }

    isLoading.value = true;
    serverStatus.value = "Connecting...";

    try {
      final response = await http.get(
        Uri.parse('http://$serverIp:8080/items'), // Changed to /items
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {


        // Save IP locally
        await LocalStorage.saveServerIp(serverIp);

        serverData.value = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        serverStatus.value = "✅ Connected to Server";
        isConnected.value = true;
      } else {
        serverStatus.value = "❌ Server Error: ${response.statusCode}";
      }
    } on SocketException {
      serverStatus.value = "❌ Connection Failed";
    } on TimeoutException {
      serverStatus.value = "❌ Request Timeout";
    } catch (e) {
      serverStatus.value = "❌ Error: ${e.toString()}";
    } finally {
      isLoading.value = false;
    }
  }

// Update addData
  Future<void> addData(Map<String, dynamic> newData) async {
    final serverIp = serverIpController.text;
    try {
      final response = await http.post(
        Uri.parse('http://$serverIp:8080/items'), // Changed to /items
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newData),
      );

      if (response.statusCode == 201) { // Check for 201 Created
        serverStatus.value = "✅ Data Added Successfully";
        await fetchData();
      } else {
        serverStatus.value = "❌ Server Error: ${response.body}";
      }
    } catch (e) {
      serverStatus.value = "❌ Error: ${e.toString()}";
    }
  }

// Update deleteData
  Future<void> deleteData(int id) async {
    final serverIp = serverIpController.text;
    try {
      final response = await http.delete(
        Uri.parse('http://$serverIp:8080/items/$id'), // Changed to /items/$id
      );

      if (response.statusCode == 200) {
        serverStatus.value = "✅ Data Deleted";
        await fetchData();
      } else {
        serverStatus.value = "❌ Delete Failed: ${response.statusCode}";
      }
    } catch (e) {
      serverStatus.value = "❌ Error: ${e.toString()}";
    }
  }

  // Fetch data method
  Future<void> fetchData() async {
    String? serverIp = serverIpController.text; // Get the IP from the TextField

    if (serverIp.isEmpty) {
      serverStatus.value = "Please enter a server IP address.";
      return;
    }

    final String serverUrl = "http://$serverIp:8080/data"; // Use the entered IP

    isLoading.value = true;
    serverStatus.value = "Connecting..."; // Show connection attempt

    try {
      final response = await http.get(Uri.parse(serverUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        serverData.value = List<Map<String, dynamic>>.from(data);
        serverStatus.value = "✅ Connected to Server"; // Show successful connection
        isConnected.value = true; // Mark as connected
      } else {
        serverStatus.value = "❌ Failed to Connect — Status Code: ${response.statusCode}";
      }
    } catch (e) {
      serverStatus.value = "❌ Connection Error: $e"; // Show error details
    } finally {
      isLoading.value = false;
    }
  }

  // Stop Connection
  void stopConnection() {
    serverData.clear();
    serverStatus.value = "🛑 Disconnected from Server";
    isConnected.value = false;
  }
}



