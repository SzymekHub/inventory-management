import 'package:flutter/material.dart';
import 'package:inventory_management_individual/api/api_service.dart';
import 'package:inventory_management_individual/pages/navigation_page.dart';
import '../main.dart'; // Import to access the global theme settings

class VinylListScreen extends StatefulWidget {
  const VinylListScreen({super.key});

  @override
  _VinylListScreenState createState() => _VinylListScreenState();
}

class _VinylListScreenState extends State<VinylListScreen> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> vinyls = [];
  bool _isLoading = true;
  String? errorMessage;

  @override
  // Initializes API calls in initState()
  void initState() {
    super.initState();
    _loadVinyls();
  }

  // Fetch vinyl records from the API
  Future<void> _loadVinyls() async {
    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await apiService.getVinyls(0, 10); // Page 0, size 10
      setState(() {
        vinyls = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading vinyls: $e');
      setState(() {
        _isLoading = false;
        errorMessage = 'Failed to load vinyl records. Please try again.';
      });

      //ScaffoldMessenger is inside a mounted check to prevent errors
      //if the widget is disposed before the async call completes
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage!),
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
        title: const Text('INVENTORY LIST',
            style: InventoryManagementApp.baseTextStyle),
        centerTitle: true, // Center the title
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: InventoryManagementApp
              .primaryBackgroundColor, // Match background color
        ),
        child: RefreshIndicator(
          onRefresh: _loadVinyls,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? _buildErrorMessage()
                  : _buildVinylList(),
        ),
      ),
    );
  }

  // Widget to display error message
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
                  foregroundColor:
                      InventoryManagementApp.primaryTextColor), // Text color
              onPressed: _loadVinyls,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display the vinyl list
  Widget _buildVinylList() {
    return ListView.builder(
      itemCount: vinyls.length,
      itemBuilder: (context, index) {
        final vinyl = vinyls[index];
        return VinylCard(vinyl: vinyl);
      },
    );
  }
}

// Extracted VinylCard widget for better structure
class VinylCard extends StatelessWidget {
  final Map<String, dynamic> vinyl;

  const VinylCard({super.key, required this.vinyl});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFA9D6BB), // Match theme color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(
            color: InventoryManagementApp.primaryTextColor, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Title: ',
                      style: InventoryManagementApp.baseTextStyle.copyWith(
                        fontSize: 22,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: vinyl['title'] ?? 'Unknown Title',
                      style: InventoryManagementApp.baseTextStyle.copyWith(
                        fontSize: 22,
                        color: Colors.black,
                        fontFamily: 'ABeeZee',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            HelpButton(),
          ],
        ),
        subtitle: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'quantity: ',
                style: InventoryManagementApp.baseTextStyle.copyWith(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: '${vinyl['stock'] ?? 'N/A'}',
                style: InventoryManagementApp.baseTextStyle.copyWith(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'ABeeZee',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const WidgetSpan(
                child: SizedBox(width: 15), // Add a small break
              ),
              TextSpan(
                text: 'Price: ',
                style: InventoryManagementApp.baseTextStyle.copyWith(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: '\$${vinyl['price']?.toStringAsFixed(2) ?? 'N/A'}',
                style: InventoryManagementApp.baseTextStyle.copyWith(
                  fontSize: 20,
                  color: Colors.black,
                  fontFamily: 'ABeeZee',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extracted HelpButton widget to keep code clean
class HelpButton extends StatelessWidget {
  const HelpButton({super.key});

  void _navigateToNavigationPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NavigationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _navigateToNavigationPage(context),
      icon: Image.asset(
        'assets/images/question.png',
        width: 35,
        height: 35,
      ),
      style: IconButton.styleFrom(
        alignment: Alignment.centerRight,
        backgroundColor:
            const Color(0x9E5273B5), // Background color of the circle
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(13), // Makes the button bigger
      ),
    );
  }
}
