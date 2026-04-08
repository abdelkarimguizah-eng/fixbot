import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../providers/diagnosis_provider.dart';
import '../widgets/equipment_card.dart';

class EquipmentSelectionScreen extends ConsumerStatefulWidget {
  const EquipmentSelectionScreen({super.key});

  @override
  ConsumerState<EquipmentSelectionScreen> createState() =>
      _EquipmentSelectionScreenState();
}

class _EquipmentSelectionScreenState
    extends ConsumerState<EquipmentSelectionScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _listController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _listController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final equipment = ref.watch(equipmentListProvider);
    final filtered = equipment
        .where((e) => (e['name'] as String)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth =
                constraints.maxWidth.clamp(0.0, 560.0).toDouble();
            final horizontalPadding = contentWidth < 380 ? 18.0 : 24.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  children: [
                    _buildHeader(
                      context,
                      horizontalPadding: horizontalPadding,
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? _buildEmpty()
                          : GridView.builder(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                24,
                                horizontalPadding,
                                28,
                              ),
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 1.08,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                return AnimatedEquipmentCard(
                                  index: index,
                                  name: item['name'] as String,
                                  iconType: item['icon'] as String,
                                  listController: _listController,
                                  onTap: () => _onEquipmentTapped(
                                    context,
                                    item['name'] as String,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required double horizontalPadding,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Industrial Equipment',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
                fontSize: 26,
                color: AppColors.darkAccent,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
            const Text(
              'Troubleshooting',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
                fontSize: 26,
                color: AppColors.primaryBlue,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select equipment to start diagnosis',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 13,
                color: AppColors.neutralGrey,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.search_rounded,
                      color: AppColors.neutralGrey, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.darkAccent,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search equipment...',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.neutralGrey,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 56, color: AppColors.neutralGrey),
          SizedBox(height: 12),
          Text('No equipment found',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: AppColors.neutralGrey)),
        ],
      ),
    );
  }

  void _onEquipmentTapped(BuildContext context, String equipment) {
    ref.read(diagnosisProvider.notifier).selectEquipment(equipment);
    _showBrandSheet(context, equipment);
  }

  void _showBrandSheet(BuildContext context, String equipment) {
    final brands = ref.read(brandsProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BrandSheet(
        equipment: equipment,
        brands: brands,
        onBrandSelected: (brand) {
          Navigator.of(ctx).pop();
          ref.read(diagnosisProvider.notifier).selectBrand(brand.name);
          _showModelSheet(context, equipment, brand);
        },
      ),
    );
  }

  void _showModelSheet(
      BuildContext context, String equipment, EquipmentBrand brand) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ModelSheet(
        equipment: equipment,
        brand: brand,
        onModelSelected: (model) {
          Navigator.of(ctx).pop();
          ref.read(diagnosisProvider.notifier).selectModel(model);
          context.go('/troubleshooting', extra: {
            'equipment': equipment,
            'brand': brand.name,
            'model': model,
          });
        },
      ),
    );
  }
}


class _BrandSheet extends StatelessWidget {
  final String equipment;
  final List<EquipmentBrand> brands;
  final void Function(EquipmentBrand) onBrandSelected;

  const _BrandSheet({
    required this.equipment,
    required this.brands,
    required this.onBrandSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _Sheet(
      title: 'Select Brand',
      subtitle: equipment,
      child: Column(
        children: brands.map((brand) {
          return _SheetListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryBlue,
              ),
              child: Center(
                child: Text(brand.initial,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: Colors.white,
                    )),
              ),
            ),
            title: brand.name,
            onTap: () => onBrandSelected(brand),
          );
        }).toList(),
      ),
    );
  }
}


class _ModelSheet extends StatelessWidget {
  final String equipment;
  final EquipmentBrand brand;
  final void Function(String) onModelSelected;

  const _ModelSheet({
    required this.equipment,
    required this.brand,
    required this.onModelSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _Sheet(
      title: 'Select Model',
      subtitle: '${brand.name} · $equipment',
      child: Column(
        children: brand.models.map((model) {
          return _SheetListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightBackground,
                border: Border.all(
                    color: AppColors.primaryBlue.withOpacity(0.2), width: 1.5),
              ),
              child: const Icon(Icons.precision_manufacturing_rounded,
                  color: AppColors.darkAccent, size: 20),
            ),
            title: model,
            onTap: () => onModelSelected(model),
          );
        }).toList(),
      ),
    );
  }
}


class _Sheet extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const _Sheet(
      {required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            color: AppColors.darkAccent,
                          )),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.neutralGrey,
                          )),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 36, height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F4F7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.darkAccent, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _SheetListTile extends StatefulWidget {
  final Widget leading;
  final String title;
  final VoidCallback onTap;
  const _SheetListTile(
      {required this.leading, required this.title, required this.onTap});

  @override
  State<_SheetListTile> createState() => _SheetListTileState();
}

class _SheetListTileState extends State<_SheetListTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _pressed
              ? AppColors.primaryBlue.withOpacity(0.06)
              : const Color(0xFFF8FAFB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            widget.leading,
            const SizedBox(width: 14),
            Expanded(
              child: Text(widget.title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.darkAccent,
                  )),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.neutralGrey, size: 22),
          ],
        ),
      ),
    );
  }
}
