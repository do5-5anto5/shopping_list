import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';

class GroceryList extends StatelessWidget {
  const GroceryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Groceries')),
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
