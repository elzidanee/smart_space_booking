# ENDPOINT.MD — Dokumentasi API Coworking Space (UKK RPL 2026/2027, Paket B)

Referensi lengkap 50 endpoint dari Kontrak API (Bagian III soal). Dokumen ini dipakai sebagai acuan cepat saat integrasi Flutter/Kotlin — tidak menggantikan Kontrak API resmi di soal, hanya diringkas agar mudah dicari.

## Ketentuan Global (berlaku di semua endpoint)

| Ketentuan | Detail |
|---|---|
| Header wajib semua request | `x-maker-key: <app_key>` (atau `x-app-key`) — didapat dari `POST /api/maker/register` |
| Header tambahan untuk endpoint ber-autentikasi | `Authorization: Bearer <access_token>` — didapat dari `POST /api/auth/login` |
| Format tanggal | `YYYY-MM-DD` atau ISO 8601 penuh (`2026-08-30T00:00:00.000Z`) |
| Format jam | `HH:mm` 24 jam |
| Format response sukses | `{ "status": true, "statusCode": 200/201, "message": "...", "data": {...}/[...], "timestamp": "ISO 8601" }` |
| Format response error | `{ "status": false, "statusCode": 400/401/403/404/500, "message": "...", "error": "NamaError", "timestamp": "ISO 8601" }` |
| Base URL foto | `http://localhost:3000/uploads/{spaces\|members\|general}/<nama_file>` |

> **Catatan**: `localhost:3000` di seluruh dokumen ini adalah placeholder dari soal. Base URL sebenarnya diberikan panitia saat ujian dimulai — ganti semua contoh URL di bawah dengan base URL asli tersebut.

---

## Daftar Isi

1. [Root & Health Check](#1-root--health-check)
2. [App Maker (Multi-Tenancy)](#2-app-maker-multi-tenancy)
3. [Autentikasi User](#3-autentikasi-user)
4. [Space Coworking](#4-space-coworking)
5. [Diskon & Promo](#5-diskon--promo)
6. [Reservasi Member](#6-reservasi-member)
7. [Profil Lokasi (Admin)](#7-profil-lokasi-admin)
8. [Manajemen Member (Admin)](#8-manajemen-member-admin)
9. [Manajemen Space (Admin)](#9-manajemen-space-admin)
10. [Manajemen Diskon (Admin)](#10-manajemen-diskon-admin)
11. [Reservasi & Check-in/out (Admin)](#11-reservasi--check-inout-admin)
12. [Laporan Pendapatan (Admin)](#12-laporan-pendapatan-admin)
13. [Upload Media](#13-upload-media)

---

## 1. Root & Health Check

### `GET /`
- **Auth**: Publik
- **Deskripsi**: Status API & petunjuk penggunaan.
- **Response 200**: `data` berisi `name`, `version`, `status`, `swagger_docs`, `documentation_links`.

### `GET /health`
- **Auth**: Publik
- **Deskripsi**: Health check server.
- **Response 200**: `data: { status: "ok", timestamp }`.

---

## 2. App Maker (Multi-Tenancy)

### `POST /api/maker/register`
- **Auth**: Publik
- **Deskripsi**: Registrasi akun siswa (App Maker) & generate `app_key` unik.
- **Body**: `{ name, username, email, password }`
- **Response 201**: `data: { id, name, username, email, app_key, created_at, updated_at, access_token }`
- **Error 400**: username/email sudah terdaftar.

### `POST /api/maker/login`
- **Auth**: Publik
- **Body**: `{ usernameOrEmail, password }`
- **Response 200**: `data: { id, name, username, email, app_key, access_token }`
- **Error 401**: kredensial salah.

### `GET /api/maker/me`
- **Auth**: Bearer Token App Maker
- **Deskripsi**: Lihat profil & app key siswa saat ini.
- **Response 200**: `data: { id, name, username, email, app_key, created_at }`

### `GET /api/maker/stats`
- **Auth**: Bearer Token App Maker / header `x-maker-key`
- **Deskripsi**: Statistik keseluruhan data siswa.
- **Response 200**: `data: { total_members, total_spaces, total_diskon, total_reservasi, total_pendapatan }`

### `GET /api/maker/list`
- **Auth**: Publik (panel guru/penguji)
- **Deskripsi**: Daftar semua siswa/App Maker terdaftar.
- **Response 200**: `data: [{ id, name, username, email, app_key, created_at }, ...]`

---

## 3. Autentikasi User

### `POST /api/auth/register/member`
- **Auth**: Publik | Header: `x-maker-key`
- **Deskripsi**: Registrasi akun Member/Pelanggan baru.
- **Body**: `{ username, password, nama_member, instansi, alamat, telp, foto? }`
- **Response 201**: `data: { id, username, role: "member", member: {...}, access_token }`
- **Error 400**: username sudah digunakan.

### `POST /api/auth/register/admin-space`
- **Auth**: Publik | Header: `x-maker-key`
- **Deskripsi**: Registrasi pengelola lokasi/Admin Coworking Space.
- **Body**: `{ username, password, nama_coworking, nama_pemilik, telp }`
- **Response 201**: `data: { id, username, role: "admin_space", space_owner: {...}, access_token }`

### `POST /api/auth/login`
- **Auth**: Publik | Header: `x-maker-key`
- **Deskripsi**: Login akun user (Member atau Admin Space), mengembalikan JWT.
- **Body**: `{ username, password }`
- **Response 200**: `data: { id, username, role, maker_id, member: {...} | null, space_owner: {...} | null, access_token }`
- **Error 401**: username/password salah.

### `GET /api/auth/profile`
- **Auth**: Bearer User | Header: `x-maker-key`
- **Deskripsi**: Cek profil & hak akses pengguna yang sedang login.
- **Response 200**: `data: { id, username, role, member/space_owner: {...} }`

---

## 4. Space Coworking

### `GET /api/spaces/types`
- **Auth**: Publik/User | Header: `x-maker-key`
- **Deskripsi**: Daftar tipe space (Personal Desk, Meeting Room, Private Office).
- **Response 200**: `data: [{ tipe, label, deskripsi }, ...]`

### `GET /api/spaces/availability`
- **Auth**: Publik/User | Header: `x-maker-key`
- **Query**: `id_space, tanggal, jam_mulai, durasi_jam`
- **Deskripsi**: Cek ketersediaan space berdasarkan tanggal & jam.
- **Response 200**: `data: { available, id_space, nama_space, tanggal, jam_mulai, jam_selesai, durasi_jam, harga_per_jam, estimasi_total }`
- **Error 400**: space sudah terisi/dibooking pada jam tersebut.

### `GET /api/spaces`
- **Auth**: Publik/User | Header: `x-maker-key`
- **Query (opsional)**: `?tipe=desk|meeting_room|private_office`, `?search=<keyword>`
- **Deskripsi**: Lihat semua space coworking (katalog).
- **Response 200**: `data: [{ id, nama_space, harga_per_jam, tipe, kapasitas, foto, deskripsi, id_owner, owner: {...}, foto_url }, ...]`

### `GET /api/spaces/{id}`
- **Auth**: Publik/User | Header: `x-maker-key`
- **Deskripsi**: Lihat detail space berdasarkan ID.
- **Response 200**: `data: { id, nama_space, harga_per_jam, tipe, kapasitas, foto, deskripsi, id_owner, owner: {...}, foto_url }`
- **Error 404**: space tidak ditemukan.

---

## 5. Diskon & Promo

### `GET /api/diskon/active`
- **Auth**: Publik/User | Header: `x-maker-key`
- **Deskripsi**: Daftar promo/diskon yang sedang aktif.
- **Response 200**: `data: [{ id, nama_diskon, persentase_diskon, tanggal_awal, tanggal_akhir }, ...]`

### `POST /api/diskon/check`
- **Auth**: Publik/User | Header: `x-maker-key`
- **Body**: `{ nama_diskon }`
- **Deskripsi**: Periksa validitas & hitung potongan kode promo.
- **Response 200**: `data: { id, nama_diskon, persentase_diskon, tanggal_awal, tanggal_akhir, is_active }`
- **Error 400**: kode promo tidak ditemukan/kedaluwarsa.

### `GET /api/diskon/{id}`
- **Auth**: Publik/User | Header: `x-maker-key`
- **Deskripsi**: Lihat detail diskon berdasarkan ID.
- **Response 200**: `data: { id, nama_diskon, persentase_diskon, tanggal_awal, tanggal_akhir }`

---

## 6. Reservasi Member

### `POST /api/reservasi`
- **Auth**: Bearer Member | Header: `x-maker-key`
- **Body**: `{ id_space, tanggal_reservasi, jam_mulai, durasi_jam, id_diskon?, kode_promo? }`
- **Deskripsi**: Buat pemesanan space baru (+ perhitungan otomatis).
- **Response 201**: `data: { id, kode_booking, id_member, id_space, id_diskon, tanggal_reservasi, jam_mulai, jam_selesai, durasi_jam, harga_per_jam, total_harga_awal, potongan_diskon, total_bayar, status: "belum_dikonfirm", created_at }`
- **Error 400**: space tidak tersedia pada tanggal/jam tersebut.

### `GET /api/reservasi/my`
- **Auth**: Bearer Member | Header: `x-maker-key`
- **Deskripsi**: Lihat status semua pemesanan milik sendiri.
- **Response 200**: `data: [{ id, kode_booking, tanggal_reservasi, jam_mulai, jam_selesai, durasi_jam, total_bayar, status, space: {...} }, ...]`

### `GET /api/reservasi/my/history`
- **Auth**: Bearer Member | Header: `x-maker-key`
- **Query (opsional)**: `?month=1-12`, `?year=YYYY`
- **Deskripsi**: Lihat histori pemesanan berdasarkan bulan & tahun.
- **Response 200**: `data: { month, year, total_reservasi, total_pengeluaran, items: [...] }`

### `GET /api/reservasi/{id}/e-ticket`
- **Auth**: Bearer Member/Admin | Header: `x-maker-key`
- **Deskripsi**: Cetak e-ticket/bukti nota digital reservasi.
- **Response 200**: `data: { e_ticket_number, kode_booking, coworking_space, member, space, jadwal, rincian_pembayaran, status_reservasi, qr_code_payload }`

### `GET /api/reservasi/{id}`
- **Auth**: Bearer Member/Admin | Header: `x-maker-key`
- **Deskripsi**: Lihat detail reservasi berdasarkan ID.
- **Response 200**: `data: { id, kode_booking, id_member, id_space, tanggal_reservasi, jam_mulai, jam_selesai, durasi_jam, total_bayar, status, member: {...}, space: {...} }`

### `PATCH /api/reservasi/{id}/cancel`
- **Auth**: Bearer Member | Header: `x-maker-key`
- **Deskripsi**: Batalkan pemesanan space.
- **Response 200**: `data: { id, status: "dibatalkan", updated_at }`

---

## 7. Profil Lokasi (Admin)

### `GET /api/admin/profile`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Deskripsi**: Lihat data profil lokasi coworking space.
- **Response 200**: `data: { id, nama_coworking, nama_pemilik, telp }`

### `PUT /api/admin/profile`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Body**: `{ nama_coworking, nama_pemilik, telp }`
- **Deskripsi**: Update data profil lokasi coworking space.
- **Response 200**: `data: { id, nama_coworking, nama_pemilik, telp }`

---

## 8. Manajemen Member (Admin)

### `GET /api/admin/members`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Query (opsional)**: `?search=<nama/instansi/telp>`
- **Response 200**: `data: [{ id, nama_member, instansi, alamat, telp, foto, created_at }, ...]`

### `POST /api/admin/members`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Body**: `{ username, password, nama_member, instansi, alamat, telp, foto? }`
- **Deskripsi**: Tambah data member baru (upload foto terpisah lewat `/api/upload/members`).
- **Response 201**: `data: { id, nama_member, instansi, alamat, telp, foto }`

### `GET /api/admin/members/{id}`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Response 200**: `data: { id, nama_member, instansi, alamat, telp, foto }`

### `PUT /api/admin/members/{id}`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Body**: `{ nama_member?, instansi?, alamat?, telp?, password?, foto? }` (semua opsional/partial update)
- **Response 200**: `data: { id, nama_member, instansi, alamat, telp }`

### `DELETE /api/admin/members/{id}`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Response 200**: `data: { id, deleted: true }`

---

## 9. Manajemen Space (Admin)

### `GET /api/admin/spaces`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Response 200**: `data: [{ id, nama_space, harga_per_jam, tipe, kapasitas, foto, foto_url }, ...]`

### `POST /api/admin/spaces`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Body**: `{ nama_space, harga_per_jam, tipe, kapasitas, deskripsi, foto? }`
- **Deskripsi**: Tambah ruangan/meja baru beserta fasilitas & foto.
- **Response 201**: `data: { id, nama_space, harga_per_jam, tipe, kapasitas, deskripsi, foto, id_owner }`

### `GET /api/admin/spaces/{id}`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Response 200**: `data: { id, nama_space, harga_per_jam, tipe, kapasitas, deskripsi, foto }`

### `PUT /api/admin/spaces/{id}`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Body**: `{ nama_space?, harga_per_jam?, tipe?, kapasitas?, deskripsi?, foto? }`
- **Response 200**: `data: { id, nama_space, harga_per_jam, tipe, kapasitas, deskripsi }`

### `DELETE /api/admin/spaces/{id}`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Response 200**: `data: { id, deleted: true }`

---

## 10. Manajemen Diskon (Admin)

### `GET /api/admin/diskon`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Response 200**: `data: [{ id, nama_diskon, persentase_diskon, tanggal_awal, tanggal_akhir }, ...]`

### `POST /api/admin/diskon`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Body**: `{ nama_diskon, persentase_diskon, tanggal_awal, tanggal_akhir }`
- **Response 201**: `data: { id, nama_diskon, persentase_diskon, tanggal_awal, tanggal_akhir }`

### `GET /api/admin/diskon/{id}`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Response 200**: `data: { id, nama_diskon, persentase_diskon, tanggal_awal, tanggal_akhir }`

### `PUT /api/admin/diskon/{id}`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Body**: `{ nama_diskon?, persentase_diskon?, tanggal_awal?, tanggal_akhir? }`
- **Response 200**: `data: { id, nama_diskon, persentase_diskon, tanggal_akhir }`

### `DELETE /api/admin/diskon/{id}`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Response 200**: `data: { id, deleted: true }`

---

## 11. Reservasi & Check-in/out (Admin)

### `GET /api/admin/reservasi`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Query (opsional)**: `?month=1-12`, `?year=YYYY`, `?status=belum_dikonfirm|disetujui|aktif|selesai|dibatalkan`, `?id_space=<id>`, `?tanggal=YYYY-MM-DD`
- **Deskripsi**: Lihat seluruh reservasi coworking dengan filter lengkap.
- **Response 200**: `data: [{ id, kode_booking, tanggal_reservasi, jam_mulai, jam_selesai, durasi_jam, total_harga_awal, potongan_diskon, total_bayar, status, member: {...}, space: {...} }, ...]`

### `PATCH /api/admin/reservasi/{id}/status`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Body**: `{ status: "belum_dikonfirm" | "disetujui" | "aktif" | "selesai" | "dibatalkan" }`
- **Deskripsi**: Konfirmasi & ubah status pemesanan.
- **Response 200**: `data: { id, status, updated_at }`

### `POST /api/admin/reservasi/{id}/check-in`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Deskripsi**: Check-in pelanggan (status → `aktif`).
- **Response 200**: `data: { id, status: "aktif", check_in_time }`

### `POST /api/admin/reservasi/{id}/check-out`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Deskripsi**: Check-out pelanggan (status → `selesai`).
- **Response 200**: `data: { id, status: "selesai", check_out_time }`

---

## 12. Laporan Pendapatan (Admin)

### `GET /api/admin/reports/monthly`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Query (opsional)**: `?month=1-12`, `?year=YYYY`
- **Deskripsi**: Rekapitulasi estimasi & realisasi pendapatan per bulan.
- **Response 200**: `data: { month, year, total_transaksi, total_jam_terpakai, estimasi_pendapatan_kotor, total_potongan_diskon, realisasi_pendapatan_bersih, rincian_per_tipe_space: [{ tipe, label, total_booking, total_jam, total_pendapatan }, ...] }`

### `GET /api/admin/reports/income`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`
- **Query (opsional)**: `?month=1-12`, `?year=YYYY`
- **Deskripsi**: Alias rekapitulasi pendapatan bulanan (versi ringkas).
- **Response 200**: `data: { month, year, realisasi_pendapatan_bersih }`

---

## 13. Upload Media

### `POST /api/upload/image`
- **Auth**: Publik/User/Admin | Header: `x-maker-key`, `Content-Type: multipart/form-data`
- **Body**: `form-data { file: <binary .jpg/.jpeg/.png/.webp> }`
- **Deskripsi**: Upload berkas gambar umum.
- **Response 201**: `data: { filename, original_name, mimetype, size, url }`

### `POST /api/upload/spaces`
- **Auth**: Bearer Admin Space | Header: `x-maker-key`, `Content-Type: multipart/form-data`
- **Body**: `form-data { file: <binary .jpg/.jpeg/.png> }`
- **Deskripsi**: Upload foto ruangan/meja space.
- **Response 201**: `data: { filename, url }`

### `POST /api/upload/members`
- **Auth**: Publik/User/Admin | Header: `x-maker-key`, `Content-Type: multipart/form-data`
- **Body**: `form-data { file: <binary .jpg/.jpeg/.png> }`
- **Deskripsi**: Upload foto profil member/pelanggan.
- **Response 201**: `data: { filename, url }`

---

## Ringkasan Tabel Semua 50 Endpoint

| No | Endpoint | Method | Auth |
|---|---|---|---|
| 1 | `/` | GET | Publik |
| 2 | `/health` | GET | Publik |
| 3 | `/api/maker/register` | POST | Publik |
| 4 | `/api/maker/login` | POST | Publik |
| 5 | `/api/maker/me` | GET | Bearer Maker |
| 6 | `/api/maker/stats` | GET | Bearer/x-maker-key |
| 7 | `/api/maker/list` | GET | Publik |
| 8 | `/api/auth/register/member` | POST | Publik + x-maker-key |
| 9 | `/api/auth/register/admin-space` | POST | Publik + x-maker-key |
| 10 | `/api/auth/login` | POST | Publik + x-maker-key |
| 11 | `/api/auth/profile` | GET | Bearer User |
| 12 | `/api/spaces/types` | GET | Publik/User |
| 13 | `/api/spaces/availability` | GET | Publik/User |
| 14 | `/api/spaces` | GET | Publik/User |
| 15 | `/api/spaces/{id}` | GET | Publik/User |
| 16 | `/api/diskon/active` | GET | Publik/User |
| 17 | `/api/diskon/check` | POST | Publik/User |
| 18 | `/api/diskon/{id}` | GET | Publik/User |
| 19 | `/api/reservasi` | POST | Bearer Member |
| 20 | `/api/reservasi/my` | GET | Bearer Member |
| 21 | `/api/reservasi/my/history` | GET | Bearer Member |
| 22 | `/api/reservasi/{id}/e-ticket` | GET | Bearer Member/Admin |
| 23 | `/api/reservasi/{id}` | GET | Bearer Member/Admin |
| 24 | `/api/reservasi/{id}/cancel` | PATCH | Bearer Member |
| 25 | `/api/admin/profile` | GET | Bearer Admin |
| 26 | `/api/admin/profile` | PUT | Bearer Admin |
| 27 | `/api/admin/members` | GET | Bearer Admin |
| 28 | `/api/admin/members` | POST | Bearer Admin |
| 29 | `/api/admin/members/{id}` | GET | Bearer Admin |
| 30 | `/api/admin/members/{id}` | PUT | Bearer Admin |
| 31 | `/api/admin/members/{id}` | DELETE | Bearer Admin |
| 32 | `/api/admin/spaces` | GET | Bearer Admin |
| 33 | `/api/admin/spaces` | POST | Bearer Admin |
| 34 | `/api/admin/spaces/{id}` | GET | Bearer Admin |
| 35 | `/api/admin/spaces/{id}` | PUT | Bearer Admin |
| 36 | `/api/admin/spaces/{id}` | DELETE | Bearer Admin |
| 37 | `/api/admin/diskon` | GET | Bearer Admin |
| 38 | `/api/admin/diskon` | POST | Bearer Admin |
| 39 | `/api/admin/diskon/{id}` | GET | Bearer Admin |
| 40 | `/api/admin/diskon/{id}` | PUT | Bearer Admin |
| 41 | `/api/admin/diskon/{id}` | DELETE | Bearer Admin |
| 42 | `/api/admin/reservasi` | GET | Bearer Admin |
| 43 | `/api/admin/reservasi/{id}/status` | PATCH | Bearer Admin |
| 44 | `/api/admin/reservasi/{id}/check-in` | POST | Bearer Admin |
| 45 | `/api/admin/reservasi/{id}/check-out` | POST | Bearer Admin |
| 46 | `/api/admin/reports/monthly` | GET | Bearer Admin |
| 47 | `/api/admin/reports/income` | GET | Bearer Admin |
| 48 | `/api/upload/image` | POST | x-maker-key |
| 49 | `/api/upload/spaces` | POST | Bearer Admin |
| 50 | `/api/upload/members` | POST | x-maker-key |

---

*Diringkas dari Bagian III — Kontrak API, "Soal Uji Kompetensi RPL 2026/2027 — Paket B" (SMK Telkom Malang). Untuk contoh request/response body lengkap per endpoint, lihat Postman Collection `Coworking_Space_API_UKK_PaketB.postman_collection.json`.*