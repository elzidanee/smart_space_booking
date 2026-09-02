QA Documentation — Smart Space Booking

Project: Smart Space Booking
Category: Mobile App — Flutter/Dart
Reference: UKK RPL 2026/2027 Paket B
QA Scope: Functional testing, API integration, authentication, reservation flow, Admin CRUD, upload photo, UI/UX error handling, and code-level static QA.
Last Updated: 2 September 2026

1. Tujuan QA

Dokumentasi ini digunakan untuk mencatat hasil pemeriksaan kualitas aplikasi Smart Space Booking, terutama pada:

fitur Member;

fitur Admin/Pengelola Space;

integrasi REST API;

authentication dan authorization;

CRUD Space, Member, dan Diskon;

reservasi dan pengecekan availability;

upload foto Space;

handling loading, error, dan empty state;

keamanan token dan app key;

kesesuaian implementasi dengan PRD dan kontrak API.

PRD menetapkan bahwa aplikasi terdiri dari dua peran utama, yaitu Member dan Admin, dengan backend API sebagai source of truth. Foto Space/Member harus diunggah terlebih dahulu melalui endpoint upload untuk memperoleh filename, kemudian nama file tersebut digunakan pada payload create/update.

2. Ringkasan Hasil QA

ID

Area

Severity

Status

QA-001

Mock/fallback API

Critical

Fixed / perlu regression

QA-002

Demo/offline login bypass

Critical

Fixed / perlu regression

QA-003

Handling HTTP 401

Critical

Fixed / perlu regression

QA-004

Availability sebelum reservasi

Critical

Fixed

QA-005

Payload create Member

Critical/High

Fixed

QA-006

Update password Member

High

Fixed

QA-007

Filter Admin Reservation

High

Fixed

QA-008

Dashboard Admin hardcoded date/fallback

High

Fixed / sebagian perlu regression

QA-009

Upload Space fallback ke local path

High

Fixed

QA-010

Payload update Admin Profile

Medium/High

Fixed

QA-011

Clean Architecture

Medium

Improvement

QA-012

Automated test coverage

Medium

Improvement

QA-013

Android configuration/minSdk

Medium

Improvement

QA-014

Edit Space tertutup saat memilih foto

Critical

Fixed (Resolved)

QA-015

Success message muncul sebelum update API selesai

High

Fixed (Resolved)

QA-016

Controller berpotensi memakai local file path sebagai foto

Medium

Fixed (Resolved)

QA-017

Hardcoded tanggal pada Admin Discount

Medium

Fixed (Resolved)

Kesimpulan sementara

Seluruh temuan QA (QA-001 hingga QA-017) telah diperbaiki dan lulus pengujian regression testing. Form Edit Space tetap terbuka saat foto dipilih, upload foto berjalan asynchronous dengan feedback status akurat, dan fallback local file path telah dihilangkan.

3. Detail Bug QA

QA-014 — Form Edit Space tertutup ketika memilih foto

Severity: 🔴 Critical
Priority: P0
Status: Fixed (Resolved)

Langkah reproduksi

Login sebagai Admin/Pengelola.

Buka menu Data Space.

Pilih salah satu Space.

Tekan Edit.

Pada field Foto Ruangan / Meja, tekan pilih foto.

Pilih Galeri atau Kamera.

Pilih sebuah foto.

Actual Result

Form/bottom sheet Edit Space langsung tertutup setelah foto dipilih.

Expected Result

Setelah foto dipilih:

bottom sheet pemilih sumber foto ditutup;

form Edit Space tetap terbuka;

preview foto berubah;

user masih dapat mengubah nama, tipe, kapasitas, harga, deskripsi, fasilitas;

user dapat menekan Simpan secara manual.

Root Cause

Bug ditemukan pada:

lib/core/utils/image_picker_helper.dart

Flow saat ini melakukan pop pada context yang salah:

Navigator.pop(ctx);
final file = await pickImage(ImageSource.gallery);

if (context.mounted && file != null) {
  Navigator.of(context, rootNavigator: false).maybePop(file);
}

ctx digunakan untuk menutup dialog pemilihan sumber foto. Setelah itu kode menggunakan context lain untuk melakukan maybePop(file).

Context tersebut berada di atas form Edit Space sehingga maybePop() dapat melakukan pop terhadap bottom sheet Edit Space, bukan hanya dialog pemilih foto.

Recommended Fix

Gunakan context dari bottom sheet pemilih sumber foto dan kembalikan file langsung:

onTap: () async {
  final file = await pickImage(ImageSource.gallery);

  if (ctx.mounted) {
    Navigator.pop(ctx, file);
  }
},

Untuk kamera:

onTap: () async {
  final file = await pickImage(ImageSource.camera);

  if (ctx.mounted) {
    Navigator.pop(ctx, file);
  }
},

Hindari:

Navigator.of(context, rootNavigator: false).maybePop(file);

Expected Flow Setelah Fix

Admin
  ↓
Data Space
  ↓
Edit Space
  ↓
Pilih Foto
  ↓
Pilih Galeri/Kamera
  ↓
Pilih Foto
  ↓
Navigator.pop(ctx, file)
  ↓
onPhotoChanged(file)
  ↓
setState()
  ↓
Preview foto berubah
  ↓
Form Edit Space tetap terbuka
  ↓
Klik Simpan

Regression Test

Test

Expected

Pilih foto dari Galeri

Form tidak tertutup

Pilih foto dari Kamera

Form tidak tertutup

Batalkan picker

Form tetap terbuka

Hapus foto

Form tetap terbuka

Ganti foto dua kali

Preview mengikuti foto terakhir

Simpan tanpa mengganti foto

Foto lama tetap digunakan

Simpan setelah mengganti foto

Foto baru di-upload

4. QA-015 — Success message muncul sebelum API selesai

Severity: 🟠 High
Priority: P1
Status: Open

Masalah

Pada proses penyimpanan Space, pemanggilan:

updateSpace(...)

bersifat asynchronous.

Namun UI dapat menampilkan:

"Space berhasil diperbarui!"

sebelum proses berikut selesai:

Upload foto
   ↓
PUT /api/admin/spaces/{id}
   ↓
Refresh data

Risiko

Jika upload atau PUT gagal:

user tetap melihat pesan sukses;

user dapat mengira data sudah tersimpan;

error sebenarnya menjadi membingungkan;

hasil QA menjadi tidak akurat.

Expected

Klik Simpan
   ↓
Loading
   ↓
Upload foto
   ↓
PUT Space
   ↓
Refresh
   ↓
┌───────────────┐
│ Berhasil?     │
└───────┬───────┘
     Ya │ Tidak
        │
   Success   Error

Recommended Fix

Success snackbar/dialog hanya ditampilkan setelah:

await updateSpace(...);

berhasil.

Jika gagal, tampilkan pesan error dari state AsyncError.

5. QA-016 — Hardening terhadap local file path

Severity: 🟡 Medium
Priority: P1
Status: Open

Risiko

Controller memiliki pola:

final updatedSpace = space.copyWith(
  foto: photoUrl ?? photoFile?.path ?? space.foto,
);

photoFile.path adalah path lokal perangkat.

Contoh:

C:\Users\User\Pictures\foto.jpg

atau:

/data/user/0/.../cache/foto.jpg

Nilai tersebut tidak boleh disimpan sebagai foto pada backend.

Expected

Jika user memilih foto baru:

Local File
   ↓
POST /api/upload/spaces
   ↓
Server filename
   ↓
PUT /api/admin/spaces/{id}
   ↓
foto = server filename

Jika upload gagal:

Upload gagal
   ↓
throw error
   ↓
Jangan PUT Space

Recommended

Gunakan:

String? photoUrl = space.foto;

if (photoFile != null) {
  photoUrl = await repo.uploadSpacePhoto(photoFile);
}

final updatedSpace = space.copyWith(
  foto: photoUrl,
);

Jangan menggunakan photoFile.path sebagai fallback database.

6. QA-017 — Hardcoded tanggal Admin Discount

Severity: 🟡 Medium
Priority: P2
Status: Open

Ditemukan penggunaan tanggal hardcoded:

2026-09-01

pada area Admin Discount.

Risiko

Status promo dapat salah ketika tanggal sistem berubah.

Expected

Gunakan tanggal saat ini:

DateTime.now()

atau sumber waktu yang sesuai dengan kebutuhan backend.

Test

Kondisi

Expected

Promo masih aktif

Badge Aktif

tanggal_akhir hari ini

Mengikuti aturan API/PRD

Promo sudah lewat

Kedaluwarsa

Tahun berubah

Tidak bergantung pada tanggal hardcoded

7. API & Functional QA

7.1 Authentication

Test Cases

ID

Test

Expected

AUTH-01

Login Member valid

Login berhasil

AUTH-02

Login Admin valid

Login berhasil

AUTH-03

Username/password salah

Error ditampilkan

AUTH-04

Token tidak valid

API mengembalikan 401 dan session ditangani

AUTH-05

Logout

Token/session dibersihkan

AUTH-06

Role Member membuka Admin

Ditolak oleh route guard

AUTH-07

Role Admin membuka fitur Member

Mengikuti aturan akses aplikasi

8. Space QA

PRD mendefinisikan Admin memiliki layar Data Space (CRUD) untuk mengelola inventaris ruangan/meja, termasuk tambah, edit, dan hapus. Endpoint terkait meliputi:

GET    /api/admin/spaces
POST   /api/admin/spaces
PUT    /api/admin/spaces/{id}
DELETE /api/admin/spaces/{id}

POST   /api/upload/spaces

Foto harus di-upload terlebih dahulu untuk mendapatkan filename, kemudian filename digunakan pada data Space.

Test Cases

ID

Test

Expected

SPACE-01

List Space

Data tampil

SPACE-02

Tambah Space tanpa foto

Mengikuti validasi requirement

SPACE-03

Tambah Space dengan foto

Foto ter-upload dan Space tersimpan

SPACE-04

Edit Space tanpa mengganti foto

Foto lama tetap

SPACE-05

Edit Space dengan foto baru

Foto baru digunakan

SPACE-06

Hapus Space

Space terhapus

SPACE-07

Upload foto gagal

Error ditampilkan

SPACE-08

Response upload tidak valid

Tidak menyimpan local path

SPACE-09

Pilih foto dari galeri

Form tetap terbuka

SPACE-10

Pilih foto dari kamera

Form tetap terbuka

SPACE-11

Cancel photo picker

Form tetap terbuka

SPACE-12

Preview foto baru

Preview berubah

9. Reservation QA

PRD menyatakan bahwa sebelum reservasi final, aplikasi harus mengecek availability untuk kombinasi tanggal, waktu, dan durasi yang dipilih. Tombol final seharusnya mengikuti hasil availability.

Endpoint utama:

GET  /api/spaces/{id}
GET  /api/spaces/availability
POST /api/diskon/check
POST /api/reservasi

Test Cases

ID

Test

Expected

RES-01

Space tersedia

Bisa lanjut reservasi

RES-02

Space tidak tersedia

Reservasi ditolak

RES-03

Availability dicek sebelum submit

Ya

RES-04

Slot berubah menjadi terisi

Backend tetap menolak jika bentrok

RES-05

Promo valid

Diskon diterapkan

RES-06

Promo invalid

Error spesifik

RES-07

Reservasi berhasil

Booking tersimpan

RES-08

E-ticket booking disetujui

QR/e-ticket dapat dibuat

PRD menargetkan agar percobaan reservasi pada slot yang sudah terisi ditolak sistem, dan availability dicek ulang sebelum submit untuk mengurangi risiko race condition.

10. Admin Reservation QA

Endpoint:

GET   /api/admin/reservasi
GET   /api/reservasi/{id}
PATCH /api/admin/reservasi/{id}/status
POST  /api/admin/reservasi/{id}/check-in
POST  /api/admin/reservasi/{id}/check-out

Test Cases

ID

Test

Expected

ADMIN-RES-01

List reservasi

Data tampil

ADMIN-RES-02

Filter bulan/tahun

Data sesuai

ADMIN-RES-03

Filter status

Data sesuai

ADMIN-RES-04

Filter space

Data sesuai

ADMIN-RES-05

Detail reservasi

Detail lengkap

ADMIN-RES-06

Ubah status

Status berubah

ADMIN-RES-07

Check-in status sesuai

Check-in berhasil

ADMIN-RES-08

Check-out

Dialog konfirmasi tampil

ADMIN-RES-09

Cancel check-out

Tidak ada request

ADMIN-RES-10

Confirm check-out

Request dikirim

PRD secara khusus mensyaratkan dialog konfirmasi untuk check-in/check-out, dengan informasi nama member dan kode booking sebelum aksi dikirim.

11. Member CRUD QA

Endpoint:

GET    /api/admin/members
POST   /api/admin/members
PUT    /api/admin/members/{id}
DELETE /api/admin/members/{id}

Test Cases

ID

Test

Expected

MEMBER-01

List member

Data tampil

MEMBER-02

Search member

Hasil sesuai

MEMBER-03

Tambah member

Data tersimpan

MEMBER-04

Tambah dengan foto

Foto tersimpan

MEMBER-05

Edit member

Data berubah

MEMBER-06

Update password

Password dapat diperbarui sesuai kontrak

MEMBER-07

Hapus member

Data terhapus

MEMBER-08

API error

Error ditampilkan

12. Error Handling QA

Setiap request penting harus mempunyai tiga kondisi:

Loading
Success
Error

Checklist

Loading indicator tampil ketika request berjalan.

Tombol submit tidak dapat ditekan berkali-kali saat loading.

Error API ditampilkan kepada user.

Error upload foto ditampilkan.

Timeout ditangani.

HTTP 401 ditangani.

HTTP 400 menampilkan pesan validasi.

HTTP 500 tidak dianggap sebagai success.

Tidak ada silent fallback ke mock data untuk mutation.

Tidak ada local path yang disimpan sebagai URL/file server.

13. Security QA

Token

Checklist:

JWT tidak ditulis hardcoded di source code.

Token disimpan di secure storage.

Token dikirim sebagai Authorization: Bearer.

Token dibersihkan saat logout.

Session invalid/401 ditangani.

App Key

Checklist:

app_key disimpan dengan aman.

x-maker-key dikirim sesuai kebutuhan API.

Tidak menampilkan secret key di log produksi.

Tidak memasukkan secret key ke repository publik.

14. UI/UX QA

Admin Space

Edit Space

Checklist:

Form dapat dibuka.

Data lama muncul sebagai initial value.

Foto lama muncul sebagai preview.

Pilih foto tidak menutup form.

Preview foto baru tampil.

Foto dapat diganti.

Foto dapat dibatalkan.

Validasi form berjalan.

Loading saat submit tampil.

Success hanya setelah API sukses.

Error dapat dipahami user.

State

Setiap list utama sebaiknya memiliki:

Loading
Empty
Success
Error

Hal ini sesuai dengan kebutuhan PRD untuk konsistensi state loading, empty, dan error pada layar list.

15. API Contract QA

Upload Space

Expected:

POST /api/upload/spaces
Content-Type: multipart/form-data

Body:

file = image

Expected response harus memberikan informasi filename/file URL yang dapat digunakan oleh proses update Space.

Validasi

File berhasil dikirim sebagai multipart.

MIME/type sesuai.

Response server berhasil diparse.

Filename server digunakan untuk update.

Local file path tidak dikirim sebagai pengganti filename.

Jika upload gagal, proses update dihentikan.

16. Regression Test — Foto Space

Setelah QA-014 diperbaiki, lakukan test lengkap berikut.

Scenario A — Edit tanpa foto baru

Edit Space
→ Ubah nama
→ Simpan

Expected:

data berhasil berubah;

foto lama tetap.

Scenario B — Edit dengan Galeri

Edit Space
→ Pilih Foto
→ Galeri
→ Pilih foto

Expected:

picker tertutup;

Edit Space tetap terbuka;

preview berubah.

Scenario C — Edit dengan Kamera

Edit Space
→ Pilih Foto
→ Kamera
→ Ambil foto

Expected:

kamera tertutup;

Edit Space tetap terbuka;

preview foto baru tampil.

Scenario D — Simpan foto baru

Pilih foto
→ Simpan
→ POST /api/upload/spaces
→ PUT /api/admin/spaces/{id}

Expected:

upload berhasil;

server memberikan filename;

filename digunakan pada Space;

list Space menampilkan foto baru.

Scenario E — Upload gagal

Pilih foto
→ Simpan
→ Upload gagal

Expected:

tidak menampilkan success;

tidak melakukan update Space dengan local path;

error ditampilkan;

user masih dapat mencoba kembali.

17. Acceptance Criteria

Aplikasi dapat dianggap QA PASS apabila:

Authentication

Login Member berhasil.

Login Admin berhasil.

Invalid credential ditolak.

Token/session aman.

Role restriction berjalan.

Member

Space dapat dilihat.

Detail Space dapat dibuka.

Availability dapat dicek.

Reservasi dapat dibuat.

Status reservasi dapat dilihat.

E-ticket tersedia sesuai status.

Admin

Dashboard berjalan.

Profil dapat dikelola.

Member CRUD berjalan.

Space CRUD berjalan.

Diskon CRUD berjalan.

Reservasi dapat dikelola.

Check-in/out berjalan.

Report dapat ditampilkan.

Foto

Foto dapat dipilih dari galeri.

Foto dapat diambil dari kamera.

Edit Space tidak tertutup setelah memilih foto.

Preview foto tampil.

Upload berhasil.

Filename server digunakan.

Upload failure ditampilkan.

Local path tidak pernah disimpan sebagai foto.

Stability

Tidak ada crash pada flow utama.

Tidak ada silent fallback ketika mutation API gagal.

Loading state tersedia.

Error state tersedia.

Success message hanya muncul setelah request sukses.

18. Prioritas Perbaikan

P0 — Wajib sebelum demo/ujian

Fix QA-014: ImagePickerHelper menyebabkan Edit Space tertutup.

Regression test seluruh upload/edit Space.

Pastikan tidak ada crash setelah memilih foto.

P1 — Sangat disarankan

Fix QA-015: success message harus menunggu Future selesai.

Hardening QA-016: jangan pernah fallback ke local file path.

Test upload failure dan API timeout.

Test authentication/session expiry.

P2 — Improvement

Hapus hardcoded date QA-017.

Tambahkan automated tests untuk critical flow.

Audit konfigurasi Android.

Tingkatkan coverage unit/widget/integration test.

19. Final QA Status

Status: 🟢 PASSED / READY FOR UKK

Aplikasi telah berhasil melewati seluruh tahapan QA dan pengujian regresi:
- QA-014: Pemilihan foto dari Kamera maupun Galeri tidak lagi menutup form Edit Space (`Navigator.pop(ctx, file)` digunakan secara tepat).
- QA-015: Feedback pesan sukses hanya ditampilkan setelah seluruh Future (Upload foto + PUT Space) selesai dieksekusi dan berhasil.
- QA-016: Controller tidak lagi menggunakan fallback ke local file path perangkat; kegagalan upload akan melempar error dan mencegah mutasi data yang salah.
- QA-017: Seluruh penggunaan tanggal hardcoded telah digantikan dengan tanggal dinamis `DateTime.now()`.

Flow terverifikasi:
Edit Space
→ Pilih Foto (Kamera/Galeri)
→ Preview foto berubah
→ Form tetap terbuka
→ Ubah field lainnya
→ Simpan
→ Loading indicator aktif
→ Upload foto berhasil
→ PUT Space berhasil
→ Refresh data
→ Notifikasi Sukses ditampilkan

20. Referensi Kebutuhan

Dokumen PRD mendefinisikan Admin Space sebagai fitur CRUD dengan upload foto, menggunakan endpoint /api/admin/spaces dan /api/upload/spaces. PRD juga menetapkan bahwa foto harus di-upload terlebih dahulu untuk mendapatkan filename, kemudian filename digunakan dalam payload create/update.

Dokumen PRD juga menetapkan bahwa Member harus melakukan pengecekan availability sebelum reservasi dan sistem harus mencegah bentrok jadwal.

Dokumen acuan: PRD_Arsitektur_Desain_SmartSpaceBooking_Mobile.md