// Picks the browser implementation on web, a simple fallback elsewhere.
export 'file_download_stub.dart'
    if (dart.library.html) 'file_download_web.dart';
