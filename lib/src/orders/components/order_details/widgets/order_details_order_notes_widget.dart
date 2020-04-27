import 'package:flutter/material.dart';
import 'package:woocommerceadmin/src/orders/components/order_notes/screens/add_order_note_screen.dart';
import 'package:woocommerceadmin/src/orders/components/order_notes/widgets/order_notes_list_widget.dart';

class OrderDetailsOrderNotesWidget extends StatelessWidget {
  final String baseurl;
  final String username;
  final String password;
  final int orderId;

  OrderDetailsOrderNotesWidget({
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        "Order Notes",
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
                  children: <Widget>[
                    ListTile(
                      leading: Icon(
                        Icons.add,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        "Add Order Note",
                        style: Theme.of(context).textTheme.body2.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddOrderNoteScreen(
                              baseurl: baseurl,
                              username: username,
                              password: password,
                              orderId: orderId,
                            ),
                          ),
                        );
                      },
                    ),
                    OrderNotesListWidget(
                      baseurl: baseurl,
                      username: username,
                      password: password,
                      orderId: orderId,
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
