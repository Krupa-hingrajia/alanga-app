import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DropdownItemOption {
  final String id;
  final String name;
  final dynamic rawData;

  DropdownItemOption({
    required this.id,
    required this.name,
    this.rawData,
  });
}

class SearchableDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<dynamic> items;
  final String placeholder;
  final String emptyStateMessage;
  final bool loading;
  final bool disabled;
  final String? disabledHint;
  final VoidCallback? onRequestBrand;
  final String? Function(String?)? validator;
  final void Function(String? id, String? name) onChanged;

  const SearchableDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.placeholder = 'Select option',
    this.emptyStateMessage = 'No items available',
    this.loading = false,
    this.disabled = false,
    this.disabledHint,
    this.onRequestBrand,
    this.validator,
  });

  List<DropdownItemOption> _parseItems() {
    return items.map((item) {
      if (item is Map) {
        return DropdownItemOption(
          id: (item['id'] ?? item['_id'] ?? '').toString(),
          name: (item['name'] ?? item['title'] ?? '').toString(),
          rawData: item,
        );
      }
      return DropdownItemOption(
        id: (item.id ?? '').toString(),
        name: (item.name ?? '').toString(),
        rawData: item,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final parsedItems = _parseItems();
    final selectedItem = parsedItems.firstWhere(
      (item) => item.id == value,
      orElse: () => DropdownItemOption(id: '', name: ''),
    );

    final displayText = selectedItem.id.isNotEmpty
        ? selectedItem.name
        : (disabled ? (disabledHint ?? placeholder) : placeholder);

    return FormField<String>(
      initialValue: value,
      validator: validator,
      builder: (FormFieldState<String> state) {
        final hasError = state.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF11261B),
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: (disabled || loading)
                  ? null
                  : () {
                      _showSearchModal(context, parsedItems, (selected) {
                        state.didChange(selected?.id);
                        onChanged(selected?.id, selected?.name);
                      });
                    },
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: disabled ? const Color(0xFFF3F6F4) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hasError
                        ? AppColors.brandRed
                        : (disabled ? const Color(0xFFE4ECE8) : const Color(0xFFD1DCD6)),
                    width: hasError ? 1.2 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: selectedItem.id.isNotEmpty
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: selectedItem.id.isNotEmpty
                              ? const Color(0xFF11261B)
                              : (disabled
                                  ? Colors.grey.shade400
                                  : AppColors.textSecondaryLight),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (loading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryGreen,
                        ),
                      )
                    else
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: disabled ? Colors.grey.shade400 : const Color(0xFF4C6656),
                      ),
                  ],
                ),
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  state.errorText ?? '',
                  style: const TextStyle(
                    color: AppColors.brandRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showSearchModal(
    BuildContext context,
    List<DropdownItemOption> options,
    Function(DropdownItemOption?) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SearchModalContent(
        title: label,
        options: options,
        emptyStateMessage: emptyStateMessage,
        selectedId: value,
        onRequestBrand: onRequestBrand,
        onSelect: (selected) {
          Navigator.pop(ctx);
          onSelect(selected);
        },
      ),
    );
  }
}

class _SearchModalContent extends StatefulWidget {
  final String title;
  final List<DropdownItemOption> options;
  final String emptyStateMessage;
  final String? selectedId;
  final VoidCallback? onRequestBrand;
  final Function(DropdownItemOption?) onSelect;

  const _SearchModalContent({
    required this.title,
    required this.options,
    required this.emptyStateMessage,
    required this.selectedId,
    this.onRequestBrand,
    required this.onSelect,
  });

  @override
  State<_SearchModalContent> createState() => _SearchModalContentState();
}

class _SearchModalContentState extends State<_SearchModalContent> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.options.where((opt) {
      return opt.name.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select ${widget.title}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF11261B),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                  splashRadius: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _query = val.trim()),
              decoration: InputDecoration(
                hintText: 'Search ${widget.title}...',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF5F8F6),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Options List or Empty State
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 44,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.options.isEmpty
                                ? widget.emptyStateMessage
                                : 'No matching ${widget.title.toLowerCase()} found',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEFEFEF)),
                    itemBuilder: (ctx, index) {
                      final item = filtered[index];
                      final isSelected = item.id == widget.selectedId;

                      return ListTile(
                        onTap: () => widget.onSelect(item),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        title: Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppColors.primaryGreen : const Color(0xFF11261B),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen)
                            : null,
                      );
                    },
                  ),
          ),

          // Brand Request Section
          if (widget.onRequestBrand != null) ...[
            Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAF8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE4ECE8)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Brand not found?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4C6656),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onRequestBrand!();
                      },
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                      label: const Text(
                        'Request New Brand',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(color: AppColors.primaryGreen, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
