import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'google_sign_in_helper.dart';
import 'user_profile_service.dart';
import 'gamification_service.dart';
import '../models/user_profile_model.dart';

// Provider for the AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Stream provider for auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with Email & Password
  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Register with Email & Password
  Future<UserCredential> registerWithEmailPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Check if email exists
  Future<List<String>> checkEmailExists(String email) async {
    try {
      // fetchSignInMethodsForEmail is removed in newer Firebase versions
      // We use a workaround: try to sign in with a dummy password.
      await _auth.signInWithEmailAndPassword(email: email, password: "dummy_password_checker_123");
      return ['email']; // Should not happen ideally unless password matches dummy
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return []; // Available
      } else if (e.code == 'wrong-password') {
        return ['email']; // Exists
      } else if (e.code == 'invalid-email') {
        throw 'Invalid email address.';
      }
      // Other errors might imply existence or network issues
       throw _handleAuthException(e);
    } catch (e) {
      throw 'Error checking email: $e';
    }
  }

  // Sign in with Google
  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      return await AuthorizationProvider.googleSignInMethod();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // Re-throw if it's a known string error or just wrapper
      // If AuthorizationProvider throws a custom error, we might want to catch it.
      // But for now, let's just pass it up or handle generic.
      if (e is FirebaseAuthException) rethrow;
      throw 'An unexpected error occurred during Google Sign In: $e';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await AuthorizationProvider.googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw 'Error signing out. Please try again.';
    }
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Email Verification Methods
  
  /// Send email verification to current user
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in.';
      }
      
      if (user.emailVerified) {
        throw 'Email is already verified.';
      }
      
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Failed to send verification email. Please try again.';
    }
  }

  /// Check if current user's email is verified
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Reload current user to get updated email verification status
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      print('Error reloading user: $e');
    }
  }

  /// Get current user's email
  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  /// Resend verification email with cooldown check
  Future<void> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in.';
      }
      
      if (user.emailVerified) {
        throw 'Email is already verified.';
      }

      // Firebase has built-in rate limiting, but we can add our own message
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        throw 'Too many requests. Please wait a few minutes before trying again.';
      }
      throw _handleAuthException(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Failed to resend verification email. Please try again.';
    }
  }

  // Initialize user data (profile and gamification) for new users
  Future<void> initializeUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Import services dynamically to avoid circular dependencies
      final userProfileService = UserProfileService();
      final gamificationService = GamificationService();

      // Check if profile exists
      final profileExists = await userProfileService.profileExists();
      
      if (!profileExists) {
        // Create initial profile with Firebase Auth data
        final initialProfile = UserProfile(
          name: user.displayName ?? 'User',
          age: 25,
          weight: 70.0,
          height: 170.0,
          dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 25)),
          preferredUnits: UnitPreference.metric,
          weeklyWorkoutGoal: 3,
          dailyCalorieGoal: 2000,
          totalWorkoutsCompleted: 0,
          totalMealsLogged: 0,
          daysActive: 0,
        );
        
        await userProfileService.createProfile(initialProfile);
        print('User profile initialized for ${user.uid}');
      }

      // Initialize gamification data (this will auto-create if doesn't exist)
      await gamificationService.getCurrentData();
      print('Gamification data initialized for ${user.uid}');
    } catch (e) {
      print('Error initializing user data: $e');
      // Don't throw - we want auth to succeed even if initialization fails
    }
  }

  // Error Handler
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'operation-not-allowed':
        return 'This sign-in method is disabled.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}
