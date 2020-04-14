import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recase/recase.dart';
import 'package:http/http.dart' as http;

class EditProductPricingPage extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  final String regularPrice;
  final String salePrice;
  final DateTime dateOnSaleFrom;
  final DateTime dateOnSaleTo;
  final String taxStatus;
  final String taxClass;

  EditProductPricingPage({
    @required this.baseurl,
    @required this.username,
    @required this.password,
    this.regularPrice,
    this.salePrice,
    this.dateOnSaleFrom,
    this.dateOnSaleTo,
    this.taxStatus,
    this.taxClass,
  });

  @override
  _EditProductPricingPageState createState() => _EditProductPricingPageState();
}

class _EditProductPricingPageState extends State<EditProductPricingPage> {
  String regularPrice;
  String salePrice;
  DateTime dateOnSaleFrom;
  DateTime dateOnSaleTo;
  String taxStatus;
  String taxClass;

  bool _showSaleDates = false;

  List productTaxClasses = [];
  bool isProductTaxClassesReady = false;
  bool isProductTaxClassesError = false;
  String productTaxClassesError;

  TextEditingController _dateOnSaleFromController = TextEditingController();
  TextEditingController _dateOnSaleToController = TextEditingController();

  @override
  void initState() {
    regularPrice = widget.regularPrice;
    salePrice = widget.salePrice;
    dateOnSaleFrom = widget.dateOnSaleFrom;
    _dateOnSaleFromController.text = dateOnSaleFrom is DateTime
        ? "${dateOnSaleFrom.toLocal()}".split(' ')[0]
        : "";
    _dateOnSaleToController.text = dateOnSaleTo is DateTime
        ? "${dateOnSaleTo.toLocal()}".split(' ')[0]
        : "";
    dateOnSaleTo = widget.dateOnSaleTo;
    taxStatus = widget.taxStatus;
    taxClass = widget.taxClass;
    fetchProductTaxClasses();
    super.initState();
  }

  @override
  void setState(Function fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _dateOnSaleFromController.dispose();
    _dateOnSaleToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Price"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Text(
              "Price",
              style: Theme.of(context).textTheme.subhead,
            ),
            TextFormField(
              initialValue: regularPrice ?? "",
              style: Theme.of(context).textTheme.body2,
              keyboardType: TextInputType.number,
              inputFormatters: [
                WhitelistingTextInputFormatter(RegExp(r"^\d*\.?\d*"))
              ],
              decoration: InputDecoration(
                labelText: "Regular Price",
              ),
              onChanged: (value) {
                setState(() {
                  regularPrice = value;
                });
              },
            ),
            TextFormField(
              initialValue: salePrice ?? "",
              style: Theme.of(context).textTheme.body2,
              keyboardType: TextInputType.number,
              inputFormatters: [
                WhitelistingTextInputFormatter(RegExp(r"^\d*\.?\d*"))
              ],
              decoration: InputDecoration(labelText: "Sale Price"),
              onChanged: (value) {
                setState(() {
                  salePrice = value;
                });
              },
            ),
            SizedBox(
              height: 10,
            ),
            Divider(),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "Schedule Sale",
                    style: Theme.of(context).textTheme.body2,
                  ),
                ),
                Switch(
                  value: _showSaleDates,
                  onChanged: (bool value) {
                    setState(() {
                      _showSaleDates = value;
                    }); //
                  },
                ),
              ],
            ),
            if (_showSaleDates)
              Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      final DateTime picked = await showDatePicker(
                        context: context,
                        initialDate: dateOnSaleFrom ??
                            DateTime.now().subtract(Duration(days: 6)),
                        firstDate: DateTime(2015, 8),
                        lastDate: DateTime(2101),
                      );
                      if (picked != dateOnSaleFrom)
                        setState(() {
                          dateOnSaleFrom = picked;
                          _dateOnSaleFromController.value = TextEditingValue(
                              text: dateOnSaleFrom is DateTime
                                  ? "${dateOnSaleFrom.toLocal()}".split(' ')[0]
                                  : "");
                        });
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _dateOnSaleFromController,
                        style: Theme.of(context).textTheme.body2,
                        keyboardType: TextInputType.datetime,
                        decoration: InputDecoration(
                          labelText: "From",
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      final DateTime picked = await showDatePicker(
                        context: context,
                        initialDate: dateOnSaleTo ??
                            DateTime.now().subtract(Duration(days: 6)),
                        firstDate: DateTime(2015, 8),
                        lastDate: DateTime(2101),
                      );
                      if (picked != dateOnSaleFrom)
                        setState(() {
                          dateOnSaleTo = picked;
                          _dateOnSaleToController.value = TextEditingValue(
                              text: dateOnSaleTo is DateTime
                                  ? "${dateOnSaleTo.toLocal()}".split(' ')[0]
                                  : "");
                        });
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _dateOnSaleToController,
                        style: Theme.of(context).textTheme.body2,
                        keyboardType: TextInputType.datetime,
                        decoration: InputDecoration(
                          labelText: "To",
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            Divider(),
            SizedBox(
              height: 10,
            ),
            Text(
              "Tax Setting",
              style: Theme.of(context).textTheme.subhead,
            ),
            SizedBox(
              height: 10,
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: taxStatus,
              onChanged: (String newValue) {
                FocusScope.of(context).requestFocus(FocusNode());
                setState(() {
                  taxStatus = newValue;
                });
              },
              items: <String>["taxable", "shipping", "none"]
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
            // !isProductTaxClassesReady && productTaxClasses is List
            //     ? SizedBox.shrink()
            //     : Padding(
            //         padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            //         child: DropdownButton<String>(
            //             isExpanded: true,
            //             value: taxStatus,
            //             onChanged: (String newValue) {
            //               FocusScope.of(context).requestFocus(FocusNode());
            //               setState(() {
            //                 taxStatus = newValue;
            //               });
            //             },
            //             items: productTaxClasses.map((item) {
            //               print(item);
            // if (item is Map &&
            //     item.containsKey("tax_class") &&
            //     item["tax_class"] is String &&
            //     item["tax_class"].isNotEmpty) {
            //   return DropdownMenuItem<String>(
            //     value: item["tax_class"],
            //     child: Text(
            //       item["tax_class"].titleCase,
            //       style: Theme.of(context).textTheme.body2,
            //       textAlign: TextAlign.center,
            //     ),
            //   );
            // }
            // }).toList(),
            // ),
          ],
        ),
      ),
    );
  }

  Future<Null> fetchProductTaxClasses() async {
    String url =
        "${widget.baseurl}/wp-json/wc/v3/taxes/classes?consumer_key=${widget.username}&consumer_secret=${widget.password}";
    setState(() {
      isProductTaxClassesError = false;
      isProductTaxClassesReady = false;
    });
    http.Response response;
    try {
      response = await http.get(url);
      if (response.statusCode == 200) {
        dynamic responseBody = json.decode(response.body);
        if (responseBody is List && responseBody.length > 0) {
          setState(() {
            productTaxClasses = responseBody;
            isProductTaxClassesReady = true;
            isProductTaxClassesError = false;
          });
        } else {
          setState(() {
            isProductTaxClassesReady = false;
            isProductTaxClassesError = true;
            productTaxClassesError = "Failed to fetch product tax classes";
          });
        }
      } else {
        String errorCode = "";
        if (json.decode(response.body) is Map &&
            json.decode(response.body).containsKey("code") &&
            json.decode(response.body)["code"] is String) {
          errorCode = json.decode(response.body)["code"];
        }
        setState(() {
          isProductTaxClassesReady = false;
          isProductTaxClassesError = true;
          productTaxClassesError =
              "Failed to fetch product tax classes. Error: $errorCode";
        });
      }
    } on SocketException catch (_) {
      setState(() {
        isProductTaxClassesReady = false;
        isProductTaxClassesError = true;
        productTaxClassesError =
            "Failed to fetch product tax classes. Error: Network not reachable";
      });
    } catch (e) {
      setState(() {
        isProductTaxClassesReady = false;
        isProductTaxClassesError = true;
        productTaxClassesError =
            "Failed to fetch product tax classes. Error: $e";
      });
    }
  }
}
