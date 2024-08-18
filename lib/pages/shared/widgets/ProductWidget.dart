import 'package:stor/pages/cart/CartPage.dart';
import 'package:stor/pages/products/ProductDetailsPage.dart';
import 'package:stor/pages/shared/models/products_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
//import 'package:demostore/services/cart_model.dart';

class ProductWidget extends StatefulWidget {
  final Product product;
  final bool isGrid;

  const ProductWidget({
    super.key,
    required this.product,
    this.isGrid = true,
  });

  @override
  _ProductWidgetState createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  bool _isAddedToCart = false;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _checkIfAddedToCart();
  }

  Future<void> _checkIfAddedToCart() async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final cartItem = await cartModel.getCartItem(widget.product.title);
    setState(() {
      _isAddedToCart = cartItem != null;
      _quantity = cartItem?['quantity'] ?? 1;
    });
  }

  void _toggleCart() {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    setState(() {
      _isAddedToCart = !_isAddedToCart;
      if (_isAddedToCart) {
        cartModel.addItem(
            widget.product.title, _quantity, widget.product.price);
      } else {
        cartModel.removeItem(widget.product.title);
      }
    });
  }

  void _increaseQuantity() {
    setState(() {
      _quantity++;
      if (_isAddedToCart) {
        final cartModel = Provider.of<CartModel>(context, listen: false);
        cartModel.updateItemQuantity(widget.product.title, _quantity);
      }
    });
  }

  void _decreaseQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
        if (_isAddedToCart) {
          final cartModel = Provider.of<CartModel>(context, listen: false);
          cartModel.updateItemQuantity(widget.product.title, _quantity);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(product: widget.product),
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // photo
              Image.network(
                widget.product.thumbnail,
                fit: BoxFit.contain,
                height: widget.isGrid ? null : 200,
              ),

              // space
              const Spacer(),

              // title - price
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize:MainAxisSize.min ,
                children: [
                  Text(widget.product.title),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.product.price.toStringAsFixed(2)}\$',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (_isAddedToCart) ...[
                        Row(
                          mainAxisSize:MainAxisSize.min ,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              iconSize: 20,
                              onPressed: _decreaseQuantity,
                            ),
                            Text('$_quantity'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              iconSize: 20,
                              onPressed: _increaseQuantity,
                            ),
                          ],
                        ),
                      ],
                      IconButton(
                        iconSize:20,
                        icon: Icon(
                          
                          _isAddedToCart
                          
                              ? Icons.remove_shopping_cart
                              : Icons.add_shopping_cart,
                              
                        ),
                        onPressed: _toggleCart,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
