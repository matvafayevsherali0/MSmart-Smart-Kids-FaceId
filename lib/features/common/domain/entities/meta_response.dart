import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meta_response.g.dart';

@JsonSerializable(createToJson: false)
class MetaResponse extends Equatable {
  final int? total;
  final int? page;
  final int? limit;
  final int? totalPages;

  const MetaResponse({this.total = 0, this.page = 0, this.limit = 0, this.totalPages = 0});

  factory MetaResponse.fromJson(Map<String, dynamic> json) => _$MetaResponseFromJson(json);

  @override
  List<Object?> get props => [total, page, limit, totalPages];
}
