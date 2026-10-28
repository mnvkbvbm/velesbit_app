import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import '../../../core/services/github_update_service.dart';

class OtaDownloadDialog extends StatefulWidget {
  final String downloadUrl;
  final String fallbackHtmlUrl;

  const OtaDownloadDialog({
    super.key,
    required this.downloadUrl,
    required this.fallbackHtmlUrl,
  });

  @override
  State<OtaDownloadDialog> createState() => _OtaDownloadDialogState();
}

class _OtaDownloadDialogState extends State<OtaDownloadDialog> {
  String _statusText = 'Güncelleme paketi indiriliyor...';
  double _progressValue = 0.0;
  bool _isDownloading = true;
  bool _hasError = false;
  StreamSubscription<OtaEvent>? _otaSubscription;

  @override
  void initState() {
    super.initState();
    _startOtaUpdate();
  }

  void _startOtaUpdate() {
    try {
      _otaSubscription = OtaUpdate().execute(
        widget.downloadUrl,
        destinationFilename: 'velesbit_update.apk',
      ).listen(
        (OtaEvent event) {
          if (!mounted) return;

          setState(() {
            switch (event.status) {
              case OtaStatus.DOWNLOADING:
                _isDownloading = true;
                _hasError = false;
                final int progress = int.tryParse(event.value ?? '0') ?? 0;
                _progressValue = progress / 100.0;
                _statusText = '📥 APK İndiriliyor: %$progress';
                break;
              case OtaStatus.INSTALLING:
                _isDownloading = false;
                _hasError = false;
                _statusText = '⚙️ Paket Yükleyici Başlatılıyor...\nLütfen açılan ekranda "Güncelle" veya "İzin Ver" seçeneğine basın.';
                break;
              case OtaStatus.ALREADY_RUNNING_ERROR:
                _statusText = 'İndirme zaten arka planda devam ediyor.';
                break;
              case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
                _hasError = true;
                _isDownloading = false;
                _statusText = '⚠️ Bilinmeyen Kaynaklardan Yükleme İzni Verilmedi.\nLütfen ayarlardan yüklemeye izin verin.';
                break;
              case OtaStatus.INTERNAL_ERROR:
              case OtaStatus.DOWNLOAD_ERROR:
              case OtaStatus.CHECKSUM_ERROR:
              default:
                _hasError = true;
                _isDownloading = false;
                _statusText = '⚠️ Doğrudan APK indirmede hata oluştu. Tarayıcı ile indirmeyi deneyebilirsiniz.';
                break;
            }
          });
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _hasError = true;
            _isDownloading = false;
            _statusText = '⚠️ Hata oluştu: Tarayıcıdan indirmeyi deneyin.';
          });
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isDownloading = false;
          _statusText = '⚠️ Otomatik yükleyici başlatılamadı. Tarayıcı seçeneğini kullanın.';
        });
      }
    }
  }

  @override
  void dispose() {
    _otaSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _hasError ? Icons.error_outline_rounded : Icons.system_update_rounded,
                color: _hasError ? Colors.redAccent : theme.colorScheme.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              _hasError ? 'Güncelleme İkazı' : 'Velesbit Güncelleniyor',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),

            Text(
              _statusText,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),

            if (_isDownloading) ...[
              LinearProgressIndicator(
                value: _progressValue > 0 ? _progressValue : null,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
                color: theme.colorScheme.primary,
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(height: 12),
              Text(
                '${(_progressValue * 100).toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_hasError)
                  ElevatedButton.icon(
                    onPressed: () {
                      GithubUpdateService.launchDownload(widget.fallbackHtmlUrl);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                    label: const Text('Tarayıcıda Aç & İndir'),
                  )
                else if (!_isDownloading)
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kapat'),
                  )
                else
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('İptal Et', style: TextStyle(color: Colors.grey)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
