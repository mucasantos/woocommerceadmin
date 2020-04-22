import 'package:json_annotation/json_annotation.dart';
part 'order.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Order {
  final int id;
  final int parentId;
  final String number;
  final String orderKey;
  final String createdVia;
  final String version;
  final String status;
  final String currency;
  final DateTime dateCreated;
  final DateTime dateCreatedGmt;
  final DateTime dateModified;
  final DateTime dateModifiedGmt;
  final String discountTotal;
  final String discountTax;
  final String shippingTotal;
  final String shippingTax;
  final String cartTax;
  final String total;
  final String totalTax;
  final bool pricesIncludeTax;
  final int customerId;
  final String customerIpAddress;
  final String customerUserAgent;
  final String customerNote;
  final Billing billing;
  final Shipping shipping;
  final String paymentMethod;
  final String paymentMethodTitle;
  final String transactionId;
  final DateTime datePaid;
  final DateTime datePaidGmt;
  final DateTime dateCompleted;
  final DateTime dateCompletedGmt;
  final String cartHash;
  final List<OrderMetaData> metaData;
  final List<LineItem> lineItems;
  final List<TaxLine> taxLines;
  final List<ShippingLine> shippingLines;
  // final List<FeeLine> feeLines;
  final List<CouponLine> couponLines;
  final List<Refund> refunds;
  final String currencySymbol;

  Order({
    this.id,
    this.parentId,
    this.number,
    this.orderKey,
    this.createdVia,
    this.version,
    this.status,
    this.currency,
    this.dateCreated,
    this.dateCreatedGmt,
    this.dateModified,
    this.dateModifiedGmt,
    this.discountTotal,
    this.discountTax,
    this.shippingTotal,
    this.shippingTax,
    this.cartTax,
    this.total,
    this.totalTax,
    this.pricesIncludeTax,
    this.customerId,
    this.customerIpAddress,
    this.customerUserAgent,
    this.customerNote,
    this.billing,
    this.shipping,
    this.paymentMethod,
    this.paymentMethodTitle,
    this.transactionId,
    this.datePaid,
    this.datePaidGmt,
    this.dateCompleted,
    this.dateCompletedGmt,
    this.cartHash,
    this.metaData,
    this.lineItems,
    this.taxLines,
    this.shippingLines,
    // this.feeLines,
    this.couponLines,
    this.refunds,
    this.currencySymbol,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Billing {
  final String firstName;
  final String lastName;
  final String company;
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String postcode;
  final String country;
  final String email;
  final String phone;

  Billing({
    this.firstName,
    this.lastName,
    this.company,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.postcode,
    this.country,
    this.email,
    this.phone,
  });

  factory Billing.fromJson(Map<String, dynamic> json) =>
      _$BillingFromJson(json);
  Map<String, dynamic> toJson() => _$BillingToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Shipping {
  final String firstName;
  final String lastName;
  final String company;
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String postcode;
  final String country;

  Shipping({
    this.firstName,
    this.lastName,
    this.company,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.postcode,
    this.country,
  });

  factory Shipping.fromJson(Map<String, dynamic> json) =>
      _$ShippingFromJson(json);
  Map<String, dynamic> toJson() => _$ShippingToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class OrderMetaData {
  final int id;
  final String key;
  final dynamic value;

  OrderMetaData({
    this.id,
    this.key,
    this.value,
  });

  factory OrderMetaData.fromJson(Map<String, dynamic> json) =>
      _$OrderMetaDataFromJson(json);
  Map<String, dynamic> toJson() => _$OrderMetaDataToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LineItem {
  final int id;
  final String name;
  final int productId;
  final int variationId;
  final int quantity;
  final String taxClass;
  final String subtotal;
  final String subtotalTax;
  final String total;
  final String totalTax;
  final List<Tax> taxes;
  final List<LineItemMetaData> metaData;
  final String sku;
  final double price;

  LineItem({
    this.id,
    this.name,
    this.productId,
    this.variationId,
    this.quantity,
    this.taxClass,
    this.subtotal,
    this.subtotalTax,
    this.total,
    this.totalTax,
    this.taxes,
    this.metaData,
    this.sku,
    this.price,
  });

  factory LineItem.fromJson(Map<String, dynamic> json) =>
      _$LineItemFromJson(json);
  Map<String, dynamic> toJson() => _$LineItemToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LineItemMetaData {
  final int id;
  final String key;
  final dynamic value;

  LineItemMetaData({
    this.id,
    this.key,
    this.value,
  });

  factory LineItemMetaData.fromJson(Map<String, dynamic> json) =>
      _$LineItemMetaDataFromJson(json);
  Map<String, dynamic> toJson() => _$LineItemMetaDataToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Tax {
  final int id;
  final String total;
  final String subtotal;

  Tax({
    this.id,
    this.total,
    this.subtotal,
  });

  factory Tax.fromJson(Map<String, dynamic> json) => _$TaxFromJson(json);
  Map<String, dynamic> toJson() => _$TaxToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ShippingLine {
  final int id;
  final String methodTitle;
  final String methodId;
  final String instanceId;
  final String total;
  final String totalTax;
  final List<dynamic> taxes;
  final List<ShippingLineMetaData> metaData;

  ShippingLine({
    this.id,
    this.methodTitle,
    this.methodId,
    this.instanceId,
    this.total,
    this.totalTax,
    this.taxes,
    this.metaData,
  });

  factory ShippingLine.fromJson(Map<String, dynamic> json) =>
      _$ShippingLineFromJson(json);
  Map<String, dynamic> toJson() => _$ShippingLineToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ShippingLineMetaData {
  final int id;
  final String key;
  final dynamic value;

  ShippingLineMetaData({
    this.id,
    this.key,
    this.value,
  });

  factory ShippingLineMetaData.fromJson(Map<String, dynamic> json) =>
      _$ShippingLineMetaDataFromJson(json);
  Map<String, dynamic> toJson() => _$ShippingLineMetaDataToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TaxLine {
  final int id;
  final String rateCode;
  final int rateId;
  final String label;
  final bool compound;
  final String taxTotal;
  final String shippingTaxTotal;
  final int ratePercent;
  final List<TaxLineMetaData> metaData;

  TaxLine({
    this.id,
    this.rateCode,
    this.rateId,
    this.label,
    this.compound,
    this.taxTotal,
    this.shippingTaxTotal,
    this.ratePercent,
    this.metaData,
  });

  factory TaxLine.fromJson(Map<String, dynamic> json) =>
      _$TaxLineFromJson(json);
  Map<String, dynamic> toJson() => _$TaxLineToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TaxLineMetaData {
  final int id;
  final String key;
  final dynamic value;

  TaxLineMetaData({
    this.id,
    this.key,
    this.value,
  });

  factory TaxLineMetaData.fromJson(Map<String, dynamic> json) =>
      _$TaxLineMetaDataFromJson(json);
  Map<String, dynamic> toJson() => _$TaxLineMetaDataToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class FeeLine {
  final int id;
  final String name;
  final String taxClass;
  final String taxStatus;
  final String total;
  final String totalTax;
  final TaxLine taxes;
  final List<FeeLineMetaData> metaData;

  FeeLine({
    this.id,
    this.name,
    this.taxClass,
    this.taxStatus,
    this.total,
    this.totalTax,
    this.taxes,
    this.metaData,
  });

  factory FeeLine.fromJson(Map<String, dynamic> json) =>
      _$FeeLineFromJson(json);
  Map<String, dynamic> toJson() => _$FeeLineToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class FeeLineMetaData {
  final int id;
  final String key;
  final dynamic value;

  FeeLineMetaData({
    this.id,
    this.key,
    this.value,
  });

  factory FeeLineMetaData.fromJson(Map<String, dynamic> json) =>
      _$FeeLineMetaDataFromJson(json);
  Map<String, dynamic> toJson() => _$FeeLineMetaDataToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CouponLine {
  final int id;
  final String code;
  final int discount;
  final String discountTax;
  final List<CouponLineMetaData> metaData;

  CouponLine({
    this.id,
    this.code,
    this.discount,
    this.discountTax,
    this.metaData,
  });

  factory CouponLine.fromJson(Map<String, dynamic> json) =>
      _$CouponLineFromJson(json);
  Map<String, dynamic> toJson() => _$CouponLineToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CouponLineMetaData {
  final int id;
  final String key;
  final dynamic value;

  CouponLineMetaData({
    this.id,
    this.key,
    this.value,
  });

  factory CouponLineMetaData.fromJson(Map<String, dynamic> json) =>
      _$CouponLineMetaDataFromJson(json);
  Map<String, dynamic> toJson() => _$CouponLineMetaDataToJson(this);
}


@JsonSerializable(fieldRename: FieldRename.snake)
class Refund {
  final int id;
  final String reason;
  final String total;
  
  Refund({
    this.id,
    this.reason,
    this.total,
  });

  factory Refund.fromJson(Map<String, dynamic> json) =>
      _$RefundFromJson(json);
  Map<String, dynamic> toJson() => _$RefundToJson(this);
}