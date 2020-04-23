import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
import 'package:woocommerceadmin/src/products/components/edit_product/screens/edit_product_shipping_screen.dart';
import 'package:woocommerceadmin/src/products/components/product_details/helpers/product_details_widget_helpers.dart';
import 'package:woocommerceadmin/src/products/models/product.dart';
import 'package:woocommerceadmin/src/products/providers/product_provider.dart';

class ProductDetailsShippingWidget extends StatelessWidget {
  final String baseurl;
  final String username;
  final String password;

  ProductDetailsShippingWidget({
    @required this.baseurl,
    @required this.username,
    @required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final ProductProvider productProvider =
        Provider.of<ProductProvider>(context);
    final Product productData = productProvider.product;

    Widget productShippingWidget = SizedBox.shrink();
    List<Widget> productShippingWidgetData = [];

    if (productData?.weight is String && productData.weight.isNotEmpty) {
      productShippingWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Weight: ",
          item2: productData.weight,
        ),
      );
    }

    if (productData?.dimensions?.length is String &&
        productData.dimensions.length.isNotEmpty) {
      productShippingWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Length: ",
          item2: productData.dimensions.length,
        ),
      );
    }

    if (productData?.dimensions?.width is String &&
        productData.dimensions.width.isNotEmpty) {
      productShippingWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Width: ",
          item2: productData.dimensions.width,
        ),
      );
    }

    if (productData?.dimensions?.height is String &&
        productData.dimensions.height.isNotEmpty) {
      productShippingWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Height: ",
          item2: productData.dimensions.height,
        ),
      );
    }

    if (productData?.shippingRequired is bool) {
      productShippingWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Shipping required: ",
          item2: productData.shippingRequired ? "Yes" : "No",
        ),
      );
    }

    if (productData?.shippingTaxable is bool) {
      productShippingWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Shipping taxable: ",
          item2: productData.shippingTaxable ? "Yes" : "No",
        ),
      );
    }

    if (productData?.shippingClass is String &&
        productData.shippingClass.isNotEmpty) {
      productShippingWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Shipping class: ",
          item2: productData.shippingClass.titleCase,
        ),
      );
    }

    if (productShippingWidgetData.isNotEmpty) {
      productShippingWidget = ProductDetailsWidgetsHelper.getExpansionTile(
        context: context,
        title: "Shipping",
        widgetsList: productShippingWidgetData,
        isTappable: true,
        onTap: () async {
          String result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value(
                value: productProvider,
                child: EditProductShippingScreen(
                  baseurl: this.baseurl,
                  username: this.username,
                  password: this.password,
                ),
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
    return productShippingWidget;
  }
}
