import 'package:flutter/material.dart';
import 'package:hisab_app/core/theme/app_theme.dart';
import 'package:hisab_app/features/business/provider/business_service.dart';
import 'package:hisab_app/features/business/screens/dashboard_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreateBusinessScreen extends StatefulWidget {
  const CreateBusinessScreen({super.key});

  @override
  State<CreateBusinessScreen> createState() => _CreateBusinessScreenState();
}

class _CreateBusinessScreenState extends State<CreateBusinessScreen> {
  final _nameController = TextEditingController();
  String? _selectedType;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _businessTypes = [
    {
      'value': 'GROCERY',
      'label': 'Grocery',
      'icon': Icons.shopping_basket_rounded,
    },
    {'value': 'SALON', 'label': 'Salon', 'icon': Icons.content_cut_rounded},
    {'value': 'BAKERY', 'label': 'Bakery', 'icon': Icons.cake_rounded},
    {
      'value': 'CLINIC',
      'label': 'Clinic',
      'icon': Icons.local_hospital_rounded,
    },
    {
      'value': 'RESTAURANT',
      'label': 'Restaurant',
      'icon': Icons.restaurant_rounded,
    },
    {
      'value': 'CONTRACTOR',
      'label': 'Contractor',
      'icon': Icons.construction_rounded,
    },
    {
      'value': 'DEALERSHIP',
      'label': 'Dealership',
      'icon': Icons.directions_car_rounded,
    },
    {
      'value': 'WHOLESALE',
      'label': 'Wholesale',
      'icon': Icons.warehouse_rounded,
    },
    {
      'value': 'TRANSPORT',
      'label': 'Transport',
      'icon': Icons.local_shipping_rounded,
    },
    {'value': 'COACHING', 'label': 'Coaching', 'icon': Icons.school_rounded},
    {'value': 'GYM', 'label': 'Gym', 'icon': Icons.fitness_center_rounded},
    {
      'value': 'IT_SERVICES',
      'label': 'IT Services',
      'icon': Icons.computer_rounded,
    },
    {
      'value': 'REAL_ESTATE',
      'label': 'Real Estate',
      'icon': Icons.apartment_rounded,
    },
    {
      'value': 'PHARMACY',
      'label': 'Pharmacy',
      'icon': Icons.medication_rounded,
    },
    {
      'value': 'REPAIR_SHOP',
      'label': 'Repair Shop',
      'icon': Icons.build_rounded,
    },
    {
      'value': 'PHOTOGRAPHY',
      'label': 'Photography',
      'icon': Icons.camera_alt_rounded,
    },
    {
      'value': 'CATERING',
      'label': 'Catering',
      'icon': Icons.room_service_rounded,
    },
    {
      'value': 'LAUNDRY',
      'label': 'Laundry',
      'icon': Icons.local_laundry_service_rounded,
    },
    {'value': 'OTHER', 'label': 'Other', 'icon': Icons.category_rounded},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnack('Business name daalo', isError: true);
      return;
    }
    if (_selectedType == null) {
      _showSnack('Business type select karo', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final service = BusinessService();
      await service.createBusiness(_nameController.text.trim(), _selectedType!);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupedTypes = {};
  bool _typesLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    try {
      final service = BusinessService();
      final types = await service.getBusinessTypes();
      if (!mounted) return;
      setState(() {
        _groupedTypes = types;
        _typesLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _typesLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

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
          'New Business',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimary : AppColors.textDark,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 40 : 20,
              vertical: 28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Header ──────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.storefront_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Your Business',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textPrimary
                                  : AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Setup karo, manage karo — sab ek jagah',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Business Name ────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Business Name',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimary : AppColors.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. Sharma Kirana Store',
                    hintStyle: TextStyle(color: AppColors.textHint),
                    prefixIcon: Icon(
                      Icons.storefront_rounded,
                      size: 18,
                      color: AppColors.textHint,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                // const SizedBox(height: 8),
                const SizedBox(height: 28),

                // ── Business Type ────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Business Type',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                ////////---------------------------------------
                _typesLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : Column(
                        children: _groupedTypes.entries.map((entry) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightSurface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              childrenPadding: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                                bottom: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              title: Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimary
                                      : AppColors.textDark,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: entry.value.map<Widget>((type) {
                                      final isSelected =
                                          _selectedType == type['value'];

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedType = type['value'];
                                          });
                                        },

                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),

                                          width: 180,

                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),

                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primary.withValues(
                                                    alpha: 0.08,
                                                  )
                                                : Colors.transparent,

                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),

                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : (isDark
                                                        ? AppColors.darkBorder
                                                        : AppColors
                                                              .lightBorder),
                                            ),
                                          ),

                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.storefront_rounded,
                                                size: 18,
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : AppColors.textSecondary,
                                              ),

                                              const SizedBox(width: 12),

                                              Expanded(
                                                child: Text(
                                                  type['label'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.w400,
                                                    color: isSelected
                                                        ? AppColors.primary
                                                        : (isDark
                                                              ? AppColors
                                                                    .textPrimary
                                                              : AppColors
                                                                    .textDark),
                                                  ),
                                                ),
                                              ),

                                              if (isSelected)
                                                const Icon(
                                                  Icons.check_circle_rounded,
                                                  color: AppColors.primary,
                                                  size: 18,
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                // : Column(
                //     children: _groupedTypes.entries.map((entry) {
                //       return Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           // Category header
                //           Padding(
                //             padding: const EdgeInsets.only(
                //               top: 16,
                //               bottom: 8,
                //             ),
                //             child: Text(
                //               entry.key,
                //               style: const TextStyle(
                //                 fontSize: 11,
                //                 fontWeight: FontWeight.w600,
                //                 color: AppColors.textSecondary,
                //                 letterSpacing: 1,
                //               ),
                //             ),
                //           ),
                //           // Types
                //           ...entry.value.map((type) {
                //             final isSelected =
                //                 _selectedType == type['value'];
                //             return Padding(
                //               padding: const EdgeInsets.only(bottom: 8),
                //               child: GestureDetector(
                //                 onTap: () => setState(
                //                   () => _selectedType = type['value'],
                //                 ),
                //                 child: AnimatedContainer(
                //                   duration: const Duration(
                //                     milliseconds: 180,
                //                   ),
                //                   padding: const EdgeInsets.symmetric(
                //                     horizontal: 14,
                //                     vertical: 12,
                //                   ),
                //                   decoration: BoxDecoration(
                //                     color: isSelected
                //                         ? AppColors.primary.withValues(
                //                             alpha: 0.08,
                //                           )
                //                         : isDark
                //                         ? AppColors.darkSurface
                //                         : AppColors.lightSurface,
                //                     borderRadius: BorderRadius.circular(12),
                //                     border: Border.all(
                //                       color: isSelected
                //                           ? AppColors.primary
                //                           : isDark
                //                           ? AppColors.darkBorder
                //                           : AppColors.lightBorder,
                //                       width: isSelected ? 1.5 : 1,
                //                     ),
                //                   ),
                //                   child: Row(
                //                     children: [
                //                       Container(
                //                         width: 36,
                //                         height: 36,
                //                         decoration: BoxDecoration(
                //                           color: isSelected
                //                               ? AppColors.primary
                //                                     .withValues(alpha: 0.12)
                //                               : AppColors.primary
                //                                     .withValues(
                //                                       alpha: 0.06,
                //                                     ),
                //                           borderRadius:
                //                               BorderRadius.circular(10),
                //                         ),
                //                         child: Icon(
                //                           Icons
                //                               .storefront_rounded, // icon DB se map krenge
                //                           size: 18,
                //                           color: isSelected
                //                               ? AppColors.primary
                //                               : AppColors.textSecondary,
                //                         ),
                //                       ),
                //                       const SizedBox(width: 14),
                //                       Expanded(
                //                         child: Text(
                //                           type['label'] as String,
                //                           style: TextStyle(
                //                             fontSize: 14,
                //                             fontWeight: isSelected
                //                                 ? FontWeight.w600
                //                                 : FontWeight.w400,
                //                             color: isSelected
                //                                 ? AppColors.primary
                //                                 : AppColors.textDark,
                //                           ),
                //                         ),
                //                       ),
                //                       if (isSelected)
                //                         const Icon(
                //                           Icons.check_circle_rounded,
                //                           color: AppColors.primary,
                //                           size: 18,
                //                         ),
                //                     ],
                //                   ),
                //                 ),
                //               ),
                //             );
                //           }),
                //         ],
                //       );
                //     }).toList(),
                //   ),
                /**** 
               


***/

                /**
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWide ? 4 : 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.05,
                  ),
                  itemCount: _businessTypes.length,
                  itemBuilder: (context, index) {
                    final type = _businessTypes[index];
                    final isSelected = _selectedType == type['value'];
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedType = type['value']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.12)
                              : (isDark
                                    ? AppColors.darkSurface
                                    : AppColors.lightSurface),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              type['icon'] as IconData,
                              size: 26,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              type['label'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
*/
                const SizedBox(height: 32),

                // ── Create Button ────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleCreate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Create Business',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
