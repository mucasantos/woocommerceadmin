import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/products/components/products_list/widgets/products_list_appbar.dart';
import 'package:woocommerceadmin/src/products/components/products_list/widgets/products_list_widget.dart';
import 'package:woocommerceadmin/src/products/models/product.dart';
import 'package:woocommerceadmin/src/products/models/products.dart';
import 'package:woocommerceadmin/src/products/models/products_list_filters.dart';

class ProductsListScreen extends StatefulWidget {
  static const routeName = '/products-list';
  final String baseurl;
  final String username;
  final String password;
  ProductsListScreen({
    Key key,
    @required this.baseurl,
    @required this.username,
    @required this.password,
  }) : super(key: key);

  @override
  _ProductsListScreenState createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  int _page = 1;
  bool _hasMoreToLoad = true;
  bool _isListLoading = false;
  bool _isListError = false;
  String _listError;

  @override
  void initState() {
    fetchProductsList();
    super.initState();
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
      appBar: ProductsListAppBar.getAppBar(
        context: context,
        handleRefresh: this.handleRefresh,
      ),
      body: Consumer<Products>(
        builder: (context, productsData, _) {
          return _isListError && productsData.products.isEmpty
              ? _mainErrorWidget()
              : RefreshIndicator(
                  onRefresh: () async {
                    await handleRefresh();
                  },
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (_hasMoreToLoad &&
                                !_isListLoading &&
                                scrollInfo.metrics.pixels ==
                                    scrollInfo.metrics.maxScrollExtent) {
                              handleLoadMore();
                            }
                          },
                          child: ProductsListWidget(
                            baseurl: widget.baseurl,
                            username: widget.username,
                            password: widget.password,
                          ),
                        ),
                      ),
                      if (_isListLoading)
                        Container(
                          height: 60,
                          child: Center(
                            child: SpinKitPulse(
                              color: Theme.of(context).primaryColor,
                              size: 50,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Future<void> fetchProductsList({
    int perPage = 25,
  }) async {
    ProductsListFilters productsListData =
        Provider.of<ProductsListFilters>(context, listen: false);
    String url =
        "${widget.baseurl}/wp-json/wc/v3/products?page=$_page&per_page=$perPage&consumer_key=${widget.username}&consumer_secret=${widget.password}";

    if (productsListData.searchValue is String &&
        productsListData.searchValue.isNotEmpty) {
      url += "&search=${productsListData.searchValue}";
    }
    if (productsListData.sortOrderByValue is String &&
        productsListData.sortOrderByValue.isNotEmpty) {
      url += "&orderby=${productsListData.sortOrderByValue}";
    }
    if (productsListData.sortOrderValue is String &&
        productsListData.sortOrderValue.isNotEmpty) {
      url += "&order=${productsListData.sortOrderValue}";
    }
    if (productsListData.statusFilterValue is String &&
        productsListData.statusFilterValue.isNotEmpty) {
      url += "&status=${productsListData.statusFilterValue}";
    }
    if (productsListData.stockStatusFilterValue is String &&
        productsListData.stockStatusFilterValue.isNotEmpty) {
      if (productsListData.stockStatusFilterValue == "instock" ||
          productsListData.stockStatusFilterValue == "outofstock" ||
          productsListData.stockStatusFilterValue == "onbackorder")
        url += "&stock_status=${productsListData.stockStatusFilterValue}";
    }
    if (productsListData.featuredFilterValue is bool &&
        productsListData.featuredFilterValue) {
      url += "&featured=${productsListData.featuredFilterValue}";
    }
    if (productsListData.onSaleFilterValue is bool &&
        productsListData.onSaleFilterValue) {
      url += "&on_sale=${productsListData.onSaleFilterValue}";
    }
    if (productsListData.minPriceFilterValue is String &&
        productsListData.minPriceFilterValue.isNotEmpty) {
      url += "&min_price=${productsListData.minPriceFilterValue}";
    }
    if (productsListData.maxPriceFilterValue is String &&
        productsListData.maxPriceFilterValue.isNotEmpty) {
      url += "&max_price=${productsListData.maxPriceFilterValue}";
    }
    if (productsListData.fromDateFilterValue is DateTime) {
      url += "&after=" +
          DateFormat("yyyy-MM-dd").format(productsListData.fromDateFilterValue);
    }
    if (productsListData.toDateFilterValue is DateTime) {
      url += "&before=" +
          DateFormat("yyyy-MM-dd").format(productsListData.toDateFilterValue);
    }
    setState(() {
      _isListLoading = true;
      _isListError = false;
    });
    http.Response response;
    try {
      response = await http.get(url);
      if (response.statusCode == 200) {
        dynamic responseBody = json.decode(response.body);
        if (responseBody is List) {
          if (responseBody.isNotEmpty) {
            final List<Product> loadedProducts = [];
            responseBody.forEach((item) {
              loadedProducts.add(Product.fromJson(item));
            });
            Provider.of<Products>(context, listen: false)
                .addProducts(loadedProducts);
            setState(() {
              _hasMoreToLoad = true;
              _isListLoading = false;
              _isListError = false;
            });
          } else {
            setState(() {
              _hasMoreToLoad = false;
              _isListLoading = false;
              _isListError = false;
            });
          }
        } else {
          setState(() {
            _hasMoreToLoad = true;
            _isListLoading = false;
            _isListError = true;
            _listError = "Failed to fetch products";
          });
        }
      } else {
        String errorCode = "";
        dynamic responseBody = json.decode(response.body);
        if (responseBody is Map &&
            responseBody.containsKey("code") &&
            responseBody["code"] is String) {
          errorCode = responseBody["code"];
        }
        setState(() {
          _hasMoreToLoad = true;
          _isListLoading = false;
          _isListError = true;
          _listError = "Failed to fetch products. Error: $errorCode";
        });
      }
    } on SocketException catch (_) {
      setState(() {
        _hasMoreToLoad = true;
        _isListLoading = false;
        _isListError = true;
        _listError = "Failed to fetch products. Error: Network not reachable";
      });
    } catch (e) {
      setState(() {
        _hasMoreToLoad = true;
        _isListLoading = false;
        _isListError = true;
        _listError = "Failed to fetch products. Error: $e";
      });
    }
  }

  Future<void> handleLoadMore() async {
    _page++;
    await fetchProductsList();
  }

  Future<void> handleRefresh() async {
    _page = 1;
    Provider.of<Products>(context, listen: false).clearProductsList();
    fetchProductsList();
  }

  Widget _mainErrorWidget() {
    Widget mainErrorWidget = SizedBox.shrink();
    if (_isListError && _listError is String && _listError.isNotEmpty)
      mainErrorWidget = Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
              child: Text(
                _listError ?? "",
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
                onPressed: () => handleRefresh(),
              ),
            )
          ],
        ),
      );
    return mainErrorWidget;
  }
}
