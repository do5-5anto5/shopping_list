import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Groceries')),
      body: ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder:
            (context, index) => ListTile(
              title: Text(groceryItems[index].name),
              leading: SizedBox(
                height: 20,
                width: 20,
                child: Container(color: groceryItems[index].category.color),
              ),
              trailing: Text(groceryItems[index].quantity.toString()),
            ),
      ),
    );
  }
}
