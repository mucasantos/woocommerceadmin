import 'dart:convert';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:woocommerceadmin/src/orders/models/order_note.dart';
import 'package:woocommerceadmin/src/orders/providers/order_note_provider.dart';
import 'package:woocommerceadmin/src/orders/providers/order_notes_list_provider.dart';

class OrderNotesListWidget extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  final int orderId;

  OrderNotesListWidget({
    this.baseurl,
    this.username,
    this.password,
    this.orderId,
  });

  @override
  _OrderNotesListWidgetState createState() => _OrderNotesListWidgetState();
}

class _OrderNotesListWidgetState extends State<OrderNotesListWidget> {
  bool isOrderNotesDataReady = false;
  bool isOrderNotesDataError = false;
  List orderNotesData = [];
  String orderNotesDataError;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    fetchOrderNotes(
      baseurl: widget.baseurl,
      username: widget.username,
      password: widget.password,
      orderId: widget.orderId,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isOrderNotesDataError
        ? Container(
            height: 200,
            child: Center(
              child: Text(
                orderNotesDataError ?? "",
                textAlign: TextAlign.center,
              ),
            ),
          )
        : !isOrderNotesDataReady
            ? Container(
                height: 100,
                child: Center(
                  child: SpinKitPulse(
                    color: Theme.of(context).primaryColor,
                    size: 50,
                  ),
                ),
              )
            : Consumer<OrderNoteProvidersList>(
                builder: (context, orderNoteProvidersList, _) {
                  List<Widget> orderNotesListWidgetData = [];
                  orderNoteProvidersList.orderNoteProvider.forEach(
                    (item) {
                      orderNotesListWidgetData.add(
                        Card(
                          color: (item.orderNote.customerNote is bool &&
                                  item.orderNote.customerNote)
                              ? Colors.purple[100]
                              : Colors.white,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        item.orderNote.note is String
                                            ? Linkify(
                                                text: item.orderNote.note,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .body1
                                                    .copyWith(fontSize: 16),
                                                onOpen: (link) async {
                                                  if (await canLaunch(
                                                      link.url)) {
                                                    await launch(link.url);
                                                  }
                                                },
                                                options: LinkifyOptions(
                                                    humanize: false),
                                              )
                                            : SizedBox.shrink(),
                                        Text(
                                          "Note added" +
                                              (item.orderNote.author.isNotEmpty
                                                  ? " by ${item.orderNote.author}"
                                                  : "") +
                                              (item.orderNote.dateCreated
                                                      is DateTime
                                                  ? " at " +
                                                      DateFormat(
                                                              "EEEE, d/M/y h:mm:ss a")
                                                          .format(item.orderNote
                                                              .dateCreated)
                                                  : ""),
                                          style: Theme.of(context)
                                              .textTheme
                                              .body1
                                              .copyWith(fontSize: 12),
                                        )
                                      ]),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Center(
                                  child: GestureDetector(
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onTap: () async {
                                      return showDialog<void>(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("Delete Order Note"),
                                              titlePadding: EdgeInsets.fromLTRB(
                                                  15, 20, 15, 0),
                                              content: Text(
                                                "Do you really want to delete this order note?",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .body1,
                                              ),
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      15, 10, 15, 0),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text("No"),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                FlatButton(
                                                  child: Text("Yes"),
                                                  onPressed: () {
                                                    if (item.orderNote.id
                                                        is int) {
                                                      deleteOrderNote(
                                                        baseurl: widget.baseurl,
                                                        username:
                                                            widget.username,
                                                        password:
                                                            widget.password,
                                                        orderId: widget.orderId,
                                                        orderNoteId:
                                                            item.orderNote.id,
                                                      );
                                                    }
                                                    Navigator.of(context).pop();
                                                  },
                                                )
                                              ],
                                            );
                                          });
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                  return Column(
                    children: orderNotesListWidgetData,
                  );
                },
              );
  }

  //Order Notes Functions Below
  Future<Null> fetchOrderNotes(
      {@required String baseurl,
      @required String username,
      @required String password,
      @required int orderId}) async {
    String url =
        "$baseurl/wp-json/wc/v3/orders/$orderId/notes?consumer_key=$username&consumer_secret=$password";
    setState(() {
      isOrderNotesDataReady = false;
      isOrderNotesDataError = false;
    });

    http.Response response;
    try {
      response = await http.get(url);
      if (response.statusCode == 200) {
        dynamic responseBody = json.decode(response.body);
        if (responseBody is List && responseBody.isNotEmpty) {
          final OrderNoteProvidersList orderNoteProvidersList =
              Provider.of<OrderNoteProvidersList>(context, listen: false);
          orderNoteProvidersList.clearOrderNoteProvidersList();

          List<OrderNoteProvider> tempOrderNoteProvidersList = [];
          responseBody.forEach((item) {
            tempOrderNoteProvidersList
                .add(OrderNoteProvider(OrderNote.fromJson(item)));
          });

          orderNoteProvidersList
              .addOrderNoteProviders(tempOrderNoteProvidersList);
              
          setState(() {
            isOrderNotesDataReady = true;
            isOrderNotesDataError = false;
          });
        } else {
          setState(() {
            isOrderNotesDataReady = false;
            isOrderNotesDataError = true;
            orderNotesDataError = "Failed to fetch order notes";
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
          isOrderNotesDataReady = false;
          isOrderNotesDataError = true;
          orderNotesDataError =
              "Failed to fetch order notes. Error: $errorCode";
        });
      }
    } on SocketException catch (_) {
      setState(() {
        isOrderNotesDataReady = false;
        isOrderNotesDataError = true;
        orderNotesDataError =
            "Failed to fetch order notes. Error: Network not reachable";
      });
    } catch (e) {
      setState(() {
        isOrderNotesDataReady = false;
        isOrderNotesDataError = true;
        orderNotesDataError = "Failed to fetch order notes. Error: $e";
      });
    }
  }

  //Delete Order Note
  Future<Null> deleteOrderNote(
      {@required String baseurl,
      @required String username,
      @required String password,
      @required int orderId,
      @required int orderNoteId}) async {
    String url =
        "$baseurl/wp-json/wc/v3/orders/$orderId/notes/$orderNoteId?force=true&consumer_key=$username&consumer_secret=$password";

    http.Response response;
    setState(() {
      isOrderNotesDataReady = false;
    });
    try {
      response = await http.delete(url);
      dynamic responseBody = json.decode(response.body);
      if (responseBody is Map && responseBody.containsKey("id")) {
        Provider.of<OrderNoteProvidersList>(context, listen: false)
            .deleteOrderNoteProvider(orderNoteId);
        setState(() {
          isOrderNotesDataReady = true;
        });
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Order note deleted successfully..."),
          duration: Duration(seconds: 3),
        ));
      } else {
        String errorCode = "";
        if (json.decode(response.body) is Map &&
            json.decode(response.body).containsKey("code")) {
          errorCode = json.decode(response.body)["code"];
        }
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete order note. Error: $errorCode"),
            duration: Duration(seconds: 3),
          ),
        );
        setState(() {
          isOrderNotesDataReady = true;
        });
      }
    } on SocketException catch (_) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Failed to delete order note. Error: Network not reachable"),
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        isOrderNotesDataReady = true;
      });
    } catch (e) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete order note. Error: $e"),
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        isOrderNotesDataReady = true;
      });
    }
  }
}
