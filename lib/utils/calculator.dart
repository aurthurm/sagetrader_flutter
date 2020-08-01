import 'package:msagetrader/models/currency_pair.dart';
import 'package:msagetrader/models/instrument.dart';

/*
 * Calculate Lot Units
 * Standard 1.000 lot = 100, 0000 units
 * Mini     0.100 lot = 10, 000 units
 * Micro    0.010 lot = 1000 units
 * Nano     0.001 lot = 100 units
*/
double getUnits(double lots) {
  return 10000 * lots;
}

/*
 * How many decimal places
*/
int decimalPlaces(double number) {
  List<String> words = number.toString().split(".");
  return words[1].length;
}

/*
 * is in Pippetes (not pips)
*/
bool isPipettes(double number) {
  if (decimalPlaces(number) == 3 || decimalPlaces(number) == 5) {
    return true;
  }
  return false;
}

/*
 * Get pips
*/
double getPips(double number1, double number2) {
  if (decimalPlaces(number1) != decimalPlaces(number2)) {
    return 0;
  }

  double _difference = number1 - number2;
  return _difference.abs();
}

/*
 * pipValue for 1 unit
*/
double pipValue(CurrencyPair pair, double price) {
  double _numerator = 0.01;

  if (decimalPlaces(price) > 3) {
    _numerator = 0.0001;
  }

  if (pair.quote() == "USD") {
    return (_numerator / price) * price;
  } else {
    return (_numerator / price) * 1;
  }
}

/*
 * Get pips for a given lot size
*/
double pipValueforLot(double pipvalue, double lotunits) {
  return pipvalue * lotunits;
}

/*
 * pipValue in Account Currency
*/
double pipValueforAccount(
  CurrencyPair pair,
  double price,
  Instrument account_currency,
  double units,
) {
  double pip_value = pipValue(pair, price);
  double price_per_pip = pipValueforLot(pip_value, units);
}
