import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

const ink = Color(0xFF15243B);
const forest = Color(0xFF3659E3);
const mint = Color(0xFFEDF1FF);
const canvas = Color(0xFFF5F7FB);
const muted = Color(0xFF68778D);
const green = Color(0xFF1B9F83);
const line = Color(0xFFEBEFF5);

ThemeData pocketTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: canvas,
  colorScheme: ColorScheme.fromSeed(seedColor: forest, surface: Colors.white),
  fontFamily: 'Roboto',
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: ink),
    bodyLarge: TextStyle(color: ink),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: canvas,
    contentPadding: const EdgeInsets.all(17),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: forest),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 19),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ),
  ),
);

enum FlowType { expense, income }

class MoneyEntry {
  MoneyEntry({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
    this.note = '',
    this.deleted = false,
  });
  String title;
  String category;
  double amount;
  DateTime date;
  FlowType type;
  String note;
  bool deleted;
}

class BudgetRing extends CustomPainter {
  const BudgetRing(this.progress, this.color);
  final double progress;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(7, 7, size.width - 14, size.height - 14);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = line);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant BudgetRing oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int tab = 0;
  String filter = 'Tất cả';
  String search = '';
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  double monthlyBudget = 6000000;
  final categories = <String>[
    'Ăn uống',
    'Di chuyển',
    'Mua sắm',
    'Hóa đơn',
    'Lương',
    'Khác',
  ];
  final entries = <MoneyEntry>[
    MoneyEntry(
      title: 'Cà phê sáng',
      category: 'Ăn uống',
      amount: 45000,
      date: DateTime.now(),
      type: FlowType.expense,
    ),
    MoneyEntry(
      title: 'Đi làm',
      category: 'Di chuyển',
      amount: 25000,
      date: DateTime.now(),
      type: FlowType.expense,
    ),
    MoneyEntry(
      title: 'Lương tháng',
      category: 'Lương',
      amount: 12000000,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: FlowType.income,
    ),
    MoneyEntry(
      title: 'Mua thực phẩm',
      category: 'Ăn uống',
      amount: 185000,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: FlowType.expense,
    ),
  ];
  final labels = const ['Tổng quan', 'Giao dịch', 'Ngân sách', 'Danh mục'];
  final navIcons = const [
    Icons.grid_view_rounded,
    Icons.swap_horiz_rounded,
    Icons.donut_large_rounded,
    Icons.widgets_outlined,
  ];

  bool _inMonth(MoneyEntry e, DateTime m) =>
      !e.deleted && e.date.year == m.year && e.date.month == m.month;
  List<MoneyEntry> get monthEntries =>
      entries.where((e) => _inMonth(e, month)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
  List<MoneyEntry> get visibleEntries => monthEntries
      .where(
        (e) =>
            (filter == 'Tất cả' ||
                (filter == 'Chi tiêu' && e.type == FlowType.expense) ||
                (filter == 'Thu nhập' && e.type == FlowType.income)) &&
            '${e.title} ${e.category} ${e.note}'.toLowerCase().contains(
              search.toLowerCase(),
            ),
      )
      .toList();
  double _total(FlowType type, DateTime m) => entries
      .where((e) => _inMonth(e, m) && e.type == type)
      .fold(0.0, (sum, e) => sum + e.amount);
  double get spent => _total(FlowType.expense, month);
  double get earned => _total(FlowType.income, month);
  double _categoryTotal(String c) => monthEntries
      .where((e) => e.type == FlowType.expense && e.category == c)
      .fold(0.0, (sum, e) => sum + e.amount);
  String money(double amount) =>
      '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')} đ';
  String compact(double n) => n >= 1000000
      ? '${(n / 1000000).toStringAsFixed(1)}tr'
      : '${(n / 1000).round()}k';
  void _shiftMonth(int n) =>
      setState(() => month = DateTime(month.year, month.month + n));

  @override
  Widget build(BuildContext context) => Theme(
    data: pocketTheme(),
    child: LayoutBuilder(
      builder: (context, box) {
        final desktop = box.maxWidth >= 1000;
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                if (desktop)
                  SizedBox(
                    width: 232,
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        child: SizedBox(
                          height: math.max(820.0, constraints.maxHeight),
                          child: _sidebar(),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      _topBar(desktop),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1460),
                              child: Padding(
                                padding: EdgeInsets.all(desktop ? 32 : 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _heading(desktop),
                                    const SizedBox(height: 26),
                                    if (tab == 0)
                                      _dashboard()
                                    else if (tab == 1)
                                      _transactions()
                                    else if (tab == 2)
                                      _budgets()
                                    else
                                      _categories(),
                                    const SizedBox(height: 24),
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.science_outlined,
                                          color: muted,
                                          size: 14,
                                        ),
                                        SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            'Bản demo • Dữ liệu mẫu được lưu trong phiên sử dụng',
                                            style: TextStyle(
                                              color: muted,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: desktop
              ? null
              : NavigationBar(
                  backgroundColor: Colors.white,
                  indicatorColor: mint,
                  height: 72,
                  selectedIndex: tab,
                  onDestinationSelected: (v) => setState(() => tab = v),
                  destinations: List.generate(
                    4,
                    (i) => NavigationDestination(
                      icon: Icon(navIcons[i], size: 22),
                      label: labels[i],
                    ),
                  ),
                ),
        );
      },
    ),
  );

  Widget _sidebar() => Container(
    width: 232,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(right: BorderSide(color: line)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _brand(),
          const SizedBox(height: 44),
          const Padding(
            padding: EdgeInsets.only(left: 14, bottom: 16),
            child: Text(
              'KHÔNG GIAN CỦA BẠN',
              style: TextStyle(
                color: muted,
                fontSize: 10,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...List.generate(
            4,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: i == tab ? mint : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => tab = i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          navIcons[i],
                          size: 21,
                          color: i == tab ? forest : muted,
                        ),
                        const SizedBox(width: 13),
                        Text(
                          labels[i],
                          style: TextStyle(
                            color: i == tab ? forest : muted,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        if (i == tab)
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: forest,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: canvas,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome_rounded, color: forest, size: 26),
                const SizedBox(height: 12),
                const Text(
                  'Mỗi khoản nhỏ,\nmột mục tiêu lớn.',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bắt đầu thói quen chi tiêu có kế hoạch ngay hôm nay.',
                  style: TextStyle(color: muted, fontSize: 12, height: 1.6),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() => tab = 2),
                  child: const Text('Xem ngân sách  →'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'PocketBudget © 2026',
            style: TextStyle(fontSize: 11, color: muted),
          ),
        ],
      ),
    ),
  );

  Widget _brand() => Row(
    children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: forest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.account_balance_wallet_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
      const SizedBox(width: 10),
      const Text(
        'PocketBudget',
        style: TextStyle(
          color: ink,
          fontWeight: FontWeight.w800,
          fontSize: 19,
          letterSpacing: -.5,
        ),
      ),
    ],
  );
  Widget _topBar(bool desktop) => Container(
    height: 82,
    padding: EdgeInsets.symmetric(horizontal: desktop ? 32 : 20),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: line)),
    ),
    child: Row(
      children: [
        if (desktop) ...[
          const Text(
            'Tài chính cá nhân',
            style: TextStyle(color: muted, fontSize: 13),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.chevron_right, color: muted, size: 16),
          ),
          Text(
            labels[tab],
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ] else
          _brand(),
        const Spacer(),
        if (desktop)
          const Padding(
            padding: EdgeInsets.only(right: 24),
            child: Text(
              'Theo dõi hôm nay. An tâm ngày mai.',
              style: TextStyle(color: muted, fontSize: 12),
            ),
          ),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE8CC),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Center(
            child: Text(
              'A',
              style: TextStyle(
                color: Color(0xFFB77C30),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        if (desktop)
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thế An',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                Text(
                  'Tài khoản cá nhân',
                  style: TextStyle(color: muted, fontSize: 11),
                ),
              ],
            ),
          ),
      ],
    ),
  );

  Widget _heading(bool desktop) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tab == 0 ? 'Chào An, một ngày tốt lành!' : labels[tab],
                  style: TextStyle(
                    fontSize: desktop ? 28 : 24,
                    fontWeight: FontWeight.w800,
                    color: ink,
                    letterSpacing: -.7,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  [
                    'Cùng nhìn lại bức tranh tài chính của bạn.',
                    'Mỗi khoản thu chi đều được ghi nhớ.',
                    'Chi tiêu trong kế hoạch, tiến gần mục tiêu.',
                    'Sắp xếp khoản thu chi theo cách của bạn.',
                  ][tab],
                  style: const TextStyle(
                    color: muted,
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (desktop) _addButton(),
        ],
      ),
      const SizedBox(height: 20),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Tháng trước',
                  onPressed: () => _shiftMonth(-1),
                  icon: const Icon(Icons.chevron_left, size: 19),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: forest,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tháng ${month.month}, ${month.year}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                IconButton(
                  tooltip: 'Tháng sau',
                  onPressed: () => _shiftMonth(1),
                  icon: const Icon(Icons.chevron_right, size: 19),
                ),
              ],
            ),
          ),

          if (!desktop) _addButton(compact: true),
        ],
      ),
    ],
  );
  Widget _addButton({bool compact = false}) => FilledButton.icon(
    onPressed: () => _showEntryForm(),
    icon: const Icon(Icons.add, size: 18),
    label: Text(compact ? 'Thêm' : 'Thêm giao dịch'),
  );
  Widget _panel(
    Widget child, {
    EdgeInsets padding = const EdgeInsets.all(24),
  }) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: line),
    ),
    child: child,
  );
  Widget _section(String title, String subtitle, {Widget? trailing}) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: ink,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: muted, fontSize: 12)),
          ],
        ),
      ),
      ?trailing,
    ],
  );

  Widget _dashboard() => LayoutBuilder(
    builder: (context, box) {
      final wide = box.maxWidth >= 830;
      final left = Column(
        children: [
          _cashCard(),
          const SizedBox(height: 20),
          _chart(),
          const SizedBox(height: 20),
          _panel(
            Column(
              children: [
                _section(
                  'Giao dịch gần đây',
                  '${monthEntries.length} giao dịch trong tháng',
                  trailing: TextButton(
                    onPressed: () => setState(() => tab = 1),
                    child: const Text('Xem tất cả  →'),
                  ),
                ),
                const SizedBox(height: 16),
                if (monthEntries.isEmpty)
                  _empty()
                else
                  ...monthEntries.take(4).map(_entryTile),
              ],
            ),
          ),
        ],
      );
      final right = Column(
        children: [
          _budgetSummary(),
          const SizedBox(height: 20),
          _categoryBreakdown(),
          const SizedBox(height: 20),
          _insight(),
        ],
      );
      if (wide)
      {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: left),
            const SizedBox(width: 22),
            Expanded(flex: 4, child: right),
          ],
        );
      }
      return Column(children: [left, const SizedBox(height: 20), right]);
    },
  );

  Widget _cashCard() => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF273C9D), Color(0xFF4C6BE8)],
      ),
    ),
    child: Stack(
      children: [
        Positioned(
          right: -70,
          top: -75,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: .07),
                width: 40,
              ),
            ),
          ),
        ),
        Positioned(
          right: -110,
          bottom: -130,
          child: Container(
            width: 310,
            height: 310,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: .07),
                width: 50,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Dòng tiền ròng',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Text(
                      'VND',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  money(earned - spent),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    letterSpacing: -1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Thu nhập − chi tiêu trong tháng đã chọn',
                style: TextStyle(color: Colors.white60, fontSize: 11),
              ),
              const SizedBox(height: 26),
              Container(height: 1, color: Colors.white.withValues(alpha: .15)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _flowStat('Thu nhập', earned, true)),
                  Container(
                    width: 1,
                    height: 35,
                    color: Colors.white.withValues(alpha: .15),
                  ),
                  const SizedBox(width: 22),
                  Expanded(child: _flowStat('Chi tiêu', spent, false)),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
  Widget _flowStat(String label, double value, bool income) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          income ? Icons.south_west : Icons.north_east,
          color: income ? const Color(0xFF94E8CE) : const Color(0xFFFFCDA8),
          size: 16,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                money(value),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _chart() {
    final months = List.generate(
      6,
      (i) => DateTime(month.year, month.month - 5 + i),
    );
    final incomes = months.map((m) => _total(FlowType.income, m)).toList();
    final expenses = months.map((m) => _total(FlowType.expense, m)).toList();
    final maxValue = math.max(1.0, [...incomes, ...expenses].reduce(math.max));
    return _panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('Nhịp tài chính', 'Thu nhập & chi tiêu trong 6 tháng'),
          const SizedBox(height: 20),
          Row(
            children: [
              _legend('Thu nhập', forest),
              const SizedBox(width: 18),
              _legend('Chi tiêu', const Color(0xFF82D4C4)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 164,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      compact(maxValue),
                      style: const TextStyle(color: muted, fontSize: 10),
                    ),
                    Text(
                      compact(maxValue / 2),
                      style: const TextStyle(color: muted, fontSize: 10),
                    ),
                    const Text(
                      '0',
                      style: TextStyle(color: muted, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          3,
                          (_) => Container(height: 1, color: line),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(
                          6,
                          (i) => Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _bar(incomes[i], maxValue, forest),
                                const SizedBox(width: 4),
                                _bar(
                                  expenses[i],
                                  maxValue,
                                  const Color(0xFF82D4C4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 42),
            child: Row(
              children: months
                  .map(
                    (m) => Expanded(
                      child: Center(
                        child: Text(
                          'T${m.month}',
                          style: const TextStyle(color: muted, fontSize: 11),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(double value, double max, Color color) => Flexible(
    child: Tooltip(
      message: money(value),
      child: Container(
        width: 18,
        height: value == 0 ? 3 : 150 * value / max + 3,
        decoration: BoxDecoration(
          color: value == 0 ? line : color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
        ),
      ),
    ),
  );
  Widget _legend(String text, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(color: muted, fontSize: 11)),
    ],
  );

  Widget _budgetSummary() {
    final ratio = spent / monthlyBudget;
    final warning = ratio >= .8;
    return _panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section(
            'Ngân sách tháng',
            'Chi tiêu trong tầm kiểm soát',
            trailing: IconButton(
              tooltip: 'Sửa hạn mức',
              onPressed: _editBudget,
              icon: const Icon(Icons.tune_rounded, size: 18, color: muted),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 162,
              height: 162,
              child: CustomPaint(
                painter: BudgetRing(
                  ratio.clamp(0.0, 1.0),
                  warning ? const Color(0xFFEF9B43) : forest,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(ratio * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'đã sử dụng',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _amountRow('Đã chi tiêu', money(spent), forest),
          const SizedBox(height: 12),
          _amountRow('Hạn mức tháng', money(monthlyBudget), muted),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: warning
                  ? const Color(0xFFFFF3E7)
                  : const Color(0xFFEFF9F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  warning ? Icons.info_outline : Icons.check_circle_outline,
                  color: warning ? Colors.orange : green,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ratio > 1
                        ? 'Đã vượt ${money(spent - monthlyBudget)}'
                        : 'Còn lại ${money(monthlyBudget - spent)}',
                    style: TextStyle(
                      color: warning ? const Color(0xFFB47C28) : green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountRow(String label, String value, Color color) => Row(
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 7),
      Text(label, style: const TextStyle(color: muted, fontSize: 12)),
      const Spacer(),
      Text(
        value,
        style: const TextStyle(
          color: ink,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
  Widget _categoryBreakdown() => _panel(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section('Tiền đã đi đâu?', 'Chi tiêu theo danh mục'),
        const SizedBox(height: 20),
        if (spent == 0)
          const Text(
            'Chưa có chi tiêu trong tháng này.',
            style: TextStyle(color: muted, fontSize: 12),
          )
        else
          ...categories
              .where((c) => _categoryTotal(c) > 0)
              .map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 17),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(_icon(c), size: 16, color: _color(c)),
                          const SizedBox(width: 8),
                          Text(c, style: const TextStyle(fontSize: 12)),
                          const Spacer(),
                          Text(
                            money(_categoryTotal(c)),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      LinearProgressIndicator(
                        value: _categoryTotal(c) / spent,
                        backgroundColor: canvas,
                        color: _color(c),
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    ),
  );
  Widget _insight() => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF5E5),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFFFECD0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.lightbulb_outline, color: Color(0xFFCA913E), size: 25),
        const SizedBox(height: 12),
        const Text(
          'Một chút mỗi ngày',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ghi lại khoản chi ngay sau khi thanh toán. Một thói quen nhỏ giúp bạn hiểu rõ hơn về tài chính của mình.',
          style: TextStyle(fontSize: 12, color: Color(0xFFA0896B), height: 1.7),
        ),
      ],
    ),
  );

  Widget _transactions() => _panel(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section(
          'Sổ giao dịch',
          '${visibleEntries.length} kết quả trong tháng đã chọn',
        ),
        const SizedBox(height: 20),
        TextField(
          onChanged: (v) => setState(() => search = v),
          decoration: const InputDecoration(
            hintText: 'Tìm theo tên, danh mục hoặc ghi chú...',
            prefixIcon: Icon(Icons.search_rounded, color: muted),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          children: ['Tất cả', 'Chi tiêu', 'Thu nhập']
              .map(
                (f) => ChoiceChip(
                  label: Text(f, style: const TextStyle(fontSize: 12)),
                  selected: filter == f,
                  selectedColor: mint,
                  showCheckmark: false,
                  side: BorderSide(
                    color: f == filter ? forest.withValues(alpha: .2) : line,
                  ),
                  onSelected: (_) => setState(() => filter = f),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        if (visibleEntries.isEmpty)
          _empty()
        else
          ...visibleEntries.map(_entryTile),
      ],
    ),
  );

  Widget _entryTile(MoneyEntry e) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showEntryForm(entry: e),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 3),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: _color(e.category).withValues(alpha: .10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                _icon(e.category),
                color: _color(e.category),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${e.category} · ${e.date.day.toString().padLeft(2, '0')}/${e.date.month.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 11, color: muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${e.type == FlowType.income ? '+' : '−'}${money(e.amount)}',
              style: TextStyle(
                color: e.type == FlowType.income ? green : ink,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            SizedBox(
              width: 30,
              child: PopupMenuButton<String>(
                tooltip: 'Tùy chọn',
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_horiz, size: 18, color: muted),
                onSelected: (v) {
                  if (v == 'edit') {
                    _showEntryForm(entry: e);
                  } else {
                    setState(() => e.deleted = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Đã xóa giao dịch'),
                        action: SnackBarAction(
                          label: 'Hoàn tác',
                          onPressed: () => setState(() => e.deleted = false),
                        ),
                      ),
                    );
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                  PopupMenuItem(value: 'delete', child: Text('Xóa giao dịch')),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  Widget _empty() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 36),
    child: Center(
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, color: muted, size: 36),
          SizedBox(height: 12),
          Text(
            'Chưa có giao dịch',
            style: TextStyle(color: ink, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            'Thêm khoản thu chi đầu tiên để bắt đầu.',
            style: TextStyle(color: muted, fontSize: 12),
          ),
        ],
      ),
    ),
  );

  Widget _budgets() => LayoutBuilder(
    builder: (context, box) {
      final detail = _panel(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section(
              'Chi tiết sử dụng',
              'Tỷ trọng từng danh mục trong hạn mức tổng',
            ),
            const SizedBox(height: 24),
            ...categories
                .where((c) => c != 'Lương')
                .map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(_icon(c), color: _color(c), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                c,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              money(_categoryTotal(c)),
                              style: const TextStyle(
                                fontSize: 12,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: (_categoryTotal(c) / monthlyBudget).clamp(
                            0.0,
                            1.0,
                          ),
                          minHeight: 7,
                          backgroundColor: canvas,
                          color: _color(c),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      );
      if (box.maxWidth > 750)
      {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 330, child: _budgetSummary()),
            const SizedBox(width: 22),
            Expanded(child: detail),
          ],
        );
      }
      return Column(
        children: [_budgetSummary(), const SizedBox(height: 20), detail],
      );
    },
  );
  Widget _categories() => _panel(
    Column(
      children: [
        _section(
          'Danh mục của bạn',
          '${categories.length} danh mục thu chi',
          trailing: IconButton.filledTonal(
            tooltip: 'Thêm danh mục',
            onPressed: _addCategory,
            icon: const Icon(Icons.add),
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, box) {
            final columns = box.maxWidth > 750
                ? 3
                : box.maxWidth > 400
                ? 2
                : 1;
            final width = (box.maxWidth - 14 * (columns - 1)) / columns;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: categories
                  .map(
                    (c) => SizedBox(
                      width: width,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: canvas,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: line),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _color(c).withValues(alpha: .12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _icon(c),
                                    color: _color(c),
                                    size: 20,
                                  ),
                                ),
                                const Spacer(),
                                if (!const [
                                  'Ăn uống',
                                  'Di chuyển',
                                  'Mua sắm',
                                  'Hóa đơn',
                                  'Lương',
                                  'Khác',
                                ].contains(c))
                                  IconButton(
                                    tooltip: 'Xóa danh mục',
                                    onPressed: () {
                                      if (entries.any((e) => e.category == c)) {
                                        _snack(
                                          'Danh mục đã có giao dịch, không thể xóa.',
                                        );
                                      } else {
                                        setState(() => categories.remove(c));
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: muted,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              c,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${c == 'Lương' ? 'Thu nhập' : 'Chi tiêu'} · ${monthEntries.where((e) => e.category == c).length} giao dịch',
                              style: const TextStyle(
                                color: muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    ),
  );

  Future<void> _editBudget() async {
    final controller = TextEditingController(
      text: monthlyBudget.toStringAsFixed(0),
    );
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hạn mức tháng'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Số tiền (VND)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(
                controller.text.replaceAll('.', '').replaceAll(',', ''),
              );
              if (value != null && value.isFinite && value > 0) {
                Navigator.pop(ctx, value);
              }
            },
            child: const Text('Lưu hạn mức'),
          ),
        ],
      ),
    );
    if (result != null && mounted) setState(() => monthlyBudget = result);
  }

  Color _color(String c) => switch (c) {
    'Ăn uống' => const Color(0xFFE3A24B),
    'Di chuyển' => forest,
    'Mua sắm' => const Color(0xFFAD81D6),
    'Hóa đơn' => const Color(0xFFDE827C),
    'Lương' => green,
    _ => const Color(0xFF68ABB1),
  };

  // Transaction editor and category dialog are retained below.
  Future<void> _showEntryForm({MoneyEntry? entry}) async {
    final title = TextEditingController(text: entry?.title ?? '');
    final amount = TextEditingController(
      text: entry == null ? '' : entry.amount.toStringAsFixed(0),
    );
    final note = TextEditingController(text: entry?.note ?? '');
    var type = entry?.type ?? FlowType.expense;
    var category = entry?.category ?? categories.first;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 580),
      builder: (context) => StatefulBuilder(
        builder: (context, refresh) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry == null ? 'Thêm giao dịch' : 'Chỉnh sửa giao dịch',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SegmentedButton<FlowType>(
                  segments: const [
                    ButtonSegment(
                      value: FlowType.expense,
                      label: Text('Chi tiêu'),
                      icon: Icon(Icons.north_east),
                    ),
                    ButtonSegment(
                      value: FlowType.income,
                      label: Text('Thu nhập'),
                      icon: Icon(Icons.south_west),
                    ),
                  ],
                  selected: {type},
                  onSelectionChanged: (v) => refresh(() {
                    type = v.first;
                    category = type == FlowType.income
                        ? (categories.contains('Lương')
                              ? 'Lương'
                              : categories.first)
                        : categories.first;
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Tên giao dịch'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Số tiền (VND)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: ValueKey(category),
                  initialValue: categories.contains(category)
                      ? category
                      : categories.first,
                  decoration: const InputDecoration(labelText: 'Danh mục'),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) refresh(() => category = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: note,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú (không bắt buộc)',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      final n = double.tryParse(
                        amount.text.replaceAll('.', '').replaceAll(',', ''),
                      );
                      if (title.text.trim().isEmpty ||
                          n == null ||
                          !n.isFinite ||
                          n <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Nhập tên và số tiền hợp lệ lớn hơn 0',
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context, true);
                    },
                    child: const Text('Lưu giao dịch'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (saved == true && mounted)
    {
      setState(() {
        if (entry == null)
        {
          entries.add(
            MoneyEntry(
              title: title.text.trim(),
              amount: double.parse(
                amount.text.replaceAll('.', '').replaceAll(',', ''),
              ),
              category: category,
              type: type,
              date: DateTime.now(),
              note: note.text.trim(),
            ),
          );
        }
        else {
          entry.title = title.text.trim();
          entry.amount = double.parse(
            amount.text.replaceAll('.', '').replaceAll(',', ''),
          );
          entry.category = category;
          entry.type = type;
          entry.note = note.text.trim();
        }
      });
    }
  }

  Future<void> _addCategory() async {
    final c = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Danh mục mới'),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Ví dụ: Học tập'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, c.text.trim()),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && !categories.contains(result))
    {
      setState(() => categories.add(result));
    }
  }

  IconData _icon(String name) => switch (name) {
    'Ăn uống' => Icons.restaurant,
    'Di chuyển' => Icons.directions_bus,
    'Mua sắm' => Icons.shopping_bag,
    'Hóa đơn' => Icons.receipt,
    'Lương' => Icons.payments,
    _ => Icons.more_horiz,
  };
  void _snack(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
}
