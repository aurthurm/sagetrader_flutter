import 'package:msagetrader/models/currency_pair.dart';
import 'package:msagetrader/models/instrument.dart';
import 'package:flutter/foundation.dart';

/*
 * Provider: Currency Pairs Provider
*/
class CurrencyPairs with ChangeNotifier {
  List<CurrencyPair> _pairs = <CurrencyPair>[
    CurrencyPair(id: '0', title: 'eurusd'),
    CurrencyPair(id: '1', title: 'gbpusd'),
    CurrencyPair(id: '2', title: 'audusd'),
    CurrencyPair(id: '3', title: 'nzdusd'),
    CurrencyPair(id: '4', title: 'usdjpy'),
    CurrencyPair(id: '5', title: 'usdcas'),
    CurrencyPair(id: '6', title: 'usdchf'),
    CurrencyPair(id: '7', title: 'audcad'),
    CurrencyPair(id: '7', title: 'audchf'),
  ];

  List<CurrencyPair> get pairs => _pairs;

  CurrencyPair findByName(String name) {
    final index = pairs.indexWhere((pair) => pair.name() == name.toUpperCase());
    return pairs[index];
  }

  CurrencyPair findById(String id) {
    final index = pairs.indexWhere((pair) => pair.id == id);
    return pairs[index];
  }
}

/*
 * Provider: Account Currency Denomination Provider
*/
class AccountCurrency with ChangeNotifier {
  List<Instrument> _currencies = <Instrument>[
    Instrument(id: '0', title: 'usd'),
    Instrument(id: '1', title: 'gbp'),
    Instrument(id: '2', title: 'cad'),
    Instrument(id: '3', title: 'nzd'),
    Instrument(id: '4', title: 'chf'),
    Instrument(id: '5', title: 'zar'),
    Instrument(id: '6', title: 'aud'),
    Instrument(id: '7', title: 'chf'),
    Instrument(id: '8', title: 'jpy'),
  ];

  List<Instrument> get currencies => _currencies;

  Instrument findById(String id) {
    final index = currencies.indexWhere((curr) => curr.id == id);
    return currencies[index];
  }
}
