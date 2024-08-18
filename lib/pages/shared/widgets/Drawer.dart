import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
              child: Container(
            color: Colors.grey[400],
          )),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home Page'),
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != '/') {
                Navigator.pushNamed(context, '/');
                
              } else {
                Scaffold.of(context).closeDrawer();
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.monetization_on),
            title: Text('Products Page'),
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != '/Products') {
                Navigator.pushNamed(context, '/Products');
              } else {
                Scaffold.of(context).closeDrawer();
              }
            },
          ),
        ],
      ),
    );
  }
}
