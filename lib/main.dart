import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

import 'package:intl/intl.dart';

void main() {
  runApp(const RevenueToolApp());
}

class RevenueToolApp extends StatelessWidget {
  const RevenueToolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tool Chia Doanh Thu Kế Toán',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[300]!),
          ),
        ),
      ),
      home: const RevenueCalculatorScreen(),
    );
  }
}

// ==========================================
// MODELS
// ==========================================
class ProductItem {
  String id;
  String name;
  double retail;
  double under50;
  double under100;
  double over100;

  ProductItem(
    this.id,
    this.name,
    this.retail,
    this.under50,
    this.under100,
    this.over100,
  );
}

class InvoiceRequest {
  int id;
  String date;
  String customer;
  double revenue;
  int lines;

  InvoiceRequest({
    required this.id,
    this.date = '',
    this.customer = '',
    this.revenue = 0,
    this.lines = 1,
  });
}

class ResultRow {
  String stt;
  String date;
  double invoiceRevenue;
  String customer;
  String productCode;
  String productName;
  double price;
  int quantity;
  double total;

  ResultRow({
    this.stt = '',
    this.date = '',
    this.invoiceRevenue = 0,
    this.customer = '',
    this.productCode = '',
    this.productName = '',
    this.price = 0,
    this.quantity = 0,
    this.total = 0,
  });
}

// ==========================================
// MAIN SCREEN
// ==========================================
class RevenueCalculatorScreen extends StatefulWidget {
  const RevenueCalculatorScreen({super.key});

  @override
  State<RevenueCalculatorScreen> createState() =>
      _RevenueCalculatorScreenState();
}

class _RevenueCalculatorScreenState extends State<RevenueCalculatorScreen> {
  final NumberFormat _currencyFormat = NumberFormat('#,###', 'vi_VN');

  // 1. DỮ LIỆU BẢNG GIÁ NGUỒN (117 Sản phẩm nhập sẵn)
  late List<ProductItem> priceList;

  // 2. DỮ LIỆU HÓA ĐƠN YÊU CẦU
  List<InvoiceRequest> invoiceRequests = [
    InvoiceRequest(
      id: DateTime.now().millisecondsSinceEpoch,
      date: '',
      customer: '',
      revenue: 0,
      lines: 1,
    ),
  ];

  // 3. KẾT QUẢ ĐẦU RA
  List<ResultRow> generatedData = [];
  bool isGenerating = false;

  // Thêm ScrollController để điều khiển thanh cuộn ngang bảng 3
  final ScrollController _resultScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    priceList = [
      ProductItem('HH001', 'Áo 031', 168000, 163000, 158000, 148000),
      ProductItem('HH002', 'Áo 2 dây viền chữ', 155000, 153000, 145000, 135000),
      ProductItem('HH003', 'Áo 2001', 94000, 92000, 84000, 74000),
      ProductItem('HH004', 'Áo 2321', 94000, 92000, 84000, 74000),
      ProductItem('HH005', 'Áo 2322', 80000, 78000, 70000, 60000),
      ProductItem('HH006', 'Áo 2511', 128000, 126000, 118000, 108000),
      ProductItem('HH007', 'Áo 2828', 58000, 56000, 48000, 38000),
      ProductItem('HH008', 'Áo 2884', 87000, 85000, 77000, 67000),
      ProductItem('HH009', 'Áo 366', 139000, 137000, 129000, 119000),
      ProductItem('HH010', 'Áo 4078', 78000, 76000, 68000, 58000),
      ProductItem('HH011', 'Áo 518', 59000, 57000, 49000, 39000),
      ProductItem('HH012', 'Áo 604', 85000, 83000, 75000, 65000),
      ProductItem('HH013', 'Áo 689', 86000, 84000, 76000, 66000),
      ProductItem('HH014', 'Áo 713', 84000, 82000, 74000, 64000),
      ProductItem('HH015', 'Áo 721', 65000, 63000, 55000, 45000),
      ProductItem('HH016', 'Áo 901', 92000, 90000, 82000, 72000),
      ProductItem('HH017', 'Áo 911', 64000, 62000, 54000, 44000),
      ProductItem('HH018', 'Áo 991', 112000, 110000, 102000, 92000),
      ProductItem('HH019', 'Áo bò da kem viền', 130000, 128000, 120000, 110000),
      ProductItem('HH021', 'Áo bò da ren đỏ', 130000, 128000, 120000, 110000),
      ProductItem('HH023', 'Áo bò da ren kem', 140000, 138000, 130000, 120000),
      ProductItem('HH024', 'Áo bra', 112000, 110000, 102000, 92000),
      ProductItem('HH026', 'Áo bra đen trơn', 120000, 118000, 110000, 100000),
      ProductItem(
        'HH030',
        'Áo bra đen viền chữ',
        121000,
        119000,
        111000,
        101000,
      ),
      ProductItem('HH032', 'Áo bra kem trơn', 120000, 118000, 110000, 100000),
      ProductItem(
        'HH035',
        'Áo bra kem viền chữ',
        120000,
        118000,
        110000,
        100000,
      ),
      ProductItem('HH036', 'Áo bra ren đen', 118000, 116000, 108000, 98000),
      ProductItem(
        'HH037',
        'Áo bra ren su cao cấp',
        210000,
        208000,
        200000,
        190000,
      ),
      ProductItem('HH039', 'Áo bra ren trắng', 125000, 123000, 115000, 105000),
      ProductItem('HH041', 'Áo bra ren viền', 120000, 118000, 110000, 100000),
      ProductItem('HH043', 'Áo bra trắng trơn', 120000, 118000, 110000, 100000),
      ProductItem(
        'HH046',
        'Áo bra xanh viền chữ',
        120000,
        118000,
        110000,
        100000,
      ),
      ProductItem('HH047', 'Áo C909', 75000, 73000, 65000, 55000),
      ProductItem('HH048', 'Áo cài trước 7275', 108000, 106000, 98000, 88000),
      ProductItem('HH049', 'Áo chống nắng nữ', 195000, 193000, 185000, 175000),
      ProductItem('HH050', 'Áo D52', 80000, 78000, 70000, 60000),
      ProductItem('HH051', 'áo định hình 031', 228000, 226000, 218000, 208000),
      ProductItem('HH052', 'Áo kẻ', 70000, 68000, 60000, 50000),
      ProductItem('HH053', 'Áo khoác', 188000, 186000, 178000, 168000),
      ProductItem(
        'HH054',
        'Áo khoác chống nắng có nón',
        188000,
        186000,
        178000,
        168000,
      ),
      ProductItem(
        'HH055',
        'Áo khoác chống nắng có nón dây rút',
        205000,
        203000,
        195000,
        185000,
      ),
      ProductItem(
        'HH056',
        'Áo khoác chống nắng màu đen',
        155000,
        153000,
        145000,
        135000,
      ),
      ProductItem(
        'HH057',
        'Áo khoác chống nắng màu hồng',
        155000,
        153000,
        145000,
        135000,
      ),
      ProductItem(
        'HH058',
        'Áo khoác chống nắng màu tím',
        155000,
        153000,
        145000,
        135000,
      ),
      ProductItem(
        'HH059',
        'Áo khoác chống nắng màu xanh',
        155000,
        153000,
        145000,
        135000,
      ),
      ProductItem('HH060', 'Áo lót 589', 81000, 79000, 71000, 61000),
      ProductItem('HH061', 'áo lót 9120', 110000, 108000, 100000, 90000),
      ProductItem('HH062', 'Áo lót lụa su', 110000, 108000, 100000, 90000),
      ProductItem('HH063', 'Áo lót ren', 112000, 110000, 102000, 92000),
      ProductItem('HH064', 'Áo lót sọc đen', 105000, 103000, 95000, 85000),
      ProductItem('HH065', 'Áo lót sọc hồng', 105000, 103000, 95000, 85000),
      ProductItem('HH066', 'Áo lót sọc kem', 105000, 103000, 95000, 85000),
      ProductItem('HH067', 'Áo lót sọc nâu', 105000, 103000, 95000, 85000),
      ProductItem('HH068', 'Áo lót sọc viền', 110000, 108000, 100000, 90000),
      ProductItem(
        'HH069',
        'Áo lót su ren họa tiết đen',
        120000,
        118000,
        110000,
        100000,
      ),
      ProductItem(
        'HH070',
        'Áo lót su ren họa tiết nâu',
        120000,
        118000,
        110000,
        100000,
      ),
      ProductItem(
        'HH071',
        'Áo lót su viền đen',
        120000,
        118000,
        110000,
        100000,
      ),
      ProductItem(
        'HH072',
        'Áo lót su viền kem',
        120000,
        118000,
        110000,
        100000,
      ),
      ProductItem(
        'HH073',
        'Áo lót su viền nâu',
        120000,
        118000,
        110000,
        100000,
      ),
      ProductItem('HH074', 'Áo lót viền chữ', 108000, 106000, 98000, 88000),
      ProductItem('HH075', 'Áo Miss Bra', 128000, 126000, 118000, 108000),
      ProductItem('HH076', 'áo nắng 567 nữ', 210000, 208000, 200000, 190000),
      ProductItem('HH077', 'Áo ngực đen trơn', 118000, 116000, 108000, 98000),
      ProductItem('HH078', 'Áo ngực kem trơn', 118000, 116000, 108000, 98000),
      ProductItem('HH079', 'Áo ngực nâu trơn', 118000, 116000, 108000, 98000),
      ProductItem('HH080', 'Áo ren', 125000, 123000, 115000, 105000),
      ProductItem('HH081', 'áo ren 2321', 170000, 168000, 160000, 150000),
      ProductItem('HH082', 'áo ren 2322', 142000, 140000, 132000, 122000),
      ProductItem('HH083', 'áo ren 4078', 127000, 125000, 117000, 107000),
      ProductItem('HH084', 'Áo ren 4587', 80000, 78000, 70000, 60000),
      ProductItem('HH086', 'Áo ren bra đen', 125000, 123000, 115000, 105000),
      ProductItem('HH087', 'Áo ren bra màu kem', 115000, 113000, 105000, 95000),
      ProductItem('HH088', 'Áo ren bra màu nâu', 115000, 113000, 105000, 95000),
      ProductItem('HH089', 'Áo su', 118000, 116000, 108000, 98000),
      ProductItem('HH090', 'Áo su 9737', 88000, 86000, 78000, 68000),
      ProductItem('HH091', 'Áo su goddess', 95000, 93000, 85000, 75000),
      ProductItem('HH092', 'Áo Y31', 71000, 69000, 61000, 51000),
      ProductItem('HH093', 'Áo Y36', 75000, 73000, 65000, 55000),
      ProductItem('HH094', 'Bra 5017', 132000, 130000, 122000, 112000),
      ProductItem('HH096', 'bra 77082+2566', 186422, 184422, 176422, 166422),
      ProductItem('HH097', 'bra 996', 99400, 97400, 89400, 79400),
      ProductItem('HH098', 'bra đen viền', 120000, 118000, 110000, 100000),
      ProductItem('HH099', 'Bra free', 118000, 116000, 108000, 98000),
      ProductItem('HH100', 'bra kem viền', 120000, 118000, 110000, 100000),
      ProductItem('HH101', 'bra lót su', 120000, 118000, 110000, 100000),
      ProductItem('HH102', 'bra nâu viền', 120000, 118000, 110000, 100000),
      ProductItem('HH103', 'bra ren', 100000, 98000, 90000, 80000),
      ProductItem('HH104', 'bra ren dài', 120000, 118000, 110000, 100000),
      ProductItem('HH105', 'bra su', 90000, 88000, 80000, 70000),
      ProductItem('HH106', 'bra su 2511', 180000, 178000, 170000, 160000),
      ProductItem('HH107', 'Bra su đen', 118000, 116000, 108000, 98000),
      ProductItem('HH108', 'bra su đen trơn', 118000, 116000, 108000, 98000),
      ProductItem('HH109', 'Bra su kem', 118000, 116000, 108000, 98000),
      ProductItem('HH110', 'bra su kem trơn', 118000, 116000, 108000, 98000),
      ProductItem('HH111', 'Bra su nâu', 118000, 116000, 108000, 98000),
      ProductItem('HH112', 'bra su nâu trơn', 118000, 116000, 108000, 98000),
      ProductItem('HH113', 'Bra su trắng', 118000, 116000, 108000, 98000),
      ProductItem('HH114', 'Đồ bộ hàng thun', 150000, 148000, 140000, 130000),
      ProductItem('HH115', 'Mũ', 45000, 43000, 35000, 25000),
      ProductItem('HH117', 'Quần 2794-8537', 190000, 188000, 180000, 170000),
      ProductItem('HH118', 'Quần 602', 33000, 31000, 23000, 13000),
      ProductItem('HH120', 'Quần 643+9120', 99500, 97500, 89500, 79500),
      ProductItem('HH121', 'Quần 6605', 35000, 33000, 25000, 15000),
      ProductItem('HH122', 'Quần 8250', 42000, 40000, 32000, 22000),
      ProductItem('HH123', 'Quần 9356', 40000, 38000, 30000, 20000),
      ProductItem('HH124', 'Quần định hình nữ', 105000, 103000, 95000, 85000),
      ProductItem('HH125', 'Quần gen định hình', 110000, 108000, 100000, 90000),
      ProductItem('HH126', 'Quẩn lelgin', 200000, 198000, 190000, 180000),
      ProductItem('HH127', 'quần lót', 35500, 33500, 25500, 15500),
      ProductItem('HH128', 'quần lót 8760', 38500, 36500, 28500, 18500),
      ProductItem('HH130', 'quần sịp hộp nam', 154000, 152000, 144000, 134000),
      ProductItem('HH131', 'quần su', 79000, 77000, 69000, 59000),
      ProductItem(
        'HH132',
        'Set quần chíp hình chữ',
        215000,
        213000,
        205000,
        195000,
      ),
      ProductItem(
        'HH133',
        'Set quần chíp sọc caro',
        215000,
        213000,
        205000,
        195000,
      ),
      ProductItem(
        'HH134',
        'Set quần lót nam hộp cam',
        200000,
        198000,
        190000,
        180000,
      ),
      ProductItem(
        'HH135',
        'Set quần lót nam hộp vàng',
        200000,
        198000,
        190000,
        180000,
      ),
      ProductItem('HH136', 'Tất', 60000, 58000, 50000, 40000),
    ];
  }

  double parseNumber(String val) {
    String cleanStr = val.replaceAll(RegExp(r'\D'), '');
    return cleanStr.isEmpty ? 0 : double.parse(cleanStr);
  }

  double getTierPrice(ProductItem p, int q) {
    if (q > 100) return p.over100;
    if (q >= 50) return p.under100;
    if (q >= 10) return p.under50;
    return p.retail;
  }

  void _generateData() {
    setState(() => isGenerating = true);

    List<ProductItem> validProducts =
        priceList
            .where((p) => p.id.isNotEmpty && p.name.isNotEmpty && p.retail > 0)
            .toList();

    if (validProducts.isEmpty) {
      _showError("Vui lòng nhập ít nhất 1 sản phẩm hợp lệ!");
      setState(() => isGenerating = false);
      return;
    }

    List<ResultRow> results = [];
    int stt = 1;

    for (var req in invoiceRequests) {
      if (req.revenue <= 0 || req.customer.isEmpty) continue;

      if (req.lines > validProducts.length) {
        _showError(
          'Khách hàng "${req.customer}" cần ${req.lines} mã SP, nhưng kho chỉ có ${validProducts.length} mã!',
        );
        setState(() => isGenerating = false);
        return;
      }

      double remainingRevenue = req.revenue;
      List<ResultRow> invoiceRows = [];
      List<ProductItem> availableProducts = List.from(validProducts);
      final random = Random();

      for (int i = 1; i <= req.lines; i++) {
        int remainingLines = req.lines - i + 1;

        if (i < req.lines) {
          double avgPriceRemaining =
              availableProducts.fold(0.0, (sum, p) => sum + p.retail) /
              availableProducts.length;

          double idealQ =
              (remainingRevenue / avgPriceRemaining) / remainingLines;
          int targetQ = max(5, (idealQ / 5).round() * 5);

          int randomIndex = random.nextInt(availableProducts.length);
          ProductItem product = availableProducts.removeAt(randomIndex);

          double variance = 0.7 + random.nextDouble() * 0.6;
          int q = max(5, ((targetQ * variance) / 5).round() * 5);

          double p = getTierPrice(product, q);
          double total = q * p;

          double minPriceLeft = availableProducts
              .map((e) => e.retail)
              .reduce(min);
          double maxAllowedTotal =
              remainingRevenue - (minPriceLeft * 5 * (remainingLines - 1));

          if (total > maxAllowedTotal) {
            q = max(5, (maxAllowedTotal / p / 5).floor() * 5);
            total = q * p;
          }

          remainingRevenue -= total;
          invoiceRows.add(
            ResultRow(
              invoiceRevenue: req.revenue,
              customer: req.customer,
              productCode: product.id,
              productName: product.name,
              price: p,
              quantity: q,
              total: total,
            ),
          );
        } else {
          // --- THUẬT TOÁN QUÉT TOÀN CỤC DÒNG CUỐI (GLOBAL SEARCH) ---
          double avgQSoFar = 5;
          if (invoiceRows.isEmpty) {
            double avgPrice =
                availableProducts.fold(0.0, (sum, p) => sum + p.retail) /
                availableProducts.length;
            avgQSoFar = max(5, remainingRevenue / avgPrice);
          } else {
            avgQSoFar = max(
              5,
              invoiceRows.map((e) => e.quantity).reduce((a, b) => a + b) /
                  invoiceRows.length,
            );
          }

          ProductItem? bestMatchProduct;
          int bestQ = 5;
          double bestP = 0;
          double minScore = double.infinity;

          for (var product in availableProducts) {
            int maxQ = max(
              500,
              (remainingRevenue / (product.retail * 0.5)).ceil(),
            );

            for (int q = 5; q <= maxQ; q += 5) {
              double p = remainingRevenue / q;
              bool isInteger = (remainingRevenue % q == 0);
              double standardPrice = getTierPrice(product, q);

              // LUẬT TRẦN GIÁ (Theo đúng yêu cầu kế toán)
              double maxP = 0;
              if (q > 100)
                maxP = product.under100 > 0 ? product.under100 : product.retail;
              else if (q >= 50)
                maxP = product.under50 > 0 ? product.under50 : product.retail;
              else if (q >= 10)
                maxP = product.retail;
              else
                maxP = product.retail * 1.05;

              double priceError = (p - standardPrice).abs() / standardPrice;
              double score = priceError;

              if (p > maxP) score += 1000;
              if (p < standardPrice * 0.85) score += 500;
              if (!isInteger) score += 50;

              double qDiff = (q - avgQSoFar).abs() / avgQSoFar;
              score += qDiff * 0.2;

              if (score < minScore) {
                minScore = score;
                bestMatchProduct = product;
                bestQ = q;
                bestP = p;
              }
            }
          }

          if (bestMatchProduct != null) {
            availableProducts.removeWhere((p) => p.id == bestMatchProduct!.id);
          } else {
            bestMatchProduct = availableProducts[0];
            bestQ = max(5, (avgQSoFar / 5).round() * 5);
            bestP = remainingRevenue / bestQ;
          }

          invoiceRows.add(
            ResultRow(
              invoiceRevenue: req.revenue,
              customer: req.customer,
              productCode: bestMatchProduct.id,
              productName: bestMatchProduct.name,
              price: bestP,
              quantity: bestQ,
              total: remainingRevenue,
            ),
          );
        }
      }

      if (invoiceRows.isNotEmpty) {
        invoiceRows[0].stt = stt.toString();
        stt++;
      }
      results.addAll(invoiceRows);
    }

    setState(() {
      generatedData = results;
      isGenerating = false;
    });
  }

  void _copyTableToClipboard() {
    if (generatedData.isEmpty) return;

    StringBuffer buffer = StringBuffer();
    // Header cột cách nhau bởi Tab (\t) để dán chuẩn form cột Excel
    buffer.writeln(
      'STT\tDOANH THU\tTÊN KHÁCH\tMÃ HÀNG\tTÊN HÀNG\tĐƠN GIÁ\tSỐ LƯỢNG\tTHÀNH TIỀN',
    );

    // Nạp dữ liệu từng dòng (Xuất giá trị số gốc để Excel hiểu là Số)
    for (var row in generatedData) {
      buffer.writeln(
        '${row.stt}\t${row.invoiceRevenue.toInt()}\t${row.customer}\t${row.productCode}\t${row.productName}\t${row.price.toInt()}\t${row.quantity}\t${row.total.toInt()}',
      );
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Đã sao chép Bảng 3! (Bạn có thể Paste trực tiếp vào Excel)',
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.calculate, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Tool Chia Doanh Thu (Flutter Web)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[700],
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPriceListCard(),
            const SizedBox(height: 20),
            _buildInvoiceCard(),
            const SizedBox(height: 20),
            if (generatedData.isNotEmpty) _buildResultCard(),
          ],
        ),
      ),
    );
  }

  // --- UI BẢNG 1: KHO HÀNG ---
  Widget _buildPriceListCard() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.table_chart, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  '1. Bảng Giá Nguồn (Database 117 SP)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 350, // Giới hạn chiều cao để cuộn nội bộ
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Mã hàng',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Tên Hàng',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Đơn giá lẻ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        'Giá <50C',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        'Giá <100C',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        'Giá >100C',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      numeric: true,
                    ),
                  ],
                  rows:
                      priceList.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                item.id,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            DataCell(Text(item.name)),
                            DataCell(
                              Text(
                                _currencyFormat.format(item.retail),
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(_currencyFormat.format(item.under50)),
                            ),
                            DataCell(
                              Text(_currencyFormat.format(item.under100)),
                            ),
                            DataCell(
                              Text(
                                _currencyFormat.format(item.over100),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI BẢNG 2: NHẬP HÓA ĐƠN ---
  Widget _buildInvoiceCard() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.request_quote, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      '2. Nhập Doanh Thu Mục Tiêu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: isGenerating ? null : _generateData,
                  icon: const Icon(Icons.auto_fix_high),
                  label: Text(
                    isGenerating ? 'Đang tính...' : 'Chạy Thuật Toán',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...invoiceRequests.asMap().entries.map((entry) {
                  int idx = entry.key;
                  InvoiceRequest req = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            initialValue: req.customer,
                            decoration: const InputDecoration(
                              labelText: 'Tên Khách Hàng',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) => req.customer = val,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            initialValue:
                                req.revenue > 0
                                    ? _currencyFormat.format(req.revenue)
                                    : '',
                            decoration: const InputDecoration(
                              labelText: 'Tổng Doanh Thu',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) => req.revenue = parseNumber(val),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: req.lines.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Số Dòng SP',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged:
                                (val) => req.lines = int.tryParse(val) ?? 1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            if (invoiceRequests.length > 1) {
                              setState(() => invoiceRequests.removeAt(idx));
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        invoiceRequests.add(
                          InvoiceRequest(
                            id: DateTime.now().millisecondsSinceEpoch,
                            lines: 1,
                          ),
                        );
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm Khách Hàng'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UI BẢNG 3: KẾT QUẢ --
  Widget _buildResultCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.green, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      '3. Bảng Kết Quả Tính Toán',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _copyTableToClipboard,
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Sao Chép (Dán Excel)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Scrollbar(
            controller: _resultScrollController,
            thumbVisibility:
                true, // Luôn hiển thị thanh cuộn ngang để dễ thao tác
            child: SingleChildScrollView(
              controller: _resultScrollController,
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                columns: const [
                  DataColumn(
                    label: Text(
                      'STT',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'DOANH THU',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'TÊN KHÁCH',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'MÃ HÀNG',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'TÊN HÀNG',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'ĐƠN GIÁ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'SỐ LƯỢNG',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'THÀNH TIỀN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    numeric: true,
                  ),
                ],
                rows:
                    generatedData.map((row) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              row.stt,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              row.invoiceRevenue > 0
                                  ? _currencyFormat.format(row.invoiceRevenue)
                                  : '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              row.customer,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(Text(row.productCode)),
                          DataCell(Text(row.productName)),
                          DataCell(Text(_currencyFormat.format(row.price))),
                          DataCell(
                            Text(
                              _currencyFormat.format(row.quantity),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              _currencyFormat.format(row.total),
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
