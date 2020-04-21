// To parse this JSON data, do
//
//     final product = productFromJson(jsonString);

import 'dart:convert';

Product productFromJson(String str) => Product.fromJson(json.decode(str));

String productToJson(Product data) => json.encode(data.toJson());

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
  final String priceHtml;
  final bool onSale;
  final bool purchasable;
  final int totalSales;
  final bool virtual;
  final bool downloadable;
  final List<dynamic> downloads;
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
  final List<int> relatedIds;
  final List<dynamic> upsellIds;
  final List<dynamic> crossSellIds;
  final int parentId;
  final String purchaseNote;
  final List<Category> categories;
  final List<dynamic> tags;
  final List<Image> images;
  final List<Attribute> attributes;
  final List<dynamic> defaultAttributes;
  final List<dynamic> variations;
  final List<dynamic> groupedProducts;
  final int menuOrder;
  final List<MetaDatum> metaData;
  final bool jetpackLikesEnabled;
  final Links links;

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
    this.priceHtml,
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
    this.relatedIds,
    this.upsellIds,
    this.crossSellIds,
    this.parentId,
    this.purchaseNote,
    this.categories,
    this.tags,
    this.images,
    this.attributes,
    this.defaultAttributes,
    this.variations,
    this.groupedProducts,
    this.menuOrder,
    this.metaData,
    this.jetpackLikesEnabled,
    this.links,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        slug: json["slug"] == null ? null : json["slug"],
        permalink: json["permalink"] == null ? null : json["permalink"],
        dateCreated: json["date_created"] == null
            ? null
            : DateTime.parse(json["date_created"]),
        dateCreatedGmt: json["date_created_gmt"] == null
            ? null
            : DateTime.parse(json["date_created_gmt"]),
        dateModified: json["date_modified"] == null
            ? null
            : DateTime.parse(json["date_modified"]),
        dateModifiedGmt: json["date_modified_gmt"] == null
            ? null
            : DateTime.parse(json["date_modified_gmt"]),
        type: json["type"] == null ? null : json["type"],
        status: json["status"] == null ? null : json["status"],
        featured: json["featured"] == null ? null : json["featured"],
        catalogVisibility: json["catalog_visibility"] == null
            ? null
            : json["catalog_visibility"],
        description: json["description"] == null ? null : json["description"],
        shortDescription: json["short_description"] == null
            ? null
            : json["short_description"],
        sku: json["sku"] == null ? null : json["sku"],
        price: json["price"] == null ? null : json["price"],
        regularPrice:
            json["regular_price"] == null ? null : json["regular_price"],
        salePrice: json["sale_price"] == null ? null : json["sale_price"],
        dateOnSaleFrom: json["date_on_sale_from"] == null
            ? null
            : DateTime.parse(json["date_on_sale_from"]),
        dateOnSaleFromGmt: json["date_on_sale_from_gmt"] == null
            ? null
            : DateTime.parse(json["date_on_sale_from_gmt"]),
        dateOnSaleTo: json["date_on_sale_to"] == null
            ? null
            : DateTime.parse(json["date_on_sale_to"]),
        dateOnSaleToGmt: json["date_on_sale_to_gmt"] == null
            ? null
            : DateTime.parse(json["date_on_sale_to_gmt"]),
        priceHtml: json["price_html"] == null ? null : json["price_html"],
        onSale: json["on_sale"] == null ? null : json["on_sale"],
        purchasable: json["purchasable"] == null ? null : json["purchasable"],
        totalSales: json["total_sales"] == null ? null : json["total_sales"],
        virtual: json["virtual"] == null ? null : json["virtual"],
        downloadable:
            json["downloadable"] == null ? null : json["downloadable"],
        downloads: json["downloads"] == null
            ? null
            : List<dynamic>.from(json["downloads"].map((x) => x)),
        downloadLimit:
            json["download_limit"] == null ? null : json["download_limit"],
        downloadExpiry:
            json["download_expiry"] == null ? null : json["download_expiry"],
        externalUrl: json["external_url"] == null ? null : json["external_url"],
        buttonText: json["button_text"] == null ? null : json["button_text"],
        taxStatus: json["tax_status"] == null ? null : json["tax_status"],
        taxClass: json["tax_class"] == null ? null : json["tax_class"],
        manageStock: json["manage_stock"] == null ? null : json["manage_stock"],
        stockQuantity:
            json["stock_quantity"] == null ? null : json["stock_quantity"],
        stockStatus: json["stock_status"] == null ? null : json["stock_status"],
        backorders: json["backorders"] == null ? null : json["backorders"],
        backordersAllowed: json["backorders_allowed"] == null
            ? null
            : json["backorders_allowed"],
        backordered: json["backordered"] == null ? null : json["backordered"],
        soldIndividually: json["sold_individually"],
        weight: json["weight"] == null ? null : json["weight"],
        dimensions: json["dimensions"] == null
            ? null
            : Dimensions.fromJson(json["dimensions"]),
        shippingRequired: json["shipping_required"] == null
            ? null
            : json["shipping_required"],
        shippingTaxable:
            json["shipping_taxable"] == null ? null : json["shipping_taxable"],
        shippingClass:
            json["shipping_class"] == null ? null : json["shipping_class"],
        shippingClassId: json["shipping_class_id"] == null
            ? null
            : json["shipping_class_id"],
        reviewsAllowed:
            json["reviews_allowed"] == null ? null : json["reviews_allowed"],
        averageRating:
            json["average_rating"] == null ? null : json["average_rating"],
        ratingCount: json["rating_count"] == null ? null : json["rating_count"],
        relatedIds: json["related_ids"] == null
            ? null
            : List<int>.from(json["related_ids"].map((x) => x)),
        upsellIds: json["upsell_ids"] == null
            ? null
            : List<dynamic>.from(json["upsell_ids"].map((x) => x)),
        crossSellIds: json["cross_sell_ids"] == null
            ? null
            : List<dynamic>.from(json["cross_sell_ids"].map((x) => x)),
        parentId: json["parent_id"] == null ? null : json["parent_id"],
        purchaseNote:
            json["purchase_note"] == null ? null : json["purchase_note"],
        categories: json["categories"] == null
            ? null
            : List<Category>.from(
                json["categories"].map((x) => Category.fromJson(x))),
        tags: json["tags"] == null
            ? null
            : List<dynamic>.from(json["tags"].map((x) => x)),
        images: json["images"] == null
            ? null
            : List<Image>.from(json["images"].map((x) => Image.fromJson(x))),
        attributes: json["attributes"] == null
            ? null
            : List<Attribute>.from(
                json["attributes"].map((x) => Attribute.fromJson(x))),
        defaultAttributes: json["default_attributes"] == null
            ? null
            : List<dynamic>.from(json["default_attributes"].map((x) => x)),
        variations: json["variations"] == null
            ? null
            : List<dynamic>.from(json["variations"].map((x) => x)),
        groupedProducts: json["grouped_products"] == null
            ? null
            : List<dynamic>.from(json["grouped_products"].map((x) => x)),
        menuOrder: json["menu_order"] == null ? null : json["menu_order"],
        metaData: json["meta_data"] == null
            ? null
            : List<MetaDatum>.from(
                json["meta_data"].map((x) => MetaDatum.fromJson(x))),
        jetpackLikesEnabled: json["jetpack_likes_enabled"] == null
            ? null
            : json["jetpack_likes_enabled"],
        links: json["_links"] == null ? null : Links.fromJson(json["_links"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "slug": slug == null ? null : slug,
        "permalink": permalink == null ? null : permalink,
        "date_created":
            dateCreated == null ? null : dateCreated.toIso8601String(),
        "date_created_gmt":
            dateCreatedGmt == null ? null : dateCreatedGmt.toIso8601String(),
        "date_modified":
            dateModified == null ? null : dateModified.toIso8601String(),
        "date_modified_gmt":
            dateModifiedGmt == null ? null : dateModifiedGmt.toIso8601String(),
        "type": type == null ? null : type,
        "status": status == null ? null : status,
        "featured": featured == null ? null : featured,
        "catalog_visibility":
            catalogVisibility == null ? null : catalogVisibility,
        "description": description == null ? null : description,
        "short_description": shortDescription == null ? null : shortDescription,
        "sku": sku == null ? null : sku,
        "price": price == null ? null : price,
        "regular_price": regularPrice == null ? null : regularPrice,
        "sale_price": salePrice == null ? null : salePrice,
        "date_on_sale_from":
            dateOnSaleFrom == null ? null : dateOnSaleFrom.toIso8601String(),
        "date_on_sale_from_gmt": dateOnSaleFromGmt == null
            ? null
            : dateOnSaleFromGmt.toIso8601String(),
        "date_on_sale_to":
            dateOnSaleTo == null ? null : dateOnSaleTo.toIso8601String(),
        "date_on_sale_to_gmt":
            dateOnSaleToGmt == null ? null : dateOnSaleToGmt.toIso8601String(),
        "price_html": priceHtml == null ? null : priceHtml,
        "on_sale": onSale == null ? null : onSale,
        "purchasable": purchasable == null ? null : purchasable,
        "total_sales": totalSales == null ? null : totalSales,
        "virtual": virtual == null ? null : virtual,
        "downloadable": downloadable == null ? null : downloadable,
        "downloads": downloads == null
            ? null
            : List<dynamic>.from(downloads.map((x) => x)),
        "download_limit": downloadLimit == null ? null : downloadLimit,
        "download_expiry": downloadExpiry == null ? null : downloadExpiry,
        "external_url": externalUrl == null ? null : externalUrl,
        "button_text": buttonText == null ? null : buttonText,
        "tax_status": taxStatus == null ? null : taxStatus,
        "tax_class": taxClass == null ? null : taxClass,
        "manage_stock": manageStock == null ? null : manageStock,
        "stock_quantity": stockQuantity == null ? null : stockQuantity,
        "stock_status": stockStatus == null ? null : stockStatus,
        "backorders": backorders == null ? null : backorders,
        "backorders_allowed":
            backordersAllowed == null ? null : backordersAllowed,
        "backordered": backordered == null ? null : backordered,
        "sold_individually": soldIndividually,
        "weight": weight == null ? null : weight,
        "dimensions": dimensions == null ? null : dimensions.toJson(),
        "shipping_required": shippingRequired == null ? null : shippingRequired,
        "shipping_taxable": shippingTaxable == null ? null : shippingTaxable,
        "shipping_class": shippingClass == null ? null : shippingClass,
        "shipping_class_id": shippingClassId == null ? null : shippingClassId,
        "reviews_allowed": reviewsAllowed == null ? null : reviewsAllowed,
        "average_rating": averageRating == null ? null : averageRating,
        "rating_count": ratingCount == null ? null : ratingCount,
        "related_ids": relatedIds == null
            ? null
            : List<dynamic>.from(relatedIds.map((x) => x)),
        "upsell_ids": upsellIds == null
            ? null
            : List<dynamic>.from(upsellIds.map((x) => x)),
        "cross_sell_ids": crossSellIds == null
            ? null
            : List<dynamic>.from(crossSellIds.map((x) => x)),
        "parent_id": parentId == null ? null : parentId,
        "purchase_note": purchaseNote == null ? null : purchaseNote,
        "categories": categories == null
            ? null
            : List<dynamic>.from(categories.map((x) => x.toJson())),
        "tags": tags == null ? null : List<dynamic>.from(tags.map((x) => x)),
        "images": images == null
            ? null
            : List<dynamic>.from(images.map((x) => x.toJson())),
        "attributes": attributes == null
            ? null
            : List<dynamic>.from(attributes.map((x) => x.toJson())),
        "default_attributes": defaultAttributes == null
            ? null
            : List<dynamic>.from(defaultAttributes.map((x) => x)),
        "variations": variations == null
            ? null
            : List<dynamic>.from(variations.map((x) => x)),
        "grouped_products": groupedProducts == null
            ? null
            : List<dynamic>.from(groupedProducts.map((x) => x)),
        "menu_order": menuOrder == null ? null : menuOrder,
        "meta_data": metaData == null
            ? null
            : List<dynamic>.from(metaData.map((x) => x.toJson())),
        "jetpack_likes_enabled":
            jetpackLikesEnabled == null ? null : jetpackLikesEnabled,
        "_links": links == null ? null : links.toJson(),
      };

  Product copyWith({
    int id,
    String name,
    String slug,
    String permalink,
    DateTime dateCreated,
    DateTime dateCreatedGmt,
    DateTime dateModified,
    DateTime dateModifiedGmt,
    String type,
    String status,
    bool featured,
    String catalogVisibility,
    String description,
    String shortDescription,
    String sku,
    String price,
    String regularPrice,
    String salePrice,
    DateTime dateOnSaleFrom,
    DateTime dateOnSaleFromGmt,
    dynamic dateOnSaleTo,
    dynamic dateOnSaleToGmt,
    String priceHtml,
    bool onSale,
    bool purchasable,
    int totalSales,
    bool virtual,
    bool downloadable,
    List<dynamic> downloads,
    int downloadLimit,
    int downloadExpiry,
    String externalUrl,
    String buttonText,
    String taxStatus,
    String taxClass,
    bool manageStock,
    int stockQuantity,
    String stockStatus,
    String backorders,
    bool backordersAllowed,
    bool backordered,
    dynamic soldIndividually,
    String weight,
    Dimensions dimensions,
    bool shippingRequired,
    bool shippingTaxable,
    String shippingClass,
    int shippingClassId,
    bool reviewsAllowed,
    String averageRating,
    int ratingCount,
    List<int> relatedIds,
    List<dynamic> upsellIds,
    List<dynamic> crossSellIds,
    int parentId,
    String purchaseNote,
    List<Category> categories,
    List<dynamic> tags,
    List<Image> images,
    List<Attribute> attributes,
    List<dynamic> defaultAttributes,
    List<dynamic> variations,
    List<dynamic> groupedProducts,
    int menuOrder,
    List<MetaDatum> metaData,
    bool jetpackLikesEnabled,
    Links links,
  }) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        permalink: permalink ?? this.permalink,
        dateCreated: dateCreated ?? this.dateCreated,
        dateCreatedGmt: dateCreatedGmt ?? this.dateCreatedGmt,
        dateModified: dateModified ?? this.dateModified,
        dateModifiedGmt: dateModifiedGmt ?? this.dateModifiedGmt,
        type: type ?? this.type,
        status: status ?? this.status,
        featured: featured ?? this.featured,
        catalogVisibility: catalogVisibility ?? this.catalogVisibility,
        description: description ?? this.description,
        shortDescription: shortDescription ?? this.shortDescription,
        sku: sku ?? this.sku,
        price: price ?? this.price,
        regularPrice: regularPrice ?? this.regularPrice,
        salePrice: salePrice ?? this.salePrice,
        dateOnSaleFrom: dateOnSaleFrom ?? this.dateOnSaleFrom,
        dateOnSaleFromGmt: dateOnSaleFromGmt ?? this.dateOnSaleFromGmt,
        dateOnSaleTo: dateOnSaleTo ?? this.dateOnSaleTo,
        dateOnSaleToGmt: dateOnSaleToGmt ?? this.dateOnSaleToGmt,
        priceHtml: priceHtml ?? this.priceHtml,
        onSale: onSale ?? this.onSale,
        purchasable: purchasable ?? this.purchasable,
        totalSales: totalSales ?? this.totalSales,
        virtual: virtual ?? this.virtual,
        downloadable: downloadable ?? this.downloadable,
        downloads: downloads ?? this.downloads,
        downloadLimit: downloadLimit ?? this.downloadLimit,
        downloadExpiry: downloadExpiry ?? this.downloadExpiry,
        externalUrl: externalUrl ?? this.externalUrl,
        buttonText: buttonText ?? this.buttonText,
        taxStatus: taxStatus ?? this.taxStatus,
        taxClass: taxClass ?? this.taxClass,
        manageStock: manageStock ?? this.manageStock,
        stockQuantity: stockQuantity ?? this.stockQuantity,
        stockStatus: stockStatus ?? this.stockStatus,
        backorders: backorders ?? this.backorders,
        backordersAllowed: backordersAllowed ?? this.backordersAllowed,
        backordered: backordered ?? this.backordered,
        soldIndividually: soldIndividually ?? this.soldIndividually,
        weight: weight ?? this.weight,
        dimensions: dimensions ?? this.dimensions,
        shippingRequired: shippingRequired ?? this.shippingRequired,
        shippingTaxable: shippingTaxable ?? this.shippingTaxable,
        shippingClass: shippingClass ?? this.shippingClass,
        shippingClassId: shippingClassId ?? this.shippingClassId,
        reviewsAllowed: reviewsAllowed ?? this.reviewsAllowed,
        averageRating: averageRating ?? this.averageRating,
        ratingCount: ratingCount ?? this.ratingCount,
        relatedIds: relatedIds ?? this.relatedIds,
        upsellIds: upsellIds ?? this.upsellIds,
        crossSellIds: crossSellIds ?? this.crossSellIds,
        parentId: parentId ?? this.parentId,
        purchaseNote: purchaseNote ?? this.purchaseNote,
        categories: categories ?? this.categories,
        tags: tags ?? this.tags,
        images: images ?? this.images,
        attributes: attributes ?? this.attributes,
        defaultAttributes: defaultAttributes ?? this.defaultAttributes,
        variations: variations ?? this.variations,
        groupedProducts: groupedProducts ?? this.groupedProducts,
        menuOrder: menuOrder ?? this.menuOrder,
        metaData: metaData ?? this.metaData,
        jetpackLikesEnabled: jetpackLikesEnabled ?? this.jetpackLikesEnabled,
        links: links ?? this.links,
      );
}

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

  factory Attribute.fromJson(Map<String, dynamic> json) => Attribute(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        position: json["position"] == null ? null : json["position"],
        visible: json["visible"] == null ? null : json["visible"],
        variation: json["variation"] == null ? null : json["variation"],
        options: json["options"] == null
            ? null
            : List<String>.from(json["options"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "position": position == null ? null : position,
        "visible": visible == null ? null : visible,
        "variation": variation == null ? null : variation,
        "options":
            options == null ? null : List<dynamic>.from(options.map((x) => x)),
      };

  Attribute copyWith({
    int id,
    String name,
    int position,
    bool visible,
    bool variation,
    List<String> options,
  }) =>
      Attribute(
        id: id ?? this.id,
        name: name ?? this.name,
        position: position ?? this.position,
        visible: visible ?? this.visible,
        variation: variation ?? this.variation,
        options: options ?? this.options,
      );
}

class Category {
  final int id;
  final String name;
  final String slug;

  Category({
    this.id,
    this.name,
    this.slug,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        slug: json["slug"] == null ? null : json["slug"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "slug": slug == null ? null : slug,
      };

  Category copyWith({
    int id,
    String name,
    String slug,
  }) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
      );
}

class Dimensions {
  final String length;
  final String width;
  final String height;

  Dimensions({
    this.length,
    this.width,
    this.height,
  });

  factory Dimensions.fromJson(Map<String, dynamic> json) => Dimensions(
        length: json["length"] == null ? null : json["length"],
        width: json["width"] == null ? null : json["width"],
        height: json["height"] == null ? null : json["height"],
      );

  Map<String, dynamic> toJson() => {
        "length": length == null ? null : length,
        "width": width == null ? null : width,
        "height": height == null ? null : height,
      };

  Dimensions copyWith({
    String length,
    String width,
    String height,
  }) =>
      Dimensions(
        length: length ?? this.length,
        width: width ?? this.width,
        height: height ?? this.height,
      );
}

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

  factory Image.fromJson(Map<String, dynamic> json) => Image(
        id: json["id"] == null ? null : json["id"],
        dateCreated: json["date_created"] == null
            ? null
            : DateTime.parse(json["date_created"]),
        dateCreatedGmt: json["date_created_gmt"] == null
            ? null
            : DateTime.parse(json["date_created_gmt"]),
        dateModified: json["date_modified"] == null
            ? null
            : DateTime.parse(json["date_modified"]),
        dateModifiedGmt: json["date_modified_gmt"] == null
            ? null
            : DateTime.parse(json["date_modified_gmt"]),
        src: json["src"] == null ? null : json["src"],
        name: json["name"] == null ? null : json["name"],
        alt: json["alt"] == null ? null : json["alt"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "date_created":
            dateCreated == null ? null : dateCreated.toIso8601String(),
        "date_created_gmt":
            dateCreatedGmt == null ? null : dateCreatedGmt.toIso8601String(),
        "date_modified":
            dateModified == null ? null : dateModified.toIso8601String(),
        "date_modified_gmt":
            dateModifiedGmt == null ? null : dateModifiedGmt.toIso8601String(),
        "src": src == null ? null : src,
        "name": name == null ? null : name,
        "alt": alt == null ? null : alt,
      };

  Image copyWith({
    int id,
    DateTime dateCreated,
    DateTime dateCreatedGmt,
    DateTime dateModified,
    DateTime dateModifiedGmt,
    String src,
    String name,
    String alt,
  }) =>
      Image(
        id: id ?? this.id,
        dateCreated: dateCreated ?? this.dateCreated,
        dateCreatedGmt: dateCreatedGmt ?? this.dateCreatedGmt,
        dateModified: dateModified ?? this.dateModified,
        dateModifiedGmt: dateModifiedGmt ?? this.dateModifiedGmt,
        src: src ?? this.src,
        name: name ?? this.name,
        alt: alt ?? this.alt,
      );
}

class Links {
  final List<Collection> self;
  final List<Collection> collection;

  Links({
    this.self,
    this.collection,
  });

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        self: json["self"] == null
            ? null
            : List<Collection>.from(
                json["self"].map((x) => Collection.fromJson(x))),
        collection: json["collection"] == null
            ? null
            : List<Collection>.from(
                json["collection"].map((x) => Collection.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "self": self == null
            ? null
            : List<dynamic>.from(self.map((x) => x.toJson())),
        "collection": collection == null
            ? null
            : List<dynamic>.from(collection.map((x) => x.toJson())),
      };

  Links copyWith({
    List<Collection> self,
    List<Collection> collection,
  }) =>
      Links(
        self: self ?? this.self,
        collection: collection ?? this.collection,
      );
}

class Collection {
  final String href;

  Collection({
    this.href,
  });

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
        href: json["href"] == null ? null : json["href"],
      );

  Map<String, dynamic> toJson() => {
        "href": href == null ? null : href,
      };

  Collection copyWith({
    String href,
  }) =>
      Collection(
        href: href ?? this.href,
      );
}

class MetaDatum {
  final int id;
  final String key;
  final dynamic value;

  MetaDatum({
    this.id,
    this.key,
    this.value,
  });

  factory MetaDatum.fromJson(Map<String, dynamic> json) => MetaDatum(
        id: json["id"] == null ? null : json["id"],
        key: json["key"] == null ? null : json["key"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "key": key == null ? null : key,
        "value": value,
      };

  MetaDatum copyWith({
    int id,
    String key,
    dynamic value,
  }) =>
      MetaDatum(
        id: id ?? this.id,
        key: key ?? this.key,
        value: value ?? this.value,
      );
}
