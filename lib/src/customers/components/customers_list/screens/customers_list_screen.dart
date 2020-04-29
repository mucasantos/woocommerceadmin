import 'dart:convert';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/customers/components/customers_list/widgets/customers_list_appbar.dart';
import 'package:woocommerceadmin/src/customers/components/customers_list/widgets/customers_list_widget.dart';
import 'package:woocommerceadmin/src/customers/models/customer.dart';
import 'package:woocommerceadmin/src/customers/providers/customer_provider.dart';
import 'package:woocommerceadmin/src/customers/providers/customer_providers_list.dart';
import 'package:woocommerceadmin/src/customers/providers/customers_list_filters_provider.dart';

class CustomersListScreen extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;

  CustomersListScreen({
    Key key,
    @required this.baseurl,
    @required this.username,
    @required this.password,
  }) : super(key: key);

  @override
  _CustomersListScreenState createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends State<CustomersListScreen> {
  int _page = 1;
  bool _hasMoreToLoad = true;
  bool _isListLoading = false;
  bool _isListError = false;
  String _listError;

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
      appBar: CustomersListAppbar.getAppBar(
        context: context,
        handleRefresh: handleRefresh,
      ),
      body: Consumer<CustomerProvidersList>(
        builder: (context, customerProvidersList, _) {
          return _isListError && customerProvidersList.customerProviders.isEmpty
              ? _mainErrorWidget()
              : RefreshIndicator(
                  onRefresh: handleRefresh,
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
                          child: CustomerListWidget(
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
                            color: Colors.purple,
                            size: 50,
                          )),
                        ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  fetchCustomersList({
    int perPage = 25,
  }) async {
    final CustomersListFiltersProvider customersListFiltersProvider =
        Provider.of<CustomersListFiltersProvider>(context, listen: false);
    String url =
        "${widget.baseurl}/wp-json/wc/v3/customers?page=$_page&per_page=$perPage&consumer_key=${widget.username}&consumer_secret=${widget.password}";

    if (customersListFiltersProvider?.searchValue is String &&
        customersListFiltersProvider.searchValue.isNotEmpty) {
      url += "&search=${customersListFiltersProvider.searchValue}";
    }
    if (customersListFiltersProvider?.sortOrderByValue is String &&
        customersListFiltersProvider.sortOrderByValue.isNotEmpty) {
      url += "&orderby=${customersListFiltersProvider.sortOrderByValue}";
    }
    if (customersListFiltersProvider?.sortOrderValue is String &&
        customersListFiltersProvider.sortOrderValue.isNotEmpty) {
      url += "&order=${customersListFiltersProvider.sortOrderValue}";
    }
    if (customersListFiltersProvider.roleFilterValue is String &&
        customersListFiltersProvider.roleFilterValue.isNotEmpty) {
      url += "&role=${customersListFiltersProvider.roleFilterValue}";
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
            final List<CustomerProvider> loadedCustomerProviders = [];
            responseBody.forEach((item) {
              loadedCustomerProviders
                  .add(CustomerProvider(Customer.fromJson(item)));
            });
            Provider.of<CustomerProvidersList>(context, listen: false)
                .addCustomerProviders(loadedCustomerProviders);
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
            _listError = "Failed to fetch users";
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
          _hasMoreToLoad = true;
          _isListLoading = false;
          _isListError = true;
          _listError = "Failed to fetch users. Error: $errorCode";
        });
      }
    } on SocketException catch (_) {
      setState(() {
        _hasMoreToLoad = true;
        _isListLoading = false;
        _isListError = true;
        _listError = "Failed to fetch users. Error: Network not reachable";
      });
    } catch (e) {
      setState(() {
        _hasMoreToLoad = true;
        _isListLoading = false;
        _isListError = true;
        _listError = "Failed to fetch users. Error: $e";
      });
    }
  }

  handleLoadMore() async {
    setState(() {
      _page++;
    });
    await fetchCustomersList();
  }

  Future<void> handleRefresh() async {
    setState(() {
      _page = 1;
      Provider.of<CustomerProvidersList>(context, listen: false)
          .clearCustomerProvidersList();
    });
    await fetchCustomersList();
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
                onPressed: handleRefresh,
              ),
            )
          ],
        ),
      );
    return mainErrorWidget;
  }
}
