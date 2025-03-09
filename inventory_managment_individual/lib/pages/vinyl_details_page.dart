import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inventory_management_individual/api/api_service.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';

class VinylDetailsPage extends StatefulWidget {
  final int vinylId;

  const VinylDetailsPage({super.key, required this.vinylId});

  @override
  State<VinylDetailsPage> createState() => _VinylDetailsPageState();
}

class _VinylDetailsPageState extends State<VinylDetailsPage> {
  final ApiService apiService = ApiService();
  Map<String, dynamic>? vinylDetails;
  Map<String, dynamic>? artistDetails;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isUpdating = false;
  String? errorMessage;
  bool _isDeleting = false;

  // Controllers for editable fields
  final TextEditingController _stockController = TextEditingController();

  // For image handling
  File? _newImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadVinylDetails();
  }

  Future<void> _loadVinylDetails() async {
    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await apiService.getVinyl(widget.vinylId);
      setState(() {
        vinylDetails = data;
        _isLoading = false;
        // Initialize controllers with current values
        _stockController.text = vinylDetails!['stock']?.toString() ?? '0';
      });

      // Load artist details if artist_id is available
      if (vinylDetails != null && vinylDetails!['artist_id'] != null) {
        _loadArtistDetails(vinylDetails!['artist_id']);
      }
    } catch (e) {
      debugPrint('Error loading vinyl details: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          errorMessage = e.toString();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadArtistDetails(int artistId) async {
    try {
      final data = await apiService.getArtist(artistId);
      if (mounted) {
        setState(() {
          artistDetails = data;
        });
      }
    } catch (e) {
      debugPrint('Error loading artist details: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _newImageFile = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateVinyl() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      // Prepare updated data
      Map<String, dynamic> updatedData = Map.from(vinylDetails!);
      updatedData['stock'] = int.parse(_stockController.text);
      updatedData['artist_id'] = vinylDetails!['artist_id'];

      final response = await apiService.updateVinylWithImage(
          widget.vinylId, updatedData, _newImageFile);

      if (mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vinyl updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh vinyl details
          _loadVinylDetails();
          setState(() {
            _isEditing = false;
            _isUpdating = false;
            _newImageFile = null;
          });
        } else {
          setState(() {
            _isUpdating = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update vinyl: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating vinyl: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteVinyl() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final response = await apiService.deleteVinyl(widget.vinylId);

      if (mounted) {
        if (response.statusCode == 200) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vinyl deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to the previous screen with a result
          Navigator.of(context)
              .pop(true); // Pass true to indicate deletion occurred
        } else {
          // Show error message
          setState(() {
            _isDeleting = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete vinyl: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting vinyl: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: InventoryManagementApp.primaryBackgroundColor,
          title: Text(
            'Confirm Delete',
            style: InventoryManagementApp.baseTextStyle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this vinyl?',
            style: InventoryManagementApp.baseTextStyle,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: InventoryManagementApp.baseTextStyle.copyWith(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteVinyl();
              },
              child: Text(
                'Delete',
                style: InventoryManagementApp.baseTextStyle.copyWith(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VINYL DETAILS',
            style: InventoryManagementApp.baseTextStyle),
        centerTitle: true,
        actions: [
          if (!_isLoading && errorMessage == null)
            _isEditing
                ? IconButton(
                    icon: const Icon(Icons.save, color: Colors.green),
                    onPressed: _isUpdating ? null : _updateVinyl,
                  )
                : Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed:
                            _isDeleting ? null : _showDeleteConfirmationDialog,
                      ),
                    ],
                  ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isDeleting
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Deleting vinyl...',
                        style: InventoryManagementApp.baseTextStyle,
                      ),
                    ],
                  ),
                )
              : _isUpdating
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Updating vinyl...',
                            style: InventoryManagementApp.baseTextStyle,
                          ),
                        ],
                      ),
                    )
                  : errorMessage != null
                      ? _buildErrorMessage()
                      : _buildVinylDetails(),
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 50),
            const SizedBox(height: 10),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: InventoryManagementApp.baseTextStyle
                  .copyWith(fontSize: 20, color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  foregroundColor: InventoryManagementApp.primaryTextColor),
              onPressed: _loadVinylDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVinylDetails() {
    if (vinylDetails == null) {
      return const Center(
        child: Text(
          'No details available',
          style: TextStyle(color: Colors.white60),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title and Image section
            Text(
              vinylDetails!['title'] ?? 'Unknown Title',
              style: InventoryManagementApp.baseTextStyle.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Image if available
            _isEditing ? _buildEditableImage() : _buildDisplayImage(),
            const SizedBox(height: 20),

            // Release Status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Released:',
                  style: InventoryManagementApp.baseTextStyle.copyWith(
                    fontSize: 18,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (vinylDetails!['isReleased'] ?? false)
                        ? Colors.green[800]
                        : Colors.grey[700],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    (vinylDetails!['isReleased'] ?? false) ? 'Yes' : 'No',
                    style: InventoryManagementApp.baseTextStyle.copyWith(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Artist info styled similar to form fields
            _buildInfoField(
              'Artist',
              artistDetails != null
                  ? artistDetails!['name'] ?? 'Unknown Artist'
                  : 'Loading...',
              isEditable: false,
            ),
            const SizedBox(height: 10),

            // Group vinylType and speed together
            Row(
              children: [
                Expanded(
                  child: _buildInfoField(
                      'Vinyl Type', vinylDetails!['vinylType'] ?? 'N/A',
                      isEditable: false),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInfoField(
                      'Speed', vinylDetails!['speed'] ?? 'N/A',
                      isEditable: false),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Group state and color together
            Row(
              children: [
                Expanded(
                  child: _buildInfoField(
                      'State', vinylDetails!['state'] ?? 'N/A',
                      isEditable: false),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInfoField(
                      'Color', vinylDetails!['color'] ?? 'N/A',
                      isEditable: false),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Quantity and Price Fields
            Row(
              children: [
                Expanded(
                  child: _buildInfoField(
                      'Stock', vinylDetails!['stock']?.toString() ?? 'N/A',
                      isEditable: true, controller: _stockController),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInfoField('Price',
                      '\$${vinylDetails!['price']?.toStringAsFixed(2) ?? 'N/A'}',
                      isEditable: false),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Description Field
            if (vinylDetails!['description'] != null &&
                vinylDetails!['description'].toString().isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildInfoField('Description', vinylDetails!['description'],
                  maxLines: 4, isEditable: false),
            ],

            const SizedBox(height: 20),

            // Edit mode buttons
            if (_isEditing) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          Colors.red, // Set background color to red
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _newImageFile = null;
                        // Reset controller to original value
                        _stockController.text =
                            vinylDetails!['stock']?.toString() ?? '0';
                      });
                    },
                    child: const Text('Cancel',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: InventoryManagementApp.primaryTextColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    onPressed: _updateVinyl,
                    child: const Text('SAVE',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditableImage() {
    return Column(
      children: [
        _newImageFile != null
            ? Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white60, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _newImageFile!,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : _buildDisplayImage(),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.camera_alt),
          label: const Text('Take New Photo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            foregroundColor: InventoryManagementApp.primaryTextColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          onPressed: _pickImage,
        ),
      ],
    );
  }

  Widget _buildDisplayImage() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white60, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: vinylDetails!['imagePath'] != null &&
                vinylDetails!['imagePath'].toString().isNotEmpty
            ? Image.network(
                '${apiService.baseUrl}/vinyls/images/${vinylDetails!['imagePath']}',
                fit: BoxFit.cover,
                headers: {}, // Add any required headers here
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Image failed to load: $error');
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.white60,
                    ),
                  );
                },
              )
            : const Center(
                child: Icon(
                  Icons.album,
                  size: 50,
                  color: Colors.white60,
                ),
              ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value,
      {int maxLines = 1,
      bool isEditable = false,
      TextEditingController? controller}) {
    return TextField(
      controller: controller ?? TextEditingController(text: value),
      readOnly: !isEditable,
      maxLines: maxLines,
      keyboardType:
          label == 'Stock' ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: InventoryManagementApp.baseTextStyle
            .copyWith(fontSize: 17, color: Colors.white60),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white60),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white60),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white60),
        ),
        filled: _isEditing && isEditable,
        fillColor: _isEditing && isEditable ? const Color(0x37818181) : null,
      ),
      style: InventoryManagementApp.baseTextStyle.copyWith(
        fontSize: 17,
        color: const Color(0xFFDDDDDD),
        fontFamily: 'ABeeZee',
      ),
    );
  }

  @override
  void dispose() {
    _stockController.dispose();
    super.dispose();
  }
}
