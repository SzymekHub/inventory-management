import 'package:flutter/material.dart';
import 'pages/navigation_page.dart';
import 'websockets/websocket_service.dart'; // Import WebSocketService

void main() {
  // Connect to WebSocket, this ensures that the connection is established as soon as the app starts.
  // This is ideal because the connection is available whenever I need it, and that way I avoid the overhead of reconnecting every time I navigate to a specific screen.
  final webSocketService = WebSocketService();
  try {
    webSocketService.connect('ws://10.0.2.2:8080/ws');
  } catch (e) {
    debugPrint("Error connecting to WebSocket: $e");
  }
  runApp(const InventoryManagementApp());
}

class InventoryManagementApp extends StatelessWidget {
  const InventoryManagementApp({super.key});

  // Define primary colors for consistent theming
  static const Color primaryBackgroundColor = Color(0xFF3B4D72);
  static const Color primaryButtonColor = Color(0xFF5272B4);
  static const Color primaryTextColor = Colors.white;

  // Define a base text style for consistent font and weight
  static const TextStyle baseTextStyle = TextStyle(
    fontFamily: 'Pixelify Sans',
    color: primaryTextColor,
    fontWeight: FontWeight.w400,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Pixelify Sans', // Ensures the same font throughout the app
        scaffoldBackgroundColor:
            primaryBackgroundColor, // Global background color
        appBarTheme: AppBarTheme(
          backgroundColor: primaryBackgroundColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryButtonColor,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
              side: const BorderSide(color: primaryTextColor, width: 2),
            ),
            textStyle: baseTextStyle.copyWith(fontSize: 40),
          ),
        ),
        textTheme: TextTheme(
          bodyLarge:
              baseTextStyle.copyWith(color: primaryTextColor, fontSize: 40),
          bodyMedium: baseTextStyle.copyWith(color: primaryTextColor),
        ),
      ),
      home: const HomePage(title: 'Inventory Management'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Method to navigate to the NavigationPage
  void _navigateToNavigationPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NavigationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const LogoImage(),
            const WelcomeText(),
            const SizedBox(height: 80),
            GetManagingButton(onPressed: _navigateToNavigationPage),
          ],
        ),
      ),
    );
  }
}

// Extracted widget for the logo image
class LogoImage extends StatelessWidget {
  const LogoImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
    );
  }
}

// Extracted widget for the welcome text
class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'WELCOME TO INVENTORY MANAGEMENT',
      textAlign: TextAlign.center,
      style: InventoryManagementApp.baseTextStyle.copyWith(fontSize: 40),
    );
  }
}

// Extracted widget for the "Get Managing" button
class GetManagingButton extends StatelessWidget {
  const GetManagingButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          foregroundColor:
              InventoryManagementApp.primaryTextColor), // Text color
      onPressed: onPressed,
      child: const Text('GET MANAGING!'),
    );
  }
}
