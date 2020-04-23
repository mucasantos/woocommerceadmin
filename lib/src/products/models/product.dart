import 'package:json_annotation/json_annotation.dart';
part 'product.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Product {
  final int id;
  final String name;
  final String slug;
  final String permalink;
  final DateTime dateCreated;
  final DateTime dateCreatedGmt;
  final DateTime dateModified;
  final DateTime dateModifiedGmt;
  final String type;
  final String status;
  final bool featured;
  final String catalogVisibility;
  final String description;
  final String shortDescription;
  final String sku;
  final String price;
  final String regularPrice;
  final String salePrice;
  final DateTime dateOnSaleFrom;
  final DateTime dateOnSaleFromGmt;
  final DateTime dateOnSaleTo;
  final DateTime dateOnSaleToGmt;
  final bool onSale;
  final bool purchasable;
  final int totalSales;
  final bool virtual;
  final bool downloadable;
  final List<Download> downloads;
  final int downloadLimit;
  final int downloadExpiry;
  final String externalUrl;
  final String buttonText;
  final String taxStatus;
  final String taxClass;
  final bool manageStock;
  final int stockQuantity;
  final String stockStatus;
  final String backorders;
  final bool backordersAllowed;
  final bool backordered;
  final bool soldIndividually;
  final String weight;
  final Dimensions dimensions;
  final bool shippingRequired;
  final bool shippingTaxable;
  final String shippingClass;
  final int shippingClassId;
  final bool reviewsAllowed;
  final String averageRating;
  final int ratingCount;
  final int parentId;
  final String purchaseNote;
  final List<Category> categories;
  final List<Tag> tags;
  final List<Image> images;
  final List<Attribute> attributes;
  final List<DefaultAttribute> defaultAttributes;
  final int menuOrder;
  final List<MetaData> metaData;

  Product({
    this.id,
    this.name,
    this.slug,
    this.permalink,
    this.dateCreated,
    this.dateCreatedGmt,
    this.dateModified,
    this.dateModifiedGmt,
    this.type,
    this.status,
    this.featured,
    this.catalogVisibility,
    this.description,
    this.shortDescription,
    this.sku,
    this.price,
    this.regularPrice,
    this.salePrice,
    this.dateOnSaleFrom,
    this.dateOnSaleFromGmt,
    this.dateOnSaleTo,
    this.dateOnSaleToGmt,
    this.onSale,
    this.purchasable,
    this.totalSales,
    this.virtual,
    this.downloadable,
    this.downloads,
    this.downloadLimit,
    this.downloadExpiry,
    this.externalUrl,
    this.buttonText,
    this.taxStatus,
    this.taxClass,
    this.manageStock,
    this.stockQuantity,
    this.stockStatus,
    this.backorders,
    this.backordersAllowed,
    this.backordered,
    this.soldIndividually,
    this.weight,
    this.dimensions,
    this.shippingRequired,
    this.shippingTaxable,
    this.shippingClass,
    this.shippingClassId,
    this.reviewsAllowed,
    this.averageRating,
    this.ratingCount,
    this.parentId,
    this.purchaseNote,
    this.categories,
    this.tags,
    this.images,
    this.attributes,
    this.defaultAttributes,
    this.menuOrder,
    this.metaData,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class DefaultAttribute {
  final int id;
  final String name;
  final String option;

  DefaultAttribute({
    this.id,
    this.name,
    this.option,
  });

  factory DefaultAttribute.fromJson(Map<String, dynamic> json) =>
      _$DefaultAttributeFromJson(json);
  Map<String, dynamic> toJson() => _$DefaultAttributeToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Attribute {
  final int id;
  final String name;
  final int position;
  final bool visible;
  final bool variation;
  final List<String> options;

  Attribute({
    this.id,
    this.name,
    this.position,
    this.visible,
    this.variation,
    this.options,
  });

  factory Attribute.fromJson(Map<String, dynamic> json) =>
      _$AttributeFromJson(json);
  Map<String, dynamic> toJson() => _$AttributeToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Category {
  final int id;
  final String name;
  final String slug;

  Category({
    this.id,
    this.name,
    this.slug,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Dimensions {
  final String length;
  final String width;
  final String height;

  Dimensions({
    this.length,
    this.width,
    this.height,
  });

  factory Dimensions.fromJson(Map<String, dynamic> json) =>
      _$DimensionsFromJson(json);
  Map<String, dynamic> toJson() => _$DimensionsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Image {
  final int id;
  final DateTime dateCreated;
  final DateTime dateCreatedGmt;
  final DateTime dateModified;
  final DateTime dateModifiedGmt;
  final String src;
  final String name;
  final String alt;

  Image({
    this.id,
    this.dateCreated,
    this.dateCreatedGmt,
    this.dateModified,
    this.dateModifiedGmt,
    this.src,
    this.name,
    this.alt,
  });

  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);
  Map<String, dynamic> toJson() => _$ImageToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MetaData {
  final int id;
  final String key;
  final dynamic value;

  MetaData({
    this.id,
    this.key,
    this.value,
  });

  factory MetaData.fromJson(Map<String, dynamic> json) =>
      _$MetaDataFromJson(json);
  Map<String, dynamic> toJson() => _$MetaDataToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Download {
  final String id;
  final String key;
  final String value;

  Download({
    this.id,
    this.key,
    this.value,
  });

  factory Download.fromJson(Map<String, dynamic> json) =>
      _$DownloadFromJson(json);
  Map<String, dynamic> toJson() => _$DownloadToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Tag {
  final int id;
  final String name;
  final String slug;

  Tag({
    this.id,
    this.name,
    this.slug,
  });

  factory Tag.fromJson(Map<String, dynamic> json) =>
      _$TagFromJson(json);
  Map<String, dynamic> toJson() => _$TagToJson(this);
}
