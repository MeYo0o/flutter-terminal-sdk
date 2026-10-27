import 'package:flutter_terminal_sdk/domain/models/util/json_pick.dart';
import 'package:flutter_terminal_sdk/domain/models/intents_list_response.dart'
    show Pagination;

class CashierProductResponse {
  final String id;
  final String productId;
  final String uuid;
  final String name;
  final String description;
  final num price;
  final String? type;
  final String? imageLink;
  final bool isVATExcluded;
  final bool vatExcluded;

  const CashierProductResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.imageLink,
    required this.isVATExcluded,
  })  : productId = id,
        uuid = id,
        vatExcluded = isVATExcluded;

  factory CashierProductResponse.fromJson(Map<String, dynamic> json) {
    final id =
        toStringSafe(pickKey(json, ['id', 'productId', 'product_id', 'uuid']));
    final typeValue = pickKey(json, ['type']);
    final imageLinkValue = pickKey(json, ['imageLink', 'image_link']);
    return CashierProductResponse(
      id: id,
      name: toStringSafe(pickKey(json, ['name'])),
      description: toStringSafe(pickKey(json, ['description'])),
      price: toNumSafe(pickKey(json, ['price'])),
      type: typeValue == null ? null : toStringSafe(typeValue),
      imageLink: imageLinkValue == null ? null : toStringSafe(imageLinkValue),
      isVATExcluded: toBoolSafe(
        pickKey(json, [
          'isVATExcluded',
          'vatExcluded',
          'is_vat_excluded',
          'vat_excluded'
        ]),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'type': type,
        'imageLink': imageLink,
        'isVATExcluded': isVATExcluded,
      };
}

class CashierProductsListResponse {
  final List<CashierProductResponse> data;
  final List<CashierProductResponse> products;
  final Pagination pagination;

  CashierProductsListResponse({
    required this.data,
    required this.pagination,
  }) : products = data;

  factory CashierProductsListResponse.fromJson(Map<String, dynamic> json) {
    final rawList = pickKey(json, ['data', 'products']);
    final rawPagination = pickKey(json, ['pagination']);
    return CashierProductsListResponse(
      data: rawList is List
          ? rawList
              .whereType<Map>()
              .map((e) =>
                  CashierProductResponse.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      pagination: rawPagination is Map
          ? Pagination.fromJson(Map<String, dynamic>.from(rawPagination))
          : Pagination(currentPage: 1, totalPages: 0, totalData: 0),
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.map((e) => e.toJson()).toList(),
        'pagination': pagination.toJson(),
      };
}
