import 'package:flutter/material.dart';

class RecentSearches with ChangeNotifier {
  List<String> recentCustomers = [];

//recent history function for search bars
  List<String> addRecent(String name) {
    String firstData;
    String secondData;
    String thirdData;
    String fourthData;

    if (recentCustomers.isEmpty) {
      recentCustomers.add(name);
      return recentCustomers;
    } else if (recentCustomers.length == 1) {
      firstData = recentCustomers[0];
      recentCustomers.replaceRange(0, 1, [name, firstData]);
      return recentCustomers;
    } else if (recentCustomers.length == 2) {
      firstData = recentCustomers[0];
      secondData = recentCustomers[1];
      recentCustomers.replaceRange(0, 2, [
        name,
        firstData,
        secondData,
      ]);
      return recentCustomers;
    } else if (recentCustomers.length == 3) {
      firstData = recentCustomers[0];
      secondData = recentCustomers[1];
      thirdData = recentCustomers[2];
      recentCustomers.replaceRange(0, 3, [
        name,
        firstData,
        secondData,
        thirdData,
      ]);
      return recentCustomers;
    } else if (recentCustomers.length == 4) {
      firstData = recentCustomers[0];
      secondData = recentCustomers[1];
      thirdData = recentCustomers[2];
      fourthData = recentCustomers[3];
      recentCustomers.replaceRange(
          0, 4, [name, firstData, secondData, thirdData, fourthData]);
      recentCustomers.remove(recentCustomers[4]);
      return recentCustomers;
    }
    return recentCustomers;
  }
}
