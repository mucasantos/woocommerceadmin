import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/products/components/edit_product/screens/edit_product_categories_screen.dart';
import 'package:woocommerceadmin/src/products/components/product_details/helpers/product_details_widget_helpers.dart';
import 'package:woocommerceadmin/src/products/models/product.dart';
import 'package:woocommerceadmin/src/products/models/products.dart';

class ProductDetailsCategoriesWidget extends StatelessWidget {
  final String baseurl;
  final String username;
  final String password;
  final int id;

  ProductDetailsCategoriesWidget({
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final Product productData =
        Provider.of<Products>(context).getProductById(this.id);
    Widget productCategoriesWidget = SizedBox.shrink();

    if (productData?.categories is List && productData.categories.isNotEmpty) {
      List<Widget> productCategoriesWidgetData = [
        Wrap(
          spacing: 5,
          children: <Widget>[
            for (var i = 0; i < productData.categories.length; i++)
              if (productData.categories[i]?.name is String &&
                  productData.categories[i].name.isNotEmpty)
                Container(
                  height: 40,
                  child: Chip(
                    label: Text(
                      productData.categories[i].name,
                      style: Theme.of(context).textTheme.body1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    // backgroundColor: Color(0xffededed),
                  ),
                ),
          ],
        )
      ];

      if (productCategoriesWidgetData.isNotEmpty) {
        productCategoriesWidget = ProductDetailsWidgetsHelper.getExpansionTile(
          context: context,
          title: "Categories",
          widgetsList: productCategoriesWidgetData,
          isTappable: true,
          onTap: () async {
            String result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProductCategoriesScreen(
                  baseurl: this.baseurl,
                  username: this.username,
                  password: this.password,
                  id: this.id,
                ),
              ),
            );

            if (result is String) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(result.toString()),
                  duration: Duration(seconds: 3),
                ),
              );
            }
          },
        );
      }
    }
    return productCategoriesWidget;
  }
}
