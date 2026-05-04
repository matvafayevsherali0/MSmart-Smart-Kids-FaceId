part of 'organization_bloc.dart';

@immutable
sealed class OrganizationEvent extends Equatable {
  const OrganizationEvent();

  @override
  List<Object?> get props => [];
}

class GetOrganizationsEvent extends OrganizationEvent {
  const GetOrganizationsEvent();
}

/*class LoadMoreOrganizationsEvent extends OrganizationEvent {
  const LoadMoreOrganizationsEvent();
}*/
