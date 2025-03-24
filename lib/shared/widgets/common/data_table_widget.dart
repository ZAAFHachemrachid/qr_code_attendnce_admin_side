import 'package:flutter/material.dart';

class CustomDataColumn {
  final String label;
  final String field;
  final double? width;
  final Widget Function(dynamic)? customBuilder;

  const CustomDataColumn({
    required this.label,
    required this.field,
    this.width,
    this.customBuilder,
  });
}

class DataTableWidget extends StatefulWidget {
  final List<CustomDataColumn> columns;
  final List<Map<String, dynamic>> data;
  final bool isLoading;
  final String? errorMessage;
  final Function(Map<String, dynamic>)? onEdit;
  final Function(Map<String, dynamic>)? onDelete;
  final VoidCallback? onAdd;
  final String? noDataMessage;

  const DataTableWidget({
    super.key,
    required this.columns,
    required this.data,
    this.isLoading = false,
    this.errorMessage,
    this.onEdit,
    this.onDelete,
    this.onAdd,
    this.noDataMessage,
  });

  @override
  State<DataTableWidget> createState() => _DataTableWidgetState();
}

class _DataTableWidgetState extends State<DataTableWidget> {
  String? _sortColumn;
  bool _sortAscending = true;
  List<Map<String, dynamic>> _sortedData = [];

  @override
  void initState() {
    super.initState();
    _sortedData = List.from(widget.data);
  }

  @override
  void didUpdateWidget(DataTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _sortedData = List.from(widget.data);
      _sortData();
    }
  }

  void _sortData() {
    if (_sortColumn != null) {
      _sortedData.sort((a, b) {
        final aValue = a[_sortColumn];
        final bValue = b[_sortColumn];

        if (aValue == null) return _sortAscending ? -1 : 1;
        if (bValue == null) return _sortAscending ? 1 : -1;

        int comparison;
        if (aValue is num && bValue is num) {
          comparison = aValue.compareTo(bValue);
        } else if (aValue is DateTime && bValue is DateTime) {
          comparison = aValue.compareTo(bValue);
        } else {
          comparison = aValue.toString().compareTo(bValue.toString());
        }

        return _sortAscending ? comparison : -comparison;
      });
    }
  }

  void _onSort(int columnIndex, bool ascending) {
    final column = widget.columns[columnIndex];
    setState(() {
      _sortColumn = column.field;
      _sortAscending = ascending;
      _sortData();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              widget.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      );
    }

    if (_sortedData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              widget.noDataMessage ?? 'No data available',
              style: const TextStyle(color: Colors.grey),
            ),
            if (widget.onAdd != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: widget.onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add New'),
              ),
            ],
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.onAdd != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  onPressed: widget.onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text('Add New'),
                ),
              ),
            DataTable(
              sortColumnIndex:
                  _sortColumn != null
                      ? widget.columns.indexWhere(
                        (col) => col.field == _sortColumn,
                      )
                      : null,
              sortAscending: _sortAscending,
              columns: [
                ...widget.columns.map(
                  (column) => DataColumn(
                    label: Text(column.label),
                    onSort: _onSort,
                    tooltip: column.label,
                  ),
                ),
                if (widget.onEdit != null || widget.onDelete != null)
                  const DataColumn(label: Text('Actions')),
              ],
              rows:
                  _sortedData.map((item) {
                    return DataRow(
                      cells: [
                        ...widget.columns.map(
                          (column) => DataCell(
                            column.customBuilder != null
                                ? column.customBuilder!(item[column.field])
                                : Text(item[column.field]?.toString() ?? ''),
                          ),
                        ),
                        if (widget.onEdit != null || widget.onDelete != null)
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.onEdit != null)
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => widget.onEdit!(item),
                                    tooltip: 'Edit',
                                  ),
                                if (widget.onDelete != null)
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => widget.onDelete!(item),
                                    tooltip: 'Delete',
                                  ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
