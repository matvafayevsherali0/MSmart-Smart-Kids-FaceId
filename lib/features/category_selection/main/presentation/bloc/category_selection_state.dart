part of 'category_selection_bloc.dart';

@immutable
class CategorySelectionState extends Equatable {
  final CategoryClassGroupsState classGroups;
  final CategoryPupilsState pupils;
  final CategoryEmployeesState employees;
  final CategoryPositionsState positions;
  final String search;
  final CategoryPositionItem? selectedPosition;

  const CategorySelectionState({
    this.classGroups = const CategoryClassGroupsLoading(),
    this.pupils = const CategoryPupilsLoading(),
    this.employees = const CategoryEmployeesLoading(),
    this.positions = const CategoryPositionsLoading(),
    this.search = '',
    this.selectedPosition,
  });

  CategorySelectionState copyWith({
    CategoryClassGroupsState? classGroups,
    CategoryPupilsState? pupils,
    CategoryEmployeesState? employees,
    CategoryPositionsState? positions,
    String? search,
    Object? selectedPosition = _selectedPositionSentinel,
  }) {
    return CategorySelectionState(
      classGroups: classGroups ?? this.classGroups,
      pupils: pupils ?? this.pupils,
      employees: employees ?? this.employees,
      positions: positions ?? this.positions,
      search: search ?? this.search,
      selectedPosition: selectedPosition == _selectedPositionSentinel
          ? this.selectedPosition
          : selectedPosition as CategoryPositionItem?,
    );
  }

  @override
  List<Object?> get props => [
    classGroups,
    pupils,
    employees,
    positions,
    search,
    selectedPosition,
  ];
}

const Object _selectedPositionSentinel = Object();

sealed class CategoryClassGroupsState extends Equatable {
  const CategoryClassGroupsState();

  @override
  List<Object?> get props => [];
}

class CategoryClassGroupsLoading extends CategoryClassGroupsState {
  const CategoryClassGroupsLoading();
}

class CategoryClassGroupsContent extends CategoryClassGroupsState {
  final List<CategoryClassGroupItem> items;
  final bool isLoadingMore;
  final int page;
  final bool hasMore;

  const CategoryClassGroupsContent({
    this.items = const [],
    this.isLoadingMore = false,
    this.page = 1,
    this.hasMore = false,
  });

  CategoryClassGroupsContent copyWith({
    List<CategoryClassGroupItem>? items,
    bool? isLoadingMore,
    int? page,
    bool? hasMore,
  }) {
    return CategoryClassGroupsContent(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [items, isLoadingMore, page, hasMore];
}

class CategoryClassGroupsMessage extends CategoryClassGroupsState {
  final String content;

  const CategoryClassGroupsMessage(this.content);

  @override
  List<Object?> get props => [content];
}

sealed class CategoryPupilsState extends Equatable {
  const CategoryPupilsState();

  @override
  List<Object?> get props => [];
}

class CategoryPupilsLoading extends CategoryPupilsState {
  const CategoryPupilsLoading();
}

class CategoryPupilsContent extends CategoryPupilsState {
  final List<CategoryPupilItem> items;
  final bool isLoadingMore;
  final int page;
  final bool hasMore;
  final int refreshSeq;

  const CategoryPupilsContent({
    this.items = const [],
    this.isLoadingMore = false,
    this.page = 1,
    this.hasMore = false,
    this.refreshSeq = 0,
  });

  CategoryPupilsContent copyWith({
    List<CategoryPupilItem>? items,
    bool? isLoadingMore,
    int? page,
    bool? hasMore,
    int? refreshSeq,
  }) {
    return CategoryPupilsContent(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      refreshSeq: refreshSeq ?? this.refreshSeq,
    );
  }

  @override
  List<Object?> get props => [items, isLoadingMore, page, hasMore, refreshSeq];
}

class CategoryPupilsMessage extends CategoryPupilsState {
  final String content;
  final int errorSeq;

  const CategoryPupilsMessage(this.content, {this.errorSeq = 0});

  @override
  List<Object?> get props => [content, errorSeq];
}

sealed class CategoryEmployeesState extends Equatable {
  const CategoryEmployeesState();

  @override
  List<Object?> get props => [];
}

class CategoryEmployeesLoading extends CategoryEmployeesState {
  const CategoryEmployeesLoading();
}

class CategoryEmployeesContent extends CategoryEmployeesState {
  final List<CategoryStaffItem> items;
  final bool isLoadingMore;
  final int page;
  final bool hasMore;
  final int refreshSeq;

  const CategoryEmployeesContent({
    this.items = const [],
    this.isLoadingMore = false,
    this.page = 1,
    this.hasMore = false,
    this.refreshSeq = 0,
  });

  CategoryEmployeesContent copyWith({
    List<CategoryStaffItem>? items,
    bool? isLoadingMore,
    int? page,
    bool? hasMore,
    int? refreshSeq,
  }) {
    return CategoryEmployeesContent(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      refreshSeq: refreshSeq ?? this.refreshSeq,
    );
  }

  @override
  List<Object?> get props => [items, isLoadingMore, page, hasMore, refreshSeq];
}

class CategoryEmployeesMessage extends CategoryEmployeesState {
  final String content;
  final int errorSeq;

  const CategoryEmployeesMessage(this.content, {this.errorSeq = 0});

  @override
  List<Object?> get props => [content, errorSeq];
}

sealed class CategoryPositionsState extends Equatable {
  const CategoryPositionsState();

  @override
  List<Object?> get props => [];
}

class CategoryPositionsLoading extends CategoryPositionsState {
  const CategoryPositionsLoading();
}

class CategoryPositionsContent extends CategoryPositionsState {
  final List<CategoryPositionItem> items;

  const CategoryPositionsContent({this.items = const []});

  @override
  List<Object?> get props => [items];
}

class CategoryPositionsMessage extends CategoryPositionsState {
  final String content;

  const CategoryPositionsMessage(this.content);

  @override
  List<Object?> get props => [content];
}
