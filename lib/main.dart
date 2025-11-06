// Import Flutter and Firestore packages
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'item.dart';
import 'service.dart';
import 'add_edit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(InventoryApp());
}

class InventoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Management App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: InventoryHomePage(title: 'Inventory Home Page'),
    );
  }
}

class InventoryHomePage extends StatefulWidget {
  InventoryHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _InventoryHomePageState createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  // TODO: 1. Initialize Firestore & Create a Stream for items
  final FirestoreService _firestoreService = FirestoreService();

  String _searchQuery = '';
  String _selectedCategory = 'All';

  bool _bulkMode = false;
  Set<String> _selectedItemIds = {};

  // TODO: 2. Build a ListView using a StreamBuilder to display items
  // TODO: 3. Implement Navigation to an "Add Item" screen
  // TODO: 4. Implement one of the Delete methods (swipe or in-edit)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // Bulk toggle
          IconButton(
            icon: Icon(_bulkMode ? Icons.close : Icons.select_all),
            tooltip: _bulkMode ? 'Exit Bulk Mode' : 'Select Multiple',
            onPressed: () {
              setState(() {
                _bulkMode = !_bulkMode;
                _selectedItemIds.clear();
              });
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Inventory Management System'),
            // TODO: Replace this Text widget with your StreamBuilder & ListView

            const SizedBox(height: 10),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search items by name...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),

            const SizedBox(height: 10),

            // Category Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: StreamBuilder<List<Item>>(
                stream: _firestoreService.getItemsStream(),
                builder: (context, snapshot) {
                  final allItems = snapshot.data ?? [];
                  final categories = [
                    'All',
                    ...{for (var item in allItems) item.category}
                  ];

                  return DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Category',
                      border: OutlineInputBorder(),
                    ),
                    items: categories
                        .map((cat) =>
                            DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<List<Item>>(
                stream: _firestoreService.getItemsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No items found.');
                  }

                  // Filtering
                  var items = snapshot.data!;

                  if (_searchQuery.isNotEmpty) {
                    items = items
                        .where((item) =>
                            item.name.toLowerCase().contains(_searchQuery))
                        .toList();
                  }

                  if (_selectedCategory != 'All') {
                    items = items
                        .where((item) => item.category == _selectedCategory)
                        .toList();
                  }

                  if (items.isEmpty) {
                    return const Text('No matching items found.');
                  }

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = _selectedItemIds.contains(item.id);
                      return Dismissible(
                        key: Key(item.id ?? index.toString()),
                        direction: _bulkMode
                          ? DismissDirection.none
                          : DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) async {
                          if (!_bulkMode && item.id != null) {
                            await _firestoreService.deleteItem(item.id!);
                          }
                        },
                        child: ListTile(
                          leading: _bulkMode
                            ? Checkbox(
                                value: isSelected,
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      _selectedItemIds.add(item.id!);
                                    } else {
                                      _selectedItemIds.remove(item.id);
                                    }
                                  });
                                },
                              )
                            : null,
                          title: Text(item.name),
                          subtitle: Text(
                            'Qty: ${item.quantity}, \$${item.price.toStringAsFixed(2)}'),
                          trailing: Text(item.category),
                          onTap: _bulkMode
                            ? () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedItemIds.remove(item.id);
                                  } else {
                                    _selectedItemIds.add(item.id!);
                                  }
                                });
                              }
                            : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                builder: (context) => AddEditItemScreen(item: item),
                                    ),
                                  );
                                },
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Bulk Action Bar
            if (_bulkMode && _selectedItemIds.isNotEmpty)
              Container(
                color: Colors.blue.shade50,
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete Selected'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
                      onPressed: () async {
                        for (var id in _selectedItemIds) {
                          await _firestoreService.deleteItem(id);
                        }
                        setState(() {
                          _selectedItemIds.clear();
                        });
                      },
                    ),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Bulk Update Category'),
                      onPressed: () async {
                        final newCategory = await _showCategoryDialog(context);
                        if (newCategory != null && newCategory.isNotEmpty) {
                          for (var id in _selectedItemIds) {
                            await FirebaseFirestore.instance
                              .collection('items')
                              .doc(id)
                              .update({'category': newCategory});
                          }
                          setState(() {
                            _selectedItemIds.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to the Add/Edit Item Form
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditItemScreen(),
            ),
          );
        },
        tooltip: 'Add Item',
        child: Icon(Icons.add),
      ),
    );
  }

  // Bulk category update
  Future<String?> _showCategoryDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter new category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Category name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),

          TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
  }
}
