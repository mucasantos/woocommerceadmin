import 'package:flutter/material.dart';
import 'package:woocommerceadmin/src/common/widgets/SingleSelect.dart';

class EditProductGeneralPage extends StatefulWidget {
  final String slug;
  final String type;
  final String status;
  final String catalogVisibility;
  final bool featured;
  final bool virtual;
  final bool downloadable;

  EditProductGeneralPage({
    this.slug,
    this.type,
    this.status,
    this.catalogVisibility,
    this.featured,
    this.virtual,
    this.downloadable,
  });

  @override
  _EditProductGeneralPageState createState() => _EditProductGeneralPageState();
}

class _EditProductGeneralPageState extends State<EditProductGeneralPage> {
  String slug;
  String type;
  String status;
  String catalogVisibility;
  bool featured;
  bool virtual;
  bool downloadable;

  @override
  void initState() {
    slug = widget.slug;
    type = widget.type;
    status = widget.status;
    catalogVisibility = widget.catalogVisibility;
    featured = widget.featured;
    virtual = widget.virtual;
    downloadable = widget.downloadable;
    super.initState();
  }

  @override
  void setState(Function fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("General Details"),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  initialValue: slug is String ? slug : "",
                  style: Theme.of(context).textTheme.body2,
                  decoration: InputDecoration(labelText: "Slug"),
                  onChanged: (String value) {
                    setState(() {
                      slug = value;
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(),
                SingleSelect(
                  labelText: "Type",
                  labelTextStyle: Theme.of(context).textTheme.body2,
                  modalHeadingTextStyle: Theme.of(context).textTheme.subhead,
                  modalListTextStyle: Theme.of(context).textTheme.body1,
                  selectedKey: type,
                  options: [
                    {"slug": "simple", "name": "Simple"},
                  ],
                  keyString: "slug",
                  valueString: "name",
                  onChange: (Map<String, dynamic> value) {
                    setState(() {
                      type = value["slug"];
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(),
                SingleSelect(
                  labelText: "Status",
                  labelTextStyle: Theme.of(context).textTheme.body2,
                  modalHeadingTextStyle: Theme.of(context).textTheme.subhead,
                  modalListTextStyle: Theme.of(context).textTheme.body1,
                  selectedKey: status,
                  options: [
                    {"slug": "draft", "name": "Draft"},
                    {"slug": "pending", "name": "Pending"},
                    {"slug": "private", "name": "Private"},
                    {"slug": "publish", "name": "Publish"},
                  ],
                  keyString: "slug",
                  valueString: "name",
                  onChange: (Map<String, dynamic> value) {
                    setState(() {
                      status = value["slug"];
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(),
                SingleSelect(
                  labelText: "Catalog Visibility",
                  labelTextStyle: Theme.of(context).textTheme.body2,
                  modalHeadingTextStyle: Theme.of(context).textTheme.subhead,
                  modalListTextStyle: Theme.of(context).textTheme.body1,
                  selectedKey: catalogVisibility,
                  options: [
                    {"slug": "visible", "name": "Visible"},
                    {"slug": "catalog", "name": "Catalog"},
                    {"slug": "search", "name": "Search"},
                    {"slug": "hidden", "name": "Hidden"},
                  ],
                  keyString: "slug",
                  valueString: "name",
                  onChange: (Map<String, dynamic> value) {
                    setState(() {
                      status = value["slug"];
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(),
                InkWell(
                  onTap: () {
                    setState(() {
                      featured = !featured;
                    });
                  },
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          "Featured",
                          style: Theme.of(context).textTheme.body2,
                        ),
                      ),
                      Checkbox(
                        value: featured,
                        onChanged: (bool value) {
                          setState(() {
                            featured = value;
                          });
                        },
                      )
                    ],
                  ),
                ),
                Divider(),
                InkWell(
                  onTap: () {
                    setState(() {
                      virtual = !virtual;
                    });
                  },
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          "Virtual",
                          style: Theme.of(context).textTheme.body2,
                        ),
                      ),
                      Checkbox(
                        value: virtual,
                        onChanged: (bool value) {
                          setState(() {
                            virtual = value;
                          });
                        },
                      )
                    ],
                  ),
                ),
                Divider(),
                InkWell(
                  onTap: () {
                    setState(() {
                      downloadable = !downloadable;
                    });
                  },
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          "Downloadable",
                          style: Theme.of(context).textTheme.body2,
                        ),
                      ),
                      Checkbox(
                        value: downloadable,
                        onChanged: (bool value) {
                          setState(() {
                            downloadable = value;
                          });
                        },
                      )
                    ],
                  ),
                ),
                Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
