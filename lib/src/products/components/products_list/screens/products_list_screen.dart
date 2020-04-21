import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/products/components/products_list/widgets/products_list_appbar.dart';
import 'package:woocommerceadmin/src/products/components/products_list/widgets/products_list_widget.dart';
import 'package:woocommerceadmin/src/products/models/products.dart';

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
  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) {
      Provider.of<Products>(context, listen: false).fetchProductsList(
        baseurl: widget.baseurl,
        username: widget.username,
        password: widget.password,
      );
    });
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
        baseurl: widget.baseurl,
        username: widget.username,
        password: widget.password,
      ),
      body: Consumer<Products>(
        builder: (context, productsData, _) {
          

          return productsData.isListError &&
                  productsData.products.isEmpty
              ? _mainErrorWidget()
              : RefreshIndicator(
                  onRefresh: () async {
                    await Provider.of<Products>(context, listen: false)
                        .handleRefresh(
                            baseurl: widget.baseurl,
                            username: widget.username,
                            password: widget.password);
                  },
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            Products productsProvider =
                                Provider.of<Products>(context, listen: false);
                            if (productsProvider != null &&
                                productsProvider.hasMoreToLoad &&
                                !productsProvider.isListLoading &&
                                scrollInfo.metrics.pixels ==
                                    scrollInfo.metrics.maxScrollExtent) {
                              productsProvider.handleLoadMore(
                                baseurl: widget.baseurl,
                                username: widget.username,
                                password: widget.password,
                              );
                            }
                          },
                          child: ProductsListWidget(
                            baseurl: widget.baseurl,
                            username: widget.username,
                            password: widget.password,
                          ),
                        ),
                      ),
                      if (productsData.isListLoading)
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

  Widget _mainErrorWidget() {
    Products productsData = Provider.of<Products>(context, listen: false);
    Widget mainErrorWidget = SizedBox.shrink();
    if (productsData.isListError &&
        productsData.listError is String &&
        productsData.listError.isNotEmpty)
      mainErrorWidget = Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
              child: Text(
                productsData.listError ?? "",
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
                onPressed: () => productsData.handleRefresh(
                  baseurl: widget.baseurl,
                  username: widget.username,
                  password: widget.password,
                ),
              ),
            )
          ],
        ),
      );
    return mainErrorWidget;
  }
}
