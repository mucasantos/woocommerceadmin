import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/products/components/products_list/screens/products_list_filters_screen.dart';
import 'package:woocommerceadmin/src/products/providers/products_list_filters_provider.dart';

class ProductsListAppBar {
  static AppBar getAppBar({
    @required BuildContext context,
    @required Function handleRefresh,
  }) {
    final ProductsListFiltersProvider productsListFiltersProvider =
        Provider.of<ProductsListFiltersProvider>(context);
    return AppBar(
      title: Row(
        children: <Widget>[
          productsListFiltersProvider.isSearching
              ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.search),
                )
              : SizedBox.shrink(),
          productsListFiltersProvider.isSearching
              ? Expanded(
                  child: TextField(
                    controller: TextEditingController(
                        text: productsListFiltersProvider.searchValue),
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
                      productsListFiltersProvider.changeSearchValue(value);
                      handleRefresh();
                    },
                  ),
                )
              : Expanded(
                  child: Text("Products List"),
                ),
          productsListFiltersProvider.isSearching
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
                    productsListFiltersProvider.toggleIsSearching();
                  },
                ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductsListFiltersScreen(
                    handleRefresh: handleRefresh,
                  ),
                ),
              );
            },
          ),
          productsListFiltersProvider.isSearching
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    bool isPreviousSearchValueNotEmpty = false;
                    if (productsListFiltersProvider.searchValue.isNotEmpty) {
                      isPreviousSearchValueNotEmpty = true;
                    } else {
                      isPreviousSearchValueNotEmpty = false;
                    }
                    productsListFiltersProvider.toggleIsSearching();
                    productsListFiltersProvider.changeSearchValue("");
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
    ProductsListFiltersProvider productsListFilters =
        Provider.of<ProductsListFiltersProvider>(context, listen: false);
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
