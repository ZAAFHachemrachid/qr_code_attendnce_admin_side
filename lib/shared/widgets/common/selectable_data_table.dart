import 'package:flutter/material.dart';

class SelectableDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<Map<String, dynamic>> data;
  final bool isLoading;
  final String? errorMessage;
  final String noDataMessage;
  final void Function(Map<String, dynamic>)? onAdd;
  final void Function(Map<String, dynamic>)? onEdit;
  final void Function(Map<String, dynamic>)? onDelete;
  final void Function(Map<String, dynamic>)? onSelect;

  const SelectableDataTable({
    super.key,
    required this.columns,
    required this.data,
    this.isLoading = false,
    this.errorMessage,
    this.noDataMessage = 'No data available',
    this.onAdd,
    this.onEdit,
    this.onDelete,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(noDataMessage),
            if (onAdd != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => onAdd!({}),
                child: const Text('Add New'),
              ),
            ],
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: columns,
          rows: data.map((item) {
            return DataRow(
              cells: columns.map((column) {
                return DataCell(
                  Text(item[column.label.toString().toLowerCase()] ?? '-'),
                );
              }).toList(),
              onSelectChanged: onSelect != null ? (_) => onSelect!(item) : null,
            );
          }).toList(),
        ),
      ),
    );
  }
}
