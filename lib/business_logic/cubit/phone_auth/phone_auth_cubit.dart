import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'phone_auth_state.dart';

class PhoneAuthCubit extends Cubit<PhoneAuthState> {
  late String verificationId;
  PhoneAuthCubit() : super(PhoneAuthInitial());

  Future<void> submitPhoneNumber(String phoneNumber) async {
    emit(Loading());
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+963$phoneNumber', //وقت المعالجة مع فايربيز
      timeout: const Duration(seconds: 14),
      verificationCompleted:
          verificationCompleted, //احيانا عند وصول كود التاكيد على مبوبايك بيقرئه دون  ما تكتبه
      verificationFailed: verificationFailed, //
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
    emit(ErrorOccurred(
        errorMsg: "44444444444444444444444444444444444444444444"));
  }

  void verificationCompleted(PhoneAuthCredential credential) async {
    //بعد وصول  كود التاكيد على الجهاز مباشرة سوف يدخل على التطبيق قبل ما ادخل الرقم
    print('verificationCompleted');
    await signIn(credential);
  }

  void verificationFailed(FirebaseAuthException error) {
    print('verificationFailed : ${error.toString()}'); //في حال كان هناك غلط
    emit(ErrorOccurred(errorMsg: error.toString())); //يولد غلط
  }

  void codeSent(String verificationId, int? resendToken) {
    //
    print('codeSent');
    this.verificationId = verificationId; //لما يوصل كود التاكيد
    emit(PhoneNumberSubmited());
  }

  void codeAutoRetrievalTimeout(String verificationId) {
    print('codeAutoRetrievalTimeout');
  }

//////////////////////////////////////////عند ادخال كود التاكيد /////////////////////////////////////////////////////////////////
  Future<void> submitOTP(String otpCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: this.verificationId,
      smsCode: otpCode,
    );
    await signIn(credential);
  }

  Future<void> signIn(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      emit(PhoneOTPVerified());
    } catch (error) {
      emit(ErrorOccurred(errorMsg: error.toString()));
    }
  }

  Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
  }

  User getLoggedInUser() {
    User firebaseUser = FirebaseAuth.instance.currentUser!;
    return firebaseUser;
  }
}
