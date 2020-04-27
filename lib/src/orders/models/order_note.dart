import 'package:json_annotation/json_annotation.dart';
part 'order_note.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class OrderNote {
  final int id;
  final String author;
  final DateTime dateCreated;
  final DateTime dateCreatedGmt;
  final String note;
  final bool customerNote;

  OrderNote({
    this.id,
    this.author,
    this.dateCreated,
    this.dateCreatedGmt,
    this.note,
    this.customerNote,
  });

  factory OrderNote.fromJson(Map<String, dynamic> json) => _$OrderNoteFromJson(json);
  Map<String, dynamic> toJson() => _$OrderNoteToJson(this);
}
