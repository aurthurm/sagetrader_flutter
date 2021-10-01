/*
 * Model: 
 * COTContract
*/
class COTContract {
  String uid;
  String name;
  String code;
  COTContract({this.uid, this.name, this.code});

  factory COTContract.fromJson(Map<String, dynamic> json) {
    if (json == null) return COTContract();
    return COTContract(
      uid: json['uid'].toString(),
      name: json['name'],
      code: json['code'],
    );
  }
}

/*
 * Model: 
 * COTReport
*/
class COTReport {
  String uid;
  COTContract contract;
  String date;
  double openInterest;
  double openInterestCh;
  double nonCommercialLong;
  double nonCommercialLongCh;
  double nonCommercialShort;
  double nonCommercialShortCh;
  double nonCommercialSpreads;
  double nonCommercialSpreadsCh;
  double commercialLong;
  double commercialLongCh;
  double commercialShort;
  double commercialShortCh;
  double totalLong;
  double totalLongCh;
  double totalShort;
  double totalShortCh;
  double nonReportableLong;
  double nonReportableLongCh;
  double nonReportableShort;
  double nonReportableShortCh;
  COTReport({
    this.uid,
    this.contract,
    this.date,
    this.openInterest,
    this.openInterestCh,
    this.nonCommercialLong,
    this.nonCommercialLongCh,
    this.nonCommercialShort,
    this.nonCommercialShortCh,
    this.nonCommercialSpreads,
    this.nonCommercialSpreadsCh,
    this.commercialLong,
    this.commercialLongCh,
    this.commercialShort,
    this.commercialShortCh,
    this.totalLong,
    this.totalLongCh,
    this.totalShort,
    this.totalShortCh,
    this.nonReportableLong,
    this.nonReportableLongCh,
    this.nonReportableShort,
    this.nonReportableShortCh,
  });

  factory COTReport.fromJson(Map<String, dynamic> json) {
    return COTReport(
      uid: json['uid'].toString(),
      contract: COTContract.fromJson(json['contract']),
      date: json['date'],
      openInterest: json['open_interest'],
      openInterestCh: json['open_interest_ch'],
      nonCommercialLong: json['non_commercial_long'],
      nonCommercialLongCh: json['non_commercial_long_ch'],
      nonCommercialShort: json['non_commercial_short'],
      nonCommercialShortCh: json['non_commercial_short_ch'],
      nonCommercialSpreads: json['non_commercial_spreads'],
      nonCommercialSpreadsCh: json['non_commercial_spreads_ch'],
      commercialLong: json['commercial_long'],
      commercialLongCh: json['commercial_long_ch'],
      commercialShort: json['commercial_short'],
      commercialShortCh: json['commercial_short_ch'],
      totalLong: json['total_long'],
      totalLongCh: json['total_long_ch'],
      totalShort: json['total_short'],
      totalShortCh: json['total_short_ch'],
      nonReportableLong: json['non_reportable-long'],
      nonReportableLongCh: json['non_reportable-long_ch'],
      nonReportableShort: json['non_reportable_short'],
      nonReportableShortCh: json['non_reportable_short_ch'],
    );
  }
}

/*
 * Model: 
 * COTContract
*/
class PairBias {
  String bias;
  double baseNetPositions;
  double quoteNetPositions;
  double quoteWeight;
  int quoteStrength;
  double baseWeight;
  int baseStrength;
  PairBias(
      {this.bias,
      this.baseNetPositions,
      this.baseWeight,
      this.baseStrength,
      this.quoteNetPositions,
      this.quoteWeight,
      this.quoteStrength});

  factory PairBias.fromJson(Map<String, dynamic> json) {
    return PairBias(
      bias: json['bias'].toString(),
      baseWeight: json['baseWeight'],
      baseNetPositions: json['baseNetPositions'],
      baseStrength: json['baseStrength'],
      quoteWeight: json['quoteWeight'],
      quoteNetPositions: json['quoteNetPositions'],
      quoteStrength: json['quoteStrength'],
    );
  }
}
