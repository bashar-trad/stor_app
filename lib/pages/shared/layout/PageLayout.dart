import 'package:stor/pages/shared/widgets/Drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../cart/CartPage.dart';

class PageLayout extends StatefulWidget {
  final String title;
  final Widget body;
  const PageLayout(
      {super.key, required this.title, required, required this.body});

  @override
  State<PageLayout> createState() => _PageLayoutState();
}

class _PageLayoutState extends State<PageLayout> {
  void _navigateToAccountPage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      Navigator.pushNamed(context, '/account');
    } else {
      Navigator.pushNamed(context, '/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Consumer<CartModel>(
            builder: (context, cart, child) {
              return cart.count > 0 ?
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () async {
                      Navigator.pushNamed(context, '/order');
                    },
                  ),
                  Text(
                    '${cart.count}',
                  ),
                ],
              ) : Container();
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: _navigateToAccountPage,
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: widget.body,
    );
  }
}
