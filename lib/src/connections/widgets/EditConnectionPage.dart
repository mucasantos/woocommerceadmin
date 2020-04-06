import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import 'package:woocommerceadmin/main.dart';
import 'package:woocommerceadmin/src/db/ConnectionDBProvider.dart';
import 'package:woocommerceadmin/src/db/models/Connection.dart';

class EditConnectionPage extends StatefulWidget {
  final int id;
  final String baseurl;
  final String username;
  final String password;
  final Function() refreshConnectionsList;

  EditConnectionPage(
      {Key key,
      @required this.id,
      @required this.baseurl,
      @required this.username,
      @required this.password,
      this.refreshConnectionsList})
      : super(key: key);
  @override
  _EditConnectionPageState createState() => _EditConnectionPageState();
}

class _EditConnectionPageState extends State<EditConnectionPage> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String baseurl;
  String username;
  String password;
  bool isPasswordVisible = false;
  bool isSubmitButtonLoading = false;

  @override
  void initState() {
    super.initState();
    baseurl = widget.baseurl;
    username = widget.username;
    password = widget.password;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Edit Connection"),
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
                  initialValue: baseurl,
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
                  initialValue: username,
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
                      return null;
                    }
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
                  initialValue: password,
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
                    child: Text("Update",
                        style: Theme.of(context).textTheme.button),
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
    if (widget.id is int &&
        baseurl is String &&
        baseurl.isNotEmpty &&
        username is String &&
        username.isNotEmpty &&
        password is String &&
        password.isNotEmpty) {
      setState(() {
        isSubmitButtonLoading = true;
      });
      await ConnectionDBProvider.db.updateConnection(Connection(
          id: widget.id,
          baseurl: baseurl,
          username: username,
          password: password));
      setState(() {
        isSubmitButtonLoading = false;
      });
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Connection updated successfully..."),
        duration: Duration(seconds: 3),
      ));
      if (widget.refreshConnectionsList != null) {
        widget.refreshConnectionsList();
      }
      MyBottomNavigator myBottomNavigator = MyBottomNavigator();
      myBottomNavigator.getInitialConnection();
    }
  }
}
