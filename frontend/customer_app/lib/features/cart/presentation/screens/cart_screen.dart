import 'package:flutter/material.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Shopping Cart',
          style: TextStyle(
            color: Color(0xFF11261B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: EmptyStateWidget(
        icon: Icons.shopping_bag_outlined,
        title: 'Your Cart is Empty',
        description: 'Looks like you haven\'t added anything to your cart yet.',
        buttonText: 'Start Shopping',
        onButtonPressed: () {},
      ),
    );
  }
}
