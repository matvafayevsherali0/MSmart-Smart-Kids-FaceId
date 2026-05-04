import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasource/auth_data_source.dart';
import '../../features/auth/data/locale_data_source/auth_local_data_source.dart';
import '../../features/auth/data/repository/auth_repository.dart';
import '../../features/auth/domain/mapper/auth_mapper.dart';
import '../../features/auth/domain/repository/auth_repository.dart';
import '../../features/category_selection/main/data/data_source/category_selection_data_source.dart';
import '../../features/category_selection/main/data/repository/category_selection_repository.dart';
import '../../features/category_selection/main/domain/mapper/category_selection_mapper.dart';
import '../../features/category_selection/main/domain/repository/category_selection_repository.dart';
import '../../features/devices/data/data_source/devices_data_source.dart';
import '../../features/devices/data/repository/devices_repository.dart';
import '../../features/devices/domain/mapper/devices_mapper.dart';
import '../../features/devices/domain/repository/devices_repository.dart';
import '../../features/face_enrollment/data/data_source/face_enrollment_data_source.dart';
import '../../features/face_enrollment/data/repository/face_enrollment_repository_impl.dart';
import '../../features/face_enrollment/domain/repository/face_enrollment_repository.dart';
import '../../features/hikvision/data/data_source/hikvision_data_source.dart';
import '../../features/hikvision/data/repository/hikvision_repository_impl.dart';
import '../../features/hikvision/data/service/hikvision_service.dart';
import '../../features/hikvision/domain/repository/hikvision_repository.dart';
import '../../features/organization/data/data_source/organization_data_source.dart';
import '../../features/organization/data/repository/organization_repository.dart';
import '../../features/organization/domain/mapper/organization_mapper.dart';
import '../../features/organization/domain/repository/organization_repository.dart';
import '../../features/users/data/data_source/users_data_source.dart';
import '../../features/users/data/repository/users_repository.dart';
import '../../features/users/domain/mapper/users_mapper.dart';
import '../../features/users/domain/repository/users_repository.dart';
import '../network/dio_setting.dart';
import '../storage/storage.dart';
import '../vault/vault_update_service.dart';

final serviceLocator = GetIt.instance;

Future<void> setUpLocator() async {
  /// storage
  final storage = await StorageRepository.getInstance();
  serviceLocator.registerLazySingleton<StorageRepository>(() => storage);

  /// Network
  serviceLocator.registerLazySingleton<DioSettings>(() => DioSettings(serviceLocator<StorageRepository>()));
  serviceLocator.registerLazySingleton<VaultUpdateService>(() => VaultUpdateService());

  /// auth
  serviceLocator.registerLazySingleton<AuthRemoteDataSource>(() => AuthDataSourceImpl());
  serviceLocator.registerLazySingleton<AuthMapper>(() => AuthMapper());
  serviceLocator.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(serviceLocator<StorageRepository>()));
  serviceLocator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      serviceLocator<AuthRemoteDataSource>(),
      serviceLocator<AuthLocalDataSource>(),
      serviceLocator<AuthMapper>(),
    ),
  );

  /// organization
  serviceLocator.registerLazySingleton<OrganizationRemoteDataSource>(() => OrganizationDataSourceImpl());
  serviceLocator.registerLazySingleton<OrganizationMapper>(() => OrganizationMapper());
  serviceLocator.registerLazySingleton<OrganizationRepository>(
    () => OrganizationRepositoryImpl(serviceLocator<OrganizationRemoteDataSource>(), serviceLocator<OrganizationMapper>()),
  );

  /// users
  serviceLocator.registerLazySingleton<UsersRemoteDataSource>(() => UsersDataSourceImpl());
  serviceLocator.registerLazySingleton<UsersMapper>(() => UsersMapper());
  serviceLocator.registerLazySingleton<UsersRepository>(
    () => UsersRepositoryImpl(serviceLocator<UsersRemoteDataSource>(), serviceLocator<UsersMapper>()),
  );

  /// devices
  serviceLocator.registerLazySingleton<DevicesRemoteDataSource>(() => DevicesDataSourceImpl());
  serviceLocator.registerLazySingleton<DevicesMapper>(() => DevicesMapper());
  serviceLocator.registerLazySingleton<DevicesRepository>(
    () => DevicesRepositoryImpl(serviceLocator<DevicesRemoteDataSource>(), serviceLocator<DevicesMapper>()),
  );

  /// category selection
  serviceLocator.registerLazySingleton<CategorySelectionRemoteDataSource>(() => CategorySelectionDataSourceImpl());
  serviceLocator.registerLazySingleton<CategorySelectionMapper>(() => CategorySelectionMapper());
  serviceLocator.registerLazySingleton<CategorySelectionRepository>(
    () => CategorySelectionRepositoryImpl(
      serviceLocator<CategorySelectionRemoteDataSource>(),
      serviceLocator<CategorySelectionMapper>(),
    ),
  );

  /// face enrollment
  serviceLocator.registerLazySingleton<FaceEnrollmentRemoteDataSource>(() => FaceEnrollmentDataSourceImpl());
  serviceLocator.registerLazySingleton<FaceEnrollmentRepository>(
    () => FaceEnrollmentRepositoryImpl(serviceLocator<FaceEnrollmentRemoteDataSource>()),
  );

  /// hikvision
  serviceLocator.registerLazySingleton<HikvisionService>(() => HikvisionService(baseUrl: '', username: '', password: ''));
  serviceLocator.registerLazySingleton<HikvisionRemoteDataSource>(
    () => HikvisionRemoteDataSourceImpl(serviceLocator<HikvisionService>()),
  );
  serviceLocator.registerLazySingleton<HikvisionRepository>(
    () => HikvisionRepositoryImpl(serviceLocator<HikvisionRemoteDataSource>()),
  );
}
