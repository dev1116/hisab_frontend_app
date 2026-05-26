import 'package:flutter/material.dart';
import 'package:hisab_app/features/quotations/screens/edit_quotation_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../model/quotation_model.dart';
import '../provider/quotation_service.dart';
import 'create_quotation_screen.dart';

class QuotationsScreen extends StatefulWidget {
  final int businessId;
  const QuotationsScreen({super.key, required this.businessId});

  @override
  State<QuotationsScreen> createState() => _QuotationsScreenState();
}

class _QuotationsScreenState extends State<QuotationsScreen> {
  List<QuotationModel> _quotes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final service = QuotationService();
      final data = await service.getQuotations(widget.businessId);
      if (!mounted) return;
      setState(() {
        _quotes = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack('Failed to load quotations', isError: true);
    }
  }

  Future<void> _openPdf(String url) async {
    // Full URL banao
    final fullUrl = 'http://localhost:8082$url';
    final uri = Uri.parse(fullUrl);

    // Chrome pe webOnlyWindowName use karo
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        webOnlyWindowName: '_blank', // new tab mein open hoga
      );
    } else {
      _showSnack('Could not open PDF', isError: true);
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
          'Quotations',
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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    CreateQuotationScreen(businessId: widget.businessId),
              ),
            ).then((_) => _load()),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _quotes.isEmpty
          ? _emptyState()
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ── Stats Row ──────────────────────────
                  _statsRow(isDark),
                  const SizedBox(height: 20),

                  // ── Section Label ──────────────────────
                  _sectionLabel('All Quotations'),
                  const SizedBox(height: 12),

                  // ── Quotation Cards ────────────────────
                  ..._quotes.map(
                    (q) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Dismissible(
                        key: Key('quote_${q.id}'),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          // Delete confirm dialog
                          return await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text('Delete Quotation?'),
                              content: Text(
                                '${q.quoteNumber} will be permanently deleted.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
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
                          );
                        },
                        onDismissed: (_) async {
                          try {
                            final service = QuotationService();
                            await service.deleteQuotation(
                              businessId: widget.businessId,
                              quotationId: q.id,
                            );
                            _load();
                          } catch (e) {
                            _showSnack('Delete failed', isError: true);
                          }
                        },
                        // Swipe background — red delete
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
                        child: _QuotationTile(
                          quote: q,
                          isDark: isDark,
                          onPdfTap: q.pdfUrl != null && q.pdfUrl!.isNotEmpty
                              ? () => _openPdf(q.pdfUrl!)
                              : null,
                          onEdit: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditQuotationScreen(
                                  businessId: widget.businessId,
                                  quotation: q,
                                ),
                              ),
                            );
                            if (result == true) _load();
                          },
                          onStatusUpdate: (status) async {
                            try {
                              final service = QuotationService();
                              await service.updateStatus(
                                businessId: widget.businessId,
                                quotationId: q.id,
                                status: status,
                              );
                              _load();
                            } catch (e) {
                              _showSnack('Update failed', isError: true);
                            }
                          },
                          onDelete: () async {
                            try {
                              final service = QuotationService();
                              await service.deleteQuotation(
                                businessId: widget.businessId,
                                quotationId: q.id,
                              );
                              _load();
                            } catch (e) {
                              _showSnack('Delete failed', isError: true);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ── Stats Row ─────────────────────────────────────────────────
  Widget _statsRow(bool isDark) {
    final total = _quotes.length;
    final accepted = _quotes.where((q) => q.status == 'ACCEPTED').length;
    final pending = _quotes.where((q) => q.status == 'SENT').length;
    final totalValue = _quotes.fold<double>(0, (sum, q) => sum + q.totalAmount);

    return Row(
      children: [
        _StatCard(
          label: 'Total',
          value: '$total',
          isDark: isDark,
          color: AppColors.primary,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Accepted',
          value: '$accepted',
          isDark: isDark,
          color: AppColors.success,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Pending',
          value: '$pending',
          isDark: isDark,
          color: const Color(0xFFF59E0B),
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Value',
          value: '₹${totalValue.toStringAsFixed(0)}',
          isDark: isDark,
          color: AppColors.accent,
        ),
      ],
    );
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
              Icons.receipt_long_rounded,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No quotations yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to create your first quotation',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: 200,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CreateQuotationScreen(businessId: widget.businessId),
                ),
              ).then((_) => _load()),
              icon: const Icon(
                Icons.add_rounded,
                size: 18,
                color: Colors.white,
              ),
              label: const Text(
                'New Quotation',
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
  final bool isDark;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.isDark,
    required this.color,
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

// ── Quotation Tile ────────────────────────────────────────────────
class _QuotationTile extends StatelessWidget {
  final QuotationModel quote;
  final bool isDark;
  final VoidCallback? onPdfTap;
  final Function(String) onStatusUpdate;
  final VoidCallback onDelete;
  final VoidCallback onEdit; // ← add

  const _QuotationTile({
    required this.quote,
    required this.isDark,
    required this.onPdfTap,
    required this.onStatusUpdate,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          // ── Top Row ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                // Quote number
                Text(
                  quote.quoteNumber,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),

                // Version badge
                if (quote.version > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'v${quote.version}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ),

                const Spacer(),

                // Status chip
                _StatusChip(status: quote.status, color: quote.statusColor),
                const SizedBox(width: 8),

                // More menu
                _MoreMenu(
                  quote: quote,
                  onStatusUpdate: onStatusUpdate,
                  onDelete: onDelete,
                  onEdit: onEdit,
                ),
              ],
            ),
          ),

          // ── Divider ────────────────────────────────────────
          Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),

          // ── Middle — Title + Customer ──────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quote.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimary
                              : AppColors.textDark,
                        ),
                      ),
                      if (quote.customerName != null) ...[
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
                              quote.customerName!,
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

                // Amount
                Text(
                  '₹${quote.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Row — Date + PDF ────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 12,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: 4),
                Text(
                  quote.issueDate,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),

                if (quote.validUntil != null) ...[
                  const SizedBox(width: 8),
                  const Text(
                    '→',
                    style: TextStyle(fontSize: 11, color: AppColors.textHint),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    quote.validUntil!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],

                const Spacer(),

                // PDF button
                if (quote.pdfUrl != null && quote.pdfUrl!.isNotEmpty)
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
  final QuotationModel quote;
  final Function(String) onStatusUpdate;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _MoreMenu({
    required this.quote,
    required this.onStatusUpdate,
    required this.onDelete,
    required this.onEdit,
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
        if (val == 'edit') {
          onEdit(); // ← add
        } else if (val == 'delete') {
          onDelete();
        } else {
          onStatusUpdate(val);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(
                Icons.edit_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Text(
                'Edit / Revise',
                style: TextStyle(fontSize: 13, color: AppColors.primary),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        if (quote.status != 'SENT')
          _menuItem('SENT', Icons.send_rounded, 'Mark as Sent', AppColors.info),
        if (quote.status != 'ACCEPTED')
          _menuItem(
            'ACCEPTED',
            Icons.check_circle_rounded,
            'Mark as Accepted',
            AppColors.success,
          ),
        if (quote.status != 'REJECTED')
          _menuItem(
            'REJECTED',
            Icons.cancel_rounded,
            'Mark as Rejected',
            AppColors.error,
          ),
        const PopupMenuDivider(),
        _menuItem(
          'delete',
          Icons.delete_outline_rounded,
          'Delete',
          AppColors.error,
        ),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(
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
