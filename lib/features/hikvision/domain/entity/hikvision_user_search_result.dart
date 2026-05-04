import 'package:equatable/equatable.dart';

import 'hikvision_user.dart';

class HikvisionUserSearchResult extends Equatable {
  final int totalMatches;
  final List<HikvisionUser> users;

  const HikvisionUserSearchResult({
    required this.totalMatches,
    required this.users,
  });

  @override
  List<Object?> get props => [totalMatches, users];
}

