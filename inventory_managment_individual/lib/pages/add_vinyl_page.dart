import 'package:flutter/material.dart';
import 'package:inventory_management_individual/api/api_service.dart';
import 'package:inventory_management_individual/main.dart';

class AddVinylPage extends StatefulWidget {
  const AddVinylPage({super.key});

  @override
  AddVinylPageState createState() => AddVinylPageState();
}

class AddVinylPageState extends State<AddVinylPage> {
  final ApiService apiService = ApiService();

  // State for enum values
  Map<String, List<String>> enums = {};

  // Group related dropdown selections together
  String? selectedVinylType;
  String? selectedSpeed;
  String? selectedState;
  String? selectedColor;

  // Form controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController artistController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEnums();
  }

  // Fetch enums from the API
  Future<void> _loadEnums() async {
    try {
      final fetchedEnums = await apiService.getVinylEnums();
      setState(() {
        enums = fetchedEnums;
      });
    } catch (e) {
      // Handle error (e.g., show a snackbar)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load enums: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADD VINYL',
            style: InventoryManagementApp.baseTextStyle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image and Title section
              const ImageAndTitleSection(),
              const SizedBox(height: 20),

              // Artist Field
              CustomTextField(
                controller: artistController,
                labelText: 'Artist',
              ),
              const SizedBox(height: 10),

              // Group vinylType and speed together
              Row(
                children: [
                  Expanded(
                    child: CustomDropdown(
                      labelText: 'Vinyl Type',
                      value: selectedVinylType,
                      items: enums['vinylTypes'] ?? [],
                      onChanged: (value) =>
                          setState(() => selectedVinylType = value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomDropdown(
                      labelText: 'Speed',
                      value: selectedSpeed,
                      items: enums['speeds'] ?? [],
                      onChanged: (value) =>
                          setState(() => selectedSpeed = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Group state and color together
              Row(
                children: [
                  Expanded(
                    child: CustomDropdown(
                      labelText: 'State',
                      value: selectedState,
                      items: enums['states'] ?? [],
                      onChanged: (value) =>
                          setState(() => selectedState = value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomDropdown(
                      labelText: 'Color',
                      value: selectedColor,
                      items: enums['colors'] ?? [],
                      onChanged: (value) =>
                          setState(() => selectedColor = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Quantity and Price Fields
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: quantityController,
                      labelText: 'Quantity',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: priceController,
                      labelText: 'Price',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Description Field
              CustomTextField(
                controller: descriptionController,
                labelText: 'Description',
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Action Buttons
              ActionButtonsRow(
                onCancel: () => Navigator.pop(context),
                onSave: _addVinyl,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to add a vinyl record
  Future<void> _addVinyl() async {
    // Collect the data from the form
    final Map<String, dynamic> vinylData = {
      'title': titleController.text,
      'artist': artistController.text,
      'quantity': int.tryParse(quantityController.text) ?? 0,
      'price': double.tryParse(priceController.text) ?? 0.0,
      'vinylType': selectedVinylType,
      'speed': selectedSpeed,
      'state': selectedState,
      'color': selectedColor,
      'description': descriptionController.text,
    };

    try {
      // Call the addVinyl API method
      final response = await apiService.addVinyl(vinylData);

      // Check the response status
      if (response.statusCode == 201) {
        // Vinyl added successfully
        debugPrint('Vinyl added successfully');

        // Show a success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vinyl added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Clear the form
        _resetForm();
      } else {
        // Failed to add vinyl
        debugPrint('Failed to add vinyl: ${response.statusCode}');

        // Show an error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add vinyl: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Error occurred while calling the API
      debugPrint('Error adding vinyl: $e');

      // Show an error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding vinyl: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper method to reset form fields
  void _resetForm() {
    titleController.clear();
    artistController.clear();
    quantityController.clear();
    priceController.clear();
    descriptionController.clear();
    setState(() {
      selectedVinylType = null;
      selectedSpeed = null;
      selectedState = null;
      selectedColor = null;
    });
  }
}

// Image and Title section widget
class ImageAndTitleSection extends StatelessWidget {
  const ImageAndTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white60, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.add_a_photo, color: Colors.white60),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: SizedBox(
            height: 75,
            child: CustomTextField(
              controller:
                  TextEditingController(), // This will be fixed in the implementation
              labelText: 'Title',
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Dropdown widget
class CustomDropdown extends StatelessWidget {
  final String labelText;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;

  const CustomDropdown({
    super.key,
    required this.labelText,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return items.isEmpty
        ? Text('Loading $labelText...',
            style: const TextStyle(color: Colors.white))
        : DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: InventoryManagementApp.baseTextStyle
                  .copyWith(fontSize: 17, color: Colors.white60),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white60),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white60),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFFFFFF), width: 3),
              ),
            ),
            dropdownColor: const Color.fromRGBO(40, 40, 43, 1.0),
            style: InventoryManagementApp.baseTextStyle.copyWith(
              fontSize: 17,
              color: const Color(0xFFDDDDDD),
              fontFamily: 'ABeeZee',
            ),
            value: value,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          );
  }
}

// Custom TextField widget
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: InventoryManagementApp.baseTextStyle
            .copyWith(fontSize: 17, color: Colors.white60),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white60),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white60),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFFFFFF), width: 3),
        ),
      ),
      style: InventoryManagementApp.baseTextStyle.copyWith(
        fontSize: 17,
        color: const Color(0xFFDDDDDD),
        fontFamily: 'ABeeZee',
      ),
    );
  }
}

// Action Buttons Row widget
class ActionButtonsRow extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const ActionButtonsRow({
    super.key,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Cancel Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: 150,
            height: 65,
            child: CancelButton(onPressed: onCancel),
          ),
        ),
        // Save Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: 150,
            height: 65,
            child: SaveButton(onPressed: onSave),
          ),
        ),
      ],
    );
  }
}

// Save Button widget
class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SaveButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: InventoryManagementApp.primaryTextColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      onPressed: onPressed,
      child: const Text('SAVE',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }
}

// Cancel Button widget
class CancelButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CancelButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red, // Set background color to red
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      onPressed: onPressed,
      child: const Text('CANCEL',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }
}
