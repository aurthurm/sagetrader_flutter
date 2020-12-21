/*
 * Model: 
 * Intsrument either in stocks, forex etc
*/
import 'package:msagetrader/models/instrument.dart';

class CurrencyPair extends Instrument {
  CurrencyPair({uid, title}) : super(uid: uid, title: title);

  String base() {
    return title.substring(0, 3);
  }

  String quote() {
    return title.substring(title.length - 3);
  }
}
