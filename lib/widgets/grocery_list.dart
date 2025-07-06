import 'package:flutter/material.dart';

import 'package:shopping_list/data/dummy_items.dart';
import 'new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
    void _addItem() {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (ctx) => NewItem()));
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: () {
          _addItem();
        }, icon: Icon(Icons.add))],
      ),
      body: ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder:
            (context, index) => ListTile(
              title: Text(groceryItems[index].name),
              leading: Container(
                color: groceryItems[index].category.color,
                height: 24,
                width: 24,
              ),
              trailing: Text(groceryItems[index].quantity.toString()),
            ),
      ),
    );
  }
}
