import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:woocommerceadmin/src/products/widgets/ProductDetailsPage.dart';
import 'package:woocommerceadmin/src/products/widgets/ProductsListFiltersModal.dart';

class ProductsListPage extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  ProductsListPage({
    Key key,
    @required this.baseurl,
    @required this.username,
    @required this.password,
  }) : super(key: key);

  @override
  _ProductsListPageState createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  List productsListData = [];
  int page = 1;
  bool hasMoreToLoad = true;
  bool isListLoading = false;
  bool isListError = false;
  String listError;

  bool isSearching = false;
  String searchValue = "";

  String sortOrderByValue = "date";
  String sortOrderValue = "desc";

  String statusFilterValue = "any";
  String stockStatusFilterValue = "all";
  bool featuredFilterValue = false;
  bool onSaleFilterValue = false;
  String minPriceFilterValue = "";
  String maxPriceFilterValue = "";
  DateTime fromDateFilterValue;
  DateTime toDateFilterValue;

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    fetchProductsList();
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
      body: isListError && productsListData.isEmpty
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
                          itemCount: productsListData.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailsPage(
                                        baseurl: widget.baseurl,
                                        username: widget.username,
                                        password: widget.password,
                                        id: productsListData[index]["id"],
                                        productData: productsListData[index],
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
                                      (productsListData[index]
                                                  .containsKey("images") &&
                                              productsListData[index]["images"]
                                                  is List &&
                                              productsListData[index]["images"]
                                                  .isNotEmpty &&
                                              productsListData[index]["images"]
                                                      [0]
                                                  .containsKey("src") &&
                                              productsListData[index]["images"]
                                                  [0]["src"] is String)
                                          ? ExtendedImage.network(
                                              productsListData[index]["images"]
                                                  [0]["src"],
                                              fit: BoxFit.fill,
                                              width: 140,
                                              height: 140,
                                              cache: true,
                                              enableLoadState: true,
                                              loadStateChanged:
                                                  (ExtendedImageState state) {
                                                if (state
                                                        .extendedImageLoadState ==
                                                    LoadState.loading) {
                                                  return SpinKitPulse(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    size: 50,
                                                  );
                                                }
                                                return null;
                                              },
                                            )
                                          : SizedBox(
                                              height: 140,
                                              width: 140,
                                            ),
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
                                                if (productsListData[index]
                                                        .containsKey("name") &&
                                                    productsListData[index]
                                                            ["name"] !=
                                                        null)
                                                  Text(
                                                    productsListData[index]
                                                        ["name"],
                                                    style: TextStyle(
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                if (productsListData[index]
                                                        .containsKey("sku") &&
                                                    productsListData[index]
                                                            ["sku"] !=
                                                        null)
                                                  Text(
                                                    "SKU: ${productsListData[index]["sku"]}",
                                                  ),
                                                if (productsListData[index]
                                                        .containsKey("price") &&
                                                    productsListData[index]
                                                            ["price"] !=
                                                        null)
                                                  Text(
                                                    "Price: ${productsListData[index]["price"]}",
                                                  ),
                                                if (productsListData[index]
                                                        .containsKey(
                                                            "stock_status") &&
                                                    productsListData[index]
                                                            ["stock_status"] !=
                                                        null)
                                                  Text(
                                                    "Stock Status: ${productsListData[index]["stock_status"]}",
                                                  ),
                                                if (productsListData[index]
                                                        .containsKey(
                                                            "stock_quantity") &&
                                                    productsListData[index][
                                                            "stock_quantity"] !=
                                                        null)
                                                  Text(
                                                    "Stock: ${productsListData[index]["stock_quantity"]}",
                                                  ),
                                                if (productsListData[index]
                                                        .containsKey(
                                                            "status") &&
                                                    productsListData[index]
                                                            ["status"] !=
                                                        null)
                                                  Text(
                                                    "Status: ${productsListData[index]["status"]}",
                                                  )
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
                        color: Theme.of(context).primaryColor,
                        size: 50,
                      )),
                    ),
                ],
              ),
            ),
    );
  }

  Future<void> fetchProductsList() async {
    String url =
        "${widget.baseurl}/wp-json/wc/v3/products?page=$page&per_page=20&consumer_key=${widget.username}&consumer_secret=${widget.password}";
    if (searchValue is String && searchValue.isNotEmpty) {
      url += "&search=$searchValue";
    }
    if (sortOrderByValue is String && sortOrderByValue.isNotEmpty) {
      url += "&orderby=$sortOrderByValue";
    }
    if (sortOrderValue is String && sortOrderValue.isNotEmpty) {
      url += "&order=$sortOrderValue";
    }
    if (statusFilterValue is String && statusFilterValue.isNotEmpty) {
      url += "&status=$statusFilterValue";
    }
    if (stockStatusFilterValue is String && stockStatusFilterValue.isNotEmpty) {
      if (stockStatusFilterValue == "instock" ||
          stockStatusFilterValue == "outofstock" ||
          stockStatusFilterValue == "onbackorder")
        url += "&stock_status=$stockStatusFilterValue";
    }
    if (featuredFilterValue is bool && featuredFilterValue) {
      url += "&featured=$featuredFilterValue";
    }
    if (onSaleFilterValue is bool && onSaleFilterValue) {
      url += "&on_sale=$onSaleFilterValue";
    }
    if (minPriceFilterValue is String && minPriceFilterValue.isNotEmpty) {
      url += "&min_price=$minPriceFilterValue";
    }
    if (maxPriceFilterValue is String && maxPriceFilterValue.isNotEmpty) {
      url += "&max_price=$maxPriceFilterValue";
    }
    // if (fromDateFilterValue is DateTime) {
    //   url += "&after=" + DateFormat("yyyy-MM-dd").format(fromDateFilterValue);
    // }
    // if (toDateFilterValue is DateTime) {
    //   url += "&before=" + DateFormat("yyyy-MM-dd").format(toDateFilterValue);
    // }

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
              productsListData.addAll(json.decode(response.body));
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
            listError = "Failed to fetch products";
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
          listError = "Failed to fetch products. Error: $errorCode";
        });
      }
    } on SocketException catch (_) {
      setState(() {
        hasMoreToLoad = true;
        isListLoading = false;
        isListError = true;
        listError = "Failed to fetch products. Error: Network not reachable";
      });
    } catch (e) {
      setState(() {
        hasMoreToLoad = true;
        isListLoading = false;
        isListError = true;
        listError = "Failed to fetch products. Error: $e";
      });
    }
  }

  handleLoadMore() async {
    setState(() {
      page++;
    });
    await fetchProductsList();
  }

  Future<void> handleRefresh() async {
    setState(() {
      page = 1;
      productsListData = [];
    });
    await fetchProductsList();
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
                      hintText: "Search Products",
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
              : Expanded(
                  child: Text("Products List"),
                ),
          isSearching
              ? IconButton(
                  icon: Icon(Icons.center_focus_strong),
                  onPressed: scanBarcode,
                )
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
                  return ProductsListFiltersModal(
                    sortOrderByValue: sortOrderByValue,
                    sortOrderValue: sortOrderValue,
                    statusFilterValue: statusFilterValue,
                    stockStatusFilterValue: stockStatusFilterValue,
                    featuredFilterValue: featuredFilterValue,
                    onSaleFilterValue: onSaleFilterValue,
                    minPriceFilterValue: minPriceFilterValue,
                    maxPriceFilterValue: maxPriceFilterValue,
                    fromDateFilterValue: fromDateFilterValue,
                    toDateFilterValue: toDateFilterValue,
                    onSubmit: (sortOrderByValue,
                        sortOrderValue,
                        statusFilterValue,
                        stockStatusFilterValue,
                        featuredFilterValue,
                        onSaleFilterValue,
                        minPriceFilterValue,
                        maxPriceFilterValue,
                        fromDateFilterValue,
                        toDateFilterValue) {
                      setState(() {
                        this.sortOrderByValue = sortOrderByValue;
                        this.sortOrderValue = sortOrderValue;
                        this.statusFilterValue = statusFilterValue;
                        this.stockStatusFilterValue = stockStatusFilterValue;
                        this.featuredFilterValue = featuredFilterValue;
                        this.onSaleFilterValue = onSaleFilterValue;
                        this.minPriceFilterValue = minPriceFilterValue;
                        this.maxPriceFilterValue = maxPriceFilterValue;
                        this.fromDateFilterValue = fromDateFilterValue;
                        this.toDateFilterValue = toDateFilterValue;
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
