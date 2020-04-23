// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) {
  return Order(
    id: json['id'] as int,
    parentId: json['parent_id'] as int,
    number: json['number'] as String,
    orderKey: json['order_key'] as String,
    createdVia: json['created_via'] as String,
    version: json['version'] as String,
    status: json['status'] as String,
    currency: json['currency'] as String,
    dateCreated: json['date_created'] == null
        ? null
        : DateTime.parse(json['date_created'] as String),
    dateCreatedGmt: json['date_created_gmt'] == null
        ? null
        : DateTime.parse(json['date_created_gmt'] as String),
    dateModified: json['date_modified'] == null
        ? null
        : DateTime.parse(json['date_modified'] as String),
    dateModifiedGmt: json['date_modified_gmt'] == null
        ? null
        : DateTime.parse(json['date_modified_gmt'] as String),
    discountTotal: json['discount_total'] as String,
    discountTax: json['discount_tax'] as String,
    shippingTotal: json['shipping_total'] as String,
    shippingTax: json['shipping_tax'] as String,
    cartTax: json['cart_tax'] as String,
    total: json['total'] as String,
    totalTax: json['total_tax'] as String,
    pricesIncludeTax: json['prices_include_tax'] as bool,
    customerId: json['customer_id'] as int,
    customerIpAddress: json['customer_ip_address'] as String,
    customerUserAgent: json['customer_user_agent'] as String,
    customerNote: json['customer_note'] as String,
    billing: json['billing'] == null
        ? null
        : Billing.fromJson(json['billing'] as Map<String, dynamic>),
    shipping: json['shipping'] == null
        ? null
        : Shipping.fromJson(json['shipping'] as Map<String, dynamic>),
    paymentMethod: json['payment_method'] as String,
    paymentMethodTitle: json['payment_method_title'] as String,
    transactionId: json['transaction_id'] as String,
    datePaid: json['date_paid'] == null
        ? null
        : DateTime.parse(json['date_paid'] as String),
    datePaidGmt: json['date_paid_gmt'] == null
        ? null
        : DateTime.parse(json['date_paid_gmt'] as String),
    dateCompleted: json['date_completed'] == null
        ? null
        : DateTime.parse(json['date_completed'] as String),
    dateCompletedGmt: json['date_completed_gmt'] == null
        ? null
        : DateTime.parse(json['date_completed_gmt'] as String),
    cartHash: json['cart_hash'] as String,
    metaData: (json['meta_data'] as List)
        ?.map((e) => e == null
            ? null
            : OrderMetaData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    lineItems: (json['line_items'] as List)
        ?.map((e) =>
            e == null ? null : LineItem.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    taxLines: (json['tax_lines'] as List)
        ?.map((e) =>
            e == null ? null : TaxLine.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    shippingLines: (json['shipping_lines'] as List)
        ?.map((e) =>
            e == null ? null : ShippingLine.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    feeLines: (json['fee_lines'] as List)
        ?.map((e) =>
            e == null ? null : FeeLine.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    couponLines: (json['coupon_lines'] as List)
        ?.map((e) =>
            e == null ? null : CouponLine.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    refunds: (json['refunds'] as List)
        ?.map((e) =>
            e == null ? null : Refund.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    currencySymbol: json['currency_symbol'] as String,
  );
}

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'parent_id': instance.parentId,
      'number': instance.number,
      'order_key': instance.orderKey,
      'created_via': instance.createdVia,
      'version': instance.version,
      'status': instance.status,
      'currency': instance.currency,
      'date_created': instance.dateCreated?.toIso8601String(),
      'date_created_gmt': instance.dateCreatedGmt?.toIso8601String(),
      'date_modified': instance.dateModified?.toIso8601String(),
      'date_modified_gmt': instance.dateModifiedGmt?.toIso8601String(),
      'discount_total': instance.discountTotal,
      'discount_tax': instance.discountTax,
      'shipping_total': instance.shippingTotal,
      'shipping_tax': instance.shippingTax,
      'cart_tax': instance.cartTax,
      'total': instance.total,
      'total_tax': instance.totalTax,
      'prices_include_tax': instance.pricesIncludeTax,
      'customer_id': instance.customerId,
      'customer_ip_address': instance.customerIpAddress,
      'customer_user_agent': instance.customerUserAgent,
      'customer_note': instance.customerNote,
      'billing': instance.billing,
      'shipping': instance.shipping,
      'payment_method': instance.paymentMethod,
      'payment_method_title': instance.paymentMethodTitle,
      'transaction_id': instance.transactionId,
      'date_paid': instance.datePaid?.toIso8601String(),
      'date_paid_gmt': instance.datePaidGmt?.toIso8601String(),
      'date_completed': instance.dateCompleted?.toIso8601String(),
      'date_completed_gmt': instance.dateCompletedGmt?.toIso8601String(),
      'cart_hash': instance.cartHash,
      'meta_data': instance.metaData,
      'line_items': instance.lineItems,
      'tax_lines': instance.taxLines,
      'shipping_lines': instance.shippingLines,
      'fee_lines': instance.feeLines,
      'coupon_lines': instance.couponLines,
      'refunds': instance.refunds,
      'currency_symbol': instance.currencySymbol,
    };

Billing _$BillingFromJson(Map<String, dynamic> json) {
  return Billing(
    firstName: json['first_name'] as String,
    lastName: json['last_name'] as String,
    company: json['company'] as String,
    address1: json['address1'] as String,
    address2: json['address2'] as String,
    city: json['city'] as String,
    state: json['state'] as String,
    postcode: json['postcode'] as String,
    country: json['country'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
  );
}

Map<String, dynamic> _$BillingToJson(Billing instance) => <String, dynamic>{
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'company': instance.company,
      'address1': instance.address1,
      'address2': instance.address2,
      'city': instance.city,
      'state': instance.state,
      'postcode': instance.postcode,
      'country': instance.country,
      'email': instance.email,
      'phone': instance.phone,
    };

Shipping _$ShippingFromJson(Map<String, dynamic> json) {
  return Shipping(
    firstName: json['first_name'] as String,
    lastName: json['last_name'] as String,
    company: json['company'] as String,
    address1: json['address1'] as String,
    address2: json['address2'] as String,
    city: json['city'] as String,
    state: json['state'] as String,
    postcode: json['postcode'] as String,
    country: json['country'] as String,
  );
}

Map<String, dynamic> _$ShippingToJson(Shipping instance) => <String, dynamic>{
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'company': instance.company,
      'address1': instance.address1,
      'address2': instance.address2,
      'city': instance.city,
      'state': instance.state,
      'postcode': instance.postcode,
      'country': instance.country,
    };

OrderMetaData _$OrderMetaDataFromJson(Map<String, dynamic> json) {
  return OrderMetaData(
    id: json['id'] as int,
    key: json['key'] as String,
    value: json['value'],
  );
}

Map<String, dynamic> _$OrderMetaDataToJson(OrderMetaData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'value': instance.value,
    };

LineItem _$LineItemFromJson(Map<String, dynamic> json) {
  return LineItem(
    id: json['id'] as int,
    name: json['name'] as String,
    productId: json['product_id'] as int,
    variationId: json['variation_id'] as int,
    quantity: json['quantity'] as int,
    taxClass: json['tax_class'] as String,
    subtotal: json['subtotal'] as String,
    subtotalTax: json['subtotal_tax'] as String,
    total: json['total'] as String,
    totalTax: json['total_tax'] as String,
    taxes: (json['taxes'] as List)
        ?.map((e) => e == null ? null : Tax.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    metaData: (json['meta_data'] as List)
        ?.map((e) => e == null
            ? null
            : LineItemMetaData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    sku: json['sku'] as String,
    price: (json['price'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$LineItemToJson(LineItem instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'product_id': instance.productId,
      'variation_id': instance.variationId,
      'quantity': instance.quantity,
      'tax_class': instance.taxClass,
      'subtotal': instance.subtotal,
      'subtotal_tax': instance.subtotalTax,
      'total': instance.total,
      'total_tax': instance.totalTax,
      'taxes': instance.taxes,
      'meta_data': instance.metaData,
      'sku': instance.sku,
      'price': instance.price,
    };

LineItemMetaData _$LineItemMetaDataFromJson(Map<String, dynamic> json) {
  return LineItemMetaData(
    id: json['id'] as int,
    key: json['key'] as String,
    value: json['value'],
  );
}

Map<String, dynamic> _$LineItemMetaDataToJson(LineItemMetaData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'value': instance.value,
    };

Tax _$TaxFromJson(Map<String, dynamic> json) {
  return Tax(
    id: json['id'] as int,
    total: json['total'] as String,
    subtotal: json['subtotal'] as String,
  );
}

Map<String, dynamic> _$TaxToJson(Tax instance) => <String, dynamic>{
      'id': instance.id,
      'total': instance.total,
      'subtotal': instance.subtotal,
    };

ShippingLine _$ShippingLineFromJson(Map<String, dynamic> json) {
  return ShippingLine(
    id: json['id'] as int,
    methodTitle: json['method_title'] as String,
    methodId: json['method_id'] as String,
    instanceId: json['instance_id'] as String,
    total: json['total'] as String,
    totalTax: json['total_tax'] as String,
    taxes: json['taxes'] as List,
    metaData: (json['meta_data'] as List)
        ?.map((e) => e == null
            ? null
            : ShippingLineMetaData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ShippingLineToJson(ShippingLine instance) =>
    <String, dynamic>{
      'id': instance.id,
      'method_title': instance.methodTitle,
      'method_id': instance.methodId,
      'instance_id': instance.instanceId,
      'total': instance.total,
      'total_tax': instance.totalTax,
      'taxes': instance.taxes,
      'meta_data': instance.metaData,
    };

ShippingLineMetaData _$ShippingLineMetaDataFromJson(Map<String, dynamic> json) {
  return ShippingLineMetaData(
    id: json['id'] as int,
    key: json['key'] as String,
    value: json['value'],
  );
}

Map<String, dynamic> _$ShippingLineMetaDataToJson(
        ShippingLineMetaData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'value': instance.value,
    };

TaxLine _$TaxLineFromJson(Map<String, dynamic> json) {
  return TaxLine(
    id: json['id'] as int,
    rateCode: json['rate_code'] as String,
    rateId: json['rate_id'] as int,
    label: json['label'] as String,
    compound: json['compound'] as bool,
    taxTotal: json['tax_total'] as String,
    shippingTaxTotal: json['shipping_tax_total'] as String,
    ratePercent: json['rate_percent'] as int,
    metaData: (json['meta_data'] as List)
        ?.map((e) => e == null
            ? null
            : TaxLineMetaData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$TaxLineToJson(TaxLine instance) => <String, dynamic>{
      'id': instance.id,
      'rate_code': instance.rateCode,
      'rate_id': instance.rateId,
      'label': instance.label,
      'compound': instance.compound,
      'tax_total': instance.taxTotal,
      'shipping_tax_total': instance.shippingTaxTotal,
      'rate_percent': instance.ratePercent,
      'meta_data': instance.metaData,
    };

TaxLineMetaData _$TaxLineMetaDataFromJson(Map<String, dynamic> json) {
  return TaxLineMetaData(
    id: json['id'] as int,
    key: json['key'] as String,
    value: json['value'],
  );
}

Map<String, dynamic> _$TaxLineMetaDataToJson(TaxLineMetaData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'value': instance.value,
    };

FeeLine _$FeeLineFromJson(Map<String, dynamic> json) {
  return FeeLine(
    id: json['id'] as int,
    name: json['name'] as String,
    taxClass: json['tax_class'] as String,
    taxStatus: json['tax_status'] as String,
    total: json['total'] as String,
    totalTax: json['total_tax'] as String,
    taxes: json['taxes'] == null
        ? null
        : TaxLine.fromJson(json['taxes'] as Map<String, dynamic>),
    metaData: (json['meta_data'] as List)
        ?.map((e) => e == null
            ? null
            : FeeLineMetaData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$FeeLineToJson(FeeLine instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'tax_class': instance.taxClass,
      'tax_status': instance.taxStatus,
      'total': instance.total,
      'total_tax': instance.totalTax,
      'taxes': instance.taxes,
      'meta_data': instance.metaData,
    };

FeeLineMetaData _$FeeLineMetaDataFromJson(Map<String, dynamic> json) {
  return FeeLineMetaData(
    id: json['id'] as int,
    key: json['key'] as String,
    value: json['value'],
  );
}

Map<String, dynamic> _$FeeLineMetaDataToJson(FeeLineMetaData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'value': instance.value,
    };

CouponLine _$CouponLineFromJson(Map<String, dynamic> json) {
  return CouponLine(
    id: json['id'] as int,
    code: json['code'] as String,
    discount: json['discount'] as int,
    discountTax: json['discount_tax'] as String,
    metaData: (json['meta_data'] as List)
        ?.map((e) => e == null
            ? null
            : CouponLineMetaData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$CouponLineToJson(CouponLine instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'discount': instance.discount,
      'discount_tax': instance.discountTax,
      'meta_data': instance.metaData,
    };

CouponLineMetaData _$CouponLineMetaDataFromJson(Map<String, dynamic> json) {
  return CouponLineMetaData(
    id: json['id'] as int,
    key: json['key'] as String,
    value: json['value'],
  );
}

Map<String, dynamic> _$CouponLineMetaDataToJson(CouponLineMetaData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'value': instance.value,
    };

Refund _$RefundFromJson(Map<String, dynamic> json) {
  return Refund(
    id: json['id'] as int,
    reason: json['reason'] as String,
    total: json['total'] as String,
  );
}

Map<String, dynamic> _$RefundToJson(Refund instance) => <String, dynamic>{
      'id': instance.id,
      'reason': instance.reason,
      'total': instance.total,
    };
