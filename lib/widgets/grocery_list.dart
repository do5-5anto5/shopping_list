import 'package:flutter/material.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];

  void _addItem() async {
    final newItem = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => NewItem()));

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: () {
              _addItem();
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder:
            (context, index) => ListTile(
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
}
