import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/products/components/products_list/widgets/products_list_item_widget.dart';
import 'package:woocommerceadmin/src/products/providers/product_providers_list.dart';

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
    return Consumer<ProductProvidersList>(
      builder: (context, productsListProvider, _) {
        return ListView.builder(
          itemCount: productsListProvider.productProviders.length,
          itemBuilder: (BuildContext context, int index) {
            return ProductItemWidget(
              baseurl: baseurl,
              username: username,
              password: password,
              productProvider: productsListProvider.productProviders[index],
            );
          },
        );
      },
    );
  }
}
