import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hisab_app/core/network/api_client.dart';
import 'package:hisab_app/core/theme/app_theme.dart';
import 'package:hisab_app/features/invoice/provider/invoice_service.dart';
import 'dart:typed_data';

class CreateInvoiceScreen extends StatefulWidget {
  final int businessId;
  const CreateInvoiceScreen({super.key, required this.businessId});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _amount = TextEditingController();
  final _tax = TextEditingController();
  final _total = TextEditingController();
  final _notes = TextEditingController();
  final _customerName = TextEditingController();
  final _billNumber = TextEditingController();
  final _address1 = TextEditingController();
  final _address2 = TextEditingController();
  final _pincode = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _country = TextEditingController(text: 'India');
  final _paidAmount = TextEditingController(text: '0');

  Uint8List? _pdfBytes;
  String? _pdfName;
  DateTime? _dueDate;
  DateTime? _billDate;
  bool _saving = false;
  bool _fetchingPincode = false;

  @override
  void initState() {
    super.initState();
    _amount.addListener(_calcTotal);
    _tax.addListener(_calcTotal);
    _pincode.addListener(() {
      if (_pincode.text.length == 6) {
        _fetchPincodeDetails(_pincode.text);
      }
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _amount.dispose();
    _tax.dispose();
    _total.dispose();
    _notes.dispose();
    _customerName.dispose();
    _billNumber.dispose();
    _address1.dispose();
    _address2.dispose();
    _pincode.dispose();
    _city.dispose();
    _state.dispose();
    _country.dispose();
    _paidAmount.dispose();
    super.dispose();
  }

  void _calcTotal() {
    final a = double.tryParse(_amount.text) ?? 0;
    final t = double.tryParse(_tax.text) ?? 0;
    _total.text = (a + t).toStringAsFixed(2);
  }

  Future<void> _pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null) {
      setState(() {
        _pdfBytes = result.files.single.bytes;
        _pdfName = result.files.single.name;
      });
    }
  }

  Future<void> _fetchPincodeDetails(String pincode) async {
    setState(() => _fetchingPincode = true);
    try {
      final res = await ApiClient.dio.get('/utils/pincode/$pincode');
      if (!mounted) return;
      setState(() {
        _city.text = res.data['city'] ?? '';
        _state.text = res.data['state'] ?? '';
      });
    } catch (_) {
      if (mounted) _showSnack('Invalid pincode', isError: true);
    } finally {
      if (mounted) setState(() => _fetchingPincode = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final service = InvoiceService();
      await service.createInvoice(
        businessId: widget.businessId,
        data: {
          'customerName': _customerName.text.isEmpty
              ? null
              : _customerName.text,
          'billNumber': _billNumber.text.isEmpty ? null : _billNumber.text,
          'billDate': _billDate?.toIso8601String().split('T').first,
          'title': _title.text,
          'description': _desc.text.isEmpty ? null : _desc.text,
          'amount': double.parse(_amount.text),
          'taxAmount': double.tryParse(_tax.text),
          'totalAmount': double.parse(_total.text),
          'paidAmount': double.tryParse(_paidAmount.text) ?? 0,
          'dueDate': _dueDate?.toIso8601String().split('T').first,
          'addressLine1': _address1.text.isEmpty ? null : _address1.text,
          'addressLine2': _address2.text.isEmpty ? null : _address2.text,
          'pincode': _pincode.text.isEmpty ? null : _pincode.text,
          'city': _city.text.isEmpty ? null : _city.text,
          'state': _state.text.isEmpty ? null : _state.text,
          'country': _country.text.isEmpty ? null : _country.text,
          'notes': _notes.text.isEmpty ? null : _notes.text,
        },
        pdfBytes: _pdfBytes,
        pdfName: _pdfName,
      );
      if (!mounted) return;
      _showSnack('Invoice created successfully!');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
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
          'New Invoice',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimary : AppColors.textDark,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ── Bill Info ──────────────────────────
                  _sectionLabel('Bill Information'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          _billNumber,
                          'Bill Number (16 digits)',
                          icon: Icons.tag_rounded,
                          keyboardType: TextInputType.number,
                          maxLength: 16,
                          validator: (v) {
                            if (v != null && v.isNotEmpty && v.length != 16) {
                              return 'Must be 16 digits';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _datePicker(
                          label: 'Bill Date',
                          date: _billDate,
                          icon: Icons.receipt_outlined,
                          isDark: isDark,
                          onTap: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (d != null) {
                              setState(() => _billDate = d);
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Customer Details ───────────────────
                  _sectionLabel('Customer Details'),
                  const SizedBox(height: 10),
                  _field(
                    _customerName,
                    'Customer Name',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    _address1,
                    'Address Line 1',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    _address2,
                    'Address Line 2',
                    icon: Icons.home_outlined,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _pincodeField(isDark)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(
                          _city,
                          'City',
                          icon: Icons.location_city_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          _state,
                          'State',
                          icon: Icons.map_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(_country, 'Country', icon: Icons.public),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Invoice Details ────────────────────
                  _sectionLabel('Invoice Details'),
                  const SizedBox(height: 10),
                  _field(
                    _title,
                    'Title *',
                    icon: Icons.title,
                    validator: (v) => v!.isEmpty ? 'Title required' : null,
                  ),
                  const SizedBox(height: 12),
                  _field(_desc, 'Description', icon: Icons.notes, maxLines: 3),

                  const SizedBox(height: 24),

                  // ── Pricing ────────────────────────────
                  _sectionLabel('Pricing'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          _amount,
                          'Amount *',
                          icon: Icons.currency_rupee,
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(
                          _tax,
                          'Tax Amount',
                          icon: Icons.percent,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Total highlighted
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        ValueListenableBuilder(
                          valueListenable: _total,
                          builder: (_, __, ___) => Text(
                            '₹ ${_total.text.isEmpty ? '0.00' : _total.text}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Paid Amount
                  _field(
                    _paidAmount,
                    'Paid Amount (if any)',
                    icon: Icons.payments_outlined,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 24),

                  // ── Additional Info ────────────────────
                  _sectionLabel('Additional Info'),
                  const SizedBox(height: 10),

                  // Due Date
                  _datePicker(
                    label: 'Due Date',
                    date: _dueDate,
                    icon: Icons.event_outlined,
                    isDark: isDark,
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(
                          const Duration(days: 30),
                        ),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (d != null) setState(() => _dueDate = d);
                    },
                  ),
                  const SizedBox(height: 12),
                  _field(
                    _notes,
                    'Notes',
                    icon: Icons.sticky_note_2_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),

                  // PDF Upload
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _pickPDF,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _pdfBytes != null
                                ? AppColors.success
                                : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _pdfBytes != null
                                  ? Icons.picture_as_pdf_rounded
                                  : Icons.upload_file_rounded,
                              color: _pdfBytes != null
                                  ? AppColors.success
                                  : AppColors.textHint,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _pdfBytes != null
                                        ? 'PDF Attached'
                                        : 'Attach PDF (optional)',
                                    style: TextStyle(
                                      color: _pdfBytes != null
                                          ? AppColors.success
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (_pdfName != null)
                                    Text(
                                      _pdfName!,
                                      style: const TextStyle(
                                        color: AppColors.textHint,
                                        fontSize: 11,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            if (_pdfBytes != null)
                              GestureDetector(
                                onTap: () => setState(() {
                                  _pdfBytes = null;
                                  _pdfName = null;
                                }),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: AppColors.textHint,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),

            // ── Bottom Button ──────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBg : AppColors.lightBg,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Create Invoice'),
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget _datePicker({
    required String label,
    required DateTime? date,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: date != null
                  ? AppColors.primary
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: date != null ? AppColors.primary : AppColors.textHint,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  date == null
                      ? label
                      : date.toIso8601String().split('T').first,
                  style: TextStyle(
                    fontSize: 12,
                    color: date != null
                        ? AppColors.primary
                        : AppColors.textHint,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pincodeField(bool isDark) {
    return TextFormField(
      controller: _pincode,
      keyboardType: TextInputType.number,
      maxLength: 6,
      style: TextStyle(
        color: isDark ? AppColors.textPrimary : AppColors.textDark,
      ),
      decoration: InputDecoration(
        labelText: 'Pincode',
        labelStyle: TextStyle(color: AppColors.textHint),
        prefixIcon: Icon(
          Icons.pin_drop_outlined,
          color: AppColors.textHint,
          size: 18,
        ),
        suffixIcon: _fetchingPincode
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
        counterText: '',
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    IconData? icon,
    int maxLines = 1,
    int? maxLength,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      maxLength: maxLength,
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: isDark ? AppColors.textPrimary : AppColors.textDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textHint),
        counterText: maxLength != null ? '' : null,
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.textHint, size: 18)
            : null,
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
