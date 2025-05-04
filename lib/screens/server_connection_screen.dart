import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../utils/user_storage.dart';
import 'database/offline/offline_database.dart';
import 'offline_controller.dart';
import 'oflline/local_server.dart';

class ConnectToOfflinePage extends StatefulWidget {

  @override
  State<ConnectToOfflinePage> createState() => _ConnectToOfflinePageState();
}

class _ConnectToOfflinePageState extends State<ConnectToOfflinePage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  final LocalServer _localServer = LocalServer();
 // Initialize Server
  List<Map<String, dynamic>> _offlineData = [];

  // ✅ Controllers for Adding and Editing Data
  final TextEditingController _storageCodeController = TextEditingController();

  final TextEditingController _serialNoController = TextEditingController();

  final TextEditingController _itemNameController = TextEditingController();

  final TextEditingController _brandController = TextEditingController();

  final TextEditingController _expirationDateController = TextEditingController();

  final TextEditingController _unitMeasurementController = TextEditingController();

  final TextEditingController _specificationController = TextEditingController();

  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOfflineData();
  }

  /// ✅ Load Offline Data from SQLite
  Future<void> _loadOfflineData() async {
    final data = await _databaseHelper.getAllData();
    setState(() {
      _offlineData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ConnectToOfflineController());

    return Scaffold(
      appBar: AppBar(
        title: Text("Offline Server Connection", style: TextStyle(color: Colors.white)),
        backgroundColor: MyColors.red,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 10),
            child: _buildIPField(controller),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
            child: _buildButton(
              icon: Icons.wifi,
              label: "Connect to Offline Database",
              color: MyColors.orange,
              onTap: controller.connectToOfflineServer,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 10),
            child: _buildButton(
              icon: Icons.add,
              label: "Add New Data",
              color: MyColors.orange,
              onTap: () => _showAddDataDialog(),
            ),
          ),
          Obx(() => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              controller.serverStatus.value,
              style: TextStyle(
                color: controller.serverStatus.value.contains("✅") ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          )),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              return controller.serverData.isEmpty
                  ? Center(child: Text("No data available."))
                  : ListView.builder(
                itemCount: controller.serverData.length,
                itemBuilder: (context, index) {
                  final entry = controller.serverData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                    child: GestureDetector(
                      onTap: () {
                        _showUseItemDialog(entry);
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(entry['itemName'] ?? "Unknown Item"),
                          subtitle: Text("Quantity: ${entry['quantity']}"),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => controller.deleteData(entry['id']),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showUseItemDialog(Map<String, dynamic> item) {
    final int id = item['id'];
    final int currentQuantity = int.tryParse(item['quantity'].toString()) ?? 0;
    final TextEditingController _quantityUsedController = TextEditingController();
    final controller = Get.find<ConnectToOfflineController>();

    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔴 Title with Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "🧰 Use Item",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: MyColors.red,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey[700]),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  Divider(),

                  // 🔹 Item Details
                  _buildInfoRow("Item Name", item['itemName']),
                  _buildInfoRow("Serial No", item['serialNo']),
                  _buildInfoRow("Brand", item['brand']),
                  _buildInfoRow("Storage Code", item['storageCode']),
                  _buildInfoRow("Expiration Date", item['expirationDate']),
                  _buildInfoRow("Unit", item['unitMeasurement']),
                  _buildInfoRow("Specification", item['specification']),
                  SizedBox(height: 10),

                  Text(
                    "Current Quantity: $currentQuantity",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: MyColors.orange,
                    ),
                  ),

                  SizedBox(height: 16),

                  _buildTextField("Quantity to Use", _quantityUsedController, isNumeric: true),

                  SizedBox(height: 20),

                  // ✅ Update Button
                  GestureDetector(
                    onTap: () async {
                      final quantityUsed = int.tryParse(_quantityUsedController.text) ?? 0;

                      if (quantityUsed <= 0) {
                        Get.snackbar("Error", "Please enter a valid quantity.",
                            backgroundColor: Colors.red, colorText: Colors.white);
                        return;
                      }

                      final newQuantity = currentQuantity - quantityUsed;

                      if (newQuantity < 0) {
                        Get.snackbar("Error", "Insufficient stock.",
                            backgroundColor: Colors.red, colorText: Colors.white);
                        return;
                      }

                      final success = await controller.updateItemQuantity(id, newQuantity);

                      if (success) {
                        await _loadOfflineData();

                        Navigator.of(context).pop();
                        Get.snackbar("Success", "Quantity updated successfully!",
                            backgroundColor: Colors.green, colorText: Colors.white);
                      } else {
                        Get.snackbar("Error", "Failed to update quantity",
                            backgroundColor: Colors.red, colorText: Colors.white);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: MyColors.red,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text("Update",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  // ❌ Cancel Button
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        "$label: $value",
        style: TextStyle(fontSize: 14),
      ),
    );
  }


  Widget _buildIPField(ConnectToOfflineController controller) {
    return TextField(
      controller: controller.serverIpController,
      decoration: InputDecoration(
        labelText: 'Enter Server IP',
        hintText: 'e.g., 192.168.1.57',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8),
            Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  /// ✅ Add New Data Dialog
  void _showAddDataDialog() {
    final controller = Get.find<ConnectToOfflineController>();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          height: 500,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔴 Custom Title Row with "X" Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Add New Data",
                    style: TextStyle(
                      color: MyColors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[700]),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),

              Divider(),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField("Storage Code", _storageCodeController),
                      _buildTextField("Serial No.", _serialNoController),
                      _buildTextField("Item Name", _itemNameController),
                      _buildTextField("Brand", _brandController),
                      _buildTextField("Expiration Date (YYYY-MM-DD)", _expirationDateController),
                      _buildTextField("Unit of Measurement", _unitMeasurementController),
                      _buildTextField("Specifications", _specificationController),
                      _buildTextField("Quantity", _quantityController, isNumeric: true),

                      SizedBox(height: 20),

                      GestureDetector(
                        onTap: () async{
                          print("running");
                          await _addNewData();
                          controller.connectToOfflineServer();

                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: MyColors.red,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text("Add Data", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),

                      SizedBox(height: 12),

                      Center(
                        child: TextButton(
                          onPressed: () => Get.back(),
                          child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// ✅ Add New Data to Offline Database
  Future<void> _addNewData() async {
    // Debug: Print form values
    print("Form Values:");
    print("Storage Code: ${_storageCodeController.text}");
    print("Serial No: ${_serialNoController.text}");
    print("Item Name: ${_itemNameController.text}");
    print("Brand: ${_brandController.text}");
    print("Exp Date: ${_expirationDateController.text}");
    print("Unit: ${_unitMeasurementController.text}");
    print("Spec: ${_specificationController.text}");
    print("Qty: ${_quantityController.text}");

    // Validate fields
    if (_storageCodeController.text.trim().isEmpty ||
        _serialNoController.text.trim().isEmpty ||
        _itemNameController.text.trim().isEmpty ||
        _brandController.text.trim().isEmpty ||
        _expirationDateController.text.trim().isEmpty ||
        _unitMeasurementController.text.trim().isEmpty ||
        _specificationController.text.trim().isEmpty ||
        _quantityController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please fill all required fields",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      final serverIp = LocalStorage.getServerIp(); // Already includes :8080
      if (serverIp == null || serverIp.isEmpty) {
        Get.snackbar("Error", "Server IP is missing. Please reconnect.",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      print("🌐 Attempting connection to: $serverIp");
      print("Adding to server");


      final newData = {
        'storageCode': _storageCodeController.text,
        'serialNo': _serialNoController.text,
        'itemName': _itemNameController.text,
        'brand': _brandController.text,
        'expirationDate': _expirationDateController.text,
        'unitMeasurement': _unitMeasurementController.text,
        'specification': _specificationController.text,
        'quantity': int.tryParse(_quantityController.text) ?? 0,
      };
      print(newData);

      final response = await http.post(
        Uri.parse('http://$serverIp:8080/items'), // ✅ Fixed: no duplicate :8080
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newData),
      ).timeout(Duration(seconds: 5));

      print("🔄 Server response: ${response.statusCode}");
      print("📦 Response body: ${response.body}");

      if (response.statusCode == 201) {
        Get.snackbar("Success", "Data saved to server!",
            backgroundColor: Colors.green, colorText: Colors.white);
        await _loadFromServer();
      } else {
        Get.snackbar("Error", "Server error: ${response.body}",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
    } on SocketException catch (e) {
      Get.snackbar("Error", "No network connection: ${e.toString()}",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    } on TimeoutException catch (e) {
      Get.snackbar("Error", "Server timeout: ${e.toString()}",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    } catch (e) {
      Get.snackbar("Error", "Unexpected error: ${e.toString()}",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    _clearFormFields();
    Get.back();
    Navigator.pop(context);
  }




  /// 🌐 Get Current Server IP Address
  Future<String> _getCurrentServerIp() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      print("⚠️ Error getting IP: $e");
    }
    return '10.0.2.2'; // Fallback for emulators
  }


  /// 🔄 Load Data from Server
  Future<void> _loadFromServer() async {
    try {
      final serverIp = await LocalStorage.getServerIp(); // Already includes :8080();
      final response = await http.get(Uri.parse('http://$serverIp/items'));

      if (response.statusCode == 200) {
        setState(() {
          _offlineData = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      }
    } catch (e) {
    }
  }


  /// ✅ Clear All Form Fields
  void _clearFormFields() {
    _storageCodeController.clear();
    _serialNoController.clear();
    _itemNameController.clear();
    _brandController.clear();
    _expirationDateController.clear();
    _unitMeasurementController.clear();
    _specificationController.clear();
    _quantityController.clear();
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade500),
              borderRadius: BorderRadius.circular(5),
            ),
            child: TextField(
              controller: controller,
              keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
