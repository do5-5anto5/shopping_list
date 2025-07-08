import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/models/grocery_item.dart';

import '../data/categories.dart';
import '../sec/secrets.dart';
import 'new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  // var _isLoading = true;
  late Future<List<GroceryItem>> _loadedItems;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItems();
  }

  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https(baseUrl, 'shopping-list.json');

    // try {
    final response = await http.get(url);
    if (response.statusCode >= 400) {
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('Failed to fetch data. Please try again later.',
      //         style: TextStyle(color: Colors.white),),
      //       backgroundColor: Colors.red.withAlpha(100),
      //     ),
      //   );
      // }
      throw Exception('Failed to fetch data. Please try again later.');
    }

    if (response.body == 'null') {
      // setState(() {
      //   _isLoading = false;
      // });
      return [];
    }

    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category =
          categories.entries
              .firstWhere(
                (catItem) => catItem.value.title == item.value['category'],
              )
              .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }
    setState(() {
      _groceryItems = loadedItems;
      _error = 'Failed load the items. Please try again later.';
      // _isLoading = false;
    });

    return loadedItems;
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('Failed load the items. Please try again later.',
    //           style: TextStyle(color: Colors.white),),
    //         backgroundColor: Colors.red.withAlpha(100),
    //       ),
    //     );
    //
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   }
    // }
  }

  void _addItem() async {
    final newItem = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => const NewItem()));

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  Future<bool> _removeItem(GroceryItem item) async {
    final url = Uri.https(baseUrl, 'shopping-list/${item.id}.json');

    try {
      final response = await http.delete(url);
      print(response.statusCode.toString());

      if (response.statusCode >= 400) {
        // If failed, show a snack bar with an error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete ${item.name}. Please try again.',
              style: TextStyle(color: Colors.white),),
              backgroundColor: Colors.red.withAlpha(100),
            ),
          );
        }
        return false; // deletion failed
      }
      return true; // deletion succeeded
    } catch (e) {
      // network error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error. Failed to delete ${item.name}.',
            style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.red.withAlpha(100),
          ),
        );
      }
      return false; // deletion failed
    }
  }

  @override
  Widget build(BuildContext context) {
    // Widget content = Container();

    // if (_isLoading) {
    //   content = const Center(child: CircularProgressIndicator());
    // } else if (_groceryItems.isEmpty && _error == null) {
    //   content = const Center(child: Text('No items added yet.'));
    // } else if (_error != null) {
    //   content = Center(child: Text(_error!));
    // } else {
    //   content = ListView.builder(
    //     itemCount: _groceryItems.length,
    //     itemBuilder: (ctx, index) => Dismissible(
    //       key: ValueKey(_groceryItems[index].id),
    //       confirmDismiss: (direction) async {
    //         final item = _groceryItems[index];
    //
    //         // Show loading dialog
    //         showDialog(
    //           context: context,
    //           barrierDismissible: false,
    //           builder: (ctx) => const Center(
    //             child: CircularProgressIndicator(),
    //           ),
    //         );
    //
    //         final success = await _removeItem(item);
    //
    //         // Remove loading dialog
    //         if (mounted) {
    //           Navigator.of(context).pop();
    //         }
    //
    //         // If deletion was successful, remove the item from the list
    //         // else, show a snackbar with an error message
    //         return success;
    //       },
    //       child: ListTile(
    //         title: Text(_groceryItems[index].name),
    //         leading: Container(
    //           color: _groceryItems[index].category.color,
    //           height: 24,
    //           width: 24,
    //         ),
    //         trailing: Text(_groceryItems[index].quantity.toString()),
    //       ),
    //     ),
    //   );
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: FutureBuilder(future: _loadedItems, builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(snapshot.error.toString()),
          ));
        }

        if(snapshot.data!.isEmpty) {
          return const Center(child: Text('No items added yet.'));
        }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (ctx, index) => Dismissible(
              key: ValueKey(snapshot.data![index].id),
              background: Container(color: Colors.red.withAlpha(100)),
              confirmDismiss: (direction) async {
                final item = snapshot.data![index];

                // Show loading dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                final success = await _removeItem(item);

                // Remove loading dialog
                if (mounted) {
                  Navigator.of(context).pop();
                }

                // If deletion was successful, remove the item from the list
                // else, show a snackbar with an error message
                return success;
              },
              child: ListTile(
                title: Text(snapshot.data![index].name),
                leading: Container(
                  color: snapshot.data![index].category.color,
                  height: 24,
                  width: 24,
                ),
                trailing: Text(snapshot.data![index].quantity.toString()),
              ),
            ),
          );
    }),
    );
  }
}
