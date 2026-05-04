part of 'category_selection_bloc.dart';

@immutable
sealed class CategorySelectionEvent extends Equatable {
  const CategorySelectionEvent();

  @override
  List<Object?> get props => [];
}

class CategoryClassGroupsStarted extends CategorySelectionEvent {
  final String organizationId;

  const CategoryClassGroupsStarted(this.organizationId);

  @override
  List<Object?> get props => [organizationId];
}

class CategoryClassGroupsLoadMore extends CategorySelectionEvent {
  const CategoryClassGroupsLoadMore();
}

class CategoryPupilsStarted extends CategorySelectionEvent {
  final String organizationId;
  final String classGroupId;

  const CategoryPupilsStarted({
    required this.organizationId,
    required this.classGroupId,
  });

  @override
  List<Object?> get props => [organizationId, classGroupId];
}

class CategoryPupilsSearchChanged extends CategorySelectionEvent {
  final String search;

  const CategoryPupilsSearchChanged(this.search);

  @override
  List<Object?> get props => [search];
}

class CategoryPupilsLoadMore extends CategorySelectionEvent {
  const CategoryPupilsLoadMore();
}

class CategoryEmployeesStarted extends CategorySelectionEvent {
  final String organizationId;

  const CategoryEmployeesStarted(this.organizationId);

  @override
  List<Object?> get props => [organizationId];
}

class CategoryEmployeesSearchChanged extends CategorySelectionEvent {
  final String search;

  const CategoryEmployeesSearchChanged(this.search);

  @override
  List<Object?> get props => [search];
}

class CategoryEmployeesPositionChanged extends CategorySelectionEvent {
  final CategoryPositionItem? position;

  const CategoryEmployeesPositionChanged(this.position);

  @override
  List<Object?> get props => [position];
}

class CategoryEmployeesLoadMore extends CategorySelectionEvent {
  const CategoryEmployeesLoadMore();
}
