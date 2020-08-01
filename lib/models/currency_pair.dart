/*
 * Model: 
 * Intsrument either in stocks, forex etc
*/
import 'package:msagetrader/models/instrument.dart';

class CurrencyPair extends Instrument {
  CurrencyPair({id, title}) : super(id: id, title: title);

  String base() {
    return title.substring(0, 3);
  }

  String quote() {
    return title.substring(title.length - 3);
  }
}
