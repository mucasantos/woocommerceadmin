import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
import 'package:woocommerceadmin/src/products/components/edit_product/screens/edit_product_inventory_screen.dart';
import 'package:woocommerceadmin/src/products/components/product_details/helpers/product_details_widget_helpers.dart';
import 'package:woocommerceadmin/src/products/models/product.dart';
import 'package:woocommerceadmin/src/products/models/products.dart';

class ProductDetailsInventoryWidget extends StatelessWidget {
  final String baseurl;
  final String username;
  final String password;
  final int id;

  ProductDetailsInventoryWidget({
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final Product productData =
        Provider.of<Products>(context).getProductById(this.id);
    Widget productInventoryWidget = SizedBox.shrink();
    List<Widget> productInventoryWidgetData = [];

    if (productData?.sku is String && productData.sku.isNotEmpty) {
      productInventoryWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Sku: ",
          item2: productData.sku,
        ),
      );
    }

    if (productData?.stockStatus is String &&
        productData.stockStatus.isNotEmpty) {
      productInventoryWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Stock status: ",
          item2: productData.stockStatus.titleCase,
        ),
      );
    }

    if (productData?.manageStock is bool) {
      productInventoryWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Manage stock: ",
          item2: productData.manageStock ? "Yes" : "No",
        ),
      );
    }

    if (productData?.stockQuantity is int) {
      productInventoryWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Stock quantity: ",
          item2: "${productData.stockQuantity}",
        ),
      );
    }

    if (productData?.backordersAllowed is bool) {
      productInventoryWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Backorders allowed: ",
          item2: productData.backordersAllowed ? "Yes" : "No",
        ),
      );
    }

    if (productData?.backorders is String) {
      productInventoryWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Backorders: ",
          item2: productData.backorders.titleCase,
        ),
      );
    }

    if (productData?.soldIndividually is bool) {
      productInventoryWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Sold individually: ",
          item2: productData.soldIndividually ? "Yes" : "No",
        ),
      );
    }

    if (productInventoryWidgetData.isNotEmpty) {
      productInventoryWidget = ProductDetailsWidgetsHelper.getExpansionTile(
        context: context,
        title: "Inventory",
        widgetsList: productInventoryWidgetData,
        isTappable: true,
        onTap: () async {
          String result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProductInventoryScreen(
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
    return productInventoryWidget;
  }
}
