import 'dart:convert';
import 'dart:io';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:woocommerceadmin/src/customers/widgets/CustomerDetailsPage.dart';
import 'package:woocommerceadmin/src/customers/widgets/CustomersListFiltersModal.dart';

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
  bool isListError = false;
  String listError;

  bool isSearching = false;
  String searchValue = "";

  String sortOrderByValue = "registered_date";
  String sortOrderValue = "desc";
  String roleFilterValue = "customer";

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    fetchCustomersList();
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
      key: scaffoldKey,
      appBar: _myAppBar(),
      body: isListError && customersListData.isEmpty
          ? _mainErrorWidget()
          : RefreshIndicator(
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
                                        id: customersListData[index]["id"],
                                        customerData: customersListData[index],
                                        preFetch: false,
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                      height: 60,
                      child: Center(
                          child: SpinKitPulse(
                        color: Colors.purple,
                        size: 50,
                      )),
                    ),
                ],
              ),
            ),
    );
  }

  fetchCustomersList() async {
    String url =
        "${widget.baseurl}/wp-json/wc/v3/customers?page=$page&per_page=20&consumer_key=${widget.username}&consumer_secret=${widget.password}";

    if (searchValue is String && searchValue.isNotEmpty) {
      url += "&search=$searchValue";
    }
    if (sortOrderByValue is String && sortOrderByValue.isNotEmpty) {
      url += "&orderby=$sortOrderByValue";
    }
    if (sortOrderValue is String && sortOrderValue.isNotEmpty) {
      url += "&order=$sortOrderValue";
    }
    if (roleFilterValue is String && roleFilterValue.isNotEmpty) {
      url += "&role=$roleFilterValue";
    }

    setState(() {
      isListLoading = true;
      isListError = false;
    });
    http.Response response;
    try {
      response = await http.get(url);
      if (response.statusCode == 200) {
        if (json.decode(response.body) is List) {
          if (json.decode(response.body).isNotEmpty) {
            setState(() {
              hasMoreToLoad = true;
              customersListData.addAll(json.decode(response.body));
              isListLoading = false;
              isListError = false;
            });
          } else {
            setState(() {
              hasMoreToLoad = false;
              isListLoading = false;
              isListError = false;
            });
          }
        } else {
          setState(() {
            hasMoreToLoad = true;
            isListLoading = false;
            isListError = true;
            listError = "Failed to fetch users";
          });
        }
      } else {
        String errorCode = "";
        if (json.decode(response.body) is Map &&
            json.decode(response.body).containsKey("code") &&
            json.decode(response.body)["code"] is String) {
          errorCode = json.decode(response.body)["code"];
        }
        setState(() {
          hasMoreToLoad = true;
          isListLoading = false;
          isListError = true;
          listError = "Failed to fetch users. Error: $errorCode";
        });
      }
    } on SocketException catch (_) {
      setState(() {
        hasMoreToLoad = true;
        isListLoading = false;
        isListError = true;
        listError = "Failed to fetch users. Error: Network not reachable";
      });
    } catch (e) {
      setState(() {
        hasMoreToLoad = true;
        isListLoading = false;
        isListError = true;
        listError = "Failed to fetch users. Error: $e";
      });
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

  Future<void> scanBarcode() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() {
        searchValue = barcode;
      });
      handleRefresh();
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Camera permission is not granted"),
          duration: Duration(seconds: 3),
        ));
      } else {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Unknown barcode scan error: $e"),
          duration: Duration(seconds: 3),
        ));
      }
    } on FormatException {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Barcode scan cancelled"),
        duration: Duration(seconds: 3),
      ));
    } catch (e) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Unknown barcode scan error: $e"),
        duration: Duration(seconds: 3),
      ));
    }
  }

  Widget _myAppBar() {
    Widget myAppBar;

    myAppBar = AppBar(
      title: Row(
        children: <Widget>[
          isSearching
              ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.search),
                )
              : SizedBox.shrink(),
          isSearching
              ? Expanded(
                  child: TextField(
                    controller: TextEditingController(text: searchValue),
                    style: TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search Users",
                      hintStyle: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.6),
                      ),
                    ),
                    cursorColor: Colors.white,
                    onSubmitted: (String value) {
                      setState(() {
                        searchValue = value;
                      });
                      handleRefresh();
                    },
                  ),
                )
              : Expanded(child: Text("Customers List")),
          isSearching
              ? IconButton(
                  icon: Icon(Icons.center_focus_strong), onPressed: scanBarcode)
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      isSearching = !isSearching;
                    });
                  },
                ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return CustomersListFiltersModal(
                    baseurl: widget.baseurl,
                    username: widget.username,
                    password: widget.password,
                    sortOrderByValue: sortOrderByValue,
                    sortOrderValue: sortOrderValue,
                    roleFilterValue: roleFilterValue,
                    onSubmit:
                        (sortOrderByValue, sortOrderValue, roleFilterValue) {
                      setState(() {
                        this.sortOrderByValue = sortOrderByValue;
                        this.sortOrderValue = sortOrderValue;
                        this.roleFilterValue = roleFilterValue;
                      });
                      handleRefresh();
                    },
                  );
                },
              );
            },
          ),
          isSearching
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    bool isPreviousSearchValueNotEmpty = false;
                    if (searchValue.isNotEmpty) {
                      isPreviousSearchValueNotEmpty = true;
                    } else {
                      isPreviousSearchValueNotEmpty = false;
                    }
                    setState(() {
                      isSearching = !isSearching;
                      searchValue = "";
                    });
                    if (isPreviousSearchValueNotEmpty is bool &&
                        isPreviousSearchValueNotEmpty) {
                      handleRefresh();
                    }
                  },
                )
              : SizedBox.shrink(),
        ],
      ),
    );
    return myAppBar;
  }

  Widget _customerImage(Map customerDetailsMap) {
    Widget customerImageWidget = Padding(
      padding: EdgeInsets.all(10),
      child: SizedBox(
        height: 140,
        width: 140,
        child: Icon(
          Icons.person,
          size: 30,
        ),
      ),
    );
    if (customerDetailsMap.containsKey("avatar_url") &&
        customerDetailsMap["avatar_url"] is String &&
        customerDetailsMap["avatar_url"].isNotEmpty) {
      customerImageWidget = ExtendedImage.network(
        customerDetailsMap["avatar_url"],
        fit: BoxFit.fill,
        width: 140.0,
        height: 140.0,
        cache: true,
        enableLoadState: true,
        loadStateChanged: (ExtendedImageState state) {
          if (state.extendedImageLoadState == LoadState.loading) {
            return SpinKitPulse(
              color: Theme.of(context).primaryColor,
              size: 50,
            );
          }
          return null;
        },
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

  Widget _mainErrorWidget() {
    Widget mainErrorWidget = SizedBox.shrink();
    if (isListError && listError is String && listError.isNotEmpty)
      mainErrorWidget = Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
              child: Text(
                listError ?? "",
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              height: 45,
              width: 200,
              child: RaisedButton(
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Text("Retry"),
                onPressed: handleRefresh,
              ),
            )
          ],
        ),
      );
    return mainErrorWidget;
  }
}
