// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Fetches [url] with real progress, then saves it as [fileName]
/// (the browser starts a normal file download).
Future<void> downloadFile(
  String url,
  String fileName, {
  void Function(double progress)? onProgress,
}) async {
  final request = await html.HttpRequest.request(
    url,
    responseType: 'blob',
    onProgress: (e) {
      final total = e.total ?? 0;
      if (e.lengthComputable && total > 0) {
        onProgress?.call((e.loaded ?? 0) / total);
      }
    },
  );
  onProgress?.call(1);

  final blob = request.response as html.Blob;
  final blobUrl = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: blobUrl)
    ..download = fileName
    ..style.display = 'none';
  html.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  // Give the browser a moment to start the download before freeing the URL.
  Future.delayed(const Duration(seconds: 2), () {
    html.Url.revokeObjectUrl(blobUrl);
  });
}
