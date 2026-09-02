import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Modal dialog untuk pengaturan dinamis Server URL & Maker App Key (QA-014)
class ServerConfigBottomSheet extends ConsumerStatefulWidget {
  const ServerConfigBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const ServerConfigBottomSheet(),
    );
  }

  @override
  ConsumerState<ServerConfigBottomSheet> createState() => _ServerConfigBottomSheetState();
}

class _ServerConfigBottomSheetState extends ConsumerState<ServerConfigBottomSheet> {
  final _urlController = TextEditingController();
  final _keyController = TextEditingController();
  bool _isLoading = true;
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storage = ref.read(secureStorageServiceProvider);
    final customUrl = await storage.readBaseUrl();
    final appKey = await storage.readAppKey();

    _urlController.text = customUrl ?? ApiEndpoints.baseUrl;
    _keyController.text = appKey ?? '';

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final dio = ref.read(dioClientProvider);
      final testUrl = _urlController.text.trim();
      final key = _keyController.text.trim();

      final res = await dio.get(
        '$testUrl/health',
        options: key.isNotEmpty ? Options(headers: {'x-maker-key': key}) : null,
      );

      if (mounted) {
        setState(() {
          _isTesting = false;
          _testSuccess = true;
          _testResult = 'Koneksi Berhasil! Server siap (${res.statusCode})';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTesting = false;
          _testSuccess = false;
          _testResult = 'Gagal terhubung: $e';
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    final storage = ref.read(secureStorageServiceProvider);
    final url = _urlController.text.trim();
    final key = _keyController.text.trim();

    if (url.isNotEmpty && url != ApiEndpoints.baseUrl) {
      await storage.saveBaseUrl(url);
    } else {
      await storage.deleteBaseUrl();
    }

    if (key.isNotEmpty) {
      await storage.saveAppKey(key);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfigurasi server berhasil disimpan!'),
          backgroundColor: AppColors.secondary,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _resetToDefault() async {
    final storage = ref.read(secureStorageServiceProvider);
    await storage.deleteBaseUrl();
    _urlController.text = ApiEndpoints.baseUrl;

    if (mounted) {
      setState(() {
        _testResult = 'URL di-reset ke default panitia.';
        _testSuccess = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.settings_ethernet, color: AppColors.secondary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text('Konfigurasi Server & Key', style: AppTypography.h3),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Sesuaikan URL server API atau kunci Maker (x-maker-key) saat ujian.',
              style: AppTypography.caption.copyWith(color: AppColors.ink600),
            ),
            const SizedBox(height: 16),

            // API Base URL Field
            Text('API Server Base URL:', style: AppTypography.captionMedium),
            const SizedBox(height: 6),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'https://learn.smktelkom-mlg.sch.id/coworking',
                filled: true,
                fillColor: AppColors.surface50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),

            // Maker App Key Field
            Text('Maker App Key (x-maker-key):', style: AppTypography.captionMedium),
            const SizedBox(height: 6),
            TextField(
              controller: _keyController,
              decoration: InputDecoration(
                hintText: 'Masukkan kunci maker Anda...',
                filled: true,
                fillColor: AppColors.surface50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            // Test Status Banner
            if (_testResult != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _testSuccess ? AppColors.secondaryContainer : const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _testSuccess ? AppColors.secondary : AppColors.danger,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testSuccess ? Icons.check_circle : Icons.error_outline,
                      color: _testSuccess ? AppColors.secondary : AppColors.danger,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _testResult!,
                        style: AppTypography.captionMedium.copyWith(
                          color: _testSuccess ? AppColors.secondary : AppColors.danger,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Test Connection & Reset Buttons
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: OutlinedButton.icon(
                    onPressed: _isTesting ? null : _testConnection,
                    icon: _isTesting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.network_check, size: 16),
                    label: const Text('Tes Koneksi'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: _resetToDefault,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Reset Default'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simpan Pengaturan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
