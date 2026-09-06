<div align="center">

# 🏢 Smart Space Booking
### Modern Coworking Space & Workstation Reservation Mobile Application
**Solusi Digital Terpadu Reservasi Ruang Kerja & Manajemen Coworking Multi-Tenant Lintas Peran**

[![Flutter](https://img.shields.io/badge/Flutter-3.38.7-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10.7-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![State Management](https://img.shields.io/badge/State-Riverpod_2.6-blueviolet?style=for-the-badge&logo=redux&logoColor=white)](https://riverpod.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean_Feature--First-orange?style=for-the-badge)]()
[![API Endpoints](https://img.shields.io/badge/API_Contract-50%2F50_Endpoints_(100%25)-brightgreen?style=for-the-badge&logo=postman&logoColor=white)]()
[![QA Status](https://img.shields.io/badge/QA_Tests-48%2F48_Passed_(0_Issues)-success?style=for-the-badge&logo=checkmarx&logoColor=white)]()
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Windows-green?style=for-the-badge&logo=android)]()

<br>

<p align="center">
  <b>Uji Kompetensi Keahlian (UKK) Rekayasa Perangkat Lunak 2026/2027</b><br>
  <b>SMK Telkom Malang — Paket B: Smart Coworking Space Booking (Lampiran D)</b>
</p>

[Latar Belakang](#-latar-belakang--problem-statement) •
[Fitur Utama](#-fitur-lengkap-berdasarkan-peran) •
[Alur Status](#-siklus-status-reservasi-state-machine) •
[Arsitektur & Folder](#-arsitektur-perangkat-lunak--struktur-proyek) •
[Matriks API (50 Endpoint)](#-matriks-kontrak-api-50-endpoint-lengkap) •
[Sistem Desain](#-sistem-desain--pengalaman-pengguna-uiux) •
[Keamanan & Multi-Tenancy](#-keamanan-multi-tenancy--resiliensi-sistem) •
[Instalasi & Build APK](#-panduan-instalasi--menjalankan-proyek) •
[Pengujian QA](#-jaminan-kualitas--pengujian-otomatis-qa) •
[Cheatsheet Penguji](#-panduan-pengujian-cepat-untuk-penguji-cheatsheet-ukk)

---

</div>

## 📖 Latar Belakang & Problem Statement

Pengelolaan operasional reservasi coworking space dan workstation secara konvensional (melalui WhatsApp, buku tamu fisik, atau spreadsheet) memiliki 3 celah fatal:
1. **Bentrok Jadwal (*Double Booking*)**: Tidak adanya validasi slot ketersediaan meja/ruangan secara *real-time* sebelum pemesanan dibuat, sehingga dua tamu dapat memesan ruangan yang sama pada slot jam yang bertabrakan.
2. **Ketiadaan Bukti Sah yang Terverifikasi**: Tamu kesulitan membuktikan keabsahan reservasinya di meja resepsionis tanpa sistem tiket digital resmi berbasis QR Code.
3. **Pencatatan Finansial Manual**: Pengelola kesulitan menghitung estimasi pendapatan kotor, akumulasi potongan voucher promo/diskon, dan realisasi pendapatan bersih per jenis ruangan secara akurat.

### Solusi yang Dihadirkan: Smart Space Booking
**Smart Space Booking** adalah aplikasi mobile *native-grade* berbasis **Flutter** dengan arsitektur **Clean Architecture (Feature-First)** yang mengintegrasikan dua peran pengguna (**Member** dan **Admin Pengelola Space**) ke dalam satu ekosistem terpadu:
* 🛡️ **Pencegahan Double-Booking**: Mesin pengecekan ketersediaan slot waktu dinamis (`/api/spaces/availability`) dengan *double-check validation* sesaat sebelum transaksi dikirim ke server.
* 🎫 **Tiket Digital QR Code**: Penerbitan e-ticket instan dengan barcode 2D QR Code yang dapat langsung diverifikasi di lokasi saat *check-in*.
* 📊 **Laporan Finansial Otomatis**: Rekapitulasi pendapatan bulanan (omzet kotor, diskon, omzet bersih, jam pemakaian) lengkap dengan visualisasi proporsi pendapatan per tipe ruangan.
* 🌐 **Multi-Tenant Ready**: Mendukung isolasi data tenant antar peserta ujian menggunakan header wajib `x-maker-key` dan konfigurasi dinamis langsung dari antarmuka aplikasi.

---

## ✨ Fitur Lengkap Berdasarkan Peran

Aplikasi mengimplementasikan **seluruh 24 Kebutuhan Fungsional (FR-01 s.d. FR-24)** dari PRD dan spesifikasi soal UKK Paket B:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           SMART SPACE BOOKING SYSTEM                            │
├──────────────────────────────────────┬──────────────────────────────────────────┤
│        👤 MODUL MEMBER (TAMU)        │       🛡️ MODUL ADMIN (PENGELOLA)        │
├──────────────────────────────────────┼──────────────────────────────────────────┤
│ • Registrasi Akun & Foto Profil      │ • Registrasi Lokasi Coworking & Admin    │
│ • Login Aman dengan Sesi Terenkripsi │ • Dashboard Operasional & Real-time KPI  │
│ • Katalog Space (Desk/Meeting/Office)│ • Master Data Member (CRUD Penuh)        │
│ • Filter Tipe Ruangan & Quick Search │ • Master Data Space & Upload Foto Ruangan│
│ • Cek Ketersediaan Real-Time         │ • Master Data Diskon/Promo (CRUD Penuh)  │
│ • Klaim Kupon Diskon / Voucher Promo │ • Operasional Check-In Tamu              │
│ • Rincian Biaya Transparan           │ • Operasional Check-Out (Dialog Aman)    │
│ • E-Ticket Resmi Berfitur QR Code    │ • Filter Multi-Parameter Reservasi Masuk │
│ • Pelacakan Status Pemesanan 5 Fase  │ • Laporan Finansial Bulanan Komprehensif │
│ • Histori Transaksi & Filter Bulanan │ • Distribusi Pendapatan per Tipe Space   │
│ • Profil & Rekap Pengeluaran Pribadi │ • Profil Lokasi & Informasi Kontak Space │
└──────────────────────────────────────┴──────────────────────────────────────────┘
```

### 1. 👤 Modul Member (Penyewa / Tamu)
* **Onboarding & Autentikasi**:
  * Pendaftaran akun member baru (`/api/auth/register/member`) lengkap dengan nama, instansi, nomor telepon, alamat, username, dan foto profil.
  * Login kredensial dengan penyimpanan token JWT terenkripsi dan opsi *Remember Me*.
* **Katalog & Eksplorasi Ruangan**:
  * Menampilkan seluruh inventaris ruangan dengan foto resolusi tinggi, kapasitas orang, tarif sewa per jam, dan badge fasilitas (WiFi, AC, Proyektor, Kopi, Whiteboard, dll.).
  * Filter instan berbasis kategori (*Personal Desk*, *Meeting Room*, *Private Office*) serta kolom pencarian nama ruangan yang responsif.
* **Mesin Pemesanan & Slot Availability Engine**:
  * Pemilihan tanggal sewa, jam mulai (format 24 jam), dan durasi penggunaan.
  * Tombol **Cek Ketersediaan** yang mengecek bentrok slot ke server secara *real-time* sebelum pemesanan diajukan.
  * Pengecekan ulang otomatis (*pre-submit double check*) untuk menjamin tidak terjadi *race condition* antar pengguna.
* **Kalkulasi Biaya & Kupon Diskon**:
  * Validasi kode kupon promo (`/api/diskon/check`) dengan verifikasi rentang masa berlaku.
  * Ringkasan rincian biaya transparan: Subtotal (Durasi × Tarif per Jam), Potongan Diskon, dan Total Bayar Bersih.
* **Pelacakan Status & Pembatalan Mandiri**:
  * Layar pelacakan status dengan tab filter (Semua, Menunggu, Disetujui, Aktif, Selesai, Dibatalkan).
  * Fitur pembatalan mandiri untuk pemesanan yang masih berstatus `belum_dikonfirm` atau `disetujui`.
* **Tiket Digital (E-Ticket) dengan QR Code**:
  * Menampilkan e-ticket resmi bergaya boarding pass modern dengan nomor reservasi, detail space, jadwal sewa, nama pemesan, dan QR Code dinamis (`qr_flutter`) untuk proses *check-in* di resepsionis.
* **Histori Pemesanan Bulanan**:
  * Arsip riwayat pemesanan yang dapat difilter per bulan dan tahun.
  * Kartu ringkasan finansial personal: Total Reservasi, Akumulasi Jam, dan Total Pengeluaran bulanan.
* **Profil & Akun Member**:
  * Tampilan kartu identitas digital member, informasi instansi, nomor kontak, statistik pemakaian personal, dan tombol logout aman.

### 2. 🛡️ Modul Admin (Pengelola Coworking Space)
* **Registrasi & Dashboard Lokasi**:
  * Registrasi lokasi coworking dan akun pemilik baru (`/api/auth/register/admin-space`).
  * Dashboard harian dengan kartu metrik ringkasan: Reservasi Hari Ini, Menunggu Konfirmasi, Tamu Aktif di Lokasi, Transaksi Selesai, dan Estimasi Omzet.
* **Master Data Member (CRUD Penuh)**:
  * Tambah member baru langsung dari portal admin dengan form validasi lengkap.
  * Cari member berdasarkan nama/instansi, perbarui data profil/kontak, dan hapus akun member.
* **Master Data Ruangan & Upload Media Multipart**:
  * Tambah ruangan baru (*Personal Desk*, *Meeting Room*, *Private Office*).
  * Kelola tarif per jam, kapasitas kursi, dan daftar fasilitas pendukung.
  * Upload foto ruangan asli via endpoint multipart (`/api/upload/spaces`) dengan integrasi kamera dan galeri (`image_picker`).
  * Edit dan hapus data ruangan dari inventaris.
* **Master Data Kupon Diskon / Promo (CRUD Penuh)**:
  * Buat kode kupon promo baru dengan persentase diskon (1% s.d. 100%).
  * Atur tanggal mulai dan tanggal berakhir masa berlaku promo.
  * Indikator status promo aktif atau kedaluwarsa secara otomatis.
* **Operasional Resepsionis (Check-In & Check-Out)**:
  * Filter daftar reservasi masuk berdasarkan status, nama space, maupun tanggal spesifik.
  * Konfirmasi pesanan baru (`belum_dikonfirm` → `disetujui`) atau tolak pesanan (`dibatalkan`).
  * Aksi **Check-In** satu ketuk saat tamu tiba dan menunjukkan e-ticket QR Code (`disetujui` → `aktif`).
  * Aksi **Check-Out** saat sesi sewa berakhir (`aktif` → `selesai`) yang dilindungi oleh **dialog konfirmasi dua langkah** untuk mencegah ketidaksengajaan petugas.
* **Laporan Finansial Bulanan & Distribusi Omzet**:
  * Pemilih bulan dan tahun fleksibel untuk audit pembukuan.
  * 5 Metrik Finansial Utama:
    1. **Estimasi Pendapatan Kotor**
    2. **Total Potongan Diskon**
    3. **Realisasi Pendapatan Bersih**
    4. **Total Transaksi Reservasi**
    5. **Akumulasi Durasi Jam Terpakai**
  * Visualisasi bar proporsional distribusi pendapatan per kategori ruangan (*Personal Desk*, *Meeting Room*, *Private Office*).
* **Profil Coworking Space**:
  * Tinjau dan perbarui nama lokasi coworking, nama penanggung jawab/pemilik, nomor telepon, dan alamat operasional.

### 3. ⚙️ Fitur Penguji & Developer (Developer Excellence)
* **Dynamic Server & Maker Key Switcher (`ServerConfigBottomSheet`)**:
  * Tombol pintas konfigurasi jaringan di pojok kanan atas layar login (`Icons.settings_ethernet`).
  * Penguji dapat mengganti **Base URL** dan **`x-maker-key`** secara dinamis saat aplikasi berjalan tanpa perlu mengompilasi ulang kode sumber.
  * **Tombol Preset 1-Ketuk**:
    * 🏫 *Server Sekolah / Production*: `https://learn.smktelkom-mlg.sch.id/coworking`
    * 📱 *Android Emulator*: `http://10.0.2.2:3000`
    * 💻 *Localhost / Desktop*: `http://localhost:3000`
  * Tombol **Uji Koneksi** (`GET /health`) dengan indikator latensi real-time untuk memastikan server dapat dijangkau sebelum login.

---

## 🔄 Siklus Status Reservasi (State Machine)

Alur status reservasi dirancang dengan aturan transisi status yang ketat sesuai spesifikasi UKK:

```mermaid
stateDiagram-v2
    [*] --> belum_dikonfirm : Member Mengajukan Reservasi
    belum_dikonfirm --> disetujui : Admin Menyetujui Reservasi
    belum_dikonfirm --> dibatalkan : Dibatalkan (Member / Admin)
    disetujui --> aktif : Tamu Hadir & Admin Check-In
    disetujui --> dibatalkan : Dibatalkan (Member / Admin)
    aktif --> selesai : Sesi Berakhir & Admin Check-Out
    selesai --> [*] : Masuk Rekap Pendapatan Bersih
    dibatalkan --> [*] : Transaksi Hangus (Omzet = Rp 0)
```

### Matriks Aturan Transisi Status & Hak Akses

| Status Sistem | Label Tampilan UI | Aksen Warna | Hak Akses Member | Hak Akses Admin |
|:---:|:---:|:---:|:---:|:---:|
| `belum_dikonfirm` | **Menunggu** | 🟡 Amber (`#D97706`) | Dapat melihat rincian & membatalkan | Dapat **Menyetujui** atau **Menolak** |
| `disetujui` | **Disetujui** | 🔵 Biru Info (`#2563EB`) | **E-Ticket QR Aktif**, dapat membatalkan | Dapat melakukan **Check-In Tamu** |
| `aktif` | **Sedang Digunakan** | 🟢 Hijau Emerald (`#059669`) | Menampilkan sesi aktif & waktu mulai | Dapat melakukan **Check-Out Tamu** |
| `selesai` | **Selesai** | ⚪ Slate Gray (`#64748B`) | Tersimpan di Histori Transaksi | Tercatat di Laporan Finansial Bulanan |
| `dibatalkan` | **Dibatalkan** | 🔴 Merah Crimson (`#DC2626`) | Status arsip batal | Tidak dihitung dalam pendapatan bersih |

---

## 🏗️ Arsitektur Perangkat Lunak & Struktur Proyek

Aplikasi dibangun mengikuti standar industri **Clean Architecture** dengan pendekatan **Feature-First (Modular by Feature)**. Pola ini memastikan *separation of concerns*, independensi logika bisnis, kemudahan pengujian unit/widget, serta keteraturan kode:

```mermaid
flowchart TD
    subgraph ClientDevice["Aplikasi Mobile Flutter"]
        subgraph PresentationLayer["1. Presentation Layer (UI & State)"]
            Screens["Screens (Views)"]
            Widgets["Reusable Custom Widgets"]
            Controllers["Riverpod Controllers (StateNotifier)"]
        end
        
        subgraph DomainLayer["2. Domain Layer (Abstraksi Bisnis)"]
            ReposInterface["Repository Interfaces"]
            Entities["Entities & Value Objects"]
        end
        
        subgraph DataLayer["3. Data Layer (Sumber Data & DTO)"]
            DataSources["Remote DataSources (Dio REST API)"]
            Models["DTO Models (fromJson / toJson)"]
            ReposImpl["Repository Implementations"]
        end
        
        subgraph CoreLayer["Core Infrastructure"]
            Network["Dio Client + Header Interceptor"]
            Security["Secure Storage (Keystore/Keychain)"]
            Router["GoRouter + Role Guards"]
            Theme["Design Tokens (Colors, Typography)"]
        end
    end
    
    BackendAPI[("Panitia REST API Server\n(50 Endpoints)")]

    Screens --> Controllers
    Widgets --> Controllers
    Controllers --> ReposInterface
    ReposImpl .-> ReposInterface
    ReposImpl --> DataSources
    DataSources --> Network
    DataSources --> Models
    Network <--> BackendAPI
    Controllers --> Security
    Router --> Security
```

### Struktur Direktori Lengkap (`lib/`)

```
lib/
├── main.dart                                  # Titik masuk utama (ProviderScope + MaterialApp.router)
│
├── core/                                      # Fondasi Global & Utilitas Lintas Fitur
│   ├── errors/
│   │   ├── failure.dart                       # Domain Failure abstractions (ServerFailure, NetworkFailure, dll.)
│   │   └── exception_mapper.dart              # Pemetaan DioException -> Pesan kegagalan ramah pengguna
│   ├── network/
│   │   ├── api_endpoints.dart                 # Sumber kebenaran URL path 50 endpoint API
│   │   ├── api_header_interceptor.dart        # Interceptor otomatis (x-maker-key, Bearer Token, 401 Expiry)
│   │   └── dio_client.dart                    # Konfigurasi instance Dio HTTP Client dengan timeout 15s
│   ├── router/
│   │   └── app_router.dart                    # GoRouter dengan proteksi rute berbasis Role (Member vs Admin)
│   ├── storage/
│   │   └── secure_storage_service.dart        # Enkripsi sesi lokal via Android Keystore & iOS Keychain
│   ├── theme/
│   │   ├── app_colors.dart                    # Token warna terstandarisasi (Teal, Amber, Emerald, Slate)
│   │   ├── app_spacing.dart                   # Grid spasi konsisten (xs: 4dp, sm: 8dp, md: 12dp, lg: 16dp, xl: 24dp)
│   │   ├── app_typography.dart                # Tipografi Sora (Headings) & Inter (Body/Data Finansial)
│   │   └── app_theme.dart                     # Konfigurasi ThemeData Material 3
│   ├── utils/
│   │   ├── app_url_helper.dart                # Resolusi URL foto & normalisasi port backend otomatis
│   │   ├── currency_formatter.dart            # Pemformatan mata uang Rupiah Indonesia (Rp x.xxx.xxx)
│   │   ├── date_formatter.dart                # Pemformatan tanggal & jam Indonesia (WIB)
│   │   └── image_picker_helper.dart           # Pembungkus helper ImagePicker (Kamera & Galeri)
│   └── widgets/
│       ├── app_alert.dart                     # Banner notifikasi & toast kustom bergaya modern
│       ├── app_illustrations.dart             # Ilustrasi vektor kustom untuk state kosong/login
│       ├── app_photo_picker_field.dart        # Komponen interaktif pemilihan foto profil & space
│       ├── app_shimmer.dart                   # Komponen skeleton loading shimmer anti-blank
│       ├── auth_illustration.dart             # Ilustrasi adaptif role Member/Admin
│       ├── server_config_bottom_sheet.dart    # Modal dialog pengaturan dinamis Base URL & Maker Key
│       └── status_badge.dart                  # Badge status reservasi seragam di seluruh layar
│
└── features/                                  # Fitur Bisnis (Feature-First Architecture)
    ├── auth/                                  # Modul Autentikasi & Registrasi
    │   ├── data/
    │   │   ├── datasources/auth_remote_datasource.dart
    │   │   └── models/auth_models.dart        # UserModel, AuthSession, DTO Requests
    │   ├── domain/
    │   │   └── repositories/auth_repository.dart
    │   └── presentation/
    │       ├── providers/auth_controller.dart # State autentikasi, login, register, dan auto-logout
    │       └── screens/
    │           ├── login_screen.dart          # Layar login dwifungsi dengan pemilih role & server config
    │           ├── register_member_screen.dart# Formulir registrasi tamu/member
    │           └── register_admin_screen.dart # Formulir registrasi pengelola lokasi coworking
    │
    ├── spaces/                                # Modul Katalog & Reservasi Ruangan
    │   ├── data/
    │   │   ├── datasources/spaces_remote_datasource.dart
    │   │   └── models/space_models.dart       # SpaceModel, AvailabilityResult, PromoCheckResult
    │   ├── domain/
    │   │   └── repositories/spaces_repository.dart
    │   └── presentation/
    │       ├── providers/spaces_controller.dart
    │       └── screens/
    │           ├── spaces_catalog_screen.dart # Katalog ruang kerja dengan filter & pencarian
    │           └── space_detail_booking_screen.dart # Detail space, form booking, ketersediaan, promo
    │
    ├── reservations/                          # Modul Siklus Reservasi, Tiket & Histori
    │   ├── data/
    │   │   ├── datasources/reservations_remote_datasource.dart
    │   │   └── models/ (terpadu di domain/data)
    │   ├── domain/
    │   │   └── repositories/reservations_repository.dart
    │   └── presentation/
    │       ├── providers/reservations_controller.dart
    │       └── screens/
    │           ├── reservations_status_screen.dart  # Layar status reservasi aktif dengan tab filter
    │           ├── e_ticket_screen.dart             # Layar e-ticket resmi dengan QR Code scanner
    │           └── reservations_history_screen.dart # Histori reservasi dengan filter bulan & rekap
    │
    ├── member/                                # Modul Shell & Profil Pengunjung
    │   └── presentation/screens/
    │       ├── member_shell_screen.dart       # Navigasi utama member (4 Tab BottomNavigationBar)
    │       └── member_profile_screen.dart     # Profil member & ringkasan statistik akumulatif
    │
    └── admin/                                 # Modul Panel Pengelola Coworking
        ├── data/
        │   ├── datasources/admin_remote_datasource.dart
        │   └── models/admin_models.dart       # AdminProfile, AdminMember, AdminSpace, MonthlyReport
        ├── domain/
        │   └── repositories/admin_repository.dart
        ├── presentation/
        │   ├── providers/admin_controller.dart
        │   ├── widgets/
        │   │   ├── admin_stat_card.dart       # Kartu statistik metrik dashboard admin
        │   │   └── confirmation_dialog.dart   # Dialog konfirmasi aksi destruktif dua langkah
        │   └── screens/
        │       ├── admin_shell_screen.dart    # Navigasi utama admin (4 Tab BottomNavigationBar)
        │       ├── admin_dashboard_screen.dart# Dashboard ringkasan harian
        │       ├── admin_reservations_screen.dart # Manajemen reservasi masuk & filter
        │       ├── admin_reservation_detail_screen.dart # Detail reservasi, aksi konfirmasi/check-in/check-out
        │       ├── admin_master_data_screen.dart # Hub Master Data (Space, Member, Diskon)
        │       ├── admin_spaces_screen.dart   # CRUD Ruangan & upload foto
        │       ├── admin_members_screen.dart  # CRUD Member pengguna
        │       ├── admin_discounts_screen.dart# CRUD Kupon diskon/promo
        │       ├── admin_monthly_report_screen.dart # Rekapitulasi pendapatan & distribusi omzet
        │       └── admin_profile_screen.dart  # Profil lokasi & pengaturan coworking
```

---

## 📡 Matriks Kontrak API (50 Endpoint Lengkap)

Aplikasi telah diaudit secara ketat dan **100% patuh** terhadap seluruh 50 endpoint yang didefinisikan pada Postman Collection UKK Paket B:

<details open>
<summary><b>Klik untuk Melihat Matriks Lengkap 50 Endpoint API</b></summary>
<br>

| No | Modul / Folder | Method | URL Endpoint | Fungsi & Implementasi di Aplikasi |
|:---:|---|:---:|---|---|
| **1** | `0. Root & Health` | `GET` | `/` | Cek status server API panitia |
| **2** | `0. Root & Health` | `GET` | `/health` | Health check & pengujian latensi koneksi di `ServerConfigBottomSheet` |
| **3** | `1. App Maker` | `POST` | `/api/maker/register` | Pendaftaran App Maker tenant (penyedia `app_key`) |
| **4** | `1. App Maker` | `POST` | `/api/maker/login` | Login akun developer App Maker |
| **5** | `1. App Maker` | `GET` | `/api/maker/me` | Mengambil data identitas & `app_key` siswa aktif |
| **6** | `1. App Maker` | `GET` | `/api/maker/stats` | Ringkasan statistik data tenant App Maker |
| **7** | `1. App Maker` | `GET` | `/api/maker/list` | Daftar publik seluruh App Maker terdaftar |
| **8** | `2. Autentikasi` | `POST` | `/api/auth/register/member` | Registrasi akun Member / Tamu baru |
| **9** | `2. Autentikasi` | `POST` | `/api/auth/register/admin-space` | Registrasi pengelola coworking & admin baru |
| **10** | `2. Autentikasi` | `POST` | `/api/auth/login` | Login user (Member/Admin) & penerbitan Bearer Token |
| **11** | `2. Autentikasi` | `GET` | `/api/auth/profile` | Mengambil profil user yang sedang login |
| **12** | `3. Space Coworking` | `GET` | `/api/spaces/types` | Mengambil daftar kategori/tipe ruangan yang ada |
| **13** | `3. Space Coworking` | `GET` | `/api/spaces/availability` | Validasi slot ketersediaan ruangan sebelum pemesanan |
| **14** | `3. Space Coworking` | `GET` | `/api/spaces` | Katalog space dengan parameter pencarian dan filter tipe |
| **15** | `3. Space Coworking` | `GET` | `/api/spaces/:id` | Mengambil detail spesifik ruangan & fasilitas |
| **16** | `4. Diskon & Promo` | `GET` | `/api/diskon/active` | Mengambil daftar kupon diskon yang sedang aktif |
| **17** | `4. Diskon & Promo` | `POST` | `/api/diskon/check` | Validasi kode voucher & kalkulasi persentase diskon |
| **18** | `4. Diskon & Promo` | `GET` | `/api/diskon/:id` | Detail data kupon promo tertentu |
| **19** | `5. Reservasi Member` | `POST` | `/api/reservasi` | Pengajuan pembuatan reservasi sewa ruangan |
| **20** | `5. Reservasi Member` | `GET` | `/api/reservasi/my` | Daftar seluruh pemesanan milik member aktif |
| **21** | `5. Reservasi Member` | `GET` | `/api/reservasi/my/history` | Riwayat transaksi member bulanan & rekap biaya |
| **22** | `5. Reservasi Member` | `GET` | `/api/reservasi/:id/e-ticket` | Penerbitan data e-ticket resmi & payload QR Code |
| **23** | `5. Reservasi Member` | `GET` | `/api/reservasi/:id` | Detail lengkap satu data reservasi pemesan |
| **24** | `5. Reservasi Member` | `PATCH` | `/api/reservasi/:id/cancel` | Pembatalan pemesanan secara mandiri oleh Member |
| **25** | `6. Profil Lokasi Admin`| `GET` | `/api/admin/profile` | Mengambil data profil usaha coworking space |
| **26** | `6. Profil Lokasi Admin`| `PUT` | `/api/admin/profile` | Memperbarui informasi lokasi coworking space |
| **27** | `7. Manajemen Member` | `GET` | `/api/admin/members` | Mengambil daftar seluruh member terdaftar di space |
| **28** | `7. Manajemen Member` | `POST` | `/api/admin/members` | Menambahkan member baru dari portal admin |
| **29** | `7. Manajemen Member` | `GET` | `/api/admin/members/:id` | Detail lengkap data profil member |
| **30** | `7. Manajemen Member` | `PUT` | `/api/admin/members/:id` | Memperbarui data member dari portal admin |
| **31** | `7. Manajemen Member` | `DELETE`| `/api/admin/members/:id` | Menghapus akun member dari sistem |
| **32** | `8. Manajemen Space` | `GET` | `/api/admin/spaces` | Mengambil seluruh inventaris ruangan coworking |
| **33** | `8. Manajemen Space` | `POST` | `/api/admin/spaces` | Menambahkan unit ruangan baru ke inventaris |
| **34** | `8. Manajemen Space` | `GET` | `/api/admin/spaces/:id` | Detail data inventaris ruangan tertentu |
| **35** | `8. Manajemen Space` | `PUT` | `/api/admin/spaces/:id` | Memperbarui tarif, kapasitas, atau fasilitas ruangan |
| **36** | `8. Manajemen Space` | `DELETE`| `/api/admin/spaces/:id` | Menghapus ruangan dari inventaris coworking |
| **37** | `9. Manajemen Diskon` | `GET` | `/api/admin/diskon` | Mengambil daftar seluruh voucher promo yang dibuat |
| **38** | `9. Manajemen Diskon` | `POST` | `/api/admin/diskon` | Menerbitkan kupon voucher diskon baru |
| **39** | `9. Manajemen Diskon` | `GET` | `/api/admin/diskon/:id` | Mengambil detail satu data kupon promo |
| **40** | `9. Manajemen Diskon` | `PUT` | `/api/admin/diskon/:id` | Memperbarui besaran diskon & rentang masa berlaku |
| **41** | `9. Manajemen Diskon` | `DELETE`| `/api/admin/diskon/:id` | Menghapus voucher promo dari sistem |
| **42** | `10. Operasional Reservasi`| `GET` | `/api/admin/reservasi` | Filter reservasi masuk (status, space, tanggal) |
| **43** | `10. Operasional Reservasi`| `PATCH` | `/api/admin/reservasi/:id/status`| Konfirmasi status pesanan (`disetujui` / `dibatalkan`) |
| **44** | `10. Operasional Reservasi`| `POST` | `/api/admin/reservasi/:id/check-in` | Aksi **Check-In** pelanggan saat tiba di lokasi |
| **45** | `10. Operasional Reservasi`| `POST` | `/api/admin/reservasi/:id/check-out`| Aksi **Check-Out** saat sesi sewa ruangan selesai |
| **46** | `11. Laporan Pendapatan`| `GET` | `/api/admin/reports/monthly` | Laporan pendapatan bulanan, jam pakai & distribusi |
| **47** | `11. Laporan Pendapatan`| `GET` | `/api/admin/reports/income` | Ringkasan omzet / pendapatan alternatif (alias) |
| **48** | `12. Upload Media` | `POST` | `/api/upload/image` | Unggah file gambar umum via multipart form-data |
| **49** | `12. Upload Media` | `POST` | `/api/upload/spaces` | Unggah foto ruangan coworking via multipart form-data |
| **50** | `12. Upload Media` | `POST` | `/api/upload/members` | Unggah foto profil pengguna via multipart form-data |

</details>

---

## 🎨 Sistem Desain & Pengalaman Pengguna (UI/UX)

Antarmuka **Smart Space Booking** dirancang dengan standar ergonomi tinggi, kontras warna yang nyaman, serta mikro-interaksi halus yang memberikan kesan aplikasi profesional:

```
Palette Warna Utama:
┌─────────────────────────┐  ┌─────────────────────────┐  ┌─────────────────────────┐
│     Primary Teal        │  │     Deep Teal Dark      │  │       Surface Warm      │
│        #0E7C6B          │  │         #0A5C50         │  │         #FAF9F7         │
│   (Identitas Utama)     │  │     (Aksen Pengelola)   │  │   (Latar Belakang Halus)│
└─────────────────────────┘  └─────────────────────────┘  └─────────────────────────┘
```

### Token Desain Utama
* **Warna Semantik Status**:
  * 🟡 **Menunggu Konfirmasi**: Amber (`#D97706`) dengan latar lembut (`#FEF3C7`).
  * 🔵 **Disetujui**: Royal Blue (`#2563EB`) dengan latar lembut (`#DBEAFE`).
  * 🟢 **Aktif (Check-In)**: Emerald Green (`#059669`) dengan latar lembut (`#D1FAE5`).
  * ⚪ **Selesai**: Slate Gray (`#64748B`) dengan latar lembut (`#F1F5F9`).
  * 🔴 **Dibatalkan**: Crimson Red (`#DC2626`) dengan latar lembut (`#FEE2E2`).
* **Tipografi Modern (Google Fonts)**:
  * **Sora**: Digunakan untuk judul (*Headings*), *Brand Title*, dan komponen kartu sorotan demi impresi visual yang tegas dan berkarakter.
  * **Inter**: Digunakan untuk teks isi (*Body Text*), label formulir, serta angka finansial tabular agar data mudah dibaca dalam satu pandangan.
* **Pola UX Unggulan**:
  * **Skeleton Shimmer Loading**: Mencegah tampilan layar putih kosong (*blank white flash*) selama pemanggilan data ke API.
  * **Safe Network Image Resolver (`AppUrlHelper`)**: Mencegah aplikasi crash apabila server mengirimkan URL foto bertuliskan `localhost:3000` atau format nama file relatif.
  * **Konfirmasi Dua Langkah**: Aksi krusial seperti *Check-Out* tamu atau penghapusan data selalu diverifikasi lewat dialog konfirmasi modal.
  * **Toast Notifikasi Kustom (`AppAlert`)**: Notifikasi pop-up transparan dan informatif untuk setiap aksi berhasil atau gagal.

---

## 🔐 Keamanan, Multi-Tenancy & Resiliensi Sistem

1. **Multi-Tenancy Guard (`x-maker-key`)**:
   Setiap permintaan HTTP dari aplikasi secara otomatis disisipi header `x-maker-key` melalui [`ApiHeaderInterceptor`](lib/core/network/api_header_interceptor.dart). Hal ini menjamin isolasi data mutlak antar peserta ujian yang mengakses server bersama.
2. **Penyimpanan Sesi Terenkripsi Perangkat Keras**:
   Token akses JWT, data profil, dan pengaturan tersimpan di [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage) yang memanfaatkan **Android Keystore** (dengan enkripsi AES-GCM) dan **iOS Keychain**.
3. **Session Expiry Handler (401 Interceptor)**:
   Bila sesi login kedaluwarsa atau token dicabut di sisi server, interceptor secara otomatis menghapus token lokal dan mengembalikan pengguna ke layar login dengan notifikasi yang jelas tanpa menyebabkan *state corruption*.
4. **Proteksi Akses Berbasis Peran (RBAC GoRouter Guard)**:
   Sistem rute memverifikasi peran pengguna secara ketat:
   * Pengguna dengan role `member` tidak dapat membuka rute `/admin/*`.
   * Pengguna dengan role `admin_space` tidak dapat membuka rute `/member/*`.
   * Pengguna yang belum login otomatis diarahkan ke rute `/login`.
5. **Availability Pre-Submit Verification**:
   Sesaat sebelum pengajuan reservasi dikirim, aplikasi melakukan pemeriksaan ketersediaan instan ke `/api/spaces/availability` untuk mengeliminasi potensi bentrok jadwal akibat transaksi simultan.

---

## 🚀 Panduan Instalasi & Menjalankan Proyek

### Prasyarat Lingkungan Pengembangan
* **Flutter SDK**: Versi `>= 3.38.7` (Channel Stable)
* **Dart SDK**: Versi `>= 3.10.7`
* **Java Development Kit (JDK)**: JDK 17 atau yang kompatibel dengan Gradle Android terbaru
* **Android Studio / VS Code**: Terpasang plugin Flutter dan Dart
* Perangkat fisik Android (USB Debugging aktif) atau Android Emulator (API level 29+)

### Langkah Menjalankan Aplikasi

1. **Clone Repositori**:
   ```bash
   git clone https://github.com/username/bookingworkroom.git
   cd bookingworkroom
   ```

2. **Unduh Seluruh Dependensi**:
   ```bash
   flutter pub get
   ```

3. **Pengaturan URL API Server & App Key**:
   * **Opsi A (Melalui File Kode)**:
     Buka file [`lib/core/network/api_endpoints.dart`](lib/core/network/api_endpoints.dart) dan sesuaikan konstanta:
     ```dart
     static String baseUrl = 'https://learn.smktelkom-mlg.sch.id/coworking';
     ```
   * **Opsi B (Paling Praktis — Tanpa Edit Kode)**:
     Cukup jalankan aplikasi, lalu di layar Login ketuk ikon **Pengaturan Jaringan** (di pojok kanan atas) untuk memilih server (Production/Emulator/Localhost) dan memasukkan `x-maker-key` Anda.

4. **Jalankan Aplikasi**:
   ```bash
   # Menjalankan di perangkat atau emulator yang terhubung
   flutter run
   ```

---

## 📦 Panduan Build APK Siap Rilis (Distribution)

Untuk kebutuhan demonstrasi, evaluasi juri, atau instalasi langsung ke perangkat penguji, Anda dapat menghasilkan file APK rilis:

```bash
# 1. Menghasilkan Universal Release APK (Dapat dipasang di semua arsitektur Android)
flutter build apk --release

# 2. ATAU menghasilkan Split APK per ABI (Ukuran file jauh lebih kecil dan cepat diinstal)
flutter build apk --split-per-abi
```

### Lokasi Hasil Output File APK:
* **Universal APK**:
  ```
  build/app/outputs/flutter-apk/app-release.apk
  ```
* **Split ABI APK**:
  ```
  build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
  build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
  build/app/outputs/flutter-apk/app-x86_64-release.apk
  ```

---

## 🧪 Jaminan Kualitas & Pengujian Otomatis (QA)

Kualitas kode proyek ini dijaga dengan pengujian berlapis (*Static Analysis*, *Unit Testing*, *Widget Testing*, dan *Regression Testing*):

```bash
# Menjalankan Static Code Analyzer (Hasil: 0 Issues / Bebas Warning)
flutter analyze

# Menjalankan Seluruh 48 Automated Tests
flutter test
```

### Ringkasan Hasil Uji Otomatis (48/48 Passed — 100%)

| Berkas Pengujian | Jenis Pengujian | Jumlah Test | Status |
|---|---|:---:|:---:|
| [`test/admin_test.dart`](test/admin_test.dart) | Widget & Model Testing Modul Admin (Dashboard, Master Data, Report, Shell) | 16 Tests | 🟢 **PASSED** |
| [`test/business_logic_qa_test.dart`](test/business_logic_qa_test.dart) | Logika Bisnis, Login Tanpa Bypass, 401 Force Logout, Pre-check Availability | 8 Tests | 🟢 **PASSED** |
| [`test/detail_space_qa_regression_test.dart`](test/detail_space_qa_regression_test.dart) | Regresi Detail Space, Normalisasi URL Foto, Penanganan Missing JSON Keys | 8 Tests | 🟢 **PASSED** |
| [`test/widget_test.dart`](test/widget_test.dart) | Smoke Tests & UI Rendering (Catalog, Booking Form, E-Ticket QR, Filter Histori) | 16 Tests | 🟢 **PASSED** |
| **TOTAL** | **Seluruh Cakupan Pengujian Sistem** | **48 Tests** | 🟢 **ALL PASSED** |

---

## 🎯 Panduan Pengujian Cepat untuk Penguji (Cheatsheet UKK)

Untuk memudahkan Bapak/Ibu Guru Penguji dalam menilai fungsionalitas aplikasi selama sesi ujian praktik, ikuti panduan 8 langkah evaluasi cepat di bawah ini:

```
Skenario Pengujian Cepat 5 Menit:
1. Konfigurasi Server  ──► 2. Registrasi / Login  ──► 3. Cek Ketersediaan Space
        │                                                     │
        ▼                                                     ▼
6. Check-In & Check-Out ◄── 5. Verifikasi Admin   ◄── 4. Booking & E-Ticket QR
        │
        ▼
7. Laporan Finansial   ──► 8. Master Data CRUD
```

1. **Uji Konfigurasi Dinamis**:
   * Di layar Login, ketuk ikon pengaturan di pojok kanan atas.
   * Pilih preset server panitia atau ketik URL lokal. Ketuk **Uji Koneksi** untuk memvalidasi respons status `200 OK`.
2. **Uji Autentikasi Member**:
   * Ketuk tab **Member**, pilih tautan **Daftar Akun**.
   * Isi nama, instansi, nomor telepon, username, password, dan foto profil.
   * Setelah berhasil terdaftar, lakukan login ke portal Member.
3. **Uji Cek Ketersediaan (*Availability Engine*)**:
   * Masuk ke **Katalog**, pilih salah satu ruangan (*Meeting Room* / *Personal Desk*).
   * Masukkan tanggal hari ini, jam mulai, dan durasi sewa.
   * Ketuk tombol **Cek Ketersediaan**. Perhatikan indikator ketersediaan slot yang tampil secara *real-time*.
4. **Uji Kode Promo & Pemesanan**:
   * Masukkan kode voucher diskon yang masih berlaku.
   * Perhatikan kalkulasi rincian biaya: Subtotal, Potongan Diskon, dan Total Bayar.
   * Tekan tombol **Buat Reservasi**. Sistem otomatis melakukan pengecekan ganda ketersediaan sebelum menyimpan data.
5. **Uji E-Ticket & QR Code**:
   * Buka tab **Status Pemesanan**. Pesanan baru akan berstatus `Menunggu`.
   * Setelah disetujui admin, ketuk kartu reservasi untuk membuka **E-Ticket**.
   * Pastikan kode booking dan QR Code barcode tampil jelas untuk dipindai.
6. **Uji Operasional Admin (Konfirmasi & Check-In)**:
   * Logout dari akun Member, lalu beralih ke tab **Pengelola Space** di layar login.
   * Masuk ke akun Admin Coworking. Pada dashboard operasional, buka daftar reservasi.
   * Ketuk pesanan member tadi: lakukan aksi **Setujui**.
   * Saat tamu tiba, tekan tombol **Check-In** (status berubah menjadi `aktif`).
7. **Uji Operasional Admin (Check-Out Aman)**:
   * Pada detail reservasi aktif, tekan tombol **Check-Out**.
   * Dialog konfirmasi dua langkah akan muncul. Konfirmasikan aksi (status berubah menjadi `selesai`).
8. **Uji Laporan Finansial & Master Data**:
   * Buka tab **Laporan**. Periksa kalkulasi otomatis omzet kotor, total potongan promo, dan omzet bersih bulan berjalan.
   * Amati visualisasi proporsi pendapatan per tipe ruangan.
   * Buka tab **Master Data** untuk mencoba CRUD Member, CRUD Ruangan (termasuk upload foto ruangan), dan CRUD Kupon Diskon.

---

<div align="center">
  <sub>Aplikasi ini dikembangkan untuk memenuhi penilaian:</sub><br>
  <b>Uji Kompetensi Keahlian (UKK) Rekayasa Perangkat Lunak Tahun Ajaran 2026/2027</b><br>
  <b>SMK Telkom Malang — Pelopor Pendidikan Vokasi Berbasis Teknologi</b>
</div>
