import 'package:flutter/material.dart';
import 'package:recase/recase.dart';

class CustomersListFiltersModal extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  final String sortOrderByValue;
  final String sortOrderValue;
  final String roleFilterValue;
  final void Function(String, String, String) onSubmit;

  CustomersListFiltersModal({
    Key key,
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.sortOrderByValue,
    @required this.sortOrderValue,
    @required this.roleFilterValue,
    @required this.onSubmit,
  }) : super(key: key);

  @override
  _CustomersListFiltersModalState createState() =>
      _CustomersListFiltersModalState();
}

class _CustomersListFiltersModalState extends State<CustomersListFiltersModal> {
  String sortOrderByValue = "registered_date";
  String sortOrderValue = "desc";
  String roleFilterValue = "customer";

  @override
  void initState() {
    super.initState();
    sortOrderByValue = widget.sortOrderByValue;
    sortOrderValue = widget.sortOrderValue;
    roleFilterValue = widget.roleFilterValue;
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Sort by",
                style: Theme.of(context).textTheme.subhead,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: DropdownButton<String>(
                          underline: SizedBox.shrink(),
                          value: sortOrderByValue,
                          onChanged: (String newValue) {
                            FocusScope.of(context).requestFocus(FocusNode());
                            setState(() {
                              sortOrderByValue = newValue;
                            });
                          },
                          items: <String>[
                            "registered_date",
                            "id",
                            "name",
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
              ),
              Text(
                "Filter by",
                style: Theme.of(context).textTheme.subhead,
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(children: <Widget>[
                        Text(
                            "Role",
                            style: Theme.of(context).textTheme.body1.copyWith(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Expanded(child: SizedBox.shrink()),
                          Container(
                            height: 20,
                            child: DropdownButton<String>(
                              underline: SizedBox.shrink(),
                              value: roleFilterValue,
                              onChanged: (String newValue) {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                setState(() {
                                  roleFilterValue = newValue;
                                });
                              },
                              items: <String>[
                                "all",
                                "administrator",
                                "editor",
                                "author",
                                "contributor",
                                "subscriber",
                                "customer",
                                "shop_manager"
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
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 0),
      actions: <Widget>[
        FlatButton(
          child: Text("Close"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text("Ok"),
          onPressed: () {
            widget.onSubmit(sortOrderByValue, sortOrderValue, roleFilterValue);
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
