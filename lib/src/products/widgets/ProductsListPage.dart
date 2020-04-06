import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:woocommerceadmin/src/config.dart';
import 'package:woocommerceadmin/src/products/widgets/ProductDetailsPage.dart';

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

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    fetchProductsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products List"),
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
                                ),
                              ),
                            );
                          },
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                (productsListData[index]
                                            .containsKey("images") &&
                                        productsListData[index]["images"]
                                                .length !=
                                            0)
                                    ? (productsListData[index]["images"][0]
                                                ["src"] !=
                                            null)
                                        ? Image.network(
                                            productsListData[index]["images"][0]
                                                ["src"],
                                            fit: BoxFit.fill,
                                            width: 120.0,
                                            height: 120.0,
                                          )
                                        : SizedBox(
                                            height: 120,
                                            width: 120,
                                          )
                                    : SizedBox(
                                        height: 120,
                                        width: 120,
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
                                              productsListData[index]["name"] !=
                                                  null)
                                            Text(
                                              productsListData[index]["name"],
                                              style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          if (productsListData[index]
                                                  .containsKey("sku") &&
                                              productsListData[index]["sku"] !=
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
                                              productsListData[index]
                                                      ["stock_quantity"] !=
                                                  null)
                                            Text(
                                              "Stock: ${productsListData[index]["stock_quantity"]}",
                                            ),
                                          if (productsListData[index]
                                                  .containsKey("status") &&
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
                height: 60.0,
                color: Colors.white,
                child: Center(
                    child: SpinKitFadingCube(
                  color: Config.colors["lightTheme"]["mainThemeColor"],
                  size: 30.0,
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
    setState(() {
      isListLoading = true;
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
      if (json.decode(response.body) is List &&
          !json.decode(response.body).isEmpty) {
        setState(() {
          hasMoreToLoad = true;
          productsListData.addAll(json.decode(response.body));
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
    await fetchProductsList();
  }

  Future<void> handleRefresh() async {
    setState(() {
      page = 1;
      productsListData = [];
    });
    await fetchProductsList();
  }
}
