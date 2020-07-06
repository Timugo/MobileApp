//flutter dependencies
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;
import 'package:timugo/globals.dart' as globals;
import 'dart:convert';
// Preferences
import 'package:timugo/src/preferencesUser/preferencesUser.dart';

final String urlBase = globals.url;

/* 
  Class that contains the  login services
*/
class LoginServices {
  /* Request Url  */
  final String url = urlBase + 'loginUserV2';
  final prefs = PreferenciasUsuario();

  Future<Map<String, dynamic>> sendNumber(int phone, String city) async {
    /* Headers */
    Map<String, String> headers = {"Content-Type": "application/json"};
    /* Body */
    var data = {"phone": phone, "city": city};
    /* Response */
    final encodedData = json.encode(data);
    // making  POST request
    http.Response response =
        await http.post(url, headers: headers, body: encodedData);
    return jsonDecode(response.body);
  }

  final String urlGetUser = urlBase + 'getUser';
  Future<Map<String, dynamic>> getName(String phone) async {
    var _urlcode = urlGetUser + '?phone=' + phone;
    http.Response response = await http.get(_urlcode);

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to load post');
    }
    final decodeData = jsonDecode(response.body);
    //POST request (Need to be improved, servives only returns a https requests)
    if (decodeData['response'] == 2) {
      prefs.name = decodeData['content']['name'].toString();
      prefs.pts = decodeData['content']['points'].toString();
      prefs.id = decodeData['content']['id'].toString();
      prefs.email = decodeData['content']['email'].toString();
    }
    return decodeData;
  }

  /*
    Function to login the user with facebook account
    and return the user data
  */
  Future<Map<String, dynamic>> loginFacebook() async {
    final facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn(['email']);

    if (result.status != FacebookLoginStatus.error) {
      return null;
    }
    final token = result.accessToken.token;
    final graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
    final profile = jsonDecode(graphResponse.body);
    return profile;
  }

  /*
    Function to login the user with Apple account
    and return the user data
  */
  Future<Map<String, dynamic>> appleLogin() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    print(credential);
    // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
    // after they have been validated with Apple (see `Integration` section for more information on how to do this)
    
  }
}
