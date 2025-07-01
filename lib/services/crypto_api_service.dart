import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import '../models.dart'; 

class CryptoApiService {
  final String _baseUrl = "https://api.coingecko.com/api/v3";

  final Map<String, String> _coinIdMap = {
    'BTC': 'bitcoin',
    'ETH': 'ethereum',
    'SOL': 'solana',
    'XRP': 'ripple',
    'DOGE': 'dogecoin',
  };

  Future<List<CryptoCurrency>> getLiveCryptoPrices() async {
    final ids = _coinIdMap.values.join(',');
    final url = Uri.parse('$_baseUrl/simple/price?ids=$ids&vs_currencies=usd&include_24hr_change=true');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        List<CryptoCurrency> cryptoList = [];
        _coinIdMap.forEach((symbol, id) {
          if (data.containsKey(id)) {
            cryptoList.add(
              CryptoCurrency(
                id: id,
                symbol: symbol,
                name: id.substring(0, 1).toUpperCase() + id.substring(1),
                price: (data[id]['usd'] as num).toDouble(),
                change24h: (data[id]['usd_24h_change'] as num).toDouble(),

                // --- FIXED: Initialize with an empty Map {} instead of a List [] ---
                priceData: {}, 
              ),
            );
          }
        });
        return cryptoList;
      } else {
        throw Exception('Failed to load crypto prices');
      }
    } catch (e) {
      throw Exception('Failed to connect to the network: $e');
    }
  }

  Future<List<FlSpot>> getHistoricalChartData(String coinId, TimeRange timeRange) async {
    int days;
    switch (timeRange) {
      case TimeRange.oneDay:
        days = 1;
        break;
      case TimeRange.oneWeek:
        days = 7;
        break;
      case TimeRange.oneMonth:
        days = 30;
        break;
      case TimeRange.sixMonths:
        days = 180;
        break;
    }

    final url = Uri.parse('$_baseUrl/coins/$coinId/market_chart?vs_currency=usd&days=$days&interval=daily');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> prices = data['prices'];
        
        return prices.asMap().entries.map((entry) {
          // The API returns timestamp in milliseconds for X, and price for Y.
          return FlSpot((entry.value[0] as num).toDouble(), (entry.value[1] as num).toDouble());
        }).toList();
      } else {
        throw Exception('Failed to load chart data for $coinId');
      }
    } catch (e) {
      throw Exception('Failed to connect to the network: $e');
    }
  }
}