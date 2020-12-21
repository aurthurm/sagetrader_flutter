import 'package:msagetrader/models/currency_pair.dart';
import 'package:msagetrader/models/instrument.dart';
import 'package:flutter/foundation.dart';

/*
 * Provider: Currency Pairs Provider
*/
class CurrencyPairs with ChangeNotifier {
  List<CurrencyPair> _pairs = <CurrencyPair>[
    CurrencyPair(uid: '0', title: 'eurusd'),
    CurrencyPair(uid: '1', title: 'gbpusd'),
    CurrencyPair(uid: '2', title: 'audusd'),
    CurrencyPair(uid: '3', title: 'nzdusd'),
    CurrencyPair(uid: '4', title: 'usdjpy'),
    CurrencyPair(uid: '5', title: 'usdcas'),
    CurrencyPair(uid: '6', title: 'usdchf'),
    CurrencyPair(uid: '7', title: 'audcad'),
    CurrencyPair(uid: '7', title: 'audchf'),
  ];

  List<CurrencyPair> get pairs => _pairs;

  CurrencyPair findByName(String name) {
    final index = pairs.indexWhere((pair) => pair.name() == name.toUpperCase());
    return pairs[index];
  }

  CurrencyPair findById(String id) {
    final index = pairs.indexWhere((pair) => pair.uid == id);
    if(index == -1) {
      return null;
    }
    return pairs[index];
  }
}

/*
 * Provider: Account Currency Denomination Provider
*/
class AccountCurrency with ChangeNotifier {
  List<Instrument> _currencies = <Instrument>[
    Instrument(uid: '0', title: 'usd'),
    Instrument(uid: '1', title: 'gbp'),
    Instrument(uid: '2', title: 'cad'),
    Instrument(uid: '3', title: 'nzd'),
    Instrument(uid: '4', title: 'chf'),
    Instrument(uid: '5', title: 'zar'),
    Instrument(uid: '6', title: 'aud'),
    Instrument(uid: '7', title: 'chf'),
    Instrument(uid: '8', title: 'jpy'),
  ];

  List<Instrument> get currencies => _currencies;

  Instrument findById(String id) {
    final index = currencies.indexWhere((curr) => curr.uid == id);
    if(index == -1) {
      return null;
    }
    return currencies[index];
  }
}
