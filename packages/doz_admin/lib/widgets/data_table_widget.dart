import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

/// Generic reusable data table with sorting, selection, pagination support.
class AdminDataTable<T> extends StatelessWidget {
  final List<DataColumn> columns;
  final List<T> rows;
  final DataRow Function(T item, int index) rowBuilder;
  final bool isLoading;
  final String? emptyMessage;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final void Function(int page)? onPageChanged;

  const AdminDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.rowBuilder,
    this.isLoading = false,
    this.emptyMessage,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.pageSize = 20,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        DozColors.primaryGreen),
                  ),
                )
              : rows.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: DozColors.textDisabledLight,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            emptyMessage ?? 'No data available',
                            style: const TextStyle(
                              fontSize: 14,
                              color: DozColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width -
                                (MediaQuery.of(context).size.width < 1100
                                    ? 64
                                    : 240) -
                                40,
                          ),
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                                DozColors.backgroundLight),
                            headingTextStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: DozColors.textMutedLight,
                              letterSpacing: 0.5,
                            ),
                            dataTextStyle: const TextStyle(
                              fontSize: 13,
                              color: DozColors.textSecondaryLight,
                            ),
                            dataRowMinHeight: 52,
                            dataRowMaxHeight: 60,
                            dividerThickness: 1,
                            columnSpacing: 20,
                            horizontalMargin: 16,
                            columns: columns,
                            rows: rows
                                .asMap()
                                .entries
                                .map((e) => rowBuilder(e.value, e.key))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
        ),
        if (onPageChanged != null && totalPages > 0)
          _PaginationBar(
            currentPage: currentPage,
            totalPages: totalPages,
            totalItems: totalItems,
            pageSize: pageSize,
            onPageChanged: onPageChanged!,
          ),
      ],
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final void Function(int) onPageChanged;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final start = (currentPage - 1) * pageSize + 1;
    final end = (currentPage * pageSize).clamp(0, totalItems);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: DozColors.surfaceLight,
        border: Border(
          top: BorderSide(color: DozColors.borderLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Showing $start–$end of $totalItems',
            style: const TextStyle(
              fontSize: 12,
              color: DozColors.textMutedLight,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              _PageButton(
                icon: Icons.first_page,
                onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
              ),
              _PageButton(
                icon: Icons.chevron_left,
                onPressed:
                    currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
              ),
              const SizedBox(width: 8),
              ..._buildPageNumbers(),
              const SizedBox(width: 8),
              _PageButton(
                icon: Icons.chevron_right,
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
              ),
              _PageButton(
                icon: Icons.last_page,
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(totalPages)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    final pages = <int>[];
    if (totalPages <= 5) {
      pages.addAll(List.generate(totalPages, (i) => i + 1));
    } else {
      pages.add(1);
      if (currentPage > 3) pages.add(-1); // ellipsis
      for (int i = (currentPage - 1).clamp(2, totalPages - 1);
          i <= (currentPage + 1).clamp(2, totalPages - 1);
          i++) {
        pages.add(i);
      }
      if (currentPage < totalPages - 2) pages.add(-1);
      pages.add(totalPages);
    }

    return pages.map((p) {
      if (p == -1) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(color: DozColors.textMutedLight)),
        );
      }
      final isActive = p == currentPage;
      return GestureDetector(
        onTap: isActive ? null : () => onPageChanged(p),
        child: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isActive ? DozColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isActive
                ? null
                : Border.all(color: DozColors.borderLight),
          ),
          child: Center(
            child: Text(
              '$p',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : DozColors.textSecondaryLight,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _PageButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        padding: EdgeInsets.zero,
        color: onPressed != null
            ? DozColors.textSecondaryLight
            : DozColors.textDisabledLight,
      ),
    );
  }
}
