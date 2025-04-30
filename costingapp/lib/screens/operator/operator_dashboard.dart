import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class OperatorDashboard extends StatefulWidget {
  const OperatorDashboard({Key? key}) : super(key: key);

  @override
  State<OperatorDashboard> createState() => _OperatorDashboardState();
}

class _OperatorDashboardState extends State<OperatorDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ScanningPage(),
    const LoggingPage(),
    const TasksPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Operator Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.signOut(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          NavigationDestination(icon: Icon(Icons.edit_note), label: 'Log'),
          NavigationDestination(icon: Icon(Icons.assignment), label: 'Tasks'),
        ],
      ),
    );
  }
}

// Scanning Page
class ScanningPage extends StatelessWidget {
  const ScanningPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Camera placeholder with animation
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, double value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                size: 100,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              // Show a snackbar for demo purposes
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Scanner functionality coming soon'),
                ),
              );
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Start Scanning'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Scan material barcode or QR code',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// Logging Page
class LoggingPage extends StatelessWidget {
  const LoggingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Material Logging Page Coming Soon'));
  }
}

// Tasks Page
class TasksPage extends StatelessWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Assigned Tasks Page Coming Soon'));
  }
}
