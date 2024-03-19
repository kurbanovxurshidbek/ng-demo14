import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:ngdemo14/models/response/cat_list_res.dart';
import 'package:ngdemo14/models/response/cat_upload_res.dart';
import 'package:ngdemo14/services/log.service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

//https://api.thecatapi.com/v1/images/?limit=20&page=0&order=DESC
//https://api.thecatapi.com/v1/images/upload

class Network {
  static bool isTester = true;
  static String SERVER_DEV = "api.thecatapi.com";
  static String SERVER_PROD = "api.thecatapi.com";
  static String API_KEY = "live_25MQkrVdHQyw0AcUzRc7yxgCV3hG5Wvt0XcYPPFlJHEj7a8zS6YfEed4jkO6p6cB";

  static String getServer() {
    if (isTester) return SERVER_DEV;
    return SERVER_PROD;
  }

  static Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'x-api-key': API_KEY
  };

  /* Http Requests */
  static Future<String?> GET(String api, Map<String, String> params) async {
    var uri = Uri.https(getServer(), api, params);
    var response = await get(uri, headers: headers);
    if (response.statusCode == 200) {
      return response.body;
    }
    return null;
  }

  static Future<String?> POST(String api, Map<String, String> params) async {
    var uri = Uri.https(getServer(), api);
    var response = await post(uri, headers: headers, body: jsonEncode(params));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    }
    return null;
  }

  static Future<String?> PUT(String api, Map<String, String> params) async {
    var uri = Uri.https(getServer(), api);
    var response = await put(uri, headers: headers, body: jsonEncode(params));
    if (response.statusCode == 200) {
      return response.body;
    }
    return null;
  }

  static Future<String?> DEL(String api, Map<String, String> params) async {
    var uri = Uri.https(getServer(), api, params);
    var response = await delete(uri, headers: headers);
    if (response.statusCode == 200) {
      return response.body;
    }
    return null;
  }

  static Future<String?> MUL(
      String api, File file, Map<String, String> params) async {
    var uri = Uri.https(getServer(), api); // http or https
    var request = MultipartRequest('POST', uri);
    request.headers['x-api-key'] = API_KEY;
    request.headers['Content-Type'] = 'multipart/form-data';
    String filename = file.path.split("/").last;
    LogService.i(filename);

    request.files.add(
      http.MultipartFile(
        'file',
        file.readAsBytes().asStream(),
        file.lengthSync(),
        filename: filename,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    request.fields.addAll(params);

    StreamedResponse streamedResponse = await request.send();
    var response = await Response.fromStream(streamedResponse);
    if (response.statusCode == 201) {
      return response.body;
    }
    return null;
  }

  /* Http Apis*/
  static String API_CAT_LIST = "/v1/images";
  static String API_CAT_UPLOAD = "/v1/images/upload";

  /* Http Params */
  static Map<String, String> paramsEmpty() {
    Map<String, String> params = Map();
    return params;
  }

  //limit=20&page=0&order=DESC
  static Map<String, String> paramsCatList() {
    Map<String, String> params = new Map();
    params.addAll({'limit': "20", 'page': "0", 'order': "DESC"});
    return params;
  }

/* Http Parsing */

  static List<CatListRes> parseCatList(String response) {
    dynamic json = jsonDecode(response);
    return List<CatListRes>.from(json.map((x) => CatListRes.fromJson(x)));
  }

  static CatUploadRes parseCatUpload(String response) {
    dynamic json = jsonDecode(response);
    return CatUploadRes.fromJson(json);
  }
}
