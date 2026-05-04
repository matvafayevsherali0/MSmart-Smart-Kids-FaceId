part of 'users_bloc.dart';

@immutable
class UsersState extends Equatable {
  final StaffListState staffList;
  final EmployeeListState employeeList;

  const UsersState({this.staffList = const StaffListLoading(), this.employeeList = const EmployeeListLoading()});

  UsersState copyWith({StaffListState? staffList, EmployeeListState? employeeList}) {
    return UsersState(staffList: staffList ?? this.staffList, employeeList: employeeList ?? this.employeeList);
  }

  @override
  List<Object?> get props => [staffList, employeeList];
}

sealed class StaffListState extends Equatable {
  const StaffListState();

  @override
  List<Object?> get props => [];
}

class StaffListLoading extends StaffListState {
  const StaffListLoading();
}

class StaffListContent extends StaffListState {
  final List<StaffItem> items;
  final bool isLoadingMore;
  final int page;
  final bool hasMore;

  const StaffListContent({this.items = const [], this.isLoadingMore = false, this.page = 1, this.hasMore = false});

  StaffListContent copyWith({List<StaffItem>? items, bool? isLoadingMore, int? page, bool? hasMore}) {
    return StaffListContent(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [items, isLoadingMore, page, hasMore];
}

class StaffListMessage extends StaffListState {
  final String content;

  const StaffListMessage(this.content);

  @override
  List<Object?> get props => [content];
}

sealed class EmployeeListState extends Equatable {
  const EmployeeListState();

  @override
  List<Object?> get props => [];
}

class EmployeeListLoading extends EmployeeListState {
  const EmployeeListLoading();
}

class EmployeeListContent extends EmployeeListState {
  final List<EmployeeItem> items;
  final bool isLoadingMore;
  final int page;
  final bool hasMore;

  const EmployeeListContent({this.items = const [], this.isLoadingMore = false, this.page = 1, this.hasMore = false});

  EmployeeListContent copyWith({List<EmployeeItem>? items, bool? isLoadingMore, int? page, bool? hasMore}) {
    return EmployeeListContent(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [items, isLoadingMore, page, hasMore];
}

class EmployeeListMessage extends EmployeeListState {
  final String content;

  const EmployeeListMessage(this.content);

  @override
  List<Object?> get props => [content];
}
