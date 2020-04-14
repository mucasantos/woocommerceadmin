import 'package:flutter/material.dart';

class EditProductShippingPage extends StatefulWidget {
  final String weight;
  final String length;
  final String width;
  final String height;
  final bool shippingRequired;
  final bool shippingTaxable;
  final String shippingClass;

  EditProductShippingPage({
    this.weight,
    this.length,
    this.width,
    this.height,
    this.shippingRequired,
    this.shippingTaxable,
    this.shippingClass,
  });

  @override
  _EditProductShippingPageState createState() =>
      _EditProductShippingPageState();
}

class _EditProductShippingPageState extends State<EditProductShippingPage> {
  String weight;
  String length;
  String width;
  String height;
  bool shippingRequired;
  bool shippingTaxable;
  String shippingClass;

  @override
  void initState() {
    weight = widget.weight;
    length = widget.length;
    width = widget.width;
    height = widget.height;
    shippingRequired = widget.shippingRequired;
    shippingTaxable = widget.shippingTaxable;
    shippingClass =widget.shippingClass;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
