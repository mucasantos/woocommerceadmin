import 'package:flutter/material.dart';
import 'package:woocommerceadmin/src/common/widgets/MyDrawer.dart';
import 'package:woocommerceadmin/src/connections/widgets/AddConnectionPage.dart';
import 'package:woocommerceadmin/src/customers/widgets/CustomersListPage.dart';
import 'package:woocommerceadmin/src/db/ConnectionDBProvider.dart';
import 'package:woocommerceadmin/src/db/models/Connection.dart';
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
              fontSize: 14.0,
            ),
            button: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            )),
      ),
      home: MyBottomNavigator(),
    );
  }
}

class MyBottomNavigator extends StatefulWidget {
  final _MyBottomNavigatorState _myBottomNavigatorState  = _MyBottomNavigatorState();

  @override
  _MyBottomNavigatorState createState() => _myBottomNavigatorState;
  
  Future<void> getInitialConnection() async{
    await _myBottomNavigatorState.getInitialConnection();
  }
}

class _MyBottomNavigatorState extends State<MyBottomNavigator> {
  int _selectedIndex = 0;
  Connection selectedConnection;
  List<Widget> _children = [];

  @override
  void initState() {
    super.initState();
    getInitialConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: myAppBar(),
        drawer: MyDrawer(),
        body: myBody(),
        bottomNavigationBar: myBottomNavigation());
  }

  Future<void> getInitialConnection() async {
    List<Connection> connectionList =
        await ConnectionDBProvider.db.getAllConnections();
    if (connectionList.length > 0) {
      selectedConnection = connectionList[0];
      setState(() {
        _children = [
          ReportsPage(
            baseurl: selectedConnection.baseurl,
            username: selectedConnection.username,
            password: selectedConnection.password,
          ),
          OrdersListPage(
            baseurl: selectedConnection.baseurl,
            username: selectedConnection.username,
            password: selectedConnection.password,
          ),
          ProductsListPage(
            baseurl: selectedConnection.baseurl,
            username: selectedConnection.username,
            password: selectedConnection.password,
          ),
          CustomersListPage(
            baseurl: selectedConnection.baseurl,
            username: selectedConnection.username,
            password: selectedConnection.password,
          )
        ];
      });
    }
  }

  Widget myAppBar() {
    Widget myAppBarWidgetData;
    if (!(selectedConnection is Connection)) {
      myAppBarWidgetData = AppBar(
        title: Text("Setup"),
      );
    }
    return myAppBarWidgetData;
  }

  Widget myBody() {
    Widget myBodyWidgetData = SizedBox.shrink();
    if (selectedConnection is Connection) {
      myBodyWidgetData =
          IndexedStack(index: _selectedIndex, children: _children);
    } else {
      final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
          new GlobalKey<RefreshIndicatorState>();
      myBodyWidgetData = RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: getInitialConnection,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Kindly add a connection to manage woocommerce",
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 45,
                  width: 200,
                  child: RaisedButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddConnectionPage(
                            refreshConnectionsList: getInitialConnection,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "Add Connection",
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
    return myBodyWidgetData;
  }

  Widget myBottomNavigation() {
    Widget myBottomNavigationWidgetData = SizedBox.shrink();
    if (selectedConnection is Connection) {
      myBottomNavigationWidgetData = BottomNavigationBar(
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
          ]);
    }
    return myBottomNavigationWidgetData;
  }
}
