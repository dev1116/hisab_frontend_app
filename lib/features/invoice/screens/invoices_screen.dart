import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../model/invoice_model.dart';
import '../provider/invoice_service.dart';
import 'create_invoice_screen.dart';
import 'invoice_detail_screen.dart';

class InvoicesScreen extends StatefulWidget {
  final int businessId;
  const InvoicesScreen({super.key, required this.businessId});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  List<InvoiceModel> _invoices = [];
  bool _loading = true;
  String _searchQuery = '';
  String _searchField = 'title';
  String _selectedFilter = 'ALL';

  final List<Map<String, String>> _searchFields = [
    {'value': 'title', 'label': 'Title'},
    {'value': 'customerName', 'label': 'Customer'},
    {'value': 'invoiceNumber', 'label': 'Invoice No'},
    {'value': 'billNumber', 'label': 'Bill No'},
    {'value': 'amount', 'label': 'Amount'},
    {'value': 'date', 'label': 'Date'},
  ];

  List<InvoiceModel> get _filtered {
    return _invoices.where((inv) {
      final matchFilter =
          _selectedFilter == 'ALL' || inv.status == _selectedFilter;
      final q = _searchQuery.toLowerCase().trim();
      if (q.isEmpty) return matchFilter;
      bool matchSearch = false;
      switch (_searchField) {
        case 'title':
          matchSearch = inv.title.toLowerCase().contains(q);
          break;
        case 'customerName':
          matchSearch = inv.customerName?.toLowerCase().contains(q) ?? false;
          break;
        case 'invoiceNumber':
          matchSearch = inv.invoiceNumber.toLowerCase().contains(q);
          break;
        case 'billNumber':
          matchSearch = inv.billNumber?.toLowerCase().contains(q) ?? false;
          break;
        case 'amount':
          matchSearch = inv.totalAmount.toString().contains(q);
          break;
        case 'date':
          matchSearch =
              inv.issueDate.contains(q) ||
              (inv.billDate?.contains(q) ?? false) ||
              (inv.dueDate?.contains(q) ?? false);
          break;
      }
      return matchFilter && matchSearch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await InvoiceService().getInvoices(widget.businessId);
      if (!mounted) return;
      setState(() {
        _invoices = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack('Failed to load invoices', isError: true);
    }
  }

  Future<void> _openPdf(String url) async {
    final uri = Uri.parse('http://localhost:8082$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Invoices',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimary : AppColors.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            color: AppColors.primary,
            onPressed: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CreateInvoiceScreen(businessId: widget.businessId),
                  ),
                ).then((v) {
                  if (v == true) _load();
                }),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _invoices.isEmpty
          ? _emptyState()
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _statsRow(isDark),
                  const SizedBox(height: 16),
                  _searchAndFilter(isDark),
                  const SizedBox(height: 16),
                  _sectionLabel(
                    '${_filtered.length} of ${_invoices.length} Invoices',
                  ),
                  const SizedBox(height: 12),
                  ..._filtered.map(
                    (inv) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Dismissible(
                        key: Key('inv_${inv.id}'),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async => await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text('Delete Invoice?'),
                            content: Text(
                              '${inv.invoiceNumber} will be permanently deleted.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onDismissed: (_) async {
                          try {
                            await InvoiceService().deleteInvoice(
                              businessId: widget.businessId,
                              invoiceId: inv.id,
                            );
                            _load();
                          } catch (_) {
                            _showSnack('Delete failed', isError: true);
                          }
                        },
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          alignment: Alignment.centerRight,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.error,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => InvoiceDetailScreen(
                                    businessId: widget.businessId,
                                    invoice: inv,
                                  ),
                                ),
                              );
                              if (result == true) _load();
                            },
                            child: _InvoiceTile(
                              invoice: inv,
                              isDark: isDark,
                              onPdfTap:
                                  inv.pdfUrl != null && inv.pdfUrl!.isNotEmpty
                                  ? () => _openPdf(inv.pdfUrl!)
                                  : null,
                              onStatusUpdate: (status) async {
                                try {
                                  await InvoiceService().updateStatus(
                                    businessId: widget.businessId,
                                    invoiceId: inv.id,
                                    status: status,
                                  );
                                  _load();
                                } catch (_) {
                                  _showSnack('Update failed', isError: true);
                                }
                              },
                              onDelete: () async {
                                try {
                                  await InvoiceService().deleteInvoice(
                                    businessId: widget.businessId,
                                    invoiceId: inv.id,
                                  );
                                  _load();
                                } catch (_) {
                                  _showSnack('Delete failed', isError: true);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _statsRow(bool isDark) {
    final total = _invoices.length;
    final paid = _invoices.where((i) => i.status == 'PAID').length;
    final overdue = _invoices.where((i) => i.status == 'OVERDUE').length;
    final totalDue = _invoices.fold<double>(0, (s, i) => s + i.remainingAmount);

    return Row(
      children: [
        _StatCard(
          label: 'Total',
          value: '$total',
          color: AppColors.primary,
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Paid',
          value: '$paid',
          color: AppColors.success,
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Overdue',
          value: '$overdue',
          color: AppColors.error,
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Due',
          value: '₹${totalDue.toStringAsFixed(0)}',
          color: const Color(0xFFF59E0B),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _searchAndFilter(bool isDark) {
    final filters = [
      'ALL',
      'UNPAID',
      'PARTIAL',
      'PAID',
      'OVERDUE',
      'CANCELLED',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _searchField,
                  isDense: true,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  dropdownColor: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  items: _searchFields
                      .map(
                        (f) => DropdownMenuItem(
                          value: f['value'],
                          child: Text(f['label']!),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _searchField = val;
                        _searchQuery = '';
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _searchQuery.isNotEmpty
                        ? AppColors.primary
                        : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                  ),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimary : AppColors.textDark,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: _getHint(),
                    hintStyle: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textHint,
                      size: 18,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textHint,
                              size: 16,
                            ),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((f) {
              final isSelected = _selectedFilter == f;
              final color = _filterColor(f);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.12)
                            : (isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightSurface),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? color
                              : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (isSelected) ...[
                            Icon(Icons.check_rounded, size: 12, color: color),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            f,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? color
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (_searchQuery.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 12,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Searching "${_searchQuery}" in ${_searchFields.firstWhere((f) => f['value'] == _searchField)['label']}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => setState(() {
                    _searchQuery = '';
                    _selectedFilter = 'ALL';
                  }),
                  child: const Text(
                    'Clear all',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _getHint() {
    switch (_searchField) {
      case 'title':
        return 'e.g. Cement supply...';
      case 'customerName':
        return 'e.g. Rahul Sharma...';
      case 'invoiceNumber':
        return 'e.g. INV-2026-0001';
      case 'billNumber':
        return 'e.g. 1234567890123456';
      case 'amount':
        return 'e.g. 50000';
      case 'date':
        return 'e.g. 2026-05';
      default:
        return 'Search...';
    }
  }

  Color _filterColor(String f) {
    switch (f) {
      case 'PAID':
        return AppColors.success;
      case 'PARTIAL':
        return AppColors.info;
      case 'OVERDUE':
        return AppColors.error;
      case 'CANCELLED':
        return AppColors.textSecondary;
      case 'UNPAID':
        return const Color(0xFFF59E0B);
      default:
        return AppColors.primary;
    }
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No invoices yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to create your first invoice',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: 200,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CreateInvoiceScreen(businessId: widget.businessId),
                    ),
                  ).then((v) {
                    if (v == true) _load();
                  }),
              icon: const Icon(
                Icons.add_rounded,
                size: 18,
                color: Colors.white,
              ),
              label: const Text(
                'New Invoice',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Invoice Tile ──────────────────────────────────────────────────
class _InvoiceTile extends StatelessWidget {
  final InvoiceModel invoice;
  final bool isDark;
  final VoidCallback? onPdfTap;
  final Function(String) onStatusUpdate;
  final VoidCallback onDelete;

  const _InvoiceTile({
    required this.invoice,
    required this.isDark,
    required this.onPdfTap,
    required this.onStatusUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: invoice.isOverdue
              ? AppColors.error.withValues(alpha: 0.4)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Column(
        children: [
          // ── Top ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                // Invoice number
                Text(
                  invoice.invoiceNumber,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                if (invoice.billNumber != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Bill #${invoice.billNumber}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                _StatusChip(status: invoice.status, color: invoice.statusColor),
                const SizedBox(width: 8),
                _MoreMenu(
                  invoice: invoice,
                  onStatusUpdate: onStatusUpdate,
                  onDelete: onDelete,
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),

          // ── Middle ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimary
                              : AppColors.textDark,
                        ),
                      ),
                      if (invoice.customerName != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline_rounded,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              invoice.customerName!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${invoice.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    if (invoice.remainingAmount > 0)
                      Text(
                        'Due: ₹${invoice.remainingAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: invoice.isOverdue
                              ? AppColors.error
                              : AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ── Progress bar ─────────────────────────────────
          if (invoice.status == 'PARTIAL')
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: invoice.paidAmount / invoice.totalAmount,
                  backgroundColor: AppColors.info.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.info,
                  ),
                  minHeight: 4,
                ),
              ),
            ),

          // ── Bottom ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 12,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: 4),
                Text(
                  invoice.issueDate,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
                if (invoice.dueDate != null) ...[
                  const SizedBox(width: 6),
                  const Text(
                    '→',
                    style: TextStyle(fontSize: 11, color: AppColors.textHint),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    invoice.dueDate!,
                    style: TextStyle(
                      fontSize: 11,
                      color: invoice.isOverdue
                          ? AppColors.error
                          : AppColors.textHint,
                      fontWeight: invoice.isOverdue
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
                const Spacer(),
                if (invoice.pdfUrl != null && invoice.pdfUrl!.isNotEmpty)
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onPdfTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.picture_as_pdf_rounded,
                              size: 14,
                              color: AppColors.error,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'View PDF',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  const Text(
                    'No PDF',
                    style: TextStyle(fontSize: 11, color: AppColors.textHint),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status Chip ───────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── More Menu ─────────────────────────────────────────────────────
class _MoreMenu extends StatelessWidget {
  final InvoiceModel invoice;
  final Function(String) onStatusUpdate;
  final VoidCallback onDelete;

  const _MoreMenu({
    required this.invoice,
    required this.onStatusUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert_rounded,
        color: AppColors.textSecondary,
        size: 18,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (val) {
        if (val == 'delete') {
          onDelete();
        } else {
          onStatusUpdate(val);
        }
      },
      itemBuilder: (_) => [
        if (invoice.status != 'PAID')
          _item(
            'PAID',
            Icons.check_circle_rounded,
            'Mark as Paid',
            AppColors.success,
          ),
        if (invoice.status != 'CANCELLED')
          _item(
            'CANCELLED',
            Icons.cancel_rounded,
            'Cancel Invoice',
            AppColors.error,
          ),
        const PopupMenuDivider(),
        _item(
          'delete',
          Icons.delete_outline_rounded,
          'Delete',
          AppColors.error,
        ),
      ],
    );
  }

  PopupMenuItem<String> _item(
    String value,
    IconData icon,
    String label,
    Color color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 13, color: color)),
        ],
      ),
    );
  }
}
