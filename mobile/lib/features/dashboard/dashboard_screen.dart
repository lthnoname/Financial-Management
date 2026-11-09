import 'package:flutter/material.dart';

const ink = Color(0xFF18261F);
const forest = Color(0xFF176B4D);
const mint = Color(0xFFE8F4EC);
const canvas = Color(0xFFF7F8F5);

enum FlowType { expense, income }

class MoneyEntry {
  MoneyEntry({required this.title, required this.category, required this.amount,
    required this.date, required this.type, this.note = '', this.deleted = false});
  String title;
  String category;
  double amount;
  DateTime date;
  FlowType type;
  String note;
  bool deleted;
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int tab = 0;
  String filter = 'Tất cả';
  double monthlyBudget = 6000000;
  final categories = <String>['Ăn uống', 'Di chuyển', 'Mua sắm', 'Hóa đơn', 'Lương', 'Khác'];
  final entries = <MoneyEntry>[
    MoneyEntry(title: 'Cà phê sáng', category: 'Ăn uống', amount: 45000, date: DateTime.now(), type: FlowType.expense),
    MoneyEntry(title: 'Đi làm', category: 'Di chuyển', amount: 25000, date: DateTime.now(), type: FlowType.expense),
    MoneyEntry(title: 'Lương tháng', category: 'Lương', amount: 12000000, date: DateTime.now().subtract(const Duration(days: 1)), type: FlowType.income),
    MoneyEntry(title: 'Mua thực phẩm', category: 'Ăn uống', amount: 185000, date: DateTime.now().subtract(const Duration(days: 1)), type: FlowType.expense),
  ];

  List<MoneyEntry> get visibleEntries => entries.where((e) => !e.deleted &&
      (filter == 'Tất cả' || (filter == 'Chi tiêu' && e.type == FlowType.expense) || (filter == 'Thu nhập' && e.type == FlowType.income))).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
  double get spent => entries.where((e) => !e.deleted && e.type == FlowType.expense && e.date.month == DateTime.now().month).fold(0, (a, e) => a + e.amount);
  double get earned => entries.where((e) => !e.deleted && e.type == FlowType.income && e.date.month == DateTime.now().month).fold(0, (a, e) => a + e.amount);
  String money(double amount) => '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')} đ';

  @override
  Widget build(BuildContext context) {
    final pages = [_dashboard(), _transactions(), _budgets(), _categories()];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: canvas,
        title: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: forest, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 21)),
          const SizedBox(width: 10), const Text('PocketBudget', style: TextStyle(fontWeight: FontWeight.w800, color: ink)),
        ]),
        actions: [IconButton(onPressed: () => _snack('Xin chào, An!'), icon: const CircleAvatar(backgroundColor: mint, child: Text('A', style: TextStyle(color: forest, fontWeight: FontWeight.bold))))],
      ),
      body: SafeArea(child: IndexedStack(index: tab, children: pages)),
      floatingActionButton: tab < 2 ? FloatingActionButton.extended(onPressed: _showEntryForm, backgroundColor: forest, foregroundColor: Colors.white, icon: const Icon(Icons.add), label: const Text('Thêm giao dịch')) : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.space_dashboard_outlined), selectedIcon: Icon(Icons.space_dashboard), label: 'Tổng quan'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Giao dịch'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline), selectedIcon: Icon(Icons.pie_chart), label: 'Ngân sách'),
          NavigationDestination(icon: Icon(Icons.category_outlined), selectedIcon: Icon(Icons.category), label: 'Danh mục'),
        ],
      ),
    );
  }

  Widget _dashboard() => ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 100), children: [
    const Text('Thứ Hai, 09 tháng 11', style: TextStyle(color: Colors.black54)),
    const SizedBox(height: 4), const Text('Tài chính của bạn', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: ink)),
    const SizedBox(height: 18),
    Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF176B4D), Color(0xFF27956B)]), borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('DÒNG TIỀN THÁNG NÀY', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8), Text(money(earned - spent), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
      const SizedBox(height: 18), Row(children: [Expanded(child: _miniStat('Thu nhập', earned, Icons.south_west)), const SizedBox(width: 16), Expanded(child: _miniStat('Chi tiêu', spent, Icons.north_east))]),
    ])),
    const SizedBox(height: 18),
    Row(children: [Expanded(child: _statCard('Ngân sách tháng', money(monthlyBudget), Icons.account_balance_wallet_outlined, const Color(0xFFE8F4EC))), const SizedBox(width: 12), Expanded(child: _statCard('Đã sử dụng', '${(spent / monthlyBudget * 100).clamp(0, 100).round()}%', Icons.donut_small, const Color(0xFFFFF2DF)))]),
    const SizedBox(height: 22),
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Chi tiêu 6 tháng', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: ink)), TextButton(onPressed: () => setState(() => tab = 2), child: const Text('Chi tiết'))]),
    _chart(),
    const SizedBox(height: 18),
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Giao dịch gần đây', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: ink)), TextButton(onPressed: () => setState(() => tab = 1), child: const Text('Tất cả'))]),
    ...visibleEntries.take(3).map(_entryTile),
  ]);

  Widget _miniStat(String label, double amount, IconData icon) => Row(children: [Icon(icon, size: 15, color: Colors.white70), const SizedBox(width: 6), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)), Text(money(amount), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]))]);
  Widget _statCard(String label, String value, IconData icon, Color bg) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [CircleAvatar(radius: 17, backgroundColor: bg, child: Icon(icon, size: 18, color: forest)), const SizedBox(height: 10), Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)), const SizedBox(height: 2), Text(value, style: const TextStyle(fontWeight: FontWeight.w800, color: ink))]));
  Widget _chart() { final values = [0.48, 0.68, 0.52, 0.82, 0.62, (spent / monthlyBudget).clamp(.12, 1.0)]; final labels = ['T6', 'T7', 'T8', 'T9', 'T10', 'T11']; return Container(height: 155, padding: const EdgeInsets.fromLTRB(18, 18, 18, 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceAround, children: List.generate(6, (i) => Column(mainAxisAlignment: MainAxisAlignment.end, children: [Container(width: 25, height: 85 * values[i] + 8, decoration: BoxDecoration(color: i == 5 ? forest : const Color(0xFFDCECE2), borderRadius: BorderRadius.circular(8))), const SizedBox(height: 8), Text(labels[i], style: TextStyle(fontSize: 11, color: i == 5 ? forest : Colors.black45, fontWeight: i == 5 ? FontWeight.bold : FontWeight.normal))]))); }

  Widget _transactions() => ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 100), children: [const Text('Giao dịch', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: ink)), const SizedBox(height: 14), Wrap(spacing: 8, children: ['Tất cả', 'Chi tiêu', 'Thu nhập'].map((f) => ChoiceChip(label: Text(f), selected: filter == f, onSelected: (_) => setState(() => filter = f))).toList()), const SizedBox(height: 12), if (visibleEntries.isEmpty) const Padding(padding: EdgeInsets.all(36), child: Center(child: Text('Chưa có giao dịch. Hãy thêm khoản đầu tiên!'))) else ...visibleEntries.map(_entryTile)]);

  Widget _entryTile(MoneyEntry entry) => Card(color: Colors.white, elevation: 0, margin: const EdgeInsets.only(bottom: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: ListTile(onTap: () => _showEntryForm(entry: entry), leading: CircleAvatar(backgroundColor: entry.type == FlowType.income ? mint : const Color(0xFFFFF0E9), child: Icon(_icon(entry.category), color: entry.type == FlowType.income ? forest : const Color(0xFFD36B43))), title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text('${entry.category} · ${entry.date.day}/${entry.date.month}'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text('${entry.type == FlowType.income ? '+' : '-'}${money(entry.amount)}', style: TextStyle(fontWeight: FontWeight.w800, color: entry.type == FlowType.income ? forest : ink)), PopupMenuButton<String>(onSelected: (v) { if (v == 'edit') _showEntryForm(entry: entry); else setState(() => entry.deleted = true); }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')), PopupMenuItem(value: 'delete', child: Text('Xóa mềm'))])])));

  Widget _budgets() => ListView(padding: const EdgeInsets.all(20), children: [const Text('Ngân sách tháng', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: ink)), const SizedBox(height: 6), const Text('Theo dõi chi tiêu trong tháng 11', style: TextStyle(color: Colors.black54)), const SizedBox(height: 20), _budgetCard('Tổng ngân sách', monthlyBudget, spent, Icons.wallet_outlined), ...categories.where((c) => c != 'Lương').map((c) { final amount = entries.where((e) => !e.deleted && e.type == FlowType.expense && e.category == c).fold<double>(0, (a, e) => a + e.amount); return _budgetCard(c, monthlyBudget / 4, amount, _icon(c)); })]);
  Widget _budgetCard(String name, double limit, double amount, IconData icon) { final ratio = (amount / limit).clamp(0.0, 1.0); return Card(color: Colors.white, elevation: 0, margin: const EdgeInsets.only(bottom: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Row(children: [CircleAvatar(backgroundColor: mint, child: Icon(icon, color: forest)), const SizedBox(width: 12), Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))), Text('${(ratio * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: forest))]), const SizedBox(height: 14), LinearProgressIndicator(value: ratio, minHeight: 8, borderRadius: BorderRadius.circular(8), color: ratio >= .8 ? Colors.orange : forest, backgroundColor: mint), const SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Đã chi ${money(amount)}', style: const TextStyle(fontSize: 12, color: Colors.black54)), Text('Hạn mức ${money(limit)}', style: const TextStyle(fontSize: 12, color: Colors.black54))])]))); }

  Widget _categories() => ListView(padding: const EdgeInsets.all(20), children: [Row(children: [const Expanded(child: Text('Danh mục', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: ink))), IconButton.filled(onPressed: _addCategory, icon: const Icon(Icons.add))]), const Text('Quản lý danh mục thu và chi', style: TextStyle(color: Colors.black54)), const SizedBox(height: 14), ...categories.map((c) => Card(color: Colors.white, elevation: 0, child: ListTile(leading: CircleAvatar(backgroundColor: mint, child: Icon(_icon(c), color: forest)), title: Text(c), subtitle: Text(c == 'Lương' ? 'Thu nhập' : 'Chi tiêu'), trailing: categories.length > 1 ? IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => setState(() { categories.remove(c); for (final e in entries) { if (e.category == c) e.category = 'Khác'; } })) : null)))]);

  Future<void> _showEntryForm({MoneyEntry? entry}) async {
    final title = TextEditingController(text: entry?.title ?? ''); final amount = TextEditingController(text: entry == null ? '' : entry.amount.toStringAsFixed(0)); final note = TextEditingController(text: entry?.note ?? '');
    var type = entry?.type ?? FlowType.expense; var category = entry?.category ?? categories.first;
    final saved = await showModalBottomSheet<bool>(context: context, isScrollControlled: true, backgroundColor: canvas, builder: (context) => StatefulBuilder(builder: (context, refresh) => Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20), child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(entry == null ? 'Thêm giao dịch' : 'Chỉnh sửa giao dịch', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 16), SegmentedButton<FlowType>(segments: const [ButtonSegment(value: FlowType.expense, label: Text('Chi tiêu'), icon: Icon(Icons.north_east)), ButtonSegment(value: FlowType.income, label: Text('Thu nhập'), icon: Icon(Icons.south_west))], selected: {type}, onSelectionChanged: (v) => refresh(() { type = v.first; category = type == FlowType.income ? (categories.contains('Lương') ? 'Lương' : categories.first) : categories.first; })), const SizedBox(height: 12), TextField(controller: title, decoration: const InputDecoration(labelText: 'Tên giao dịch', border: OutlineInputBorder())), const SizedBox(height: 12), TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số tiền (VND)', border: OutlineInputBorder())), const SizedBox(height: 12), DropdownButtonFormField<String>(value: categories.contains(category) ? category : categories.first, decoration: const InputDecoration(labelText: 'Danh mục', border: OutlineInputBorder()), items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) { if (v != null) refresh(() => category = v); }), const SizedBox(height: 12), TextField(controller: note, decoration: const InputDecoration(labelText: 'Ghi chú (không bắt buộc)', border: OutlineInputBorder())), const SizedBox(height: 16), SizedBox(width: double.infinity, child: FilledButton(onPressed: () { final n = double.tryParse(amount.text.replaceAll('.', '').replaceAll(',', '')); if (title.text.trim().isEmpty || n == null || n <= 0) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nhập tên và số tiền hợp lệ lớn hơn 0'))); return; } Navigator.pop(context, true); }, child: const Text('Lưu giao dịch')))]))));
    if (saved == true && mounted) setState(() { if (entry == null) entries.add(MoneyEntry(title: title.text.trim(), amount: double.parse(amount.text.replaceAll('.', '').replaceAll(',', '')), category: category, type: type, date: DateTime.now(), note: note.text.trim())); else { entry.title = title.text.trim(); entry.amount = double.parse(amount.text.replaceAll('.', '').replaceAll(',', '')); entry.category = category; entry.type = type; entry.note = note.text.trim(); } });
  }

  Future<void> _addCategory() async { final c = TextEditingController(); final result = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(title: const Text('Danh mục mới'), content: TextField(controller: c, autofocus: true, decoration: const InputDecoration(hintText: 'Ví dụ: Học tập')), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')), FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('Thêm'))])); if (result != null && result.isNotEmpty && !categories.contains(result)) setState(() => categories.add(result)); }
  IconData _icon(String name) => switch (name) { 'Ăn uống' => Icons.restaurant, 'Di chuyển' => Icons.directions_bus, 'Mua sắm' => Icons.shopping_bag, 'Hóa đơn' => Icons.receipt, 'Lương' => Icons.payments, _ => Icons.more_horiz };
  void _snack(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
