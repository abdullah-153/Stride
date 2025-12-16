import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthorizationProvider {
  static final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  static bool isInitialized = false;

  static Future<void> initSignIn() async {
    if (!isInitialized) {
      await googleSignIn.initialize(
        serverClientId:
            "164441790077-5v8v9r15h9qr87unucuk1p95tdcniugs.apps.googleusercontent.com",
      );
    }

    isInitialized = true;
  }

  static Future<UserCredential> googleSignInMethod() async {
    await initSignIn();

    final GoogleSignInAccount account = await googleSignIn.authenticate();

    final authData = account.authentication; // âœ… await properly
    final idtoken = authData.idToken;

    final authClient = account.authorizationClient;
    if (authClient == null) {
      throw FirebaseAuthException(
        code: "auth-client-null",
        message: 'Google authorization client was not available.',
      );
    }

    GoogleSignInClientAuthorization? auth = await authClient
        .authorizationForScopes(['email', 'profile']);

    var accessToken = auth?.accessToken;

    if (accessToken == null) {
      auth = await authClient.authorizationForScopes(['email', 'profile']);
      accessToken = auth?.accessToken;
    }

    if (accessToken == null || idtoken == null) {
      throw FirebaseAuthException(
        code: "token-missing",
        message: 'Missing Google token(s).',
      );
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: accessToken,
      idToken: idtoken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void signInWithTwitter() {}
}
