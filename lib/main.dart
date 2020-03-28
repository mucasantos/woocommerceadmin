import 'package:flutter/material.dart';
import 'package:woocommerceadmin/src/common/widgets/MyDrawer.dart';
import 'package:woocommerceadmin/src/customers/widgets/CustomersListPage.dart';
import 'package:woocommerceadmin/src/orders/widgets/OrdersListPage.dart';
import 'package:woocommerceadmin/src/products/widgets/ProductsListPage.dart';
import 'package:woocommerceadmin/src/reports/widgets/ReportsPage.dart';
import 'package:woocommerceadmin/src/config.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Woocommerce Admin',
      theme: ThemeData(
          primarySwatch: Colors.purple,
          textTheme: TextTheme(
              headline: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                // backgroundColor: Colors.purple,
                // color: Colors.white
              ),
              subhead: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              body1: TextStyle(
                fontSize: 15.0,
              ))),
      home: MyBottomNavigator(),
    );
  }
}

class MyBottomNavigator extends StatefulWidget {
  @override
  _MyBottomNavigatorState createState() => _MyBottomNavigatorState();
}

class _MyBottomNavigatorState extends State<MyBottomNavigator> {
  int _selectedIndex = 0;
  final List<Widget> _children = [
    ReportsPage(),
    OrdersListPage(),
    ProductsListPage(),
    CustomersListPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      body: IndexedStack(index: _selectedIndex, children: _children),
      bottomNavigationBar: BottomNavigationBar(
          // backgroundColor: Colors.purple, //Not Working Don't Know why
          showSelectedLabels: true,
          showUnselectedLabels: true,
          unselectedItemColor: Config.colors["lightTheme"]
              ["bottomNavInactiveColor"],
          selectedItemColor: Config.colors["lightTheme"]["mainThemeColor"],
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart),
              title: Text('Reports'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              title: Text('Orders'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.collections),
              title: Text('Products'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              title: Text('Customers'),
            ),
          ]),
    );
  }
}
