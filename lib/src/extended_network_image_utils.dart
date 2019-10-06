import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

const String CacheImageFolderName = "cacheimage";

String keyToMd5(String key) => md5.convert(utf8.encode(key)).toString();

/// clear the disk cache directory then return if it succeed.
///  <param name="duration">timespan to compute whether file has expired or not</param>
Future<bool> clearDiskCachedImages({Duration duration}) async {
  try {
    Directory _cacheImagesDirectory = Directory(
        join((await getTemporaryDirectory()).path, CacheImageFolderName));
    if (_cacheImagesDirectory.existsSync()) {
      if (duration == null) {
        _cacheImagesDirectory.deleteSync(recursive: true);
      } else {
        var now = DateTime.now();
        for (var file in _cacheImagesDirectory.listSync()) {
          FileStat fs = file.statSync();
          if (now.subtract(duration).isAfter(fs.changed)) {
            //print("remove expired cached image");
            file.deleteSync(recursive: true);
          }
        }
      }
    }
  } catch (_) {
    return false;
  }
  return true;
}

/// clear the disk cache image then return if it succeed.
///  <param name="url">clear specific one</param>
Future<bool> clearDiskCachedImage(String url) async {
  try {
    var file = await getCachedImageFile(url);
    if(file!=null){
      file.delete( recursive: true );
    }
  } catch (_) {
    return false;
  }
  return true;
}

///get the local file of the cached image

Future<File> getCachedImageFile(String url) async {
  try {
    var key = keyToMd5( url );
    Directory _cacheImagesDirectory = Directory(
        join( (await getTemporaryDirectory( )).path, CacheImageFolderName ) );
    if (_cacheImagesDirectory.existsSync( )) {
      for (var file in _cacheImagesDirectory.listSync( )) {
        if (file.path.endsWith(key)) {
          return file;
        }
      }
    }
  } catch (_) {
    return null;
  }
  return null;
}


///clear all of image in memory
void clearMemoryImageCache() {
  PaintingBinding.instance.imageCache.clear();
}

/// get ImageCache
ImageCache getMemoryImageCache() {
  return PaintingBinding.instance.imageCache;
}

//List<ExtendedNetworkImageProvider> pendingImages =
//    List<ExtendedNetworkImageProvider>();

//void cancelPendingNetworkImageByToken(CancellationToken cancelToken,
//    {bool takeCareSameUrl: true}) {
//  if (cancelToken == null) return;
//
//  if (!takeCareSameUrl) cancelToken.cancel();
//
//  pendingImages
//      .where((image) => image.cancelToken == cancelToken)
//      ?.forEach((f) {
//    cancelPendingNetworkImageByProvider(f, takeCareSameUrl: takeCareSameUrl);
//  });
//}
//
//void cancelPendingNetworkImageByProvider(ExtendedNetworkImageProvider provider,
//    {bool takeCareSameUrl: true}) {
//  if (provider == null) return;
//
//  if (!takeCareSameUrl) provider.cancelToken?.cancel();
//
//  ///find the same image(url,scale) with different cancel token
//  var pendingImageList = pendingImages.where((image) =>
//      image == provider && image.cancelToken != provider.cancelToken);
//
//  if (pendingImageList.length > 0) {
//    pendingImageList.forEach((image) {
//      ///may it has no cancel token, or the request is not canceled
//      bool shouldCancel = image.cancelToken?.isCanceled == true;
//      print(shouldCancel);
//
//      ///if any one is not cancel break, this image should not be canceled.
//      if (!shouldCancel) return;
//    });
//  }
//  provider.cancelToken?.cancel();
//}

//void cancelPendingNetworkImageByUrl(String url, {bool takeCareSameUrl: true}) {
//  if (url == null) false;
//
//  pendingImages.where((image) => image.url == url).forEach((f) {
//    cancelPendingNetworkImageByProvider(f, takeCareSameUrl: takeCareSameUrl);
//  });
//}
