import 'package:flutter/material.dart';
import 'item.dart';
import 'service.dart';

// Add/Edit Screen
class AddEditItemScreen extends StatefulWidget {
  // TODO: Accept optional Item parameter for editing
  final Item? item;
  const AddEditItemScreen({Key? key, this.item}) : super(key: key);

  @override
  _AddEditItemScreenState createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;

  bool get isEditMode => widget.item != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _quantityController =
        TextEditingController(text: widget.item?.quantity.toString() ?? '');
    _priceController =
        TextEditingController(text: widget.item?.price.toString() ?? '');
    _categoryController =
        TextEditingController(text: widget.item?.category ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? 'Edit Item' : 'Add New Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // TODO: Add TextFormField for name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) =>
                  value == null || value.isEmpty ? 'Enter a name' : null,
              ),

              // TODO: Add TextFormField for quantity
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantity'),
                validator: (value) =>
                  value == null || value.isEmpty ? 'Enter quantity' : null,
              ),

              // TODO: Add TextFormField for price
              TextFormField(
                controller: _priceController,
                keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Price'),
                validator: (value) =>
                  value == null || value.isEmpty ? 'Enter price' : null,
              ),

              // TODO: Add TextFormField for category
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) =>
                  value == null || value.isEmpty ? 'Enter category' : null,
              ),

              const SizedBox(height: 20),

              // TODO: Create save button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final newItem = Item(
                      id: widget.item?.id,
                      name: _nameController.text,
                      quantity: int.parse(_quantityController.text),
                      price: double.parse(_priceController.text),
                      category: _categoryController.text,
                      createdAt: widget.item?.createdAt ?? DateTime.now(),
                    );

                    if (isEditMode) {
                      await _firestoreService.updateItem(newItem);
                    } else {
                      await _firestoreService.addItem(newItem);
                    }

                    Navigator.pop(context);
                  }
                },
                child: Text(isEditMode ? 'Update Item' : 'Add Item'),
              ),

              const SizedBox(height: 10),

              // TODO: Add delete button (only in edit mode)
              if (isEditMode)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    if (widget.item?.id != null) {
                      await _firestoreService.deleteItem(widget.item!.id!);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Delete Item'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}