import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import 'package:woocommerceadmin/src/db/ConnectionDBProvider.dart';
import 'package:woocommerceadmin/src/db/models/Connection.dart';

class AddConnectionPage extends StatefulWidget {
  final Function() refreshConnectionsList;
  AddConnectionPage({Key key, this.refreshConnectionsList}) : super(key: key);
  @override
  _AddConnectionPageState createState() => _AddConnectionPageState();
}

class _AddConnectionPageState extends State<AddConnectionPage> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isPasswordVisible = false;
  String baseurl;
  String username;
  String password;
  bool isSubmitButtonLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Add Connection"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidate: true,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextFormField(
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(labelText: "Store URL"),
                  validator: (String value) {
                    if (isURL(value,
                        protocols: ["https"], requireProtocol: true)) {
                      return null;
                    } else {
                      if (baseurl != null) {
                        return "Enter valid https store url";
                      }
                    }
                    return null;
                  },
                  onSaved: (String value) {
                    setState(() {
                      baseurl = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(labelText: "Username"),
                  validator: (String value) {
                    if (value.length > 0) {
                      if (username != null && value.contains(" ")) {
                        return "Username can't contain whitespace";
                      } else {
                        return null;
                      }
                    } else {
                      if (username != null) {
                        return "Username can't be empty";
                      }
                    }
                    return null;
                  },
                  onSaved: (String value) {
                    setState(() {
                      username = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextFormField(
                  keyboardType: isPasswordVisible
                      ? TextInputType.visiblePassword
                      : TextInputType.text,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                      labelText: "Password",
                      suffixIcon: IconButton(
                          icon: isPasswordVisible
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          })),
                  validator: (String value) {
                    if (value.length > 0) {
                      if (password != null && value.contains(" ")) {
                        return "Password can't contain whitespace";
                      } else {
                        return null;
                      }
                    } else {
                      if (password != null) {
                        return "Password can't be empty";
                      }
                    }
                    return null;
                  },
                  onSaved: (String value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Container(
                  height: 45,
                  width: 200,
                  child: RaisedButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text(
                      "Connect",
                      style: Theme.of(context).textTheme.button,
                    ),
                    padding: EdgeInsets.all(10),
                    onPressed: () {
                      final form = _formKey.currentState;
                      if (form.validate()) {
                        form.save();
                        insertConnection();
                      }
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  insertConnection() async {
    int id = await ConnectionDBProvider.db.getLastId();
    if (id is int &&
        baseurl is String &&
        baseurl.isNotEmpty &&
        username is String &&
        username.isNotEmpty &&
        password is String &&
        password.isNotEmpty) {
      setState(() {
        isSubmitButtonLoading = true;
      });
      id++;
      await ConnectionDBProvider.db.insertConnection(Connection(
          id: id, baseurl: baseurl, username: username, password: password));
      setState(() {
        isSubmitButtonLoading = false;
      });
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Connection added successfully..."),
        duration: Duration(seconds: 3),
      ));
      if (widget.refreshConnectionsList != null) {
        widget.refreshConnectionsList();
      }
    }
  }
}
