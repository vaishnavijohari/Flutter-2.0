import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../services/crypto_api_service.dart';
import 'article_list_screen.dart';
import '../models.dart'; // ADDED: The single source of truth for our models.

// DELETED: The local definitions for CryptoCurrency, ArticleCategory, and TimeRange have been removed from this file.

class CryptoScreen extends StatefulWidget {
  const CryptoScreen({super.key});

  @override
  State<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen> {
  // This map now correctly uses the CryptoCurrency model from models.dart
  Map<String, CryptoCurrency> _cryptoData = {};
  late CryptoCurrency _selectedCrypto;
  TimeRange _selectedTimeRange = TimeRange.sixMonths;

  bool _isPageLoading = true;
  bool _isChartLoading = true;
  String? _errorMessage;

  final CryptoApiService _apiService = CryptoApiService();

  final List<ArticleCategory> _articleCategories = [
    ArticleCategory(name: 'Finance', imageUrl: 'assets/images/finance.jpg'),
    ArticleCategory(name: 'Crypto', imageUrl: 'assets/images/crypto.jpg'),
    ArticleCategory(name: 'Entertainment', imageUrl: 'assets/images/entertainment.jpg'),
    ArticleCategory(name: 'Sports', imageUrl: 'assets/images/sports.jpg'),
  ];

  @override
  void initState() {
    super.initState();
    _fetchLivePrices();
  }

  Future<void> _fetchLivePrices() async {
    try {
      final prices = await _apiService.getLiveCryptoPrices();
      if (mounted) {
        setState(() {
          _cryptoData = {for (var crypto in prices) crypto.symbol: crypto};
          // Set a default selected crypto, ensuring it exists.
          if (_cryptoData.containsKey('BTC')) {
            _selectedCrypto = _cryptoData['BTC']!;
             _fetchChartDataForSelectedCrypto();
          }
          _isPageLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isPageLoading = false;
        });
      }
    }
  }

  Future<void> _fetchChartDataForSelectedCrypto() async {
    if (_selectedCrypto.priceData.containsKey(_selectedTimeRange)) {
       setState(() => _isChartLoading = false);
       return;
    }

    if (mounted) setState(() => _isChartLoading = true);

    try {
      // This call now works because both the argument and parameter are the same TimeRange type.
      final chartData = await _apiService.getHistoricalChartData(_selectedCrypto.id, _selectedTimeRange);
      if (mounted) {
        setState(() {
          _selectedCrypto.priceData[_selectedTimeRange] = chartData;
          _isChartLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isChartLoading = false);
    }
  }

  void _onCryptoChanged(String? symbol) {
    if (symbol != null && _cryptoData.containsKey(symbol)) {
      setState(() {
        _selectedCrypto = _cryptoData[symbol]!;
      });
      _fetchChartDataForSelectedCrypto();
    }
  }

  void _onTimeRangeChanged(int index) {
    if (TimeRange.values[index] != _selectedTimeRange) {
        setState(() {
          _selectedTimeRange = TimeRange.values[index];
        });
        _fetchChartDataForSelectedCrypto();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isPageLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : _buildContent(),
    );
  }

  // --- No changes needed below this line, all widgets remain the same ---

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildCryptoSelector(),
            const SizedBox(height: 16),
            _buildPriceInfo(),
            const SizedBox(height: 24),
            _buildTimeRangeSelector(),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: _isChartLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PriceChart(
                      key: ValueKey('${_selectedCrypto.symbol}_$_selectedTimeRange'),
                      crypto: _selectedCrypto,
                      timeRange: _selectedTimeRange,
                    ),
            ),
            const SizedBox(height: 32),
            _buildArticleSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaIcon(FontAwesomeIcons.bitcoin, color: Colors.amber, size: 32),
        SizedBox(width: 12),
        Text(
          'Finance',
          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCryptoSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCrypto.symbol,
          isExpanded: true,
          dropdownColor: Colors.grey[850],
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          items: _cryptoData.values.map((crypto) {
            return DropdownMenuItem(
              value: crypto.symbol,
              child: Text('${crypto.name} (${crypto.symbol})'),
            );
          }).toList(),
          onChanged: _onCryptoChanged,
        ),
      ),
    );
  }

  Widget _buildPriceInfo() {
    final bool isPositive = _selectedCrypto.change24h >= 0;
    final Color changeColor = isPositive ? Colors.greenAccent : Colors.redAccent;
    final priceFormat = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: _selectedCrypto.price > 1 ? 2 : 6,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          priceFormat.format(_selectedCrypto.price),
          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, color: changeColor, size: 16),
            const SizedBox(width: 4),
            Text(
              '${_selectedCrypto.change24h.toStringAsFixed(2)}% (24h)',
              style: TextStyle(color: changeColor, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeRangeSelector() {
    return Center(
      child: ToggleButtons(
        isSelected: TimeRange.values.map((e) => e == _selectedTimeRange).toList(),
        onPressed: _onTimeRangeChanged,
        borderRadius: BorderRadius.circular(8),
        selectedColor: Colors.black,
        color: Colors.white,
        fillColor: Colors.cyanAccent,
        borderColor: Colors.grey[700],
        selectedBorderColor: Colors.cyanAccent,
        children: const [
          Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('1D')),
          Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('1W')),
          Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('1M')),
          Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('6M')),
        ],
      ),
    );
  }

  Widget _buildArticleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Browse Articles',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _articleCategories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            return ArticleCategoryCard(category: _articleCategories[index]);
          },
        ),
      ],
    );
  }
}

class PriceChart extends StatelessWidget {
  final CryptoCurrency crypto;
  final TimeRange timeRange;

  const PriceChart({
    super.key,
    required this.crypto,
    required this.timeRange,
  });

  @override
  Widget build(BuildContext context) {
    final priceData = crypto.priceData[timeRange] ?? [];
    if (priceData.isEmpty) {
      return const Center(child: Text("Chart data not available.", style: TextStyle(color: Colors.white70)));
    }

    final tooltipPriceFormat = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: crypto.price > 1 ? 2 : 6,
    );

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (spot) => Colors.blueGrey.withAlpha(200),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${tooltipPriceFormat.format(spot.y)}\n',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white10, strokeWidth: 1),
            getDrawingVerticalLine: (value) => const FlLine(color: Colors.white10, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  final format = NumberFormat.compactSimpleCurrency(locale: 'en_US');
                  return Text(
                    format.format(value),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.left,
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: _getBottomTitleInterval(priceData),
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 8.0,
                    child: Text(
                      _getBottomTitleForValue(value.toInt(), priceData, timeRange),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white10, width: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: priceData,
              isCurved: true,
              color: Colors.cyanAccent,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [Colors.cyanAccent.withAlpha(77), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getBottomTitleInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 1;
    return spots.length / 4;
  }

  String _getBottomTitleForValue(int index, List<FlSpot> spots, TimeRange timeRange) {
    if (index < 0 || index >= spots.length) return '';
    
    // This logic needs to be based on how the API provides the data.
    // Assuming 'x' is an index for simplicity until API gives real timestamps.
    switch (timeRange) {
      case TimeRange.oneDay:
        return 'Day ${index + 1}';
      case TimeRange.oneWeek:
        return 'Week ${index + 1}';
      case TimeRange.oneMonth:
        return 'Month ${index + 1}';
      case TimeRange.sixMonths:
        return 'M ${index + 1}';
    }
  }
}

class ArticleCategoryCard extends StatelessWidget {
  final ArticleCategory category;
  const ArticleCategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleListScreen(categoryName: category.name),
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              category.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[800],
                child: const Icon(Icons.image_not_supported, color: Colors.white30),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color.fromRGBO(0, 0, 0, 0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Text(
                category.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}