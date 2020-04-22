import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/products/components/products_list/widgets/products_list_filters_modal.dart';
import 'package:woocommerceadmin/src/products/models/products_list_filters.dart';

class ProductsListAppBar {
  static AppBar getAppBar({
    @required BuildContext context,
    @required Function handleRefresh,
  }) {
    final ProductsListFilters productsListFilters =
        Provider.of<ProductsListFilters>(context);
    return AppBar(
      title: Row(
        children: <Widget>[
          productsListFilters.isSearching
              ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.search),
                )
              : SizedBox.shrink(),
          productsListFilters.isSearching
              ? Expanded(
                  child: TextField(
                    controller: TextEditingController(
                        text: productsListFilters.searchValue),
                    style: TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search Products",
                      hintStyle: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.6),
                      ),
                    ),
                    cursorColor: Colors.white,
                    onSubmitted: (String value) {
                      productsListFilters.changeSearchValue(value);
                      handleRefresh();
                    },
                  ),
                )
              : Expanded(
                  child: Text("Products List"),
                ),
          productsListFilters.isSearching
              ? IconButton(
                  icon: Icon(Icons.center_focus_strong),
                  onPressed: () => scanBarcode(
                    context: context,
                    handleRefresh: handleRefresh,
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    productsListFilters.toggleIsSearching();
                  },
                ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return ProductsListFiltersModal(
                      handleRefresh: handleRefresh,
                      // productsListFilters: productsListFilters,
                    );
                  });
            },
          ),
          productsListFilters.isSearching
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    bool isPreviousSearchValueNotEmpty = false;
                    if (productsListFilters.searchValue.isNotEmpty) {
                      isPreviousSearchValueNotEmpty = true;
                    } else {
                      isPreviousSearchValueNotEmpty = false;
                    }
                    productsListFilters.toggleIsSearching();
                    productsListFilters.changeSearchValue("");
                    if (isPreviousSearchValueNotEmpty is bool &&
                        isPreviousSearchValueNotEmpty) {
                      handleRefresh();
                    }
                  },
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  static Future<void> scanBarcode({
    @required BuildContext context,
    @required Function handleRefresh,
  }) async {
    ProductsListFilters productsListFilters =
        Provider.of<ProductsListFilters>(context, listen: false);
    try {
      String barcode = await BarcodeScanner.scan();
      productsListFilters.changeSearchValue(barcode);
      handleRefresh();
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Camera permission is not granted"),
          duration: Duration(seconds: 3),
        ));
      } else {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Unknown barcode scan error: $e"),
          duration: Duration(seconds: 3),
        ));
      }
    } on FormatException {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Barcode scan cancelled"),
        duration: Duration(seconds: 3),
      ));
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Unknown barcode scan error: $e"),
        duration: Duration(seconds: 3),
      ));
    }
  }
}
