import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woocommerceadmin/src/common/widgets/my_drawer.dart';
import 'package:woocommerceadmin/src/connections/components/add_connection/screens/add_connection_screen.dart';
import 'package:woocommerceadmin/src/customers/components/customers_list/screens/customers_list_screen.dart';
import 'package:woocommerceadmin/src/db/ConnectionDBProvider.dart';
import 'package:woocommerceadmin/src/db/models/Connection.dart';
import 'package:woocommerceadmin/src/orders/components/orders_list/screens/orders_list_screen.dart';
import 'package:woocommerceadmin/src/orders/providers/orders_list_provider.dart';
import 'package:woocommerceadmin/src/products/components/products_list/screens/products_list_screen.dart';
import 'package:woocommerceadmin/src/products/providers/products_list_filters_provider.dart';
import 'package:woocommerceadmin/src/products/providers/products_list_provider.dart';
import 'package:woocommerceadmin/src/reports/components/reports/screens/reports_screen.dart';
import 'package:woocommerceadmin/src/config.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ProductsListProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProductsListFiltersProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => OrdersListProvider(),
        ),
      ],
      child: MaterialApp(
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
                fontSize: 14,
              ),
              body2: TextStyle(
                fontSize: 16,
              ),
              button: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              )),
        ),
        home: HomePage(),
        // routes: {
        //       ProductsListScreen.routeName: (context) => ProductsListScreen(),
        //       ProductDetailsScreen.routeName: (context) => ProductDetailsScreen(),
        //     }),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage();

  final _HomePageState _homePageState = _HomePageState();

  @override
  _HomePageState createState() => _homePageState;

  Future<void> setSelectedConnection() async {
    await _homePageState.setSelectedConnection();
  }
}

class _HomePageState extends State<HomePage> {
  int _selectedConnectionId = -1;
  bool _isSelectedConnectionReady = false;
  Connection _selectedConnection;

  int _selectedBottomNavigationIndex = 0;
  List<Widget> _children = [];

  @override
  void initState() {
    super.initState();
    setSelectedConnection();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(),
      drawer: MyDrawer(),
      body: myBody(),
      bottomNavigationBar: myBottomNavigation(),
    );
  }

  Future<void> setSelectedConnection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int selectedConnectionId;
    try {
      selectedConnectionId = prefs.getInt("selectedConnectionId");
    } catch (e) {
      selectedConnectionId = -1;
      _isSelectedConnectionReady = true;
    }

    List<Connection> connectionList =
        await ConnectionDBProvider.db.getAllConnections();

    if (selectedConnectionId is int &&
        selectedConnectionId >= 0 &&
        connectionList.isNotEmpty) {
      if (connectionList[selectedConnectionId] is Connection) {
        setState(() {
          _selectedConnectionId = selectedConnectionId;
          _selectedConnection = connectionList[_selectedConnectionId];
          _isSelectedConnectionReady = true;
          _children = [
            ReportsPage(
              baseurl: _selectedConnection.baseurl,
              username: _selectedConnection.username,
              password: _selectedConnection.password,
            ),
            OrdersListPage(
              baseurl: _selectedConnection.baseurl,
              username: _selectedConnection.username,
              password: _selectedConnection.password,
            ),
            ProductsListScreen(
              baseurl: _selectedConnection.baseurl,
              username: _selectedConnection.username,
              password: _selectedConnection.password,
            ),
            CustomersListPage(
              baseurl: _selectedConnection.baseurl,
              username: _selectedConnection.username,
              password: _selectedConnection.password,
            )
          ];
        });
      }
    }
  }

  // Future<void> setBottomNavigationMenu() async {
  //   if (_isSelectedConnectionReady &&
  //       _selectedConnectionId is int &&
  //       _selectedConnectionId >= 0 &&
  //       _selectedConnection is Connection) {
  //     setState(
  //       () {
  //         _children = [
  //           ReportsPage(
  //             baseurl: _selectedConnection.baseurl,
  //             username: _selectedConnection.username,
  //             password: _selectedConnection.password,
  //           ),
  //           OrdersListPage(
  //             baseurl: _selectedConnection.baseurl,
  //             username: _selectedConnection.username,
  //             password: _selectedConnection.password,
  //           ),
  //           ProductsListPage(
  //             baseurl: _selectedConnection.baseurl,
  //             username: _selectedConnection.username,
  //             password: _selectedConnection.password,
  //           ),
  //           CustomersListPage(
  //             baseurl: _selectedConnection.baseurl,
  //             username: _selectedConnection.username,
  //             password: _selectedConnection.password,
  //           )
  //         ];
  //       },
  //     );
  //   }
  // }

  Widget myAppBar() {
    Widget myAppBarWidgetData;
    if (!_isSelectedConnectionReady &&
        _selectedConnectionId is int &&
        _selectedConnection is! Connection) {
      myAppBarWidgetData = AppBar(
        title: Text("Setup"),
      );
    }
    return myAppBarWidgetData;
  }

  Widget myBody() {
    Widget myBodyWidgetData = SizedBox.shrink();
    if (_isSelectedConnectionReady &&
        _selectedConnectionId is int &&
        _selectedConnectionId >= 0 &&
        _selectedConnection.runtimeType == Connection) {
      myBodyWidgetData = IndexedStack(
        index: _selectedBottomNavigationIndex,
        children: _children,
      );
    } else if (_isSelectedConnectionReady && _selectedConnectionId < 0) {
      final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
          new GlobalKey<RefreshIndicatorState>();
      myBodyWidgetData = RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: setSelectedConnection,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                child: Text(
                  "Kindly add a connection to manage woocommerce",
                  textAlign: TextAlign.center,
                ),
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
                          refreshConnectionsList: setSelectedConnection,
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
      );
    } else {
      myBodyWidgetData = Center(
        child: SpinKitPulse(
          color: Theme.of(context).primaryColor,
          size: 70,
        ),
      );
    }
    return myBodyWidgetData;
  }

  Widget myBottomNavigation() {
    Widget myBottomNavigationWidgetData = SizedBox.shrink();
    if (_isSelectedConnectionReady &&
        _selectedBottomNavigationIndex >= 0 &&
        _selectedConnection.runtimeType == Connection) {
      myBottomNavigationWidgetData = BottomNavigationBar(
          // backgroundColor: Colors.purple, //Not Working Don't Know why
          showSelectedLabels: true,
          showUnselectedLabels: true,
          unselectedItemColor: Config.colors["lightTheme"]
              ["bottomNavInactiveColor"],
          selectedItemColor: Config.colors["lightTheme"]["mainThemeColor"],
          currentIndex: _selectedBottomNavigationIndex,
          onTap: (int index) {
            setState(() {
              _selectedBottomNavigationIndex = index;
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
              title: Text('Users'),
            ),
          ]);
    }
    return myBottomNavigationWidgetData;
  }
}
