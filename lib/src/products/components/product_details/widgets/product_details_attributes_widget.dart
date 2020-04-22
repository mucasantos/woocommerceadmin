import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/products/components/product_details/helpers/product_details_widget_helpers.dart';
import 'package:woocommerceadmin/src/products/models/product.dart';
import 'package:woocommerceadmin/src/products/models/products.dart';

class ProductDetailsAttributesWidget extends StatelessWidget {
  final String baseurl;
  final String username;
  final String password;
  final int id;

  ProductDetailsAttributesWidget({
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final Product productData =
        Provider.of<Products>(context).getProductById(this.id);
    Widget productAttributesWidget = SizedBox.shrink();
    List<Widget> productAttributesWidgetData = [];

    if (productData?.attributes is List && productData.attributes.isNotEmpty) {
      for (int i = 0; i < productData.attributes.length; i++) {
        if (productData.attributes[i]?.name is String &&
            productData.attributes[i].name.isNotEmpty) {
          String attributeName = "${productData.attributes[i].name}: ";
          String attributeOptions = "";

          if (productData.attributes[i]?.options is List &&
              productData.attributes[i].options.isNotEmpty) {
            for (int j = 0; j < productData.attributes[i].options.length; j++) {
              if (productData.attributes[i].options[j] is String &&
                  productData.attributes[i].options[j].isNotEmpty) {
                attributeOptions +=
                    (j == productData.attributes[i].options.length - 1
                        ? productData.attributes[i].options[j]
                        : "${productData.attributes[i].options[j]}, ");
              }
            }
          }
          productAttributesWidgetData.add(
            ProductDetailsWidgetsHelper.getItemRow(
              context: context,
              item1: attributeName,
              item2: attributeOptions,
            ),
          );
        }
      }
      if (productAttributesWidgetData.isNotEmpty) {
        productAttributesWidget = ProductDetailsWidgetsHelper.getExpansionTile(
          context: context,
          title: "Attributes",
          widgetsList: productAttributesWidgetData,
        );
      }
    }
    return productAttributesWidget;
  }
}
