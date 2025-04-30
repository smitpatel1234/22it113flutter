import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardHome(),
    const MaterialsManagement(),
    const UsersManagement(),
    const ReportsAnalytics(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.signOut(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      drawer: NavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const [
          Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text('Admin Controls', style: TextStyle(fontSize: 14)),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.dashboard),
            label: Text('Dashboard'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.inventory),
            label: Text('Materials'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.people),
            label: Text('Users'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.bar_chart),
            label: Text('Reports & Analytics'),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text('Settings', style: TextStyle(fontSize: 14)),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.settings),
            label: Text('Settings'),
          ),
        ],
      ),
    );
  }
}

// Dashboard Home
class DashboardHome extends StatelessWidget {
  const DashboardHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard(
                  context,
                  title: 'Materials',
                  value: '237',
                  icon: Icons.inventory,
                  color: Colors.blue,
                ),
                _buildDashboardCard(
                  context,
                  title: 'Users',
                  value: '42',
                  icon: Icons.people,
                  color: Colors.green,
                ),
                _buildDashboardCard(
                  context,
                  title: 'Low Stock',
                  value: '18',
                  icon: Icons.warning,
                  color: Colors.orange,
                ),
                _buildDashboardCard(
                  context,
                  title: 'Today\'s Logs',
                  value: '156',
                  icon: Icons.edit_note,
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 40),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Materials Management Placeholder
class MaterialsManagement extends StatelessWidget {
  const MaterialsManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Materials Management Coming Soon'));
  }
}

// Users Management Placeholder
class UsersManagement extends StatelessWidget {
  const UsersManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Users Management Coming Soon'));
  }
}

// Reports & Analytics Placeholder
class ReportsAnalytics extends StatelessWidget {
  const ReportsAnalytics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Reports & Analytics Coming Soon'));
  }
}
