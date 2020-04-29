import 'package:json_annotation/json_annotation.dart';
part 'customer.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Customer {
  final int id;
  final DateTime dateCreated;
  final DateTime dateCreatedGmt;
  final DateTime dateModified;
  final DateTime dateModifiedGmt;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String username;
  final Billing billing;
  final Shipping shipping;
  final bool isPayingCustomer;
  final String avatarUrl;
  final List<CustomerMetaData> metaData;

  Customer({
    this.id,
    this.dateCreated,
    this.dateCreatedGmt,
    this.dateModified,
    this.dateModifiedGmt,
    this.email,
    this.firstName,
    this.lastName,
    this.role,
    this.username,
    this.billing,
    this.shipping,
    this.isPayingCustomer,
    this.avatarUrl,
    this.metaData,
  });

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Billing {
  final String firstName;
  final String lastName;
  final String company;
  final String address1;
  final String address2;
  final String city;
  final String postcode;
  final String country;
  final String state;
  final String email;
  final String phone;

  Billing({
    this.firstName,
    this.lastName,
    this.company,
    this.address1,
    this.address2,
    this.city,
    this.postcode,
    this.country,
    this.state,
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
class CustomerMetaData {
  final int id;
  final String key;
  final dynamic value;

  CustomerMetaData({
    this.id,
    this.key,
    this.value,
  });

  factory CustomerMetaData.fromJson(Map<String, dynamic> json) =>
      _$CustomerMetaDataFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerMetaDataToJson(this);
}
