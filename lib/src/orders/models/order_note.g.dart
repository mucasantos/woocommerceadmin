// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderNote _$OrderNoteFromJson(Map<String, dynamic> json) {
  return OrderNote(
    id: json['id'] as int,
    author: json['author'] as String,
    dateCreated: json['date_created'] == null
        ? null
        : DateTime.parse(json['date_created'] as String),
    dateCreatedGmt: json['date_created_gmt'] == null
        ? null
        : DateTime.parse(json['date_created_gmt'] as String),
    note: json['note'] as String,
    customerNote: json['customer_note'] as bool,
  );
}

Map<String, dynamic> _$OrderNoteToJson(OrderNote instance) => <String, dynamic>{
      'id': instance.id,
      'author': instance.author,
      'date_created': instance.dateCreated?.toIso8601String(),
      'date_created_gmt': instance.dateCreatedGmt?.toIso8601String(),
      'note': instance.note,
      'customer_note': instance.customerNote,
    };
