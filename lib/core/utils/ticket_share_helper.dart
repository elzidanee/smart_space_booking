import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/spaces/data/models/space_models.dart';
import 'currency_formatter.dart';
import 'date_formatter.dart';

/// Helper untuk membagikan E-Ticket dan QR Code ke aplikasi lain (WhatsApp, Telegram, Gmail, dll)
/// Cara kerja di HP:
/// 1. Render barcode QR Code ke dalam bentuk berkas gambar PNG secara otomatis di memori HP.
/// 2. Simpan sementara gambar QR tersebut ke folder cache HP.
/// 3. Buka jendela ShareSheet bawaan Android / iOS lengkap dengan gambar QR Code dan teks detail tiket.
class TicketShareHelper {
  TicketShareHelper._();

  static Future<bool> shareTicket({
    required BuildContext context,
    required ReservationModel ticket,
  }) async {
    try {
      DateTime? parsedDate;
      try {
        parsedDate = DateTime.parse(ticket.tanggal);
      } catch (_) {}

      final dateDisplay = parsedDate != null
          ? DateFormatter.formatFullDate(parsedDate)
          : ticket.tanggal;

      // 1. Susun teks keterangan tiket yang rapi dan mudah dibaca
      final shareText = '''
🎫 E-TICKET SMART SPACE BOOKING
━━━━━━━━━━━━━━━━━━━━━━━━━━
🏢 Ruangan: ${ticket.namaSpace ?? 'Coworking Space'}
📌 Kode Booking: ${ticket.kodeBooking}
📅 Tanggal: $dateDisplay
⏰ Jam: ${ticket.jamMulai} - ${ticket.jamSelesai} WIB (${ticket.durasi} Jam)
👤 Nama Pemesan: ${ticket.namaMember ?? 'Member Smart Space'}
💰 Total Biaya: ${CurrencyFormatter.format(ticket.totalBayar)}
━━━━━━━━━━━━━━━━━━━━━━━━━━
Tunjukkan gambar QR Code terlampir ke resepsionis saat tiba di lokasi untuk proses check-in.
''';

      // 2. Render gambar QR Code menggunakan QrPainter beresolusi tinggi (600x600 px)
      // Menggunakan warna hitam pekat di atas modul kotak agar mudah di-scan scanner resepsionis
      final painter = QrPainter(
        data: ticket.kodeBooking,
        version: QrVersions.auto,
        gapless: true,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Color(0xFF1C1917),
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Color(0xFF1C1917),
        ),
      );

      final picData = await painter.toImageData(600.0, format: ui.ImageByteFormat.png);

      // Bounding box untuk posisi pop-up share di tablet / iPad
      Rect? sharePositionOrigin;
      if (context.mounted) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          sharePositionOrigin = box.localToGlobal(Offset.zero) & box.size;
        }
      }

      // Kalau render gambar berhasil, kirim berkas gambar PNG + teks keterangan tiket
      if (picData != null) {
        final bytes = picData.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final cleanKode = ticket.kodeBooking.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
        final filePath = '${tempDir.path}/QR_$cleanKode.png';
        final file = File(filePath);
        await file.writeAsBytes(bytes, flush: true);

        final xFile = XFile(file.path, mimeType: 'image/png');

        final result = await SharePlus.instance.share(
          ShareParams(
            files: [xFile],
            text: shareText,
            subject: 'E-Ticket Reservasi #${ticket.kodeBooking}',
            sharePositionOrigin: sharePositionOrigin,
          ),
        );

        return result.status != ShareResultStatus.dismissed;
      } else {
        // Fallback: jika device gagal render byte PNG, bagikan teks tiket saja
        await SharePlus.instance.share(
          ShareParams(
            text: shareText,
            subject: 'E-Ticket Reservasi #${ticket.kodeBooking}',
            sharePositionOrigin: sharePositionOrigin,
          ),
        );
        return true;
      }
    } catch (e) {
      // Fallback kedua: teks sederhana jika terjadi kendala sistem
      try {
        await SharePlus.instance.share(
          ShareParams(
            text: 'E-Ticket Smart Space: ${ticket.kodeBooking} (${ticket.namaSpace ?? "Coworking Space"})',
            subject: 'E-Ticket ${ticket.kodeBooking}',
          ),
        );
        return true;
      } catch (_) {
        return false;
      }
    }
  }
}
