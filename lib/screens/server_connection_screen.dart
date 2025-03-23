import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'offline_controller.dart';

class ConnectToOfflinePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ConnectToOfflineController());

    return Scaffold(
      appBar: AppBar(
        title: Text("Connect to Offline Server"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: controller.serverIpController,
              decoration: InputDecoration(
                labelText: 'Enter Server IP',
                border: OutlineInputBorder(),
                hintText: 'e.g., 192.168.1.57',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.wifi, color: Colors.white),
              label: Text("Connect to Offline Database"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: controller.connectToOfflineServer,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.add, color: Colors.white),
              label: Text("Add Data"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _showAddDataDialog(controller),
            ),
          ),
          Obx(() => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              controller.serverStatus.value,
              style: TextStyle(
                  color: controller.serverStatus.value.contains("✅")
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold),
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
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: ListTile(
                      title: Text(entry['itemName'] ?? "Unknown Item"),
                      subtitle: Text("Quantity: ${entry['quantity']}"),
                      leading: Icon(Icons.storage, color: Colors.blue),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => controller.deleteData(entry['id']),
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

  void _showAddDataDialog(ConnectToOfflineController controller) {
    Get.defaultDialog(
      title: "Add New Data",
      content: Container(
        height: 370,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField("Storage Code", controller.storageCodeController),
              _buildTextField("Serial No.", controller.serialNoController),
              _buildTextField("Item Name", controller.itemNameController),
              _buildTextField("Brand", controller.brandController),
              _buildTextField("Expiration Date (YYYY-MM-DD)", controller.expirationDateController),
              _buildTextField("Unit of Measurement", controller.unitMeasurementController),
              _buildTextField("Specifications", controller.specificationController),
              _buildTextField("Quantity", controller.quantityController, isNumeric: true),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  onPressed: () async {
                    await _addNewData(controller);
                    Get.back();
                  },
                  child: Text("Add Data"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text("Cancel"),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _addNewData(ConnectToOfflineController controller) async {
    if (!_validateFields(controller)) {
      Get.snackbar("Error", "Please fill in all required fields.",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final newData = {
      'storageCode': controller.storageCodeController.text,
      'serialNo': controller.serialNoController.text,
      'itemName': controller.itemNameController.text,
      'brand': controller.brandController.text,
      'expirationDate': controller.expirationDateController.text,
      'unitMeasurement': controller.unitMeasurementController.text,
      'specification': controller.specificationController.text,
      'quantity': int.tryParse(controller.quantityController.text) ?? 0,
    };

    await controller.addData(newData);
    controller.clearFormFields();
  }

  bool _validateFields(ConnectToOfflineController controller) {
    return controller.storageCodeController.text.trim().isNotEmpty &&
        controller.serialNoController.text.trim().isNotEmpty &&
        controller.itemNameController.text.trim().isNotEmpty &&
        controller.brandController.text.trim().isNotEmpty &&
        controller.expirationDateController.text.trim().isNotEmpty &&
        controller.unitMeasurementController.text.trim().isNotEmpty &&
        controller.specificationController.text.trim().isNotEmpty &&
        controller.quantityController.text.trim().isNotEmpty;
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}