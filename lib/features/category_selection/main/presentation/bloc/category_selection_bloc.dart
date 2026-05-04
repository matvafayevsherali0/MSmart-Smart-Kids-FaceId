import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../../core/exceptions/failures.dart';
import '../../../../../core/utils/service_locator.dart';
import '../../data/data/category_class_group.dart';
import '../../data/data/category_position.dart';
import '../../data/data/category_pupil.dart';
import '../../data/data/category_staff.dart';
import '../../domain/repository/category_selection_repository.dart';

part 'category_selection_event.dart';
part 'category_selection_state.dart';

class CategorySelectionBloc
    extends Bloc<CategorySelectionEvent, CategorySelectionState> {
  final _repository = serviceLocator<CategorySelectionRepository>();
  String _organizationId = '';
  String _classGroupId = '';

  CategorySelectionBloc() : super(const CategorySelectionState()) {
    on<CategoryClassGroupsStarted>(_onClassGroupsStarted);
    on<CategoryClassGroupsLoadMore>(_onClassGroupsLoadMore);
    on<CategoryPupilsStarted>(_onPupilsStarted);
    on<CategoryPupilsSearchChanged>(_onPupilsSearchChanged);
    on<CategoryPupilsLoadMore>(_onPupilsLoadMore);
    on<CategoryEmployeesStarted>(_onEmployeesStarted);
    on<CategoryEmployeesSearchChanged>(_onEmployeesSearchChanged);
    on<CategoryEmployeesPositionChanged>(_onEmployeesPositionChanged);
    on<CategoryEmployeesLoadMore>(_onEmployeesLoadMore);
  }

  String _failureMessage(Object failure) {
    if (failure is Failure) {
      return failure.errorMessage ?? failure.toString();
    }
    return failure.toString();
  }

  FutureOr<void> _onClassGroupsStarted(
    CategoryClassGroupsStarted event,
    Emitter<CategorySelectionState> emit,
  ) async {
    _organizationId = event.organizationId.trim();
    emit(state.copyWith(classGroups: const CategoryClassGroupsLoading()));
    await _loadClassGroups(emit);
  }

  Future<void> _loadClassGroups(Emitter<CategorySelectionState> emit) async {
    if (_organizationId.isEmpty) {
      emit(
        state.copyWith(
          classGroups: const CategoryClassGroupsMessage(
            'Tashkilot tanlanmagan.',
          ),
        ),
      );
      return;
    }

    final result = await _repository.getClassGroups(
      organizationId: _organizationId,
      page: 1,
    );

    if (result.isRight) {
      final data = result.right;
      emit(
        state.copyWith(
          classGroups: CategoryClassGroupsContent(
            items: data.items,
            page: data.meta.page,
            hasMore: data.meta.totalPages > data.meta.page,
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        classGroups: CategoryClassGroupsMessage(_failureMessage(result.left)),
      ),
    );
  }

  FutureOr<void> _onClassGroupsLoadMore(
    CategoryClassGroupsLoadMore event,
    Emitter<CategorySelectionState> emit,
  ) async {
    final current = state.classGroups;
    if (current is! CategoryClassGroupsContent) return;
    if (current.isLoadingMore || !current.hasMore) return;
    if (_organizationId.isEmpty) return;

    emit(state.copyWith(classGroups: current.copyWith(isLoadingMore: true)));

    try {
      final result = await _repository.getClassGroups(
        organizationId: _organizationId,
        page: current.page + 1,
      );

      if (result.isRight) {
        final data = result.right;
        emit(
          state.copyWith(
            classGroups: current.copyWith(
              items: [...current.items, ...data.items],
              page: data.meta.page,
              hasMore: data.meta.totalPages > data.meta.page,
              isLoadingMore: false,
            ),
          ),
        );
      } else {
        emit(
          state.copyWith(classGroups: current.copyWith(isLoadingMore: false)),
        );
      }
    } catch (_) {
      emit(state.copyWith(classGroups: current.copyWith(isLoadingMore: false)));
    }
  }

  FutureOr<void> _onPupilsStarted(
    CategoryPupilsStarted event,
    Emitter<CategorySelectionState> emit,
  ) async {
    _organizationId = event.organizationId.trim();
    _classGroupId = event.classGroupId.trim();
    emit(state.copyWith(search: '', pupils: const CategoryPupilsLoading()));
    await _loadPupils(emit);
  }

  FutureOr<void> _onPupilsSearchChanged(
    CategoryPupilsSearchChanged event,
    Emitter<CategorySelectionState> emit,
  ) async {
    emit(
      state.copyWith(
        search: event.search.trim(),
        pupils: const CategoryPupilsLoading(),
      ),
    );
    await _loadPupils(emit);
  }

  Future<void> _loadPupils(Emitter<CategorySelectionState> emit) async {
    if (_organizationId.isEmpty) {
      emit(
        state.copyWith(
          pupils: const CategoryPupilsMessage('Tashkilot tanlanmagan.'),
        ),
      );
      return;
    }

    if (_classGroupId.isEmpty) {
      emit(
        state.copyWith(
          pupils: const CategoryPupilsMessage('Guruh tanlanmagan.'),
        ),
      );
      return;
    }

    final result = await _repository.getPupils(
      organizationId: _organizationId,
      classGroupId: _classGroupId,
      page: 1,
      search: state.search,
    );

    if (result.isRight) {
      final data = result.right;
      emit(
        state.copyWith(
          pupils: CategoryPupilsContent(
            items: data.items,
            page: data.meta.page,
            hasMore: data.meta.totalPages > data.meta.page,
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        pupils: CategoryPupilsMessage(_failureMessage(result.left)),
      ),
    );
  }

  FutureOr<void> _onPupilsLoadMore(
    CategoryPupilsLoadMore event,
    Emitter<CategorySelectionState> emit,
  ) async {
    final current = state.pupils;
    if (current is! CategoryPupilsContent) return;
    if (current.isLoadingMore || !current.hasMore) return;
    if (_organizationId.isEmpty || _classGroupId.isEmpty) return;

    emit(state.copyWith(pupils: current.copyWith(isLoadingMore: true)));

    try {
      final result = await _repository.getPupils(
        organizationId: _organizationId,
        classGroupId: _classGroupId,
        page: current.page + 1,
        search: state.search,
      );

      if (result.isRight) {
        final data = result.right;
        emit(
          state.copyWith(
            pupils: current.copyWith(
              items: [...current.items, ...data.items],
              page: data.meta.page,
              hasMore: data.meta.totalPages > data.meta.page,
              isLoadingMore: false,
            ),
          ),
        );
      } else {
        emit(state.copyWith(pupils: current.copyWith(isLoadingMore: false)));
      }
    } catch (_) {
      emit(state.copyWith(pupils: current.copyWith(isLoadingMore: false)));
    }
  }

  FutureOr<void> _onEmployeesStarted(
    CategoryEmployeesStarted event,
    Emitter<CategorySelectionState> emit,
  ) async {
    _organizationId = event.organizationId.trim();
    emit(
      state.copyWith(
        search: '',
        selectedPosition: null,
        employees: const CategoryEmployeesLoading(),
        positions: const CategoryPositionsLoading(),
      ),
    );

    await _loadPositions(emit);
    await _loadEmployees(emit);
  }

  FutureOr<void> _onEmployeesSearchChanged(
    CategoryEmployeesSearchChanged event,
    Emitter<CategorySelectionState> emit,
  ) async {
    emit(
      state.copyWith(
        search: event.search.trim(),
        employees: const CategoryEmployeesLoading(),
      ),
    );
    await _loadEmployees(emit);
  }

  FutureOr<void> _onEmployeesPositionChanged(
    CategoryEmployeesPositionChanged event,
    Emitter<CategorySelectionState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedPosition: event.position,
        employees: const CategoryEmployeesLoading(),
      ),
    );
    await _loadEmployees(emit);
  }

  Future<void> _loadPositions(Emitter<CategorySelectionState> emit) async {
    final allPositions = <CategoryPositionItem>[];
    var page = 1;
    var totalPages = 1;

    while (page <= totalPages) {
      final result = await _repository.getPositions(page: page);
      if (result.isLeft) {
        emit(
          state.copyWith(
            positions: CategoryPositionsMessage(_failureMessage(result.left)),
          ),
        );
        return;
      }

      final data = result.right;
      allPositions.addAll(data.items);
      totalPages = data.meta.totalPages == 0 ? page : data.meta.totalPages;
      page++;
    }

    emit(
      state.copyWith(positions: CategoryPositionsContent(items: allPositions)),
    );
  }

  Future<void> _loadEmployees(Emitter<CategorySelectionState> emit) async {
    if (_organizationId.isEmpty) {
      emit(
        state.copyWith(
          employees: const CategoryEmployeesMessage('Tashkilot tanlanmagan.'),
        ),
      );
      return;
    }

    final result = await _repository.getStaff(
      organizationId: _organizationId,
      page: 1,
      search: state.search,
      positionId: state.selectedPosition?.id ?? '',
    );

    if (result.isRight) {
      final data = result.right;
      emit(
        state.copyWith(
          employees: CategoryEmployeesContent(
            items: data.items,
            page: data.meta.page,
            hasMore: data.meta.totalPages > data.meta.page,
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        employees: CategoryEmployeesMessage(_failureMessage(result.left)),
      ),
    );
  }

  FutureOr<void> _onEmployeesLoadMore(
    CategoryEmployeesLoadMore event,
    Emitter<CategorySelectionState> emit,
  ) async {
    final current = state.employees;
    if (current is! CategoryEmployeesContent) return;
    if (current.isLoadingMore || !current.hasMore) return;
    if (_organizationId.isEmpty) return;

    emit(state.copyWith(employees: current.copyWith(isLoadingMore: true)));

    try {
      final result = await _repository.getStaff(
        organizationId: _organizationId,
        page: current.page + 1,
        search: state.search,
        positionId: state.selectedPosition?.id ?? '',
      );

      if (result.isRight) {
        final data = result.right;
        emit(
          state.copyWith(
            employees: current.copyWith(
              items: [...current.items, ...data.items],
              page: data.meta.page,
              hasMore: data.meta.totalPages > data.meta.page,
              isLoadingMore: false,
            ),
          ),
        );
      } else {
        emit(state.copyWith(employees: current.copyWith(isLoadingMore: false)));
      }
    } catch (_) {
      emit(state.copyWith(employees: current.copyWith(isLoadingMore: false)));
    }
  }
}
