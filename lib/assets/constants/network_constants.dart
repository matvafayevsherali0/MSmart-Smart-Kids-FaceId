const noConst = "No";
const baseUrl = "https://msmartkids.uz/";

// vault
const vaultBaseUrl = "http://2.56.241.168";
const vaultConfigsEndpoint = "/v1/clients/configs/by-platform";
const vaultAppId = "smart_boshqaruv_app_bundle_id";
const vaultSecureToken =
    "372978fb146b37fe5e6014bcdbe64fbc3d117b4badfc1539fa6688a771e3aafa";
const vaultUpdateConfigKey = "update_app_version";

// auth
const signInEndpoint = "api/auth/login";
const refreshTokenEndpoint = "api/auth/refresh";
const logoutEndpoint = "api/auth/logout";
const userMeEndpoint = "api/auth/me";

// organization
const organizationsEndpoint = "api/organization";

// users
const usersEndpoint = "api/users";
const staffEndpoint = "api/staff";
const employeeEndpoint = "api/students";
const classGroupsEndpoint = "api/class-groups";
const staffIdsEndpoint = "api/staff/ids";
const employeeIdsEndpoint = "api/students/ids";
const organizationTypePositionsEndpoint = "api/organization-type-positions";

// devices
const devicesEndpoint = "api/devices";

// file
const fileEndpoint = "api/file/upload";

// face enrollment (backend)
const faceEnrollmentFromDeviceEndpoint = "api/face-enrollment/from-device";
const faceEnrollmentEndpoint = "api/face-enrollment";

/// Face enrollment rasmlari CDN (staff/student `faceEnrollment.file.url` bundan yig‘iladi).
const faceEnrollmentImageBaseUrl = 'https://api.msmartkids.uz';

String resolveFaceEnrollmentImageUrl(String relativeOrAbsolute) {
  final t = relativeOrAbsolute.trim();
  if (t.isEmpty) return '';
  if (t.startsWith('http://') || t.startsWith('https://')) return t;
  final base = faceEnrollmentImageBaseUrl.endsWith('/')
      ? faceEnrollmentImageBaseUrl.substring(0, faceEnrollmentImageBaseUrl.length - 1)
      : faceEnrollmentImageBaseUrl;
  return t.startsWith('/') ? '$base$t' : '$base/$t';
}

// hikvision
const hikvisionUserInfoEndpoint = "hikvision/users/";
