import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:woocommerceadmin/src/customers/widgets/CustomerDetailsPage.dart';

class CustomersListPage extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;

  CustomersListPage({
    Key key,
    @required this.baseurl,
    @required this.username,
    @required this.password,
  }) : super(key: key);

  @override
  _CustomersListPageState createState() => _CustomersListPageState();
}

class _CustomersListPageState extends State<CustomersListPage> {
  List customersListData = [];
  int page = 1;
  bool hasMoreToLoad = true;
  bool isListLoading = false;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    fetchCustomersList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customers List"),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: handleRefresh,
        child: Column(
          children: <Widget>[
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (hasMoreToLoad &&
                      !isListLoading &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    handleLoadMore();
                  }
                },
                child: ListView.builder(
                    itemCount: customersListData.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerDetailsPage(
                                    baseurl: widget.baseurl,
                                    username: widget.username,
                                    password: widget.password,
                                    id: customersListData[index]["id"]),
                              ),
                            );
                          },
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                _customerImage(customersListData[index]),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          _customerIdAndUsername(
                                              customersListData[index]),
                                          _customerEmail(
                                              customersListData[index]),
                                          _customerName(
                                              customersListData[index]),
                                          _customerIsPaying(
                                              customersListData[index]),
                                          _customerDateCreated(
                                              customersListData[index]),
                                        ]),
                                  ),
                                )
                              ]),
                        ),
                      );
                    }),
              ),
            ),
            if (isListLoading)
              Container(
                height: 60.0,
                color: Colors.white,
                child: Center(
                    child: SpinKitFadingCube(
                  color: Colors.purple,
                  size: 30.0,
                )),
              ),
          ],
        ),
      ),
    );
  }

  fetchCustomersList() async {
    String url =
        "${widget.baseurl}/wp-json/wc/v3/customers?page=$page&per_page=20&order=desc&orderby=registered_date&consumer_key=${widget.username}&consumer_secret=${widget.password}";
    setState(() {
      isListLoading = true;
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
      if (json.decode(response.body) is List &&
          !json.decode(response.body).isEmpty) {
        setState(() {
          hasMoreToLoad = true;
          customersListData.addAll(json.decode(response.body));
          isListLoading = false;
        });
      } else {
        setState(() {
          hasMoreToLoad = false;
          isListLoading = false;
        });
      }
    } else {
      setState(() {
        hasMoreToLoad = false;
        isListLoading = false;
      });
      throw Exception("Failed to get response.");
    }
  }

  handleLoadMore() async {
    setState(() {
      page++;
    });
    await fetchCustomersList();
  }

  Future<void> handleRefresh() async {
    setState(() {
      page = 1;
      customersListData = [];
    });
    await fetchCustomersList();
  }

  Widget _customerImage(Map customerDetailsMap) {
    Widget customerImageWidget = SizedBox(
      height: 120,
      width: 120,
      child: Icon(
        Icons.person,
        size: 30,
      ),
    );
    if (customerDetailsMap.containsKey("avatar_url") &&
        customerDetailsMap["avatar_url"] is String &&
        customerDetailsMap["avatar_url"].toString().isNotEmpty) {
      customerImageWidget = Image.network(
        customerDetailsMap["avatar_url"],
        fit: BoxFit.fill,
        width: 120.0,
        height: 120.0,
      );
    }
    return customerImageWidget;
  }

  Widget _customerIdAndUsername(Map customerDetailsMap) {
    String customerIdAndUsername = "";
    Widget customerIdAndUsernameWidget = SizedBox();

    if (customerDetailsMap.containsKey("id") &&
        customerDetailsMap["id"] is int) {
      customerIdAndUsername += "#${customerDetailsMap["id"]}";
    }

    if (customerDetailsMap.containsKey("username") &&
        customerDetailsMap["username"] is String &&
        customerDetailsMap["username"].toString().isNotEmpty) {
      customerIdAndUsername += " ${customerDetailsMap["username"]}";
    }

    customerIdAndUsernameWidget = Text(
      customerIdAndUsername,
      style: Theme.of(context)
          .textTheme
          .body1
          .copyWith(fontSize: 20.0, fontWeight: FontWeight.bold),
    );
    return customerIdAndUsernameWidget;
  }

  Widget _customerName(Map customerDetailsMap) {
    String customerName = "";
    Widget customerNameWidget = SizedBox();
    if (customerDetailsMap.containsKey("first_name") &&
        customerDetailsMap["first_name"] is String &&
        customerDetailsMap["first_name"].toString().isNotEmpty) {
      customerName += customerDetailsMap["first_name"];
    }
    if (customerDetailsMap.containsKey("last_name") &&
        customerDetailsMap["last_name"] is String &&
        customerDetailsMap["last_name"].toString().isNotEmpty) {
      customerName += " ${customerDetailsMap["last_name"]}";
    }
    if (customerName.isNotEmpty) {
      customerNameWidget = Text("Name: $customerName");
    }
    return customerNameWidget;
  }

  Widget _customerEmail(Map customerDetailsMap) {
    Widget customerEmailWidget = SizedBox();
    if (customerDetailsMap.containsKey("email") &&
        customerDetailsMap["email"] is String &&
        customerDetailsMap["email"].toString().isNotEmpty) {
      customerEmailWidget = Text(customerDetailsMap["email"]);
    }
    return customerEmailWidget;
  }

  Widget _customerIsPaying(Map customerDetailsMap) {
    Widget customerIsPayingWidget = SizedBox();
    if (customerDetailsMap.containsKey("is_paying_customer") &&
        customerDetailsMap["is_paying_customer"] is bool) {
      customerIsPayingWidget = Text("Is Paying: " +
          (customerDetailsMap["is_paying_customer"] ? "Yes" : "No"));
    }
    return customerIsPayingWidget;
  }

  Widget _customerDateCreated(Map customerDetailsMap) {
    Widget customerDateCreatedWidget = SizedBox();
    if (customerDetailsMap.containsKey("date_created") &&
        customerDetailsMap["date_created"] is String &&
        customerDetailsMap["date_created"].toString().isNotEmpty) {
      customerDateCreatedWidget = Text(
        "Created: " +
            DateFormat("EEEE, d/M/y h:mm:ss a")
                .format(DateTime.parse(customerDetailsMap["date_created"])),
      );
    }
    return customerDateCreatedWidget;
  }
}
