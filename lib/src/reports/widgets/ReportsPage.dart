import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

class ReportsPage extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;

  ReportsPage({
    Key key,
    @required this.baseurl,
    @required this.username,
    @required this.password,
  }) : super(key: key);

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String baseurl;
  String username;
  String password;

  DateTime fromDate = DateTime.now().subtract(Duration(days: 6));
  DateTime toDate = DateTime.now();

  bool isSalesTotalsReportReady = false;
  bool isSalesTotalsReportError = false;
  List salesTotalsReportData = [];
  String salesTotalsReportError;

  bool isOrdersTotalsReportReady = false;
  bool isOrdersTotalsReportError = false;
  List ordersTotalsReportData = [];
  String ordersTotalsReportError;

  bool isProductsTotalsReportReady = false;
  bool isProductsTotalsReportError = false;
  List productsTotalsReportData = [];
  String productsTotalsReportError;

  bool isCustomersTotalsReportReady = false;
  bool isCustomersTotalsReportError = false;
  List customersTotalsReportData = [];
  String customersTotalsReportError;

  bool isReviewsTotalsReportReady = false;
  bool isReviewsTotalsReportError = false;
  List reviewsTotalsReportData = [];
  String reviewsTotalsReportError;

  bool isCouponsTotalsReportReady = false;
  bool isCouponsTotalsReportError = false;
  List couponsTotalsReportData = [];
  String couponsTotalsReportError;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    baseurl = widget.baseurl;
    username = widget.username;
    password = widget.password;
    fetchAllReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reports"),
      ),
      body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: fetchAllReports,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _salesTotalsReportWidget(),
                _ordersTotalsReportWidget(),
                _productsTotalsReportWidget(),
                _customersTotalsReportWidget(),
                _reviewsTotalsReportWidget(),
                _couponsTotalsReportWidget()
              ],
            ),
          )),
    );
  }

  Future<void> fetchAllReports() async {
    fetchDateBasedReports();
    fetchNonDateBasedReports();
  }

  Future<void> fetchDateBasedReports() async {
    fetchSalesTotalsReport();
  }

  Future<void> fetchNonDateBasedReports() async {
    fetchOrdersTotalsReport();
    fetchProductsTotalsReport();
    fetchCustomersTotalsReport();
    fetchReviewsTotalsReport();
    fetchCouponsTotalsReport();
  }

  Future<void> fetchSalesTotalsReport() async {
    if (fromDate is DateTime && toDate is DateTime) {
      String url = "$baseurl/wp-json/wc/v3/reports/sales?date_min=" +
          DateFormat("yyyy-MM-dd").format(fromDate) +
          "&date_max=" +
          DateFormat("yyyy-MM-dd").format(toDate) +
          "&consumer_key=$username&consumer_secret=$password";
      setState(() {
        isSalesTotalsReportReady = false;
        isSalesTotalsReportError = false;
        salesTotalsReportData = [];
        salesTotalsReportError = null;
      });

      dynamic response;
      try {
        response = await http.get(url);
        dynamic responseBody = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseBody is List &&
              responseBody.isNotEmpty &&
              responseBody[0].containsKey("total_sales")) {
            setState(() {
              salesTotalsReportData = responseBody;
              isSalesTotalsReportReady = true;
              isSalesTotalsReportError = false;
            });
          } else {
            setState(() {
              isSalesTotalsReportReady = false;
              isSalesTotalsReportError = true;
              salesTotalsReportError =
                  "Unable to fetch sales totals report. Error: rest_incorrect_schema";
            });
          }
        } else {
          setState(() {
            isSalesTotalsReportReady = false;
            isSalesTotalsReportError = true;
            if (responseBody is Map && responseBody.containsKey("code")) {
              salesTotalsReportError =
                  "Unable to fetch sales totals report. Error: ${responseBody["code"]}";
            }
          });
        }
      } catch (e) {
        setState(() {
          isSalesTotalsReportReady = false;
          isSalesTotalsReportError = true;
          salesTotalsReportError =
              "Unable to fetch sales totals report. Error: $e";
        });
      }
    }
  }

  Future<void> fetchOrdersTotalsReport() async {
    String url =
        "$baseurl/wp-json/wc/v3/reports/orders/totals?consumer_key=$username&consumer_secret=$password";
    setState(() {
      isOrdersTotalsReportReady = false;
      isOrdersTotalsReportError = false;
      ordersTotalsReportData = [];
      ordersTotalsReportError = null;
    });

    dynamic response;
    try {
      response = await http.get(url);
      dynamic responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseBody is List && responseBody.isNotEmpty) {
          setState(() {
            ordersTotalsReportData = responseBody;
            isOrdersTotalsReportReady = true;
            isOrdersTotalsReportError = false;
          });
        } else {
          setState(() {
            isOrdersTotalsReportReady = false;
            isOrdersTotalsReportError = true;
            ordersTotalsReportError =
                "Unable to fetch orders totals report. Error: rest_incorrect_schema";
          });
        }
      } else {
        setState(() {
          isOrdersTotalsReportReady = false;
          isOrdersTotalsReportError = true;
          if (responseBody is Map && responseBody.containsKey("code")) {
            ordersTotalsReportError =
                "Unable to fetch orders totals report. Error: ${responseBody["code"]}";
          }
        });
      }
    } catch (e) {
      setState(() {
        isOrdersTotalsReportReady = false;
        isOrdersTotalsReportError = true;
        ordersTotalsReportError =
            "Unable to fetch orders totals report. Error: $e";
      });
    }
  }

  Future<void> fetchProductsTotalsReport() async {
    String url =
        "$baseurl/wp-json/wc/v3/reports/products/totals?consumer_key=$username&consumer_secret=$password";
    setState(() {
      isProductsTotalsReportReady = false;
      isProductsTotalsReportError = false;
      productsTotalsReportData = [];
      productsTotalsReportError = null;
    });

    dynamic response;
    try {
      response = await http.get(url);
      dynamic responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseBody is List && responseBody.isNotEmpty) {
          setState(() {
            productsTotalsReportData = responseBody;
            isProductsTotalsReportReady = true;
            isProductsTotalsReportError = false;
          });
        } else {
          setState(() {
            isProductsTotalsReportReady = false;
            isProductsTotalsReportError = true;
            productsTotalsReportError =
                "Unable to fetch products totals report. Error: rest_incorrect_schema";
          });
        }
      } else {
        setState(() {
          isProductsTotalsReportReady = false;
          isProductsTotalsReportError = true;
          if (responseBody is Map && responseBody.containsKey("code")) {
            productsTotalsReportError =
                "Unable to fetch products totals report. Error: ${responseBody["code"]}";
          }
        });
      }
    } catch (e) {
      setState(() {
        isProductsTotalsReportReady = false;
        isProductsTotalsReportError = true;
        productsTotalsReportError =
            "Unable to fetch products totals report. Error: $e";
      });
    }
  }

  Future<void> fetchCustomersTotalsReport() async {
    String url =
        "$baseurl/wp-json/wc/v3/reports/customers/totals?consumer_key=$username&consumer_secret=$password";
    setState(() {
      isCustomersTotalsReportReady = false;
      isCustomersTotalsReportError = false;
      customersTotalsReportData = [];
      customersTotalsReportError = null;
    });

    dynamic response;
    try {
      response = await http.get(url);
      dynamic responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseBody is List && responseBody.isNotEmpty) {
          setState(() {
            customersTotalsReportData = responseBody;
            isCustomersTotalsReportReady = true;
            isCustomersTotalsReportError = false;
          });
        } else {
          setState(() {
            isCustomersTotalsReportReady = false;
            isCustomersTotalsReportError = true;
            customersTotalsReportError =
                "Unable to fetch customers totals report. Error: rest_incorrect_schema";
          });
        }
      } else {
        setState(() {
          isCustomersTotalsReportReady = false;
          isCustomersTotalsReportError = true;
          if (responseBody is Map && responseBody.containsKey("code")) {
            customersTotalsReportError =
                "Unable to fetch customers totals report. Error: ${responseBody["code"]}";
          }
        });
      }
    } catch (e) {
      setState(() {
        isCustomersTotalsReportReady = false;
        isCustomersTotalsReportError = true;
        customersTotalsReportError =
            "Unable to fetch customers totals report. Error: $e";
      });
    }
  }

  Future<void> fetchReviewsTotalsReport() async {
    String url =
        "$baseurl/wp-json/wc/v3/reports/reviews/totals?consumer_key=$username&consumer_secret=$password";
    setState(() {
      isReviewsTotalsReportReady = false;
      isReviewsTotalsReportError = false;
      reviewsTotalsReportData = [];
      reviewsTotalsReportError = null;
    });

    dynamic response;
    try {
      response = await http.get(url);
      dynamic responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseBody is List && responseBody.isNotEmpty) {
          setState(() {
            reviewsTotalsReportData = responseBody;
            isReviewsTotalsReportReady = true;
            isReviewsTotalsReportError = false;
          });
        } else {
          setState(() {
            isReviewsTotalsReportReady = false;
            isReviewsTotalsReportError = true;
            reviewsTotalsReportError =
                "Unable to fetch reviews totals report. Error: rest_incorrect_schema";
          });
        }
      } else {
        setState(() {
          isReviewsTotalsReportReady = false;
          isReviewsTotalsReportError = true;
          if (responseBody is Map && responseBody.containsKey("code")) {
            reviewsTotalsReportError =
                "Unable to fetch reviews totals report. Error: ${responseBody["code"]}";
          }
        });
      }
    } catch (e) {
      setState(() {
        isReviewsTotalsReportReady = false;
        isReviewsTotalsReportError = true;
        reviewsTotalsReportError =
            "Unable to fetch reviews totals report. Error: $e";
      });
    }
  }

  Future<void> fetchCouponsTotalsReport() async {
    String url =
        "$baseurl/wp-json/wc/v3/reports/coupons/totals?consumer_key=$username&consumer_secret=$password";
    setState(() {
      isCouponsTotalsReportReady = false;
      isCouponsTotalsReportError = false;
      couponsTotalsReportData = [];
      couponsTotalsReportError = null;
    });

    dynamic response;
    try {
      response = await http.get(url);
      dynamic responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseBody is List && responseBody.isNotEmpty) {
          setState(() {
            couponsTotalsReportData = responseBody;
            isCouponsTotalsReportReady = true;
            isCouponsTotalsReportError = false;
          });
        } else {
          setState(() {
            isCouponsTotalsReportReady = false;
            isCouponsTotalsReportError = true;
            couponsTotalsReportError =
                "Unable to fetch coupons totals report. Error: rest_incorrect_schema";
          });
        }
      } else {
        setState(() {
          isCouponsTotalsReportReady = false;
          isCouponsTotalsReportError = true;
          if (responseBody is Map && responseBody.containsKey("code")) {
            couponsTotalsReportError =
                "Unable to fetch coupons totals report. Error: ${responseBody["code"]}";
          }
        });
      }
    } catch (e) {
      setState(() {
        isCouponsTotalsReportReady = false;
        isCouponsTotalsReportError = true;
        couponsTotalsReportError =
            "Unable to fetch coupons totals report. Error: $e";
      });
    }
  }

  Widget _salesTotalsReportWidget() {
    Widget salesTotalsReportWidget = SizedBox.shrink();
    List<Widget> salesTotalsReportWidgetData = [];

    if (!isSalesTotalsReportReady && !isSalesTotalsReportError) {
      salesTotalsReportWidgetData.add(Container(
        height: 200,
        child: Center(
          child: SpinKitFadingCube(
            color: Theme.of(context).primaryColor,
            size: 30.0,
          ),
        ),
      ));
    }

    if (isSalesTotalsReportError && !isSalesTotalsReportReady) {
      salesTotalsReportWidgetData.add(Container(
        height: 200,
        child: Center(
          child: Text(
            salesTotalsReportError,
            textAlign: TextAlign.center,
          ),
        ),
      ));
    }

    if (isSalesTotalsReportReady && salesTotalsReportData[0] is Map) {
      salesTotalsReportWidgetData.add(Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Text(
                    "From Date",
                    style: Theme.of(context)
                        .textTheme
                        .subhead
                        .copyWith(fontSize: 16),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      final DateTime picked = await showDatePicker(
                          context: context,
                          initialDate:
                              (fromDate != null && fromDate is DateTime)
                                  ? fromDate
                                  : DateTime.now().subtract(Duration(days: 6)),
                          firstDate: DateTime(2015, 8),
                          lastDate: DateTime(2101));
                      if (picked != fromDate && picked != null) {
                        setState(() {
                          fromDate = picked;
                        });
                      }
                      fetchDateBasedReports();
                    },
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      DateFormat("yyyy-MM-dd").format(fromDate),
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Text(
                    "To Date",
                    style: Theme.of(context)
                        .textTheme
                        .subhead
                        .copyWith(fontSize: 16),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      final DateTime picked = await showDatePicker(
                          context: context,
                          initialDate: (toDate != null && toDate is DateTime)
                              ? toDate
                              : DateTime.now(),
                          firstDate: DateTime(2015, 8),
                          lastDate: DateTime(2101));
                      if (picked != toDate && picked != null) {
                        setState(() {
                          toDate = picked;
                        });
                      }
                      fetchDateBasedReports();
                    },
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      DateFormat("yyyy-MM-dd").format(toDate),
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ));
    }

    //Sales Report By Date
    if (isSalesTotalsReportReady && salesTotalsReportData[0] is Map) {
      salesTotalsReportWidgetData.add(Text(
        "Sales",
        style: Theme.of(context).textTheme.subhead.copyWith(fontSize: 16),
      ));

      if (salesTotalsReportData[0].containsKey("total_sales") &&
          salesTotalsReportData[0]["total_sales"] is String &&
          salesTotalsReportData[0]["total_sales"].toString().isNotEmpty) {
        salesTotalsReportWidgetData.add(
            Text("Total Sales: ${salesTotalsReportData[0]["total_sales"]}"));
      }

      if (salesTotalsReportData[0].containsKey("net_sales") &&
          salesTotalsReportData[0]["net_sales"] is String &&
          salesTotalsReportData[0]["net_sales"].toString().isNotEmpty) {
        salesTotalsReportWidgetData
            .add(Text("Net Sales: ${salesTotalsReportData[0]["net_sales"]}"));
      }

      if (salesTotalsReportData[0].containsKey("average_sales") &&
          salesTotalsReportData[0]["average_sales"] is String &&
          salesTotalsReportData[0]["average_sales"].toString().isNotEmpty) {
        salesTotalsReportWidgetData.add(Text(
            "Average Sales: ${salesTotalsReportData[0]["average_sales"]}"));
      }

      if (salesTotalsReportData[0].containsKey("total_shipping") &&
          salesTotalsReportData[0]["total_shipping"] is String &&
          salesTotalsReportData[0]["total_shipping"].toString().isNotEmpty) {
        salesTotalsReportWidgetData.add(Text(
            "Total Shipping: ${salesTotalsReportData[0]["total_shipping"]}"));
      }

      if (salesTotalsReportData[0].containsKey("total_tax") &&
          salesTotalsReportData[0]["total_tax"] is String &&
          salesTotalsReportData[0]["total_tax"].toString().isNotEmpty) {
        salesTotalsReportWidgetData
            .add(Text("Total Tax: ${salesTotalsReportData[0]["total_tax"]}"));
      }

      if (salesTotalsReportData[0].containsKey("total_discount") &&
          salesTotalsReportData[0]["total_discount"] is String &&
          salesTotalsReportData[0]["total_discount"].toString().isNotEmpty) {
        salesTotalsReportWidgetData.add(Text(
            "Total Discounts: ${salesTotalsReportData[0]["total_discount"]}"));
      }

      if (salesTotalsReportData[0].containsKey("total_refunds") &&
          salesTotalsReportData[0]["total_refunds"] is int) {
        salesTotalsReportWidgetData.add(Text(
            "Total Refunds: ${salesTotalsReportData[0]["total_refunds"]}"));
      }

      if (salesTotalsReportData[0].containsKey("totals") &&
          salesTotalsReportData[0]["totals"] is Map) {
        List<Map> modifiedSalesTotalsByDateReportData = new List<Map>();
        salesTotalsReportData[0]["totals"].forEach((k, v) {
          if (v.containsKey("sales") &&
              v["sales"] is String &&
              v["sales"].isNotEmpty) {
            int total;
            try {
              total = int.parse(v["sales"]);
            } catch (FormatException) {
              try {
                total = double.parse(v["sales"]).toInt();
              } catch (FormatException) {
                total = null;
              }
            }
            if (total is int) {
              modifiedSalesTotalsByDateReportData
                  .add({"name": "$k", "total": total});
            }
          }
        });

        List<charts.Series<Map, String>> chartSeriesList =
            List<charts.Series<Map, String>>();
        chartSeriesList.add(
          charts.Series<Map, String>(
              id: 'Sales By Date',
              domainFn: (Map saleByDate, _) => saleByDate["name"],
              measureFn: (Map saleByDate, _) => saleByDate["total"],
              data: modifiedSalesTotalsByDateReportData,
              colorFn: (_, __) => charts.ColorUtil.fromDartColor(
                  Theme.of(context).primaryColor),
              labelAccessorFn: (Map saleByDate, _) => "${saleByDate["total"]}"),
        );

        salesTotalsReportWidgetData.add(Container(
          height: 300,
          padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: charts.BarChart(
            chartSeriesList,
            animate: false,
            barRendererDecorator: charts.BarLabelDecorator<String>(),
            domainAxis: charts.OrdinalAxisSpec(
              viewport: (modifiedSalesTotalsByDateReportData.length > 0 &&
                      modifiedSalesTotalsByDateReportData[0]
                          .containsKey("name") &&
                      modifiedSalesTotalsByDateReportData[0]["name"]
                          is String &&
                      modifiedSalesTotalsByDateReportData[0]["name"].isNotEmpty)
                  ? new charts.OrdinalViewport(
                      modifiedSalesTotalsByDateReportData[0]["name"], 7)
                  : null,
              renderSpec: charts.SmallTickRendererSpec(labelRotation: 45),
            ),
            behaviors: [
              new charts.SlidingViewport(),
              new charts.PanAndZoomBehavior(),
            ],
          ),
        ));

        //Orders Report By Date
        salesTotalsReportWidgetData.add(Text(
          "Orders",
          style: Theme.of(context).textTheme.subhead.copyWith(fontSize: 16),
        ));

        if (salesTotalsReportData[0].containsKey("totals") &&
            salesTotalsReportData[0]["totals"] is Map) {
          List<Map> modifiedSalesTotalsByDateReportData = new List<Map>();
          salesTotalsReportData[0]["totals"].forEach((k, v) {
            if (v.containsKey("orders") && v["orders"] is int) {
              modifiedSalesTotalsByDateReportData
                  .add({"name": "$k", "total": v["orders"]});
            }
          });

          List<charts.Series<Map, String>> chartSeriesList =
              List<charts.Series<Map, String>>();
          chartSeriesList.add(
            charts.Series<Map, String>(
                id: 'Orders By Date',
                domainFn: (Map orderByDate, _) => orderByDate["name"],
                measureFn: (Map orderByDate, _) => orderByDate["total"],
                data: modifiedSalesTotalsByDateReportData,
                colorFn: (_, __) => charts.ColorUtil.fromDartColor(
                    Theme.of(context).primaryColor),
                labelAccessorFn: (Map orderByDate, _) =>
                    "${orderByDate["total"]}"),
          );

          salesTotalsReportWidgetData.add(Container(
            height: 300,
            padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: charts.BarChart(
              chartSeriesList,
              animate: false,
              barRendererDecorator: charts.BarLabelDecorator<String>(),
              domainAxis: charts.OrdinalAxisSpec(
                viewport: (modifiedSalesTotalsByDateReportData.length > 0 &&
                        modifiedSalesTotalsByDateReportData[0]
                            .containsKey("name") &&
                        modifiedSalesTotalsByDateReportData[0]["name"]
                            is String &&
                        modifiedSalesTotalsByDateReportData[0]["name"]
                            .isNotEmpty)
                    ? new charts.OrdinalViewport(
                        modifiedSalesTotalsByDateReportData[0]["name"], 7)
                    : null,
                renderSpec: charts.SmallTickRendererSpec(labelRotation: 45),
              ),
              behaviors: [
                new charts.SlidingViewport(),
                new charts.PanAndZoomBehavior(),
              ],
            ),
          ));
        }

        //Products Report By Date
        salesTotalsReportWidgetData.add(Text(
          "Products",
          style: Theme.of(context).textTheme.subhead.copyWith(fontSize: 16),
        ));

        if (salesTotalsReportData[0].containsKey("totals") &&
            salesTotalsReportData[0]["totals"] is Map) {
          List<Map> modifiedSalesTotalsByDateReportData = new List<Map>();
          salesTotalsReportData[0]["totals"].forEach((k, v) {
            if (v.containsKey("items") && v["items"] is int) {
              modifiedSalesTotalsByDateReportData
                  .add({"name": "$k", "total": v["items"]});
            }
          });

          List<charts.Series<Map, String>> chartSeriesList =
              List<charts.Series<Map, String>>();
          chartSeriesList.add(
            charts.Series<Map, String>(
                id: 'Products By Date',
                domainFn: (Map productByDate, _) => productByDate["name"],
                measureFn: (Map productByDate, _) => productByDate["total"],
                data: modifiedSalesTotalsByDateReportData,
                colorFn: (_, __) => charts.ColorUtil.fromDartColor(
                    Theme.of(context).primaryColor),
                labelAccessorFn: (Map productByDate, _) =>
                    "${productByDate["total"]}"),
          );

          salesTotalsReportWidgetData.add(Container(
            height: 300,
            padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: charts.BarChart(
              chartSeriesList,
              animate: false,
              barRendererDecorator: charts.BarLabelDecorator<String>(),
              domainAxis: charts.OrdinalAxisSpec(
                viewport: (modifiedSalesTotalsByDateReportData.length > 0 &&
                        modifiedSalesTotalsByDateReportData[0]
                            .containsKey("name") &&
                        modifiedSalesTotalsByDateReportData[0]["name"]
                            is String &&
                        modifiedSalesTotalsByDateReportData[0]["name"]
                            .isNotEmpty)
                    ? new charts.OrdinalViewport(
                        modifiedSalesTotalsByDateReportData[0]["name"], 7)
                    : null,
                renderSpec: charts.SmallTickRendererSpec(labelRotation: 45),
              ),
              behaviors: [
                new charts.SlidingViewport(),
                new charts.PanAndZoomBehavior(),
              ],
            ),
          ));
        }

        //Customers Report By Date
        salesTotalsReportWidgetData.add(Text(
          "Customers",
          style: Theme.of(context).textTheme.subhead.copyWith(fontSize: 16),
        ));

        if (salesTotalsReportData[0].containsKey("totals") &&
            salesTotalsReportData[0]["totals"] is Map) {
          List<Map> modifiedSalesTotalsByDateReportData = new List<Map>();
          salesTotalsReportData[0]["totals"].forEach((k, v) {
            if (v.containsKey("customers") && v["customers"] is int) {
              modifiedSalesTotalsByDateReportData
                  .add({"name": "$k", "total": v["customers"]});
            }
          });

          List<charts.Series<Map, String>> chartSeriesList =
              List<charts.Series<Map, String>>();
          chartSeriesList.add(
            charts.Series<Map, String>(
                id: 'Customers By Date',
                domainFn: (Map customerByDate, _) => customerByDate["name"],
                measureFn: (Map customerByDate, _) => customerByDate["total"],
                data: modifiedSalesTotalsByDateReportData,
                colorFn: (_, __) => charts.ColorUtil.fromDartColor(
                    Theme.of(context).primaryColor),
                labelAccessorFn: (Map customerByDate, _) =>
                    "${customerByDate["total"]}"),
          );

          salesTotalsReportWidgetData.add(Container(
            height: 300,
            padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: charts.BarChart(
              chartSeriesList,
              animate: false,
              barRendererDecorator: charts.BarLabelDecorator<String>(),
              domainAxis: charts.OrdinalAxisSpec(
                viewport: (modifiedSalesTotalsByDateReportData.length > 0 &&
                        modifiedSalesTotalsByDateReportData[0]
                            .containsKey("name") &&
                        modifiedSalesTotalsByDateReportData[0]["name"]
                            is String &&
                        modifiedSalesTotalsByDateReportData[0]["name"]
                            .isNotEmpty)
                    ? new charts.OrdinalViewport(
                        modifiedSalesTotalsByDateReportData[0]["name"], 7)
                    : null,
                renderSpec: charts.SmallTickRendererSpec(labelRotation: 45),
              ),
              behaviors: [
                new charts.SlidingViewport(),
                new charts.PanAndZoomBehavior(),
              ],
            ),
          ));
        }
      }
    }

    salesTotalsReportWidget = ExpansionTile(
      title: Text(
        "Reports By Date",
        style: Theme.of(context).textTheme.subhead,
      ),
      initiallyExpanded: true,
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: salesTotalsReportWidgetData),
              ),
            ),
          ],
        )
      ],
    );
    return salesTotalsReportWidget;
  }

  Widget _ordersTotalsReportWidget() {
    Widget ordersTotalsReportWidget = SizedBox.shrink();
    List<Widget> ordersTotalsReportWidgetData = [];

    if (!isOrdersTotalsReportReady && !isOrdersTotalsReportError) {
      ordersTotalsReportWidgetData.add(Container(
        height: 200,
        child: Center(
          child: SpinKitFadingCube(
            color: Theme.of(context).primaryColor,
            size: 30.0,
          ),
        ),
      ));
    }

    if (isOrdersTotalsReportError && !isOrdersTotalsReportReady) {
      ordersTotalsReportWidgetData.add(Container(
        height: 200,
        child: Center(
          child: Text(
            salesTotalsReportError,
            textAlign: TextAlign.center,
          ),
        ),
      ));
    }

    if (isOrdersTotalsReportReady &&
        ordersTotalsReportData[0] is Map &&
        ordersTotalsReportData[0].containsKey("name") &&
        ordersTotalsReportData[0]["name"] is String &&
        ordersTotalsReportData[0]["name"].toString().isNotEmpty &&
        ordersTotalsReportData[0].containsKey("total") &&
        ordersTotalsReportData[0]["total"] is int) {
      List<Map> modifiedOrdersTotalsReportData = new List<Map>();
      ordersTotalsReportData.forEach((item) {
        modifiedOrdersTotalsReportData
            .add({"name": "${item["name"]}", "total": item["total"]});
      });

      List<charts.Series<Map, String>> chartSeriesList =
          List<charts.Series<Map, String>>();
      chartSeriesList.add(
        charts.Series<Map, String>(
            id: 'Orders',
            domainFn: (Map order, _) => order["name"],
            measureFn: (Map order, _) => order["total"],
            data: modifiedOrdersTotalsReportData,
            colorFn: (_, __) =>
                charts.ColorUtil.fromDartColor(Theme.of(context).primaryColor),
            labelAccessorFn: (Map order, _) => "${order["total"]}"),
      );

      ordersTotalsReportWidgetData.add(Container(
        height: 300,
        child: charts.BarChart(
          chartSeriesList,
          animate: false,
          barRendererDecorator: charts.BarLabelDecorator<String>(),
          domainAxis: charts.OrdinalAxisSpec(
            showAxisLine: false,
            renderSpec: charts.SmallTickRendererSpec(labelRotation: 45),
          ),
          behaviors: [
            new charts.SlidingViewport(),
            new charts.PanAndZoomBehavior(),
          ],
        ),
      ));
    }

    ordersTotalsReportWidget = ExpansionTile(
      title: Text(
        "All Time Orders Report",
        style: Theme.of(context).textTheme.subhead,
      ),
      initiallyExpanded: true,
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: ordersTotalsReportWidgetData),
              ),
            ),
          ],
        )
      ],
    );
    return ordersTotalsReportWidget;
  }

  Widget _productsTotalsReportWidget() {
    Widget productsTotalsReportWidget = SizedBox.shrink();
    List<Widget> productsTotalsReportWidgetData = [];

    if (!isProductsTotalsReportReady && !isProductsTotalsReportError) {
      productsTotalsReportWidgetData.add(Container(
        height: 200,
        child: Center(
          child: SpinKitFadingCube(
            color: Theme.of(context).primaryColor,
            size: 30.0,
          ),
        ),
      ));
    }

    if (isProductsTotalsReportError && !isProductsTotalsReportReady) {
      productsTotalsReportWidgetData.add(Container(
        height: 200,
        child: Center(
          child: Text(
            productsTotalsReportError,
            textAlign: TextAlign.center,
          ),
        ),
      ));
    }

    if (isProductsTotalsReportReady &&
        productsTotalsReportData[0] is Map &&
        productsTotalsReportData[0].containsKey("name") &&
        productsTotalsReportData[0]["name"] is String &&
        productsTotalsReportData[0]["name"].toString().isNotEmpty &&
        productsTotalsReportData[0].containsKey("total") &&
        productsTotalsReportData[0]["total"] is int) {
      List<Map> modifiedProductsTotalsReportData = new List<Map>();
      productsTotalsReportData.forEach((item) {
        modifiedProductsTotalsReportData
            .add({"name": "${item["name"]}", "total": item["total"]});
      });

      List<charts.Series<Map, String>> chartSeriesList =
          List<charts.Series<Map, String>>();
      chartSeriesList.add(
        charts.Series<Map, String>(
            id: 'Products',
            domainFn: (Map product, _) => product["name"],
            measureFn: (Map product, _) => product["total"],
            data: modifiedProductsTotalsReportData,
            colorFn: (_, __) =>
                charts.ColorUtil.fromDartColor(Theme.of(context).primaryColor),
            labelAccessorFn: (Map product, _) => "${product["total"]}"),
      );

      productsTotalsReportWidgetData.add(Container(
        height: 300,
        child: charts.BarChart(
          chartSeriesList,
          animate: false,
          barRendererDecorator: charts.BarLabelDecorator<String>(),
          domainAxis: charts.OrdinalAxisSpec(
            showAxisLine: false,
            renderSpec: charts.SmallTickRendererSpec(labelRotation: 45),
          ),
          behaviors: [
            new charts.SlidingViewport(),
            new charts.PanAndZoomBehavior(),
          ],
        ),
      ));
    }

    productsTotalsReportWidget = ExpansionTile(
      title: Text(
        "All Time Products Report",
        style: Theme.of(context).textTheme.subhead,
      ),
      initiallyExpanded: true,
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: productsTotalsReportWidgetData),
              ),
            ),
          ],
        )
      ],
    );
    return productsTotalsReportWidget;
  }

  Widget _customersTotalsReportWidget() {
    Widget customersTotalsReportWidget = SizedBox.shrink();
    List<Widget> customersTotalsReportWidgetData = [];

    if (!isCustomersTotalsReportReady && !isCustomersTotalsReportError) {
      customersTotalsReportWidgetData.add(Container(
        height: 200,
        child: Center(
          child: SpinKitFadingCube(
            color: Theme.of(context).primaryColor,
            size: 30.0,
          ),
        ),
      ));
    }

    if (isCustomersTotalsReportError && !isCustomersTotalsReportReady) {
      customersTotalsReportWidgetData.add(Container(
        height: 200,
        child: Center(
          child: Text(
            customersTotalsReportError,
            textAlign: TextAlign.center,
          ),
        ),
      ));
    }

    if (isCustomersTotalsReportReady &&
        customersTotalsReportData[0] is Map &&
        customersTotalsReportData[0].containsKey("name") &&
        customersTotalsReportData[0]["name"] is String &&
        customersTotalsReportData[0]["name"].toString().isNotEmpty &&
        customersTotalsReportData[0].containsKey("total") &&
        customersTotalsReportData[0]["total"] is int) {
      List<Map> modifiedCustomersTotalsReportData = new List<Map>();
      customersTotalsReportData.forEach((item) {
        modifiedCustomersTotalsReportData
            .add({"name": "${item["name"]}", "total": item["total"]});
      });

      List<charts.Series<Map, String>> chartSeriesList =
          List<charts.Series<Map, String>>();
      chartSeriesList.add(
        charts.Series<Map, String>(
            id: 'Customers',
            domainFn: (Map customer, _) => customer["name"],
            measureFn: (Map customer, _) => customer["total"],
            data: modifiedCustomersTotalsReportData,
            colorFn: (_, __) =>
                charts.ColorUtil.fromDartColor(Theme.of(context).primaryColor),
            labelAccessorFn: (Map customer, _) => "${customer["total"]}"),
      );

      customersTotalsReportWidgetData.add(Container(
        height: 300,
        child: charts.BarChart(
          chartSeriesList,
          animate: false,
          barRendererDecorator: charts.BarLabelDecorator<String>(),
          domainAxis: charts.OrdinalAxisSpec(
            showAxisLine: false,
            renderSpec: charts.SmallTickRendererSpec(labelRotation: 45),
          ),
          behaviors: [
            new charts.SlidingViewport(),
            new charts.PanAndZoomBehavior(),
          ],
        ),
      ));
    }

    customersTotalsReportWidget = ExpansionTile(
      title: Text(
        "All Time Customers Report",
        style: Theme.of(context).textTheme.subhead,
      ),
      initiallyExpanded: true,
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: customersTotalsReportWidgetData),
              ),
            ),
          ],
        )
      ],
    );
    return customersTotalsReportWidget;
  }

  Widget _reviewsTotalsReportWidget() {
    Widget reviewsTotalsReportWidget = SizedBox.shrink();
    List<Widget> reviewsTotalsReportWidgetData = [];

    if (!isReviewsTotalsReportReady && !isReviewsTotalsReportError) {
      reviewsTotalsReportWidgetData.add(Container(
        height: 200,
        child: Center(
          child: SpinKitFadingCube(
            color: Theme.of(context).primaryColor,
            size: 30.0,
          ),
        ),
      ));
    }

    if (isReviewsTotalsReportError && !isReviewsTotalsReportReady) {
      reviewsTotalsReportWidgetData.add(Container(
        height: 200,
        child: Center(
          child: Text(
            reviewsTotalsReportError,
            textAlign: TextAlign.center,
          ),
        ),
      ));
    }

    if (isReviewsTotalsReportReady &&
        reviewsTotalsReportData[0] is Map &&
        reviewsTotalsReportData[0].containsKey("name") &&
        reviewsTotalsReportData[0]["name"] is String &&
        reviewsTotalsReportData[0]["name"].toString().isNotEmpty &&
        reviewsTotalsReportData[0].containsKey("total") &&
        reviewsTotalsReportData[0]["total"] is int) {
      List<Map> modifiedReviewsTotalsReportData = new List<Map>();
      reviewsTotalsReportData.forEach((item) {
        modifiedReviewsTotalsReportData
            .add({"name": "${item["name"]}", "total": item["total"]});
      });

      List<charts.Series<Map, String>> chartSeriesList =
          List<charts.Series<Map, String>>();
      chartSeriesList.add(
        charts.Series<Map, String>(
            id: 'Reviews',
            domainFn: (Map review, _) => review["name"],
            measureFn: (Map review, _) => review["total"],
            data: modifiedReviewsTotalsReportData,
            colorFn: (_, __) =>
                charts.ColorUtil.fromDartColor(Theme.of(context).primaryColor),
            labelAccessorFn: (Map review, _) => "${review["total"]}"),
      );

      reviewsTotalsReportWidgetData.add(Container(
        height: 300,
        child: charts.BarChart(
          chartSeriesList,
          animate: false,
          barRendererDecorator: charts.BarLabelDecorator<String>(),
          domainAxis: charts.OrdinalAxisSpec(
            showAxisLine: false,
            renderSpec: charts.SmallTickRendererSpec(labelRotation: 45),
          ),
          behaviors: [
            new charts.SlidingViewport(),
            new charts.PanAndZoomBehavior(),
          ],
        ),
      ));
    }

    reviewsTotalsReportWidget = ExpansionTile(
      title: Text(
        "All Time Reviews Report",
        style: Theme.of(context).textTheme.subhead,
      ),
      initiallyExpanded: true,
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: reviewsTotalsReportWidgetData),
              ),
            ),
          ],
        )
      ],
    );
    return reviewsTotalsReportWidget;
  }

  Widget _couponsTotalsReportWidget() {
    Widget couponsTotalsReportWidget = SizedBox.shrink();
    List<Widget> couponsTotalsReportWidgetData = [];

    if (!isCouponsTotalsReportReady && !isCouponsTotalsReportError) {
      couponsTotalsReportWidgetData.add(Container(
        height: 200,
        child: Center(
          child: SpinKitFadingCube(
            color: Theme.of(context).primaryColor,
            size: 30.0,
          ),
        ),
      ));
    }

    if (isCouponsTotalsReportError && !isCouponsTotalsReportReady) {
      couponsTotalsReportWidgetData.add(Container(
        height: 200,
        child: Center(
          child: Text(
            couponsTotalsReportError,
            textAlign: TextAlign.center,
          ),
        ),
      ));
    }

    if (isCouponsTotalsReportReady &&
        couponsTotalsReportData[0] is Map &&
        couponsTotalsReportData[0].containsKey("name") &&
        couponsTotalsReportData[0]["name"] is String &&
        couponsTotalsReportData[0]["name"].toString().isNotEmpty &&
        couponsTotalsReportData[0].containsKey("total") &&
        couponsTotalsReportData[0]["total"] is int) {
      List<Map> modifiedCouponsTotalsReportData = new List<Map>();
      couponsTotalsReportData.forEach((item) {
        modifiedCouponsTotalsReportData
            .add({"name": "${item["name"]}", "total": item["total"]});
      });

      List<charts.Series<Map, String>> chartSeriesList =
          List<charts.Series<Map, String>>();
      chartSeriesList.add(
        charts.Series<Map, String>(
            id: 'Reviews',
            domainFn: (Map review, _) => review["name"],
            measureFn: (Map review, _) => review["total"],
            data: modifiedCouponsTotalsReportData,
            colorFn: (_, __) =>
                charts.ColorUtil.fromDartColor(Theme.of(context).primaryColor),
            labelAccessorFn: (Map review, _) => "${review["total"]}"),
      );

      couponsTotalsReportWidgetData.add(Container(
        height: 300,
        child: charts.BarChart(
          chartSeriesList,
          animate: false,
          barRendererDecorator: charts.BarLabelDecorator<String>(),
          domainAxis: charts.OrdinalAxisSpec(
            showAxisLine: false,
            renderSpec: charts.SmallTickRendererSpec(labelRotation: 45),
          ),
          behaviors: [
            new charts.SlidingViewport(),
            new charts.PanAndZoomBehavior(),
          ],
        ),
      ));
    }

    couponsTotalsReportWidget = ExpansionTile(
      title: Text(
        "All Time Coupons Report",
        style: Theme.of(context).textTheme.subhead,
      ),
      initiallyExpanded: true,
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: couponsTotalsReportWidgetData),
              ),
            ),
          ],
        )
      ],
    );
    return couponsTotalsReportWidget;
  }
}
