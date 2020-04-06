import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:woocommerceadmin/src/connections/widgets/AddConnectionPage.dart';
import 'package:woocommerceadmin/src/connections/widgets/EditConnectionPage.dart';
import 'package:woocommerceadmin/src/db/ConnectionDBProvider.dart';
import 'package:woocommerceadmin/src/db/models/Connection.dart';

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  bool isConnectionsListReady = false;
  List<Connection> connectionsList = [];

  @override
  void initState() {
    super.initState();
    getConnectionsList();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.purple,
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: Center(
                      child: Text(
                        "Woocommerce Admin",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )),
            ),
            Expanded(
              flex: 5,
              child: !isConnectionsListReady
                  ? Center(
                      child: Container(
                      child: Center(
                        child: SpinKitFadingCube(
                          color: Theme.of(context).primaryColor,
                          size: 30.0,
                        ),
                      ),
                    ))
                  : RefreshIndicator(
                      key: _refreshIndicatorKey,
                      onRefresh: getConnectionsList,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: connectionsList.length,
                        itemBuilder: (BuildContext context, int index) {
                          Connection item = connectionsList[index];
                          return Card(
                            child: InkWell(
                              onTap: () {},
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 0, 0, 0),
                                        child: Text(
                                          "${item.baseurl}",
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditConnectionPage(
                                                    id: item.id,
                                                    baseurl: item.baseurl,
                                                    username: item.username,
                                                    password: item.password,
                                                    refreshConnectionsList:
                                                        getConnectionsList),
                                          ),
                                        );
                                      },
                                      padding: EdgeInsets.all(0),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        deleteConnectionFromList(item.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            Column(
              children: [
                Divider(
                  color: Colors.grey,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddConnectionPage(
                                refreshConnectionsList: getConnectionsList,
                              )),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 20.0,
                        ),
                        Icon(Icons.add),
                        SizedBox(
                          width: 20.0,
                        ),
                        Text("Add Connection"),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 20.0,
                        ),
                        Icon(Icons.settings),
                        SizedBox(
                          width: 20.0,
                        ),
                        Text("Settings"),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 20.0,
                        ),
                        Icon(Icons.help),
                        SizedBox(
                          width: 20.0,
                        ),
                        Text("Help"),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> getConnectionsList() async {
    setState(() {
      isConnectionsListReady = false;
    });
    List<Connection> connections =
        await ConnectionDBProvider.db.getAllConnections();
    setState(() {
      isConnectionsListReady = true;
      connectionsList = connections;
    });
  }

  Future<void> deleteConnectionFromList(int id) async {
    await ConnectionDBProvider.db.deleteConnection(id);
    getConnectionsList();
  }
}
