import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
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
  http.Client? _client;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    try {
      _client = http.Client();
      final request = http.Request('GET', Uri.parse(widget.downloadUrl));
      final response = await _client!.send(request);

      if (response.statusCode == 200 || response.statusCode == 302) {
        final totalBytes = response.contentLength ?? 55000000;
        int downloadedBytes = 0;

        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/Velesbit_Update.apk';
        final file = File(filePath);
        final sink = file.openWrite();

        response.stream.listen(
          (chunk) {
            if (!mounted) return;
            downloadedBytes += chunk.length;
            sink.add(chunk);

            final progress = (downloadedBytes / totalBytes).clamp(0.0, 1.0);
            setState(() {
              _progressValue = progress;
              _statusText = '📥 APK İndiriliyor: %${(progress * 100).toStringAsFixed(0)}';
            });
          },
          onDone: () async {
            await sink.close();
            if (!mounted) return;

            setState(() {
              _isDownloading = false;
              _progressValue = 1.0;
              _statusText = '⚙️ Paket Yükleyici Başlatılıyor...\nLütfen açılan istemde "İzin Ver" ve "Güncelle" seçeneğine basın.';
            });

            // Open Android Native Package Installer via FileProvider!
            final result = await OpenFilex.open(filePath);
            if (result.type != ResultType.done) {
              setState(() {
                _hasError = true;
                _statusText = '⚠️ Paket kurucu çalıştırılamadı: ${result.message}\nTarayıcı seçeneğini kullanabilirsiniz.';
              });
            }
          },
          onError: (error) async {
            await sink.close();
            if (!mounted) return;
            setState(() {
              _hasError = true;
              _isDownloading = false;
              _statusText = '⚠️ İndirme esnasında hata oluştu. Tarayıcı seçeneğini kullanın.';
            });
          },
          cancelOnError: true,
        );
      } else {
        throw Exception('HTTP Status ${response.statusCode}');
      }
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
    _client?.close();
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
