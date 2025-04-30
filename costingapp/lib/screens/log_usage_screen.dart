import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/material_model.dart';
import '../../providers/material_provider.dart';

class LogUsageScreen extends StatefulWidget {
  final MaterialModel material;

  const LogUsageScreen({Key? key, required this.material}) : super(key: key);

  @override
  State<LogUsageScreen> createState() => _LogUsageScreenState();
}

class _LogUsageScreenState extends State<LogUsageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _logUsage(MaterialProvider provider) {
    if (_formKey.currentState!.validate()) {
      // Parse quantity
      final quantity = double.parse(_quantityController.text);

      // Log usage
      provider
          .logMaterialUsage(
            materialId: widget.material.id,
            quantity: quantity,
            notes: _notesController.text,
          )
          .then((_) {
            // Check if there was an error
            if (provider.error == null) {
              // Show success and go back
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Usage logged successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Material Usage')),
      body: Consumer<MaterialProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Material info card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.material.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Current stock: ${widget.material.stockQuantity} ${widget.material.unitType}',
                            style: TextStyle(
                              color:
                                  widget.material.isLowStock
                                      ? Colors.red
                                      : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Unit cost: \$${widget.material.unitCost.toStringAsFixed(2)} per ${widget.material.unitType}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quantity field
                  TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity used (${widget.material.unitType})',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.shopping_cart),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a quantity';
                      }

                      final quantity = double.tryParse(value);
                      if (quantity == null) {
                        return 'Please enter a valid number';
                      }

                      if (quantity <= 0) {
                        return 'Quantity must be greater than zero';
                      }

                      if (quantity > widget.material.stockQuantity) {
                        return 'Not enough stock available';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Notes field
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),

                  // Total cost calculation
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Builder(
                      builder: (context) {
                        double quantity = 0;
                        try {
                          quantity = double.parse(_quantityController.text);
                        } catch (_) {}

                        final totalCost = quantity * widget.material.unitCost;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cost Summary:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total Cost: \$${totalCost.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Error message
                  if (provider.error != null)
                    Container(
                      color: Colors.red.shade100,
                      width: double.infinity,
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        provider.error!,
                        style: TextStyle(color: Colors.red.shade900),
                      ),
                    ),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          provider.isLoading ? null : () => _logUsage(provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child:
                          provider.isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Log Usage',
                                style: TextStyle(fontSize: 16),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
