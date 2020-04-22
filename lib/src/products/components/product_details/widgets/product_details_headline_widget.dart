import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/products/models/products.dart';

class ProductDetailsHeadlineWidget extends StatelessWidget {

  final int id;

  ProductDetailsHeadlineWidget({
    @required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<Products>(
      builder: (context, productListData, _) => Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      productListData.getProductById(this.id) ?.name ?? "",
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        padding: const EdgeInsets.all(0.0),
        alignment: Alignment.center,
      ),
    );
  }
}
