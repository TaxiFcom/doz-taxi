import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

/// Reusable search + filter bar for tables.
class SearchFilterBar extends StatefulWidget {
  final String hintText;
  final void Function(String query) onSearch;
  final List<FilterChipData>? chips;
  final List<Widget>? trailingActions;

  const SearchFilterBar({
    super.key,
    this.hintText = 'Search...',
    required this.onSearch,
    this.chips,
    this.trailingActions,
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: DozColors.surfaceLight,
        border: Border(
          bottom: BorderSide(color: DozColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          // Search field
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _controller,
                onChanged: widget.onSearch,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(
                      fontSize: 13, color: DozColors.textDisabledLight),
                  prefixIcon: const Icon(Icons.search,
                      size: 18, color: DozColors.textMutedLight),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              size: 16, color: DozColors.textMutedLight),
                          onPressed: () {
                            _controller.clear();
                            widget.onSearch('');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  filled: true,
                  fillColor: DozColors.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: DozColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: DozColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: DozColors.primaryGreen, width: 1.5),
                  ),
                ),
                style: const TextStyle(
                    fontSize: 13, color: DozColors.textPrimaryLight),
              ),
            ),
          ),

          // Filter chips
          if (widget.chips != null) ...[
            const SizedBox(width: 12),
            ...widget.chips!.map((chip) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(data: chip),
                )),
          ],

          // Trailing actions (export button etc)
          if (widget.trailingActions != null) ...[
            const Spacer(),
            ...widget.trailingActions!,
          ],
        ],
      ),
    );
  }
}

class FilterChipData {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterChipData({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
}

class _FilterChip extends StatelessWidget {
  final FilterChipData data;
  const _FilterChip({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: data.isSelected
              ? DozColors.primaryGreenSurface
              : DozColors.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: data.isSelected
                ? DozColors.primaryGreen
                : DozColors.borderLight,
            width: 1,
          ),
        ),
        child: Text(
          data.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: data.isSelected
                ? DozColors.primaryGreen
                : DozColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}
