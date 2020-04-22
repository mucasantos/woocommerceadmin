import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
import 'package:woocommerceadmin/src/products/components/edit_product/screens/edit_product_pricing_screen.dart';
import 'package:woocommerceadmin/src/products/components/product_details/helpers/product_details_widget_helpers.dart';
import 'package:woocommerceadmin/src/products/models/product.dart';
import 'package:woocommerceadmin/src/products/models/products.dart';

class ProductDetailsPricingWidget extends StatelessWidget {
  final String baseurl;
  final String username;
  final String password;
  final int id;

  ProductDetailsPricingWidget({
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final Product productData = Provider.of<Products>(context).getProductById(this.id);
    Widget productPricingWidget = SizedBox.shrink();
    List<Widget> productPricingWidgetData = [];

    if (productData?.regularPrice is String &&
        productData.regularPrice.isNotEmpty) {
      productPricingWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Regular Price: ",
          item2: productData.regularPrice,
        ),
      );
    }

    if (productData?.salePrice is String && productData.salePrice.isNotEmpty) {
      productPricingWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Sale Price: ",
          item2: productData.salePrice,
        ),
      );
    }

    if (productData.dateOnSaleFrom is DateTime) {
      productPricingWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Sale start date: ",
          item2:
              DateFormat("EEEE, dd/MM/yyyy").format(productData.dateOnSaleFrom),
        ),
      );
    }

    if (productData.dateOnSaleTo is DateTime) {
      productPricingWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Sale end date: ",
          item2:
              DateFormat("EEEE, dd/MM/yyyy").format(productData.dateOnSaleTo),
        ),
      );
    }

    if (productData.taxStatus is String && productData.taxStatus.isNotEmpty) {
      productPricingWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Tax status: ",
          item2: productData.taxStatus.titleCase,
        ),
      );
    }

    if (productData.taxClass.isNotEmpty && productData.taxClass.isNotEmpty) {
      productPricingWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Tax class: ",
          item2: productData.taxClass,
        ),
      );
    }

    if (productPricingWidgetData.isNotEmpty) {
      productPricingWidget = ProductDetailsWidgetsHelper.getExpansionTile(
        context: context,
        title: "Pricing",
        widgetsList: productPricingWidgetData,
        isTappable: true,
        onTap: () async {
          String result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProductPricingScreen(
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
    return productPricingWidget;
  }
}
