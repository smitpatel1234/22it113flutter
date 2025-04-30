import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/material_model.dart';
import '../../../providers/material_provider.dart';
import '../log_usage_screen.dart';

class MaterialScanningScreen extends StatefulWidget {
  const MaterialScanningScreen({Key? key}) : super(key: key);

  @override
  State<MaterialScanningScreen> createState() => _MaterialScanningScreenState();
}

class _MaterialScanningScreenState extends State<MaterialScanningScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animation for scan button
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MaterialProvider>(
      builder: (context, materialProvider, _) {
        final scannedMaterial = materialProvider.scannedMaterial;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Scan Materials'),
            actions: [
              IconButton(
                icon: const Icon(Icons.sync),
                onPressed:
                    materialProvider.isLoading
                        ? null
                        : () => materialProvider.syncWithFirebase(),
                tooltip: 'Sync with server',
              ),
            ],
          ),
          body: Column(
            children: [
              // Error message
              if (materialProvider.error != null)
                Container(
                  color: Colors.red.shade100,
                  width: double.infinity,
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    materialProvider.error!,
                    style: TextStyle(color: Colors.red.shade900),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Main content
              Expanded(
                child: Center(
                  child:
                      scannedMaterial == null
                          ? _buildScanView(materialProvider)
                          : _buildMaterialDetails(
                            context,
                            materialProvider,
                            scannedMaterial,
                          ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build the scan view
  Widget _buildScanView(MaterialProvider materialProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Camera animation
        AnimatedBuilder(
          animation: _scanAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scanAnimation.value,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  size: 100,
                  color: Colors.blue,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),

        // Scan button
        SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton.icon(
            onPressed:
                materialProvider.isLoading
                    ? null
                    : () => materialProvider.scanAndFetchMaterial(),
            icon: const Icon(Icons.camera_alt),
            label:
                materialProvider.isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text('Scan Barcode'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Scan a barcode to view material details',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // Build material details view
  Widget _buildMaterialDetails(
    BuildContext context,
    MaterialProvider materialProvider,
    MaterialModel material,
  ) {
    final isLowStock = material.stockQuantity <= material.minStockThreshold;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Material name
          Text(
            material.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Barcode
          Row(
            children: [
              const Icon(Icons.qr_code, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Barcode: ${material.barcode}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Material details card
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  const Text(
                    'Category:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(material.category),
                  const SizedBox(height: 16),

                  // Unit cost
                  const Text(
                    'Unit Cost:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '\$${material.unitCost.toStringAsFixed(2)} per ${material.unitType}',
                  ),
                  const SizedBox(height: 16),

                  // Stock quantity
                  const Text(
                    'Stock Quantity:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Row(
                    children: [
                      Text(
                        '${material.stockQuantity} ${material.unitType}',
                        style: TextStyle(
                          color: isLowStock ? Colors.red : Colors.black,
                          fontWeight:
                              isLowStock ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (isLowStock) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Low Stock!',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Last updated
                  const Text(
                    'Last Updated:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '${material.lastUpdated.day}/${material.lastUpdated.month}/${material.lastUpdated.year} at ${material.lastUpdated.hour}:${material.lastUpdated.minute.toString().padLeft(2, '0')}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LogUsageScreen(material: material),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Log Usage'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    materialProvider.clearScannedMaterial();
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
