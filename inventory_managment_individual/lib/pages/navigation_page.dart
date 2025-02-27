import 'package:flutter/material.dart';
import 'package:inventory_management_individual/pages/add_vinyl_page.dart';
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

  void _navigateToAddVinylPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddVinylPage()),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  foregroundColor:
                      InventoryManagementApp.primaryTextColor), // Text color
              onPressed: () => _navigateToVinylListPage(context),
              child: const Text('View Inventory!'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  foregroundColor:
                      InventoryManagementApp.primaryTextColor), // Text color
              onPressed: () => _navigateToAddVinylPage(context),
              child: const Text('Add a new vinyl!'),
            ),
          ],
        ),
      ),
    );
  }
}
