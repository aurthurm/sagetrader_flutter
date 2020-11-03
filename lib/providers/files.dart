import 'dart:convert';

import 'package:msagetrader/auth/auth.dart';
import 'package:msagetrader/config/conf.dart';
import 'package:msagetrader/models/file.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

String token;
final String uploadsHandlerURI = serverURI + "mspt/uploads-handler";
final String filesFetchURI = serverURI + "mspt/fetch-files";
final String deleteFileURI = serverURI + "mspt/delete-file";

class Files with ChangeNotifier {
  bool loading = true;
  List<FileData> _files = <FileData>[];

  List<FileData> get files => _files;

  FileData findById(String id) {
    final index = files.indexWhere((file) => file.id == id);
    return files[index];
  }

  void addFiles(List<FileData> files) {
    files.forEach((item) => _files.add(item));
    notifyListeners();
  }

  void clearFiles() {
    _files.clear();
  }

  Future<void> deleteFile(String parent, String fileId) async {
    loading = true;
    await MSPTAuth().getToken().then((String value) => token = value);
    final response = await http.delete(
      deleteFileURI + "/$parent-$fileId",
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      _files.removeWhere((file) => file.id == fileId);
    } else if (response.statusCode == 401) {
      final String message = json.decode(response.body)['detail'];
      Exception("(${response.statusCode}): $message");
    } else {
      Exception("(${response.statusCode}): ${response.body}");
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
      filesFetchURI + "/$parent-$parentId",
      headers: bearerAuthHeader(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      responseData.forEach((item) => _files.add(FileData.fromJson(item)));
    } else if (response.statusCode == 401) {
      final String message = json.decode(response.body)['detail'];
      Exception("(${response.statusCode}): $message");
    } else {
      Exception("(${response.statusCode}): ${response.body}");
    }
    loading = false;
    notifyListeners();
    //
  }

  Future uploadFiles(
      List<FileData> images, String parent, String parentId) async {
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
    request.fields['parentId'] = parentId;
    var _response = await request.send();
    // print(_response.reasonPhrase);
    // print(_response.statusCode);
    http.Response.fromStream(_response)
        .then((_) => fetchFiles(parent, parentId));
  }
}
