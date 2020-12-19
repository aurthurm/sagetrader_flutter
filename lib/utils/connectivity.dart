import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:connectivity/connectivity.dart';


/*
 * Check if there is Network or internect connection
*/
Future<bool> hasInternetAccess() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      if (await DataConnectionChecker().hasConnection) {
        return true;
      } else {
        return false;
      }
    } else if (connectivityResult == ConnectivityResult.wifi) {
      if (await DataConnectionChecker().hasConnection) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
}

/*
 * Check if there is Network(Wifi) with/without internet access
*/
Future<bool> hasNetworkAccess() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
}

/*
 * Do some Work online
 * @param func: a function that takes a boolean paramater isOnline
*/
dynamic workOnline(Function func) async {
  await hasInternetAccess().then((internet) {
    if(internet == null) throw Exception("An Error Occured. Make sure you have a stable internet Connection. Try Again");
    func(internet);
  });
}

