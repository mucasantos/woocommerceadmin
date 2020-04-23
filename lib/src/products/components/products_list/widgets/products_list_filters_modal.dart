import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
import 'package:woocommerceadmin/src/products/providers/products_list_filters_provider.dart';

class ProductsListFiltersModal extends StatefulWidget {
  final Function handleRefresh;
  // final Products productsProvider;

  ProductsListFiltersModal({
    @required this.handleRefresh,
  });

  @override
  _ProductsListFiltersModalState createState() =>
      _ProductsListFiltersModalState();
}

class _ProductsListFiltersModalState extends State<ProductsListFiltersModal> {
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

  @override
  void didChangeDependencies() {
    if (isInit) {
      ProductsListFiltersProvider productsListFilters =
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
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Sort & Filter"),
      titlePadding: EdgeInsets.fromLTRB(15, 20, 15, 0),
      content: Container(
        height: 400,
        width: 200,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Sort by",
                style: Theme.of(context).textTheme.subhead,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: DropdownButton<String>(
                        underline: SizedBox.shrink(),
                        value: sortOrderByValue,
                        onChanged: (String value) {
                          // FocusScope.of(context).requestFocus(FocusNode());
                          setState(() {
                            sortOrderByValue = value;
                          });
                        },
                        items: <String>[
                          "date",
                          "id",
                          "title",
                          "slug",
                          "include"
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value.titleCase,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.body1,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.arrow_downward,
                        color: (sortOrderValue == "desc")
                            ? Theme.of(context).primaryColor
                            : Colors.black,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        sortOrderValue = "desc";
                      });
                    },
                  ),
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.arrow_upward,
                        color: (sortOrderValue == "asc")
                            ? Theme.of(context).primaryColor
                            : Colors.black,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        sortOrderValue = "asc";
                      });
                    },
                  ),
                ],
              ),
              Text(
                "Filter by",
                style: Theme.of(context).textTheme.subhead,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Status",
                            style: Theme.of(context).textTheme.body1.copyWith(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Expanded(child: SizedBox.shrink()),
                          Container(
                            height: 20,
                            child: DropdownButton<String>(
                              underline: SizedBox.shrink(),
                              value: statusFilterValue,
                              onChanged: (String newValue) {
                                // FocusScope.of(context)
                                //     .requestFocus(FocusNode());
                                setState(() {
                                  statusFilterValue = newValue;
                                });
                              },
                              items: <String>[
                                "any",
                                "draft",
                                "pending",
                                "private",
                                "publish"
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value.titleCase,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.body1,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Stock Status",
                            style: Theme.of(context).textTheme.body1.copyWith(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Expanded(child: SizedBox.shrink()),
                          Container(
                            height: 20,
                            child: DropdownButton<String>(
                              underline: SizedBox.shrink(),
                              value: stockStatusFilterValue,
                              onChanged: (String newValue) {
                                // FocusScope.of(context)
                                //     .requestFocus(FocusNode());
                                setState(() {
                                  stockStatusFilterValue = newValue;
                                });
                              },
                              items: <String>[
                                "all",
                                "instock",
                                "outofstock",
                                "onbackorder",
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value.titleCase,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.body1,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Featured",
                            style: Theme.of(context).textTheme.body1.copyWith(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Expanded(child: SizedBox.shrink()),
                          Container(
                            height: 20,
                            child: Switch(
                                value: featuredFilterValue,
                                onChanged: (bool value) {
                                  setState(() {
                                    featuredFilterValue = value;
                                  }); //
                                }),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "On Sale",
                            style: Theme.of(context).textTheme.body1.copyWith(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Expanded(child: SizedBox.shrink()),
                          Container(
                            height: 20,
                            child: Switch(
                                value: onSaleFilterValue,
                                onChanged: (bool value) {
                                  setState(() {
                                    onSaleFilterValue = value;
                                  }); //
                                }),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Price",
                            style: Theme.of(context).textTheme.body1.copyWith(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: TextFormField(
                                    initialValue: minPriceFilterValue is String
                                        ? minPriceFilterValue
                                        : "",
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter(
                                          RegExp(r"^\d*\.?\d*"))
                                    ],
                                    decoration:
                                        InputDecoration(labelText: "Min"),
                                    onChanged: (value) {
                                      setState(() {
                                        minPriceFilterValue = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: TextFormField(
                                    initialValue: maxPriceFilterValue is String
                                        ? maxPriceFilterValue
                                        : "",
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter(
                                          RegExp(r"^\d*\.?\d*"))
                                    ],
                                    decoration:
                                        InputDecoration(labelText: "Min"),
                                    onChanged: (value) {
                                      setState(() {
                                        maxPriceFilterValue = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: <Widget>[
                    //       Text(
                    //         "Date",
                    //         style: Theme.of(context).textTheme.body1.copyWith(
                    //             fontWeight: FontWeight.bold, fontSize: 16),
                    //       ),
                    //       Row(
                    //         children: <Widget>[
                    //           Text(
                    //             "From",
                    //             style: Theme.of(context).textTheme.body1,
                    //           ),
                    //           Expanded(child: SizedBox.shrink()),
                    //           RaisedButton(
                    //             onPressed: () async {
                    //               FocusScope.of(context)
                    //                   .requestFocus(FocusNode());
                    //               final DateTime picked = await showDatePicker(
                    //                   context: context,
                    //                   initialDate: (fromDateFilterValue !=
                    //                               null &&
                    //                           fromDateFilterValue is DateTime)
                    //                       ? fromDateFilterValue
                    //                       : DateTime.now()
                    //                           .subtract(Duration(days: 6)),
                    //                   firstDate: DateTime(2015, 8),
                    //                   lastDate: DateTime(2101));
                    //               if (picked != fromDateFilterValue)
                    //                 setState(() {
                    //                   fromDateFilterValue = picked;
                    //                 });
                    //             },
                    //             child: Text(
                    //               fromDateFilterValue != null &&
                    //                       fromDateFilterValue is DateTime
                    //                   ? "${fromDateFilterValue.toLocal()}"
                    //                       .split(' ')[0]
                    //                   : "Select Date",
                    //               style: Theme.of(context).textTheme.body1,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       Row(
                    //         children: <Widget>[
                    //           Text(
                    //             "To",
                    //             style: Theme.of(context).textTheme.body1,
                    //           ),
                    //           Expanded(child: SizedBox.shrink()),
                    //           RaisedButton(
                    //             onPressed: () async {
                    //               FocusScope.of(context)
                    //                   .requestFocus(FocusNode());
                    //               final DateTime picked = await showDatePicker(
                    //                   context: context,
                    //                   initialDate: (toDateFilterValue != null &&
                    //                           toDateFilterValue is DateTime)
                    //                       ? toDateFilterValue
                    //                       : DateTime.now(),
                    //                   firstDate: DateTime(2015, 8),
                    //                   lastDate: DateTime(2101));
                    //               if (picked != toDateFilterValue)
                    //                 setState(() {
                    //                   toDateFilterValue = picked;
                    //                 });
                    //             },
                    //             child: Text(
                    //               toDateFilterValue != null &&
                    //                       toDateFilterValue is DateTime
                    //                   ? "${toDateFilterValue.toLocal()}"
                    //                       .split(' ')[0]
                    //                   : "Select Date",
                    //               style: Theme.of(context).textTheme.body1,
                    //             ),
                    //           ),
                    //         ],
                    //       )
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 0),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text("Apply"),
          onPressed: () {
            ProductsListFiltersProvider productsListFilters =
                Provider.of<ProductsListFiltersProvider>(context, listen: false);
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
        )
      ],
    );
  }
}
