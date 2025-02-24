import 'package:flutter/material.dart';
import 'vinyl_list_page.dart';
import '../main.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  void _navigateToVinylListPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VinylListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NAVIGATION PAGE',
            style: InventoryManagementApp.baseTextStyle),
        centerTitle: true, // Center the title
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              foregroundColor:
                  InventoryManagementApp.primaryTextColor), // Text color
          onPressed: () => _navigateToVinylListPage(context),
          child: const Text('View Inventory!'),
        ),
      ),
    );
  }
}
