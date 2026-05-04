import 'package:equatable/equatable.dart';

import '../../../common/data/data/user_me.dart';

class OrganizationState extends Equatable {
  final OrganizationsDataState organizationData;
  final UserMe userMe;

  const OrganizationState({this.organizationData = const OrganizationsDataLoading(), this.userMe = const UserMe()});

  OrganizationState copyWith({OrganizationsDataState? organizationData, UserMe? userMe}) {
    return OrganizationState(organizationData: organizationData ?? this.organizationData, userMe: userMe ?? this.userMe);
  }

  @override
  List<Object?> get props => [organizationData];
}

sealed class OrganizationsDataState extends Equatable {
  const OrganizationsDataState();

  @override
  List<Object?> get props => [];
}

class OrganizationsDataContent extends OrganizationsDataState {
  final List<UserMeOrganizationItem> organizations;

  const OrganizationsDataContent({this.organizations = const []});

  OrganizationsDataContent copyWith({List<UserMeOrganizationItem>? organizations, bool? isLoadingMore, int? page}) {
    return OrganizationsDataContent(organizations: organizations ?? this.organizations);
  }

  @override
  List<Object?> get props => [organizations];
}

class OrganizationsDataLoading extends OrganizationsDataState {
  const OrganizationsDataLoading();
}

class OrganizationsDataMessageContent extends OrganizationsDataState {
  final String content;

  const OrganizationsDataMessageContent({this.content = ""});

  @override
  List<Object?> get props => [content];
}
