import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/orders/components/orders_list/widgets/orders_list_filters_modal.dart';
import 'package:woocommerceadmin/src/orders/providers/orders_list_filters_provider.dart';

class OrdersListAppbar {
  static AppBar getAppBar({
    @required BuildContext context,
    @required Function handleRefresh,
    @required String baseurl,
    @required String username,
    @required String password,
  }) {
    final OrdersListFiltersProvider ordersListFiltersProvider =
        Provider.of<OrdersListFiltersProvider>(context);

    return AppBar(
      title: Row(
        children: <Widget>[
          ordersListFiltersProvider.isSearching
              ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.search),
                )
              : SizedBox.shrink(),
          ordersListFiltersProvider.isSearching
              ? Expanded(
                  child: TextField(
                    controller: TextEditingController(
                        text: ordersListFiltersProvider.searchValue),
                    style: TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search Orders",
                      hintStyle: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.6),
                      ),
                    ),
                    cursorColor: Colors.white,
                    onSubmitted: (String value) {
                      ordersListFiltersProvider.changeSearchValue(value);
                      handleRefresh();
                    },
                  ),
                )
              : Expanded(
                  child: Text("Orders List"),
                ),
          ordersListFiltersProvider.isSearching
              ? IconButton(
                  icon: Icon(Icons.center_focus_strong),
                  onPressed: () {
                    scanBarcode(
                      context: context,
                      handleRefresh: handleRefresh,
                    );
                  },
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    ordersListFiltersProvider.toggleIsSearching();
                  },
                ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return OrdersListFiltersModal(
                    baseurl: baseurl,
                    username: username,
                    password: password,
                    handleRefresh: handleRefresh,
                  );
                },
              );
            },
          ),
          ordersListFiltersProvider.isSearching
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    bool isPreviousSearchValueNotEmpty = false;
                    if (ordersListFiltersProvider.searchValue.isNotEmpty) {
                      isPreviousSearchValueNotEmpty = true;
                    } else {
                      isPreviousSearchValueNotEmpty = false;
                    }
                    ordersListFiltersProvider.toggleIsSearching();
                    ordersListFiltersProvider.changeSearchValue("");
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
    OrdersListFiltersProvider ordersListFiltersProvider =
        Provider.of<OrdersListFiltersProvider>(context, listen: false);
    try {
      String barcode = await BarcodeScanner.scan();
      ordersListFiltersProvider.changeSearchValue(barcode);
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
