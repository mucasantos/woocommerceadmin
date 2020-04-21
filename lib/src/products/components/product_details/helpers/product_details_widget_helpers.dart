import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailsWidgetsHelper {
  static Widget getItemRow({
    @required BuildContext context,
    @required String item1,
    @required String item2,
    bool linkify = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          item1,
          style: Theme.of(context).textTheme.body1.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Flexible(
          child: linkify
              ? Text.rich(
                  TextSpan(
                    text: item2,
                    style: TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        if (await canLaunch(item2)) {
                          await launch(item2);
                        } else {
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text("Could not open url"),
                            duration: Duration(seconds: 3),
                          ));
                        }
                      },
                  ),
                )
              : Text(
                  item2,
                  style: Theme.of(context).textTheme.body1,
                ),
        ),
      ],
    );
  }

  static ExpansionTile getExpansionTile({
    @required BuildContext context,
    @required String title,
    @required List<Widget> widgetsList,
    bool isTappable = false,
    Function onTap,
  }) {
    return ExpansionTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.subhead,
      ),
      initiallyExpanded: true,
      children: <Widget>[
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 15, 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: widgetsList,
                  ),
                ),
                if (isTappable)
                  Center(
                    child: Icon(Icons.arrow_right),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
