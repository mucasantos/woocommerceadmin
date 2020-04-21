import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/products/components/products_list/widgets/products_list_filters_modal.dart';
import 'package:woocommerceadmin/src/products/models/products.dart';

class ProductsListAppBar {
  static AppBar getAppBar({
    @required BuildContext context,
    @required String baseurl,
    @required String username,
    @required String password,
  }) {
    final Products productsProvider = Provider.of<Products>(context);
    return AppBar(
      title: Row(
        children: <Widget>[
          productsProvider.isSearching
              ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.search),
                )
              : SizedBox.shrink(),
          productsProvider.isSearching
              ? Expanded(
                  child: TextField(
                    controller: TextEditingController(
                        text: productsProvider.searchValue),
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
                      productsProvider.changeSearchValue(value);
                      Provider.of<Products>(context, listen: false)
                          .handleRefresh(
                        baseurl: baseurl,
                        username: username,
                        password: password,
                      );
                    },
                  ),
                )
              : Expanded(
                  child: Text("Products List"),
                ),
          productsProvider.isSearching
              ? IconButton(
                  icon: Icon(Icons.center_focus_strong),
                  onPressed: () => scanBarcode(
                    context: context,
                    baseurl: baseurl,
                    username: username,
                    password: password,
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    productsProvider.toggleIsSearching();
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
                      baseurl: baseurl,
                      username: username,
                      password: password,
                      productsProvider: productsProvider,
                    );
                  });
            },
          ),
          productsProvider.isSearching
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    bool isPreviousSearchValueNotEmpty = false;
                    if (productsProvider.searchValue.isNotEmpty) {
                      isPreviousSearchValueNotEmpty = true;
                    } else {
                      isPreviousSearchValueNotEmpty = false;
                    }
                    productsProvider.toggleIsSearching();
                    productsProvider.changeSearchValue("");
                    if (isPreviousSearchValueNotEmpty is bool &&
                        isPreviousSearchValueNotEmpty) {
                      Provider.of<Products>(context, listen: false)
                          .handleRefresh(
                        baseurl: baseurl,
                        username: username,
                        password: password,
                      );
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
    @required String baseurl,
    @required String username,
    @required String password,
  }) async {
    Products productsProvider = Provider.of<Products>(context, listen: false);
    try {
      String barcode = await BarcodeScanner.scan();
      productsProvider.changeSearchValue(barcode);
      productsProvider.handleRefresh(
        baseurl: baseurl,
        username: username,
        password: password,
      );
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
