import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

// --- UPDATED: Import the new article list screen ---
import 'article_list_screen.dart';

// --- MODEL CLASSES ---

class CryptoCurrency {
  final String name;
  final String symbol;
  final double price;
  final double change24h;
  // Data for each time range
  final Map<TimeRange, List<FlSpot>> priceData;

  CryptoCurrency({
    required this.name,
    required this.symbol,
    required this.price,
    required this.change24h,
    required this.priceData,
  });
}

class ArticleCategory {
  final String name;
  final String imageUrl;
  ArticleCategory({required this.name, required this.imageUrl});
}

// Enum for the time range selector
enum TimeRange { oneDay, oneWeek, oneMonth, sixMonths }


// --- MAIN CRYPTO SCREEN WIDGET ---

class CryptoScreen extends StatefulWidget {
  const CryptoScreen({super.key});

  @override
  State<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen> {
  late CryptoCurrency _selectedCrypto;
  TimeRange _selectedTimeRange = TimeRange.sixMonths;
  bool _isLoading = true;

  final Map<String, CryptoCurrency> _cryptoData = {};
  final List<ArticleCategory> _articleCategories = [
    ArticleCategory(name: 'Finance', imageUrl: 'assets/images/finance.jpg'),
    ArticleCategory(name: 'Crypto', imageUrl: 'assets/images/crypto.jpg'),
    ArticleCategory(name: 'Entertainment', imageUrl: 'assets/images/entertainment.jpg'),
    ArticleCategory(name: 'Sports', imageUrl: 'assets/images/sports.jpg'),
  ];

  @override
  void initState() {
    super.initState();
    _generateDummyData();
    _selectedCrypto = _cryptoData['BTC']!;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _generateDummyData() {
    final List<String> symbols = ['BTC', 'ETH', 'SOL', 'XRP', 'DOGE', 'SHIB'];
    final List<String> names = ['Bitcoin', 'Ethereum', 'Solana', 'Ripple', 'Dogecoin', 'Shiba Inu'];
    final List<double> prices = [68450.50, 3560.80, 165.25, 0.521, 0.158, 0.000025];
    final Random random = Random();

    for (int i = 0; i < symbols.length; i++) {
      final change = (random.nextDouble() * 10) - 4;
      _cryptoData[symbols[i]] = CryptoCurrency(
        name: names[i],
        symbol: symbols[i],
        price: prices[i],
        change24h: change,
        priceData: {
          TimeRange.oneDay: _generatePriceHistory(prices[i], 24, 360),
          TimeRange.oneWeek: _generatePriceHistory(prices[i], 7 * 24, 90),
          TimeRange.oneMonth: _generatePriceHistory(prices[i], 30 * 24, 30),
          TimeRange.sixMonths: _generatePriceHistory(prices[i], 180 * 24, 1),
        },
      );
    }
  }

  List<FlSpot> _generatePriceHistory(double basePrice, int hours, int frequency) {
    final Random random = Random();
    return List.generate(hours, (index) {
      if (index % frequency != 0) return null;
      final value = basePrice * (1 + (sin(index * pi / (hours / 2)) * 0.1) + (random.nextDouble() * 0.05 - 0.025));
      return FlSpot(index.toDouble(), value);
    }).where((spot) => spot != null).cast<FlSpot>().toList();
  }

  void _onCryptoChanged(String? symbol) {
    if (symbol != null && _cryptoData.containsKey(symbol)) {
      setState(() => _selectedCrypto = _cryptoData[symbol]!);
    }
  }

  void _onTimeRangeChanged(int index) {
    setState(() => _selectedTimeRange = TimeRange.values[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildCryptoSelector(),
              const SizedBox(height: 16),
              if (!_isLoading) _buildPriceInfo(),
              const SizedBox(height: 24),
              if (!_isLoading) ...[
                _buildTimeRangeSelector(),
                const SizedBox(height: 8),
                PriceChart(
                  key: ValueKey('${_selectedCrypto.symbol}_$_selectedTimeRange'), // Ensures chart rebuilds
                  priceData: _selectedCrypto.priceData[_selectedTimeRange]!,
                ),
              ],
              const SizedBox(height: 32),
              _buildArticleSection(),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI BUILDER WIDGETS ---

  Widget _buildHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaIcon(FontAwesomeIcons.bitcoin, color: Colors.amber, size: 32),
        SizedBox(width: 12),
        Text(
          'Finance',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
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
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _articleCategories.length,
            itemBuilder: (context, index) {
              return ArticleCategoryCard(category: _articleCategories[index]);
            },
          ),
        ),
      ],
    );
  }
}


// --- ABSTRACTED WIDGETS ---

class PriceChart extends StatelessWidget {
  final List<FlSpot> priceData;
  const PriceChart({super.key, required this.priceData});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (spot) => Colors.blueGrey.withAlpha(204),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final format = NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);
                  return LineTooltipItem(
                    '${format.format(spot.y)}\n',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }).toList();
              },
            ),
          ),
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
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
}

class ArticleCategoryCard extends StatelessWidget {
  final ArticleCategory category;
  const ArticleCategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        // --- THIS IS THE UPDATED PART ---
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
      ),
    );
  }
}
