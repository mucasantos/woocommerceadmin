import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/orders/models/order_note.dart';
import 'package:woocommerceadmin/src/orders/providers/order_note_provider.dart';
import 'package:woocommerceadmin/src/orders/providers/order_notes_list_provider.dart';

class AddOrderNoteScreen extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  final int orderId;

  AddOrderNoteScreen({
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.orderId,
  });

  @override
  _AddOrderNoteScreenState createState() => _AddOrderNoteScreenState();
}

class _AddOrderNoteScreenState extends State<AddOrderNoteScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isOrderNotesDataReady = true;
  bool isOrderNotesDataError = false;
  List orderNotesData = [];
  String orderNotesDataError;

  bool isCustomerNewOrderNote = false;
  String newOrderNote = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Add Order Note"),
      ),
      body: !isOrderNotesDataReady
          ? Container(
              child: Center(
                child: SpinKitPulse(
                  color: Theme.of(context).primaryColor,
                  size: 70,
                ),
              ),
            )
          : Column(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      expands: true,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Add order note here...",
                          hintStyle: Theme.of(context).textTheme.body1),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      textAlign: TextAlign.start,
                      textAlignVertical: TextAlignVertical.top,
                      style: Theme.of(context).textTheme.body1,
                      onChanged: (value) {
                        setState(() {
                          newOrderNote = value;
                        });
                      },
                    ),
                  ),
                ),
                CheckboxListTile(
                  title: Text("Email note to customer"),
                  subtitle: Text("If disabled this note will be private"),
                  value: isCustomerNewOrderNote,
                  onChanged: (bool value) {
                    setState(() {
                      isCustomerNewOrderNote = value;
                    });
                  },
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: 50,
                        child: RaisedButton(
                          child: Text(
                            "Add",
                            style: Theme.of(context).textTheme.body1.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            addOrderNote(
                              baseurl: widget.baseurl,
                              username: widget.username,
                              password: widget.password,
                              orderId: widget.orderId,
                            );
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

  //Create Order Note
  Future<Null> addOrderNote({
    @required String baseurl,
    @required String username,
    @required String password,
    @required int orderId,
  }) async {
    String url =
        "$baseurl/wp-json/wc/v3/orders/$orderId/notes?consumer_key=$username&consumer_secret=$password";
    setState(() {
      isOrderNotesDataReady = false;
      isOrderNotesDataError = false;
    });

    http.Response response;
    try {
      response = await http.post(
        url,
        headers: {HttpHeaders.contentTypeHeader: "application/json"},
        body: json.encode({
          "customer_note": isCustomerNewOrderNote.toString(),
          "note": newOrderNote
        }),
      );
      dynamic responseBody = json.decode(response.body);
      if (responseBody is Map && responseBody.containsKey("id")) {
        Provider.of<OrderNoteProvidersList>(context, listen: false)
            .insertOrderNoteProviderAtTop(
                OrderNoteProvider(OrderNote.fromJson(responseBody)));
        Navigator.pop(context);
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("Order note added successfully..."),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        String errorCode = "";
        if (json.decode(response.body) is Map &&
            json.decode(response.body).containsKey("code")) {
          errorCode = json.decode(response.body)["code"];
        }
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text("Failed to add order note. Error: $errorCode"),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } on SocketException catch (_) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content:
              Text("Failed to add order note. Error: Network not reachable"),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Failed to add order note. Error: $e"),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
