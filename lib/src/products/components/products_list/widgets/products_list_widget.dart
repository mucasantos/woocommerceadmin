import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/products/components/products_list/widgets/products_list_item_widget.dart';
import 'package:woocommerceadmin/src/products/models/products.dart';

class ProductsListWidget extends StatelessWidget {
  final String baseurl;
  final String username;
  final String password;

  ProductsListWidget({
    @required this.baseurl,
    @required this.username,
    @required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<Products>(
      builder: (context, productsListData, _) {
        return ListView.builder(
          itemCount: productsListData.products.length,
          itemBuilder: (BuildContext context, int index) {
            return ProductItemWidget(
              baseurl: baseurl,
              username: username,
              password: password,
              productData: productsListData.products[index],
            );
          },
        );
      },
    );
  }
}
