import 'package:flutter/material.dart';
import 'package:inventory_management_individual/api/api_service.dart';
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
  String? errorMessage;

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
      // Don't show an error for this, just keep the ID
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VINYL DETAILS',
            style: InventoryManagementApp.baseTextStyle),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
            if (vinylDetails!['imagePath'] != null &&
                vinylDetails!['imagePath'].toString().isNotEmpty)
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white60, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: vinylDetails!['imagePath'] != null
                      ? Image.network(
                          '${apiService.baseUrl}/vinyls/images/${vinylDetails!['imagePath']}', // Correct URL
                          fit: BoxFit.cover,
                          headers: {}, // Add any required headers here
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('Image error: $error'); // Add this to debug
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
              )
            else
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white60, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.album,
                    size: 50,
                    color: Colors.white60,
                  ),
                ),
              ),
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
            ),
            const SizedBox(height: 10),

            // Group vinylType and speed together
            Row(
              children: [
                Expanded(
                  child: _buildInfoField(
                      'Vinyl Type', vinylDetails!['vinylType'] ?? 'N/A'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child:
                      _buildInfoField('Speed', vinylDetails!['speed'] ?? 'N/A'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Group state and color together
            Row(
              children: [
                Expanded(
                  child:
                      _buildInfoField('State', vinylDetails!['state'] ?? 'N/A'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child:
                      _buildInfoField('Color', vinylDetails!['color'] ?? 'N/A'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Quantity and Price Fields
            Row(
              children: [
                Expanded(
                  child: _buildInfoField(
                      'Stock', vinylDetails!['stock']?.toString() ?? 'N/A'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInfoField('Price',
                      '\$${vinylDetails!['price']?.toStringAsFixed(2) ?? 'N/A'}'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Description Field
            if (vinylDetails!['description'] != null &&
                vinylDetails!['description'].toString().isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildInfoField('Description', vinylDetails!['description'],
                  maxLines: 4),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value, {int maxLines = 1}) {
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
      maxLines: maxLines,
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
      ),
      style: InventoryManagementApp.baseTextStyle.copyWith(
        fontSize: 17,
        color: const Color(0xFFDDDDDD),
        fontFamily: 'ABeeZee',
      ),
    );
  }
}
