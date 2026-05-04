import 'package:equatable/equatable.dart';

import '../../../common/data/data/meta_info.dart';
import '../../../common/data/data/user_info.dart';

class Users extends Equatable {
  final List<UserInfo> users;
  final MetaInfo meta;

  const Users({this.users = const [], this.meta = const MetaInfo()});

  @override
  List<Object?> get props => [users, meta];
}