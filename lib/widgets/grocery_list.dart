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
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(baseUrl, 'shopping-list.json');
    final response = await http.get(url);

    if (response.statusCode >= 400) {
      setState(() {
        _error = 'Failed to fetch data. Please try again later.';
      });
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
      _isLoading = false;
    });
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
    final url = Uri.https('baseUrl', 'shopping-list/${item.id}.json');

    try {
      final response = await http.delete(url);
      print(response.statusCode.toString());

      if (response.statusCode >= 400) {
        // Se falhou, mostra erro mas não remove da lista
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete ${item.name}. Please try again.',
              style: TextStyle(color: Colors.white),),
              backgroundColor: Colors.red.withAlpha(100),
            ),
          );
        }
        return false; // Indica que a deleção falhou
      }
      return true; // Indica que a deleção foi bem-sucedida
    } catch (e) {
      // Em caso de erro de rede
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error. Failed to delete ${item.name}.',
            style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.red.withAlpha(100),
          ),
        );
      }
      return false; // Indica que a deleção falhou
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container();

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = Center(child: Text(_error!));
    } else if (_groceryItems.isEmpty) {
      content = const Center(child: Text('No items added yet.'));
    } else {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          confirmDismiss: (direction) async {
            final item = _groceryItems[index];

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
            title: Text(_groceryItems[index].name),
            leading: Container(
              color: _groceryItems[index].category.color,
              height: 24,
              width: 24,
            ),
            trailing: Text(_groceryItems[index].quantity.toString()),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
