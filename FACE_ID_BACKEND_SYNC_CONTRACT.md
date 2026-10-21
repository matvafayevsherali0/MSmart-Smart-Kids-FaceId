# Face ID va backend sinxronlash kontrakti

Bu hujjat ichki Swagger (`/doc`) dagi mavjud endpointlar va mobil ilovaga kerak bo‘lgan qo‘shimcha lookup endpointini jamlaydi.

## 0. Rasmni backendga yuklash

```http
POST /api/file/upload
Authorization: Bearer <access-token>
Content-Type: multipart/form-data
```

Form field: `file` — JPG/JPEG yuz rasmi.

Muvaffaqiyatli response — `200`:

```json
{
  "success": true,
  "data": {
    "id": "file-uuid",
    "url": "/uploads/face/file-name.jpg"
  }
}
```

Keyingi enrollment requestida `data.id` qiymati `faceImageId` sifatida yuboriladi.

## 1. Yangi rasm qo‘shish

Mobil ilova ketma-ketligi:

1. Face ID qurilmasiga yuz rasmi yoziladi.
2. `POST /api/file/upload` orqali rasm backendga yuklanadi.
3. Enrollment mavjud bo‘lmasa `POST /api/face-enrollment/from-device` chaqiriladi.

### Request

```http
POST /api/face-enrollment/from-device
Authorization: Bearer <access-token>
Content-Type: application/json
```

```json
{
  "ownerType": "student",
  "studentId": "student-uuid",
  "faceImageId": "file-uuid",
  "organizationId": "organization-uuid",
  "deviceSyncs": [
    {
      "deviceId": "device-uuid"
    }
  ]
}
```

Xodim uchun `ownerType: "staff"` va `staffId` yuboriladi. `studentId` va `staffId` bir vaqtda yuborilmasin.

### Muvaffaqiyatli response — `201`

```json
{
  "success": true,
  "data": {
    "id": "face-enrollment-uuid",
    "ownerType": "student",
    "studentId": "student-uuid",
    "staffId": null,
    "faceImageId": "file-uuid",
    "hikvisionFaceId": "employee-no-or-null",
    "organizationId": "organization-uuid",
    "isActive": true,
    "enrolledAt": "2026-10-20T10:00:00.000Z",
    "createdAt": "2026-10-20T10:00:00.000Z",
    "updatedAt": "2026-10-20T10:00:00.000Z",
    "isDeleted": false,
    "deletedAt": null
  }
}
```

`data.id` mobil ilovaga qaytishi shart. Keyingi update va delete shu ID bilan bajariladi.

## 2. Mavjud rasmni almashtirish

Face ID dagi rasm muvaffaqiyatli almashtirilgandan keyin:

```http
PUT /api/face-enrollment/{faceEnrollmentId}
Authorization: Bearer <access-token>
Content-Type: application/json
```

```json
{
  "faceImageId": "new-file-uuid"
}
```

Response `200` yuqoridagi `FaceEnrollmentResponse` formatida bo‘lsin.

Shundan keyin qurilma holati ham tasdiqlanadi:

```http
PUT /api/face-enrollment/{faceEnrollmentId}/device-sync
Authorization: Bearer <access-token>
Content-Type: application/json
```

```json
{
  "deviceId": "device-uuid",
  "isSynced": true
}
```

## 3. Userni o‘chirish

Mobil ilova avval Face ID userini o‘chiradi. Qurilma o‘chirishni tasdiqlagandan keyin backendga yuboradi:

```http
DELETE /api/face-enrollment/{faceEnrollmentId}
Authorization: Bearer <access-token>
```

Response `200`:

```json
{
  "success": true,
  "data": {
    "id": "face-enrollment-uuid",
    "ownerType": "student",
    "studentId": "student-uuid",
    "staffId": null,
    "faceImageId": "file-uuid",
    "hikvisionFaceId": "employee-no-or-null",
    "organizationId": "organization-uuid",
    "isActive": false,
    "enrolledAt": "2026-10-20T10:00:00.000Z",
    "createdAt": "2026-10-20T10:00:00.000Z",
    "updatedAt": "2026-10-20T10:05:00.000Z",
    "isDeleted": true,
    "deletedAt": "2026-10-20T10:05:00.000Z"
  }
}
```

Backend delete xatosida mobil ilova quyidagini yuboradi va amal qayta bajarilishi mumkin bo‘ladi:

```http
PUT /api/face-enrollment/{faceEnrollmentId}/device-sync
Authorization: Bearer <access-token>
Content-Type: application/json
```

```json
{
  "deviceId": "device-uuid",
  "isSynced": false,
  "errorMessage": "Face ID o‘chirildi, lekin backend enrollmenti o‘chirilmadi"
}
```

`errorMessage` max uzunligi backendda masalan 500 belgiga cheklansin.

## 4. Kerak bo‘ladigan lookup endpointi

Swagger’da hozir `GET /api/face-enrollment` bor, lekin unda `studentId` yoki `staffId` bo‘yicha aniq filter yo‘q. Mobil ilova vaqtincha ro‘yxatni sahifalab qidiradi. Dublikat va ortiqcha requestlarning oldini olish uchun quyidagi endpointni qo‘shish tavsiya qilinadi:

Mavjud list endpointida `sortBy` faqat `ownerName`, `enrolledAt` yoki `createdAt` bo‘lishi mumkin. `updatedAt` yuborilsa backend `422 Unprocessable Entity` qaytaradi.

```http
GET /api/face-enrollment/owner/{ownerType}/{ownerId}?organizationId={organizationId}
Authorization: Bearer <access-token>
```

`ownerType` qiymatlari: `student`, `staff` yoki backenddagi amaldagi `teacher` qiymati.

### Topilganda — `200`

```json
{
  "success": true,
  "data": {
    "id": "face-enrollment-uuid",
    "ownerType": "student",
    "studentId": "student-uuid",
    "staffId": null,
    "faceImageId": "file-uuid",
    "hikvisionFaceId": "employee-no",
    "organizationId": "organization-uuid",
    "isActive": true,
    "enrolledAt": "2026-10-20T10:00:00.000Z",
    "createdAt": "2026-10-20T10:00:00.000Z",
    "updatedAt": "2026-10-20T10:00:00.000Z",
    "isDeleted": false,
    "deletedAt": null
  }
}
```

### Enrollment yo‘q bo‘lsa — `404`

```json
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "Face enrollment topilmadi"
  }
}
```

`404` xato emas: mobil ilova bunday holatda yangi enrollment yaratadi. Bir owner uchun faol enrollment bittadan ko‘p bo‘lishiga backend yo‘l qo‘ymasligi kerak.

## 5. Muhim cheklov

Hozirgi Swagger’da Face ID qurilmasiga backendning o‘zi buyruq beradigan transaction endpoint yo‘q. Shu sabab mobil ilova Face ID va backendni ketma-ket chaqiradi; tarmoq uzilib qolsa ikki tizim vaqtincha turlicha holatda qolishi mumkin. `device-sync` shu holatni qayd etadi va keyingi retry uchun ishlatiladi.

Agar backend Face ID qurilmasiga ulana olsa, haqiqiy atomik workflow uchun alohida command endpoint kerak bo‘ladi:

```http
POST /api/face-enrollment/{faceEnrollmentId}/device-delete
Authorization: Bearer <access-token>
Idempotency-Key: <unique-operation-id>
Content-Type: application/json
```

```json
{
  "deviceId": "device-uuid",
  "employeeNo": "face-id-user-id"
}
```

Response:

```json
{
  "success": true,
  "data": {
    "faceEnrollmentId": "face-enrollment-uuid",
    "deviceId": "device-uuid",
    "operation": "delete",
    "status": "synced",
    "isSynced": true,
    "completedAt": "2026-10-20T10:05:00.000Z"
  }
}
```

Bu endpointni backend Face ID bilan o‘zi ishlaydigan bo‘lsa qo‘shish kerak; aks holda mobil ilovaning mavjud `device-sync` retry mexanizmi ishlatiladi.
