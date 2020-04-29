import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/common/widgets/single_select.dart';
import 'package:woocommerceadmin/src/customers/providers/customers_list_filters_provider.dart';

class CustomersListFiltersScreen extends StatefulWidget {
  final Function handleRefresh;

  CustomersListFiltersScreen({
    Key key,
    @required this.handleRefresh,
  }) : super(key: key);

  @override
  _CustomersListFiltersScreenState createState() =>
      _CustomersListFiltersScreenState();
}

class _CustomersListFiltersScreenState
    extends State<CustomersListFiltersScreen> {
  bool isInit = true;
  String sortOrderByValue = "registered_date";
  String sortOrderValue = "desc";
  String roleFilterValue = "customer";

  final List<SingleSelectMenu> sortOrderByOptions = [
    SingleSelectMenu(value: "registered_date", name: "Registered Date"),
    SingleSelectMenu(value: "id", name: "Id"),
    SingleSelectMenu(value: "name", name: "Name"),
    SingleSelectMenu(value: "include", name: "Include"),
  ];

  final List<SingleSelectMenu> roleFilterOptions = [
    SingleSelectMenu(value: "all", name: "All"),
    SingleSelectMenu(value: "administrator", name: "Administrator"),
    SingleSelectMenu(value: "editor", name: "Editor"),
    SingleSelectMenu(value: "author", name: "Author"),
    SingleSelectMenu(value: "contributor", name: "Contributor"),
    SingleSelectMenu(value: "subscriber", name: "Subscriber"),
    SingleSelectMenu(value: "customer", name: "Customer"),
    SingleSelectMenu(value: "shop_manager", name: "Shop Manager"),
  ];

  @override
  void didChangeDependencies() {
    if (isInit) {
      CustomersListFiltersProvider customersListFiltersProvider =
          Provider.of<CustomersListFiltersProvider>(context, listen: false);
      sortOrderByValue = customersListFiltersProvider.sortOrderByValue;
      sortOrderValue = customersListFiltersProvider.sortOrderValue;
      roleFilterValue = customersListFiltersProvider.roleFilterValue;
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customers List Filter"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: SingleSelect(
                    labelText: "Sort by",
                    labelTextStyle: Theme.of(context).textTheme.body2,
                    modalHeadingTextStyle: Theme.of(context).textTheme.subhead,
                    modalListTextStyle: Theme.of(context).textTheme.body1,
                    selectedValue: sortOrderByValue,
                    options: sortOrderByOptions,
                    onChange: (value) {
                      setState(() {
                        sortOrderByValue = value;
                      });
                    },
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.arrow_downward,
                          color: (sortOrderValue == "desc")
                              ? Theme.of(context).primaryColor
                              : Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            sortOrderValue = "desc";
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_upward,
                          color: (sortOrderValue == "asc")
                              ? Theme.of(context).primaryColor
                              : Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            sortOrderValue = "asc";
                          });
                        },
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: SingleSelect(
                    labelText: "Filter by role",
                    labelTextStyle: Theme.of(context).textTheme.body2,
                    modalHeadingTextStyle: Theme.of(context).textTheme.subhead,
                    modalListTextStyle: Theme.of(context).textTheme.body1,
                    selectedValue: roleFilterValue,
                    options: roleFilterOptions,
                    onChange: (value) {
                      setState(() {
                        roleFilterValue = value;
                      });
                    },
                  ),
                ),
                Divider(),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 50,
                  child: RaisedButton(
                    child: Text(
                      "Apply",
                      style: Theme.of(context).textTheme.button,
                    ),
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      Provider.of<CustomersListFiltersProvider>(context,
                              listen: false)
                          .changeFilterModalValues(
                        sortOrderByValue: sortOrderByValue,
                        sortOrderValue: sortOrderValue,
                        roleFilterValue: roleFilterValue,
                      );
                      widget.handleRefresh();
                      Navigator.pop(context);
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
}
