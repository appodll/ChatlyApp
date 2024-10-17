import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetCheck {
  Future<void>connectionCheck()async{
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (isConnected == false){
      print('sa');
    }else{
      print('as');
    }
  }
}