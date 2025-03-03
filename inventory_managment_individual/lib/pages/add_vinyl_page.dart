import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inventory_management_individual/api/api_service.dart';
import 'package:inventory_management_individual/main.dart';
import 'package:image_picker/image_picker.dart';

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

  // Artist handling
  List<Map<String, dynamic>> artists = [];
  String? selectedArtistName;
  int? selectedArtistId;
  bool isAddingNewArtist = false;

  // Form controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController artistController = TextEditingController();
  final TextEditingController newArtistNameController = TextEditingController();
  final TextEditingController newArtistBioController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  bool isReleased = false; // Default to false
  final TextEditingController descriptionController = TextEditingController();

  // Image Picker
  File? _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        debugPrint('No image selected.');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadEnums();
    _loadArtists();
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

  Future<void> _loadArtists() async {
    try {
      final data = await apiService.getArtists(
          0, 100); // Fetch all artists, adjust page size as needed
      setState(() {
        artists = data;
      });
    } catch (e) {
      // Handle error (e.g., show a snackbar)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load artists: $e'),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image and Title section
              InkWell(
                onTap: getImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white60, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _image == null
                      ? const Icon(Icons.add_a_photo, color: Colors.white60)
                      : Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 10),

              // Release Status Toggle Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Released?',
                    style: InventoryManagementApp.baseTextStyle.copyWith(
                      fontSize: 18,
                      color: Colors.white60,
                    ),
                  ),
                  Switch(
                    value: isReleased,
                    onChanged: (bool value) {
                      setState(() {
                        isReleased = value;
                      });
                    },
                    activeColor: Colors.greenAccent,
                    inactiveTrackColor: Colors.grey[700],
                    activeTrackColor: Colors.green[800],
                  ),
                ],
              ),

              // Title Field
              CustomTextField(
                controller: titleController,
                labelText: 'Title',
              ),
              const SizedBox(height: 10),

              // Artist Dropdown or Input
              if (!isAddingNewArtist)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Artist',
                        labelStyle: InventoryManagementApp.baseTextStyle
                            .copyWith(fontSize: 17, color: Colors.white60),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white60),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white60),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFFFFFFFF), width: 3),
                        ),
                      ),
                      dropdownColor: const Color.fromRGBO(40, 40, 43, 1.0),
                      style: InventoryManagementApp.baseTextStyle.copyWith(
                        fontSize: 17,
                        color: const Color(0xFFDDDDDD),
                        fontFamily: 'ABeeZee',
                      ),
                      value: selectedArtistName,
                      items: artists.map((artist) {
                        return DropdownMenuItem<String>(
                          value: artist['name'],
                          child: Text(artist['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedArtistName = value;
                          //Find the selected Artist from the dropdown
                          selectedArtistId = artists.firstWhere(
                              (artist) => artist['name'] == value)['id'];
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isAddingNewArtist = true;
                        });
                      },
                      child: const Text(
                        'Add New Artist',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      controller: newArtistNameController,
                      labelText: 'New Artist Name',
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: newArtistBioController,
                      labelText: 'New Artist Bio',
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isAddingNewArtist = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                                InventoryManagementApp.primaryTextColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: const Text('CANCEL',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                        ElevatedButton(
                          onPressed: _createNewArtist,
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                                InventoryManagementApp.primaryTextColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: const Text('CREATE',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),

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
      'artist_id': selectedArtistId,
      'stock': int.tryParse(quantityController.text) ?? 0,
      'price': double.tryParse(priceController.text) ?? 0.0,
      'vinylType': selectedVinylType,
      'speed': selectedSpeed,
      'state': selectedState,
      'color': selectedColor,
      'description': descriptionController.text,
      'isReleased': isReleased, // Add this line
    };

    try {
      // Call the addVinyl API method, passing the image if available
      final response = await apiService.addVinyl(vinylData, _image);

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

  Future<void> _createNewArtist() async {
    // Collect the data from the form
    final Map<String, dynamic> artistData = {
      'name': newArtistNameController.text,
      'bio': newArtistBioController.text,
    };

    try {
      final response = await apiService.createArtist(artistData);

      if (response.statusCode == 201) {
        // Artist created successfully
        debugPrint('Artist created successfully');

        // Show a success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Artist created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        //Reload the list of artists
        await _loadArtists();
        setState(() {
          isAddingNewArtist = false;
          selectedArtistName = newArtistNameController.text;
          newArtistNameController.clear();
          newArtistBioController.clear();
        });

        // Clear the form
        _resetForm();
      } else {
        // Failed to add artist
        debugPrint('Failed to add artist: ${response.statusCode}');

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
      debugPrint('Error adding artist: $e');

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
      isReleased = false; // Reset the isReleased state
      _image = null; // Also clear the selected image
    });
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
              fontSize: 14,
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
