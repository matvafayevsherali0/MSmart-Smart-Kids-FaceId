import 'package:equatable/equatable.dart';

class MetaInfo extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const MetaInfo({this.total = 0, this.page = 0, this.limit = 0, this.totalPages = 0});

  @override
  List<Object?> get props => [total, page, limit, totalPages];
}
