// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) {
  return Product(
    id: json['id'] as int,
    name: json['name'] as String,
    slug: json['slug'] as String,
    permalink: json['permalink'] as String,
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
    type: json['type'] as String,
    status: json['status'] as String,
    featured: json['featured'] as bool,
    catalogVisibility: json['catalog_visibility'] as String,
    description: json['description'] as String,
    shortDescription: json['short_description'] as String,
    sku: json['sku'] as String,
    price: json['price'] as String,
    regularPrice: json['regular_price'] as String,
    salePrice: json['sale_price'] as String,
    dateOnSaleFrom: json['date_on_sale_from'] == null
        ? null
        : DateTime.parse(json['date_on_sale_from'] as String),
    dateOnSaleFromGmt: json['date_on_sale_from_gmt'] == null
        ? null
        : DateTime.parse(json['date_on_sale_from_gmt'] as String),
    dateOnSaleTo: json['date_on_sale_to'] == null
        ? null
        : DateTime.parse(json['date_on_sale_to'] as String),
    dateOnSaleToGmt: json['date_on_sale_to_gmt'] == null
        ? null
        : DateTime.parse(json['date_on_sale_to_gmt'] as String),
    onSale: json['on_sale'] as bool,
    purchasable: json['purchasable'] as bool,
    totalSales: json['total_sales'] as int,
    virtual: json['virtual'] as bool,
    downloadable: json['downloadable'] as bool,
    downloads: (json['downloads'] as List)
        ?.map((e) =>
            e == null ? null : Download.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    downloadLimit: json['download_limit'] as int,
    downloadExpiry: json['download_expiry'] as int,
    externalUrl: json['external_url'] as String,
    buttonText: json['button_text'] as String,
    taxStatus: json['tax_status'] as String,
    taxClass: json['tax_class'] as String,
    manageStock: json['manage_stock'] as bool,
    stockQuantity: json['stock_quantity'] as int,
    stockStatus: json['stock_status'] as String,
    backorders: json['backorders'] as String,
    backordersAllowed: json['backorders_allowed'] as bool,
    backordered: json['backordered'] as bool,
    soldIndividually: json['sold_individually'] as bool,
    weight: json['weight'] as String,
    dimensions: json['dimensions'] == null
        ? null
        : Dimensions.fromJson(json['dimensions'] as Map<String, dynamic>),
    shippingRequired: json['shipping_required'] as bool,
    shippingTaxable: json['shipping_taxable'] as bool,
    shippingClass: json['shipping_class'] as String,
    shippingClassId: json['shipping_class_id'] as int,
    reviewsAllowed: json['reviews_allowed'] as bool,
    averageRating: json['average_rating'] as String,
    ratingCount: json['rating_count'] as int,
    parentId: json['parent_id'] as int,
    purchaseNote: json['purchase_note'] as String,
    categories: (json['categories'] as List)
        ?.map((e) =>
            e == null ? null : Category.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    tags: (json['tags'] as List)
        ?.map((e) => e == null ? null : Tag.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    images: (json['images'] as List)
        ?.map(
            (e) => e == null ? null : Image.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    attributes: (json['attributes'] as List)
        ?.map((e) =>
            e == null ? null : Attribute.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    defaultAttributes: (json['default_attributes'] as List)
        ?.map((e) => e == null
            ? null
            : DefaultAttribute.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    menuOrder: json['menu_order'] as int,
    metaData: (json['meta_data'] as List)
        ?.map((e) =>
            e == null ? null : MetaData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'permalink': instance.permalink,
      'date_created': instance.dateCreated?.toIso8601String(),
      'date_created_gmt': instance.dateCreatedGmt?.toIso8601String(),
      'date_modified': instance.dateModified?.toIso8601String(),
      'date_modified_gmt': instance.dateModifiedGmt?.toIso8601String(),
      'type': instance.type,
      'status': instance.status,
      'featured': instance.featured,
      'catalog_visibility': instance.catalogVisibility,
      'description': instance.description,
      'short_description': instance.shortDescription,
      'sku': instance.sku,
      'price': instance.price,
      'regular_price': instance.regularPrice,
      'sale_price': instance.salePrice,
      'date_on_sale_from': instance.dateOnSaleFrom?.toIso8601String(),
      'date_on_sale_from_gmt': instance.dateOnSaleFromGmt?.toIso8601String(),
      'date_on_sale_to': instance.dateOnSaleTo?.toIso8601String(),
      'date_on_sale_to_gmt': instance.dateOnSaleToGmt?.toIso8601String(),
      'on_sale': instance.onSale,
      'purchasable': instance.purchasable,
      'total_sales': instance.totalSales,
      'virtual': instance.virtual,
      'downloadable': instance.downloadable,
      'downloads': instance.downloads,
      'download_limit': instance.downloadLimit,
      'download_expiry': instance.downloadExpiry,
      'external_url': instance.externalUrl,
      'button_text': instance.buttonText,
      'tax_status': instance.taxStatus,
      'tax_class': instance.taxClass,
      'manage_stock': instance.manageStock,
      'stock_quantity': instance.stockQuantity,
      'stock_status': instance.stockStatus,
      'backorders': instance.backorders,
      'backorders_allowed': instance.backordersAllowed,
      'backordered': instance.backordered,
      'sold_individually': instance.soldIndividually,
      'weight': instance.weight,
      'dimensions': instance.dimensions,
      'shipping_required': instance.shippingRequired,
      'shipping_taxable': instance.shippingTaxable,
      'shipping_class': instance.shippingClass,
      'shipping_class_id': instance.shippingClassId,
      'reviews_allowed': instance.reviewsAllowed,
      'average_rating': instance.averageRating,
      'rating_count': instance.ratingCount,
      'parent_id': instance.parentId,
      'purchase_note': instance.purchaseNote,
      'categories': instance.categories,
      'tags': instance.tags,
      'images': instance.images,
      'attributes': instance.attributes,
      'default_attributes': instance.defaultAttributes,
      'menu_order': instance.menuOrder,
      'meta_data': instance.metaData,
    };

DefaultAttribute _$DefaultAttributeFromJson(Map<String, dynamic> json) {
  return DefaultAttribute(
    id: json['id'] as int,
    name: json['name'] as String,
    option: json['option'] as String,
  );
}

Map<String, dynamic> _$DefaultAttributeToJson(DefaultAttribute instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'option': instance.option,
    };

Attribute _$AttributeFromJson(Map<String, dynamic> json) {
  return Attribute(
    id: json['id'] as int,
    name: json['name'] as String,
    position: json['position'] as int,
    visible: json['visible'] as bool,
    variation: json['variation'] as bool,
    options: (json['options'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$AttributeToJson(Attribute instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'position': instance.position,
      'visible': instance.visible,
      'variation': instance.variation,
      'options': instance.options,
    };

Category _$CategoryFromJson(Map<String, dynamic> json) {
  return Category(
    id: json['id'] as int,
    name: json['name'] as String,
    slug: json['slug'] as String,
  );
}

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
    };

Dimensions _$DimensionsFromJson(Map<String, dynamic> json) {
  return Dimensions(
    length: json['length'] as String,
    width: json['width'] as String,
    height: json['height'] as String,
  );
}

Map<String, dynamic> _$DimensionsToJson(Dimensions instance) =>
    <String, dynamic>{
      'length': instance.length,
      'width': instance.width,
      'height': instance.height,
    };

Image _$ImageFromJson(Map<String, dynamic> json) {
  return Image(
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
    src: json['src'] as String,
    name: json['name'] as String,
    alt: json['alt'] as String,
  );
}

Map<String, dynamic> _$ImageToJson(Image instance) => <String, dynamic>{
      'id': instance.id,
      'date_created': instance.dateCreated?.toIso8601String(),
      'date_created_gmt': instance.dateCreatedGmt?.toIso8601String(),
      'date_modified': instance.dateModified?.toIso8601String(),
      'date_modified_gmt': instance.dateModifiedGmt?.toIso8601String(),
      'src': instance.src,
      'name': instance.name,
      'alt': instance.alt,
    };

MetaData _$MetaDataFromJson(Map<String, dynamic> json) {
  return MetaData(
    id: json['id'] as int,
    key: json['key'] as String,
    value: json['value'],
  );
}

Map<String, dynamic> _$MetaDataToJson(MetaData instance) => <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'value': instance.value,
    };

Download _$DownloadFromJson(Map<String, dynamic> json) {
  return Download(
    id: json['id'] as String,
    key: json['key'] as String,
    value: json['value'] as String,
  );
}

Map<String, dynamic> _$DownloadToJson(Download instance) => <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'value': instance.value,
    };

Tag _$TagFromJson(Map<String, dynamic> json) {
  return Tag(
    id: json['id'] as int,
    name: json['name'] as String,
    slug: json['slug'] as String,
  );
}

Map<String, dynamic> _$TagToJson(Tag instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
    };
