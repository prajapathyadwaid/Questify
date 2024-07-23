import 'package:http/http.dart' as http;
import 'dart:convert';

Future processPdf(path) async {
  var url = parse('http://127.0.0.1:5000/', 'pdf', path);
  http.Response response;
  try {
    response = await http.get(url);
  } catch (e) {
    return "error1";
  }

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    if (data == 'error') {
      return 'error2';
    }
    return data;
  } else {
    return 'error3 ${response.statusCode}';
  }
}

Future answer(question) async {
  var url = parse('http://127.0.0.1:5000/run_model/', 'question', question);
  http.Response response;
  try {
    response = await http.get(url);
  } catch (e) {
    return "The remote computer refused the network connection.";
  }
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    if (data == 'error') {
      return 'Error occured :(';
    }
    return data;
  } else {
    return 'Error occured :(';
  }
}



Uri parse(baseUrl, key, value) {
  Map<String, String> params = {key: value};
  Uri uri = Uri.parse(baseUrl).replace(queryParameters: params);
  return uri;
}
