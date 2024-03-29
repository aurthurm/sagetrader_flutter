import 'dart:convert';

import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/config/conf.dart';
import 'package:msagetrader/models/file.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

String token;
final String uploadsHandlerURI = serverURI + "mspt/uploads-handler";
final String cloudinaryURI = serverURI + "mspt/cloudinary";
final String filesFetchURI = serverURI + "mspt/fetch-files";
final String deleteFileURI = serverURI + "mspt/delete-file";



class BaseFiles with ChangeNotifier {
  bool loading = true;
  List<FileData> _files = <FileData>[];

  List<FileData> get files => _files;

  Future<void> clearAll() async {
    await Future.delayed(Duration(seconds: 1)).then((_) {
      _files.clear();
    });
    notifyListeners();
  }

  FileData findById(String id) {
    final index = files.indexWhere((file) => file.uid == id);
    if(index == -1) {
      return null;
    }
    return files[index];
  }

  void addFiles(List<FileData> files) {
    files.forEach((item) => _files.add(item));
    notifyListeners();
  }

  void clearFiles() {
    _files.clear();
  }

}

class Files extends BaseFiles  {

  Future<void> deleteFile(String parent, String fileId) async {
    loading = true;
    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.delete(
      Uri.parse(deleteFileURI + "/$parent-$fileId"),
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      _files.removeWhere((file) => file.uid == fileId);
    } else if (response.statusCode == 401) {
      final String message = json.decode(response.body)['detail'];
      throw Exception("(${response.statusCode}): $message");
    } else {
      throw Exception("(${response.statusCode}): ${response.body}");
    }
    loading = false;
    notifyListeners();
    //
  }

  Future<void> fetchFiles(String parent, String parentId) async {
    loading = true;
    clearFiles();
    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.get(
      Uri.parse(filesFetchURI + "/$parent-$parentId"),
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      responseData.forEach((item) => _files.add(FileData.fromJson(item)));
    } else if (response.statusCode == 401) {
      final String message = json.decode(response.body)['detail'];
      throw Exception("(${response.statusCode}): $message");
    } else {
      throw Exception("(${response.statusCode}): ${response.body}");
    }
    loading = false;
    notifyListeners();
    //
  }

  Future uploadFiles(
    List<FileData> images, String parent, String parentId, dynamic tags, String caption) async {
    loading = true;
    await MSPTAuth().getToken().then((String value) => {token = value});

    http.MultipartFile _multipartFile;
    Uri uri = Uri.parse(uploadsHandlerURI);
    http.MultipartRequest request = http.MultipartRequest("POST", uri);
    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Content-Type": "multipart/form-data"
    });

    images.forEach((FileData imageData) => {
          _multipartFile = http.MultipartFile.fromBytes(
            'files',
            imageData.bytes,
            filename: '${DateTime.now().microsecondsSinceEpoch.toString()}.jpg',
            contentType: MediaType("image", "jpg"),
          ),
          request.files.add(_multipartFile)
        });

    request.fields['parent'] = "$parent-$parentId";
    request.fields['parentUid'] = parentId;
    request.fields['tags'] = tags.join(", ");
    request.fields['caption'] = caption;
    var _response = await request.send();
    http.Response.fromStream(_response)
    .then((res) {
      if (res.statusCode == 200) {
        List<dynamic> responseData = json.decode(res.body);
        responseData.forEach((item) => _files.add(FileData.fromJson(item)));
        loading = false;
        notifyListeners();
      } else {
        loading = false;
        notifyListeners();
        throw Exception("An error occured ${res.body.toString()}");
      }
    });
  }
}

