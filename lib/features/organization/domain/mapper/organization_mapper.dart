import '../../../common/data/data/meta_info.dart';
import '../../../common/data/data/user_me.dart';
import '../../../common/domain/entities/user_me_response.dart';
import '../../data/data/organization.dart';
import '../entity/organization_response.dart';

class OrganizationMapper {
  Organization mapOrganizationResponseToOrganization(OrganizationResponse response) {
    final metaDto = response.data?.meta;
    final meta = metaDto != null
        ? MetaInfo(
            total: metaDto.total ?? 0,
            page: metaDto.page ?? 0,
            limit: metaDto.limit ?? 0,
            totalPages: metaDto.totalPages ?? 0,
          )
        : const MetaInfo();
    final itemsDto = response.data?.items ?? const <OrganizationDataItem>[];
    if (itemsDto.isEmpty) {
      return Organization(meta: meta, items: const []);
    }
    final items = itemsDto
        .map((org) => OrganizationItems(id: org.id ?? "", name: org.name ?? "", address: org.address ?? ""))
        .toList();
    return Organization(meta: meta, items: items);
  }

  UserMe mapUserMeResponseToUserMe(UserMeResponse res) {
    final data = res.data ?? const UserMeDataDto();

    return UserMe(
      id: data.id ?? "",
      phone: data.phone ?? "",
      isActive: data.isActive ?? false,
      organizations:
          data.organizations
              ?.map(
                (e) => UserMeOrganizationItem(
                  id: e.id ?? "",
                  name: e.name ?? "",
                  positionId: e.positionId ?? "",
                  positionName: e.positionName ?? "",
                  isPrimary: e.isPrimary ?? false,
                ),
              )
              .toList() ??
          const [],
    );
  }
}
