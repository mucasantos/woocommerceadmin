import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recase/recase.dart';

class EditProductInventoryPage extends StatefulWidget {
  final String stockStatus;
  final bool manageStock;
  final int stockQuantity;
  final bool backordersAllowed;
  final String backorders;

  EditProductInventoryPage({
    this.stockStatus,
    this.manageStock,
    this.stockQuantity,
    this.backordersAllowed,
    this.backorders,
  });

  @override
  _EditProductInventoryPageState createState() =>
      _EditProductInventoryPageState();
}

class _EditProductInventoryPageState extends State<EditProductInventoryPage> {
  String stockStatus;
  bool manageStock;
  int stockQuantity;
  bool backordersAllowed;
  String backorders;

  @override
  void initState() {
    stockStatus = widget.stockStatus;
    manageStock = widget.manageStock;
    stockQuantity = widget.stockQuantity;
    backordersAllowed = widget.backordersAllowed;
    backorders = widget.backorders;
    super.initState();
  }

  @override
  void setState(Function fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (stockStatus == "outofstock") {
      manageStock = false;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventory"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Text(
              "Stock Status",
              style: Theme.of(context).textTheme.body2,
            ),
            // DropdownButton<String>(
            //   isExpanded: true,
            //   value: stockStatus,
            //   onChanged: (String newValue) {
            //     FocusScope.of(context).requestFocus(FocusNode());
            //     setState(() {
            //       stockStatus = newValue;
            //     });
            //   },
            //   items: [
            //     {"slug": "instock", "name": "In Stock"},
            //     {"slug": "outofstock", "name": "Out of Stock"},
            //     {"slug": "onbackorder", "name": "On Backorder"},
            //     {"slug": "", "name": "On Backorder"}
            //   ].map<DropdownMenuItem<String>>((item) {
            //     if (item.containsKey("slug") &&
            //         item["slug"].isNotEmpty &&
            //         item.containsKey("name") &&
            //         item["name"].isNotEmpty) {
            //       return DropdownMenuItem<String>(
            //         value: item["slug"],
            //         child: Text(
            //           item["name"].titleCase,
            //           style: Theme.of(context).textTheme.body2,
            //           textAlign: TextAlign.center,
            //         ),
            //       );
            //     }
            //     return null;
            //   }).toList(),
            // ),
            DropdownButton<String>(
              isExpanded: true,
              value: stockStatus,
              onChanged: (String value) {
                FocusScope.of(context).requestFocus(FocusNode());
                setState(() {
                  stockStatus = value;
                });
              },
              items: <String>["instock", "outofstock", "onbackorder"]
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value.titleCase,
                    style: Theme.of(context).textTheme.body2,
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            ),

            if (stockStatus == "instock")
              Column(
                children: <Widget>[
                  Divider(),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          "Manage Stock",
                          style: Theme.of(context).textTheme.body2,
                        ),
                      ),
                      Switch(
                        value: manageStock,
                        onChanged: (bool value) {
                          setState(() {
                            manageStock = value;
                          }); //
                        },
                      ),
                    ],
                  ),
                ],
              ),
            if (stockStatus == "instock" && manageStock)
              Column(
                children: <Widget>[
                  TextFormField(
                    initialValue: stockQuantity is int ? "$stockQuantity" : "",
                    style: Theme.of(context).textTheme.body2,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(labelText: "Stock Quantity"),
                    onChanged: (String value) {
                      try {
                        setState(() {
                          stockQuantity = int.parse(value);
                        });
                      } catch (e) {
                        try {
                          setState(() {
                            stockQuantity = double.parse(value).toInt();
                          });
                        } catch (e) {}
                      }
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            Divider(),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "Backorders Allowed",
                    style: Theme.of(context).textTheme.body2,
                  ),
                ),
                Switch(
                  value: backordersAllowed,
                  onChanged: (bool value) {
                    setState(() {
                      backordersAllowed = value;
                    }); //
                  },
                ),
              ],
            ),
            Divider(),
            SizedBox(
              height: 10,
            ),
            Text(
              "Backorders",
              style: Theme.of(context).textTheme.body2,
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: backorders,
              onChanged: (String value) {
                FocusScope.of(context).requestFocus(FocusNode());
                setState(() {
                  backorders = value;
                });
              },
              items: <String>["no", "notify", "yes"]
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value.titleCase,
                    style: Theme.of(context).textTheme.body2,
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
