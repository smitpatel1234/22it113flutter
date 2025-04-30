import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/material_provider.dart';
import '../../models/material_model.dart';

class MaterialsManagement extends StatefulWidget {
  const MaterialsManagement({Key? key}) : super(key: key);

  @override
  State<MaterialsManagement> createState() => _MaterialsManagementState();
}

class _MaterialsManagementState extends State<MaterialsManagement> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _unitTypeController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  final _minStockThresholdController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _unitCostController.dispose();
    _unitTypeController.dispose();
    _stockQuantityController.dispose();
    _minStockThresholdController.dispose();
    _barcodeController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MaterialProvider>(
      builder: (context, materialProvider, _) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: const Text(
                        'Materials Management',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Flexible(
                      child: Wrap(
                        spacing: 8.0,
                        children: [
                          ElevatedButton.icon(
                            onPressed:
                                materialProvider.isLoading
                                    ? null
                                    : () => materialProvider.syncWithFirebase(),
                            icon: const Icon(Icons.sync),
                            label: const Text('Sync'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed:
                                () => _showQRBatchGenerationDialog(
                                  context,
                                  materialProvider.materials,
                                ),
                            icon: const Icon(Icons.qr_code),
                            label: const Text('Generate QR Codes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showAddMaterialDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Material'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Error message
                if (materialProvider.error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Colors.red.shade100,
                    child: Text(
                      materialProvider.error!,
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),

                const SizedBox(height: 8),

                // Tab bar for All Materials and Low Stock
                DefaultTabController(
                  length: 2,
                  child: Expanded(
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(text: 'All Materials'),
                            Tab(text: 'Low Stock'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // All Materials tab
                              _buildMaterialsList(
                                context,
                                materialProvider,
                                materialProvider.materials,
                              ),

                              // Low Stock tab
                              _buildMaterialsList(
                                context,
                                materialProvider,
                                materialProvider.lowStockMaterials,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMaterialsList(
    BuildContext context,
    MaterialProvider provider,
    List<MaterialModel> materials,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (materials.isEmpty) {
      return const Center(child: Text('No materials found'));
    }

    return ListView.builder(
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final material = materials[index];
        final isLowStock = material.isLowStock;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              material.name,
              style: TextStyle(
                fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              'Stock: ${material.stockQuantity} ${material.unitType} | '
              'Cost: \$${material.unitCost.toStringAsFixed(2)} per ${material.unitType}',
            ),
            leading: CircleAvatar(
              backgroundColor: isLowStock ? Colors.red : Colors.blue,
              child: Icon(
                isLowStock ? Icons.warning : Icons.inventory,
                color: Colors.white,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // QR code button
                IconButton(
                  icon: const Icon(Icons.qr_code),
                  onPressed: () => _showQRCodeDialog(context, material),
                  color: Colors.purple,
                  tooltip: 'Generate QR Code',
                ),

                // Edit button
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditMaterialDialog(context, material),
                  color: Colors.blue,
                  tooltip: 'Edit Material',
                ),

                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed:
                      () => _showDeleteConfirmationDialog(context, material),
                  color: Colors.red,
                  tooltip: 'Delete Material',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show add material dialog
  void _showAddMaterialDialog(BuildContext context) {
    _nameController.clear();
    _unitCostController.clear();
    _unitTypeController.clear();
    _stockQuantityController.clear();
    _minStockThresholdController.clear();
    _barcodeController.clear();
    _categoryController.clear();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New Material'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Material Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _unitCostController,
                            decoration: const InputDecoration(
                              labelText: 'Unit Cost (\$)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _unitTypeController,
                            decoration: const InputDecoration(
                              labelText: 'Unit Type (kg, pc, etc)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _stockQuantityController,
                            decoration: const InputDecoration(
                              labelText: 'Stock Quantity',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _minStockThresholdController,
                            decoration: const InputDecoration(
                              labelText: 'Min Stock Threshold',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _barcodeController,
                            decoration: const InputDecoration(
                              labelText: 'Barcode',
                              border: OutlineInputBorder(),
                              helperText:
                                  'Enter a unique barcode or auto-generate',
                            ),
                            validator: (value) {
                              // Barcode can be empty as we'll auto-generate it
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final timestamp =
                                DateTime.now().millisecondsSinceEpoch
                                    .toString();
                            final randomComponent =
                                (1000 + DateTime.now().microsecond % 9000)
                                    .toString();
                            setState(() {
                              _barcodeController.text =
                                  'MTL-$timestamp-$randomComponent';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                          ),
                          child: const Text('Auto-Generate'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => _addMaterial(context),
                child: const Text('Add Material'),
              ),
            ],
          ),
    );
  }

  // Show edit material dialog
  void _showEditMaterialDialog(BuildContext context, MaterialModel material) {
    _nameController.text = material.name;
    _unitCostController.text = material.unitCost.toString();
    _unitTypeController.text = material.unitType;
    _stockQuantityController.text = material.stockQuantity.toString();
    _minStockThresholdController.text = material.minStockThreshold.toString();
    _barcodeController.text = material.barcode;
    _categoryController.text = material.category;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Material'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Material Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _unitCostController,
                            decoration: const InputDecoration(
                              labelText: 'Unit Cost (\$)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _unitTypeController,
                            decoration: const InputDecoration(
                              labelText: 'Unit Type (kg, pc, etc)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _stockQuantityController,
                            decoration: const InputDecoration(
                              labelText: 'Stock Quantity',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _minStockThresholdController,
                            decoration: const InputDecoration(
                              labelText: 'Min Stock Threshold',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(
                        labelText: 'Barcode',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a barcode';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => _updateMaterial(context, material.id),
                child: const Text('Update Material'),
              ),
            ],
          ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmationDialog(
    BuildContext context,
    MaterialModel material,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text('Are you sure you want to delete ${material.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteMaterial(context, material.id);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  // Add material
  void _addMaterial(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    // Auto-generate barcode if empty
    if (_barcodeController.text.trim().isEmpty) {
      // Generate a unique barcode based on timestamp and random component
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final randomComponent =
          (1000 + DateTime.now().microsecond % 9000).toString();
      _barcodeController.text = 'MTL-$timestamp-$randomComponent';
    }

    final material = MaterialModel(
      name: _nameController.text.trim(),
      unitCost: double.parse(_unitCostController.text),
      unitType: _unitTypeController.text.trim(),
      stockQuantity: double.parse(_stockQuantityController.text),
      minStockThreshold: double.parse(_minStockThresholdController.text),
      barcode: _barcodeController.text.trim(),
      category: _categoryController.text.trim(),
    );

    Navigator.pop(context);

    final provider = Provider.of<MaterialProvider>(context, listen: false);
    provider.addMaterial(material).then((_) {
      if (provider.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Material added successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Show the QR code for the newly added material
        if (provider.materials.isNotEmpty) {
          final newMaterial = provider.materials.firstWhere(
            (m) => m.barcode == material.barcode,
            orElse: () => material,
          );
          _showQRCodeDialog(context, newMaterial);
        }
      }
    });
  }

  // Update material
  void _updateMaterial(BuildContext context, String id) {
    if (!_formKey.currentState!.validate()) return;

    final material = MaterialModel(
      id: id,
      name: _nameController.text.trim(),
      unitCost: double.parse(_unitCostController.text),
      unitType: _unitTypeController.text.trim(),
      stockQuantity: double.parse(_stockQuantityController.text),
      minStockThreshold: double.parse(_minStockThresholdController.text),
      barcode: _barcodeController.text.trim(),
      category: _categoryController.text.trim(),
    );

    Navigator.pop(context);

    final provider = Provider.of<MaterialProvider>(context, listen: false);
    provider.updateMaterial(material).then((_) {
      if (provider.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Material updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  // Delete material
  void _deleteMaterial(BuildContext context, String id) {
    final provider = Provider.of<MaterialProvider>(context, listen: false);
    provider.deleteMaterial(id).then((_) {
      if (provider.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Material deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  // Show QR code dialog for a single material
  void _showQRCodeDialog(BuildContext context, MaterialModel material) {
    // Create a GlobalKey to capture the QR code image
    final qrKey = GlobalKey();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(material.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // QR Code with the material barcode and ID
                RepaintBoundary(
                  key: qrKey,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        QrImageView(
                          data: material.barcode,
                          version: QrVersions.auto,
                          size: 200,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          material.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'ID: ${material.id}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Barcode: ${material.barcode}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Category: ${material.category}'),
                Text('Stock: ${material.stockQuantity} ${material.unitType}'),
                Text('Unit Cost: \$${material.unitCost.toStringAsFixed(2)}'),
              ],
            ),
            actions: [
              // Print button
              TextButton.icon(
                icon: const Icon(Icons.print),
                label: const Text('Print'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Printing functionality coming soon'),
                    ),
                  );
                },
              ),
              // Save button
              TextButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save & Share'),
                onPressed: () => _saveQRCode(context, qrKey, material.name),
              ),
              // Close button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  // Show batch QR generation dialog
  void _showQRBatchGenerationDialog(
    BuildContext context,
    List<MaterialModel> materials,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Generate QR Codes'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Text('Select materials to generate QR codes:'),
                  const SizedBox(height: 16),
                  ...materials.map(
                    (material) => CheckboxListTile(
                      title: Text(material.name),
                      subtitle: Text(
                        '${material.category} - ${material.barcode}',
                      ),
                      value: false,
                      onChanged: (bool? value) {
                        // In a real app, track selected materials in a state variable
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Selected ${material.name}')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_2),
                label: const Text('Generate'),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Batch QR code generation coming soon'),
                    ),
                  );
                  // In a real app, navigate to a page showing all generated QR codes
                },
              ),
            ],
          ),
    );
  }

  // Save QR code as image
  Future<void> _saveQRCode(
    BuildContext context,
    GlobalKey qrKey,
    String materialName,
  ) async {
    try {
      // Capture the QR code widget as an image
      RenderRepaintBoundary boundary =
          qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();

        // Get temp directory
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$materialName-qr.png');
        await file.writeAsBytes(pngBytes);

        // Share the file
        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'QR Code for $materialName');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR code shared successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving QR code: $e')));
    }
  }
}
