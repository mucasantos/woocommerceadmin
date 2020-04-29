import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/customers/components/customers_list/screens/customer_list_filters_screen.dart';
import 'package:woocommerceadmin/src/customers/providers/customers_list_filters_provider.dart';

class CustomersListAppbar {
  static AppBar getAppBar({
    @required BuildContext context,
    @required Function handleRefresh,
  }) {
    final CustomersListFiltersProvider customersListFiltersProvider =
        Provider.of<CustomersListFiltersProvider>(context);

    return AppBar(
      title: Row(
        children: <Widget>[
          customersListFiltersProvider.isSearching
              ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.search),
                )
              : SizedBox.shrink(),
          customersListFiltersProvider.isSearching
              ? Expanded(
                  child: TextField(
                    controller: TextEditingController(
                        text: customersListFiltersProvider.searchValue),
                    style: TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search Users",
                      hintStyle: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.6),
                      ),
                    ),
                    cursorColor: Colors.white,
                    onSubmitted: (String value) {
                      customersListFiltersProvider.changeSearchValue(value);
                      handleRefresh();
                    },
                  ),
                )
              : Expanded(child: Text("Customers List")),
          customersListFiltersProvider.isSearching
              ? IconButton(
                  icon: Icon(Icons.center_focus_strong), onPressed: scanBarcode)
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    customersListFiltersProvider.toggleIsSearching();
                  },
                ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomersListFiltersScreen(
                    handleRefresh: handleRefresh,
                  ),
                ),
              );
            },
          ),
          customersListFiltersProvider.isSearching
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    bool isPreviousSearchValueNotEmpty = false;
                    if (customersListFiltersProvider.searchValue.isNotEmpty) {
                      isPreviousSearchValueNotEmpty = true;
                    } else {
                      isPreviousSearchValueNotEmpty = false;
                    }
                    customersListFiltersProvider.toggleIsSearching();
                    customersListFiltersProvider.changeSearchValue("");
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
    CustomersListFiltersProvider customersListFiltersProvider =
        Provider.of<CustomersListFiltersProvider>(context, listen: false);
    try {
      String barcode = await BarcodeScanner.scan();
      customersListFiltersProvider.changeSearchValue(barcode);
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
