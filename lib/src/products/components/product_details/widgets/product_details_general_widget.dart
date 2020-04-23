import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
import 'package:woocommerceadmin/src/products/components/edit_product/screens/edit_product_general_screen.dart';
import 'package:woocommerceadmin/src/products/components/product_details/helpers/product_details_widget_helpers.dart';
import 'package:woocommerceadmin/src/products/models/product.dart';
import 'package:woocommerceadmin/src/products/providers/product_provider.dart';

class ProductDetailsGeneralWidget extends StatelessWidget {
  final String baseurl;
  final String username;
  final String password;

  ProductDetailsGeneralWidget({
    @required this.baseurl,
    @required this.username,
    @required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final ProductProvider productProvider =
        Provider.of<ProductProvider>(context);
    final Product productData = productProvider.product;
    Widget productGeneralWidget = SizedBox.shrink();
    List<Widget> productGeneralWidgetData = [];

    if (productData?.id is int) {
      productGeneralWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Id: ",
          item2: "${productData.id}",
        ),
      );
    }

    if (productData?.slug is String && productData.slug.isNotEmpty) {
      productGeneralWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Slug: ",
          item2: productData.slug,
        ),
      );
    }

    if (productData?.permalink is String && productData.permalink.isNotEmpty) {
      productGeneralWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Permalink: ",
          item2: productData.permalink,
          linkify: true,
        ),
      );
    }

    if (productData?.type is String && productData.type.isNotEmpty) {
      productGeneralWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Type: ",
          item2: productData.type.titleCase,
        ),
      );
    }

    if (productData?.status is String && productData.status.isNotEmpty) {
      productGeneralWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Status: ",
          item2: productData.status.titleCase,
        ),
      );
    }

    if (productData?.catalogVisibility is String &&
        productData.catalogVisibility.isNotEmpty) {
      productGeneralWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Catalog visibility: ",
          item2: productData.catalogVisibility.titleCase,
        ),
      );
    }

    if (productData?.purchasable is bool) {
      productGeneralWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Purchasable: ",
          item2: productData.purchasable ? "Yes" : "No",
        ),
      );
    }

    if (productData?.featured is bool) {
      productGeneralWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Featured: ",
          item2: productData.featured ? "Yes" : "No",
        ),
      );
    }

    if (productData?.onSale is bool) {
      productGeneralWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "On Sale: ",
          item2: productData.onSale ? "Yes" : "No",
        ),
      );
    }

    if (productData?.virtual is bool) {
      productGeneralWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Virtual: ",
          item2: productData.virtual ? "Yes" : "No",
        ),
      );
    }

    if (productData?.downloadable is bool) {
      productGeneralWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Downloadable: ",
          item2: productData.downloadable ? "Yes" : "No",
        ),
      );
    }

    if (productData?.totalSales is int) {
      productGeneralWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Total ordered: ",
          item2: "${productData.totalSales}",
        ),
      );
    }

    if (productData.backordered is bool) {
      productGeneralWidgetData.add(
        ProductDetailsWidgetsHelper.getItemRow(
          context: context,
          item1: "Backordered: ",
          item2: productData.backordered ? "Yes" : "No",
        ),
      );
    }

    if (productGeneralWidgetData.isNotEmpty) {
      productGeneralWidget = ProductDetailsWidgetsHelper.getExpansionTile(
        context: context,
        title: "General",
        widgetsList: productGeneralWidgetData,
        isTappable: true,
        onTap: () async {
          String result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value(
                value: productProvider,
                child: EditProductGeneralScreen(
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
    return productGeneralWidget;
  }
}
