// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Customer _$CustomerFromJson(Map<String, dynamic> json) {
  return Customer(
    id: json['id'] as int,
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
    email: json['email'] as String,
    firstName: json['first_name'] as String,
    lastName: json['last_name'] as String,
    role: json['role'] as String,
    username: json['username'] as String,
    billing: json['billing'] == null
        ? null
        : Billing.fromJson(json['billing'] as Map<String, dynamic>),
    shipping: json['shipping'] == null
        ? null
        : Shipping.fromJson(json['shipping'] as Map<String, dynamic>),
    isPayingCustomer: json['is_paying_customer'] as bool,
    avatarUrl: json['avatar_url'] as String,
    metaData: (json['meta_data'] as List)
        ?.map((e) => e == null
            ? null
            : CustomerMetaData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
      'id': instance.id,
      'date_created': instance.dateCreated?.toIso8601String(),
      'date_created_gmt': instance.dateCreatedGmt?.toIso8601String(),
      'date_modified': instance.dateModified?.toIso8601String(),
      'date_modified_gmt': instance.dateModifiedGmt?.toIso8601String(),
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'role': instance.role,
      'username': instance.username,
      'billing': instance.billing,
      'shipping': instance.shipping,
      'is_paying_customer': instance.isPayingCustomer,
      'avatar_url': instance.avatarUrl,
      'meta_data': instance.metaData,
    };

Billing _$BillingFromJson(Map<String, dynamic> json) {
  return Billing(
    firstName: json['first_name'] as String,
    lastName: json['last_name'] as String,
    company: json['company'] as String,
    address1: json['address1'] as String,
    address2: json['address2'] as String,
    city: json['city'] as String,
    postcode: json['postcode'] as String,
    country: json['country'] as String,
    state: json['state'] as String,
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
      'postcode': instance.postcode,
      'country': instance.country,
      'state': instance.state,
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

CustomerMetaData _$CustomerMetaDataFromJson(Map<String, dynamic> json) {
  return CustomerMetaData(
    id: json['id'] as int,
    key: json['key'] as String,
    value: json['value'],
  );
}

Map<String, dynamic> _$CustomerMetaDataToJson(CustomerMetaData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'value': instance.value,
    };
