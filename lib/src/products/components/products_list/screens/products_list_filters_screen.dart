import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/common/widgets/single_select.dart';
import 'package:woocommerceadmin/src/products/providers/products_list_filters_provider.dart';

class ProductsListFiltersScreen extends StatefulWidget {
  final Function handleRefresh;

  ProductsListFiltersScreen({
    Key key,
    @required this.handleRefresh,
  }) : super(key: key);

  @override
  _ProductsListFiltersScreenState createState() =>
      _ProductsListFiltersScreenState();
}

class _ProductsListFiltersScreenState extends State<ProductsListFiltersScreen> {
  bool isInit = true;
  String sortOrderByValue = "date";
  String sortOrderValue = "desc";

  String statusFilterValue = "any";
  String stockStatusFilterValue = "all";
  bool featuredFilterValue = false;
  bool onSaleFilterValue = false;
  String minPriceFilterValue = "";
  String maxPriceFilterValue = "";
  DateTime fromDateFilterValue;
  DateTime toDateFilterValue;

  TextEditingController _fromDateFilterController = TextEditingController();
  TextEditingController _toDateFilterValueController = TextEditingController();

  final List<SingleSelectMenu> sortOrderByOptions = [
    SingleSelectMenu(value: "registered_date", name: "Registered Date"),
    SingleSelectMenu(value: "id", name: "Id"),
    SingleSelectMenu(value: "name", name: "Name"),
    SingleSelectMenu(value: "include", name: "Include"),
  ];

  final List<SingleSelectMenu> statusFilterOptions = [
    SingleSelectMenu(value: "any", name: "Any"),
    SingleSelectMenu(value: "draft", name: "Draft"),
    SingleSelectMenu(value: "pending", name: "Pending"),
    SingleSelectMenu(value: "private", name: "Private"),
    SingleSelectMenu(value: "publish", name: "Publish"),
  ];

   final List<SingleSelectMenu> stockStatusFilterOptions = [
    SingleSelectMenu(value: "all", name: "All"),
    SingleSelectMenu(value: "instock", name: "In stock"),
    SingleSelectMenu(value: "outofstock", name: "Out of stock"),
    SingleSelectMenu(value: "onbackorder", name: "On backorder"),
  ];

  @override
  void didChangeDependencies() {
    if (isInit) {
      final ProductsListFiltersProvider productsListFilters =
          Provider.of<ProductsListFiltersProvider>(context, listen: false);
      sortOrderByValue = productsListFilters.sortOrderByValue;
      sortOrderValue = productsListFilters.sortOrderValue;
      statusFilterValue = productsListFilters.statusFilterValue;
      stockStatusFilterValue = productsListFilters.stockStatusFilterValue;
      featuredFilterValue = productsListFilters.featuredFilterValue;
      onSaleFilterValue = productsListFilters.onSaleFilterValue;
      minPriceFilterValue = productsListFilters.minPriceFilterValue;
      maxPriceFilterValue = productsListFilters.maxPriceFilterValue;
      fromDateFilterValue = productsListFilters.fromDateFilterValue;
      toDateFilterValue = productsListFilters.toDateFilterValue;
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _fromDateFilterController.dispose();
    _toDateFilterValueController.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products List Filter"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: SingleSelect(
                    labelText: "Sort by",
                    labelTextStyle: Theme.of(context).textTheme.body2,
                    modalHeadingTextStyle: Theme.of(context).textTheme.subhead,
                    modalListTextStyle: Theme.of(context).textTheme.body1,
                    selectedValue: sortOrderByValue,
                    options: sortOrderByOptions,
                    onChange: (value) {
                      setState(() {
                        sortOrderByValue = value;
                      });
                    },
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.arrow_downward,
                          color: (sortOrderValue == "desc")
                              ? Theme.of(context).primaryColor
                              : Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            sortOrderValue = "desc";
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_upward,
                          color: (sortOrderValue == "asc")
                              ? Theme.of(context).primaryColor
                              : Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            sortOrderValue = "asc";
                          });
                        },
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: SingleSelect(
                    labelText: "Filter by status",
                    labelTextStyle: Theme.of(context).textTheme.body2,
                    modalHeadingTextStyle: Theme.of(context).textTheme.subhead,
                    modalListTextStyle: Theme.of(context).textTheme.body1,
                    selectedValue: statusFilterValue,
                    options: statusFilterOptions,
                    onChange: (value) {
                      setState(() {
                        statusFilterValue = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: SingleSelect(
                    labelText: "Filter by stock status",
                    labelTextStyle: Theme.of(context).textTheme.body2,
                    modalHeadingTextStyle: Theme.of(context).textTheme.subhead,
                    modalListTextStyle: Theme.of(context).textTheme.body1,
                    selectedValue: stockStatusFilterValue,
                    options: stockStatusFilterOptions,
                    onChange: (value) {
                      setState(() {
                        stockStatusFilterValue = value;
                      });
                    },
                  ),
                ),
                CheckboxListTile(
                  title: Text(
                    "Featured",
                    style: Theme.of(context).textTheme.body2,
                  ),
                  value: featuredFilterValue,
                  onChanged: (bool value) {
                    setState(() {
                      featuredFilterValue = value;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(
                    "On sale",
                    style: Theme.of(context).textTheme.body2,
                  ),
                  value: onSaleFilterValue,
                  onChanged: (bool value) {
                    setState(() {
                      onSaleFilterValue = value;
                    });
                  },
                ),
                ListTile(
                  title: TextFormField(
                    initialValue: minPriceFilterValue is String
                        ? minPriceFilterValue
                        : "",
                    style: Theme.of(context).textTheme.body2,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp(r"^\d*\.?\d*"))
                    ],
                    decoration:
                        InputDecoration(labelText: "Fiter by minimum price"),
                    onChanged: (value) {
                      setState(() {
                        minPriceFilterValue = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: TextFormField(
                    initialValue: maxPriceFilterValue is String
                        ? maxPriceFilterValue
                        : "",
                    style: Theme.of(context).textTheme.body2,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp(r"^\d*\.?\d*"))
                    ],
                    decoration:
                        InputDecoration(labelText: "Fiter by maximum price"),
                    onChanged: (value) {
                      setState(() {
                        maxPriceFilterValue = value;
                      });
                    },
                  ),
                ),
                // ListTile(
                //   title: AbsorbPointer(
                //     child: TextFormField(
                //       controller: _fromDateFilterController,
                //       style: Theme.of(context).textTheme.body2,
                //       keyboardType: TextInputType.datetime,
                //       decoration: InputDecoration(
                //         labelText: "Filter by from date",
                //         suffixIcon: Icon(Icons.arrow_drop_down),
                //       ),
                //     ),
                //   ),
                //   onTap: () async {
                //     FocusScope.of(context).requestFocus(FocusNode());
                //     final DateTime picked = await showDatePicker(
                //       context: context,
                //       initialDate: fromDateFilterValue ??
                //           DateTime.now().subtract(Duration(days: 6)),
                //       firstDate: DateTime(2015, 8),
                //       lastDate: DateTime(2101),
                //       builder: (context, child) {
                //         return Localizations.override(
                //           context: context,
                //           delegates: [
                //             CancelButtonLocalizationDelegate(),
                //           ],
                //           child: child,
                //         );
                //       },
                //     );
                //     if (picked != fromDateFilterValue) {
                //       setState(() {
                //         fromDateFilterValue = picked;
                //         _fromDateFilterController.value = TextEditingValue(
                //             text: fromDateFilterValue is DateTime
                //                 ? "${fromDateFilterValue.toLocal()}"
                //                     .split(' ')[0]
                //                 : "");
                //       });
                //     }
                //   },
                // ),
                // ListTile(
                //   title: AbsorbPointer(
                //     child: TextFormField(
                //       controller: _toDateFilterValueController,
                //       style: Theme.of(context).textTheme.body2,
                //       keyboardType: TextInputType.datetime,
                //       decoration: InputDecoration(
                //         labelText: "Filter by to date",
                //         suffixIcon: Icon(Icons.arrow_drop_down),
                //       ),
                //     ),
                //   ),
                //   onTap: () async {
                //     FocusScope.of(context).requestFocus(FocusNode());
                //     final DateTime picked = await showDatePicker(
                //       context: context,
                //       initialDate: toDateFilterValue ??
                //           DateTime.now().subtract(Duration(days: 6)),
                //       firstDate: DateTime(2015, 8),
                //       lastDate: DateTime(2101),
                //       builder: (context, child) {
                //         return Localizations.override(
                //           context: context,
                //           delegates: [
                //             CancelButtonLocalizationDelegate(),
                //           ],
                //           child: child,
                //         );
                //       },
                //     );
                //     if (picked != toDateFilterValue) {
                //       setState(() {
                //         toDateFilterValue = picked;
                //         _toDateFilterValueController.value = TextEditingValue(
                //             text: toDateFilterValue is DateTime
                //                 ? "${toDateFilterValue.toLocal()}".split(' ')[0]
                //                 : "");
                //       });
                //     }
                //   },
                // ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 50,
                  child: RaisedButton(
                    child: Text(
                      "Apply",
                      style: Theme.of(context).textTheme.button,
                    ),
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      ProductsListFiltersProvider productsListFilters =
                          Provider.of<ProductsListFiltersProvider>(context,
                              listen: false);
                      productsListFilters.changeFilterModalValues(
                          sortOrderByValue: sortOrderByValue,
                          sortOrderValue: sortOrderValue,
                          statusFilterValue: statusFilterValue,
                          stockStatusFilterValue: stockStatusFilterValue,
                          featuredFilterValue: featuredFilterValue,
                          onSaleFilterValue: onSaleFilterValue,
                          minPriceFilterValue: minPriceFilterValue,
                          maxPriceFilterValue: maxPriceFilterValue,
                          fromDateFilterValue: fromDateFilterValue,
                          toDateFilterValue: toDateFilterValue);
                      widget.handleRefresh();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//For Custom Cancel Button in DatePicker
class CancelButtonLocalizationDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const CancelButtonLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      Future.value(CancelButtonLocalization());

  @override
  bool shouldReload(CancelButtonLocalizationDelegate old) => false;
}

class CancelButtonLocalization extends DefaultMaterialLocalizations {
  const CancelButtonLocalization();

  @override
  String get cancelButtonLabel => "Clear";
}
