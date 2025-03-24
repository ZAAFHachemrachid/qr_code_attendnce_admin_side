# Department Management Implementation Plan

## 1. Data Layer

### 1.1 Department Model (`lib/features/department/data/models/department_model.dart`)
```dart
class DepartmentModel {
  final String id;
  final String name;
  final String code;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Constructor
  // fromJson method
  // toJson method
  // copyWith method
}
```

### 1.2 Department Repository (`lib/features/department/data/repositories/department_repository.dart`)
```dart
class DepartmentRepository {
  final SupabaseClient _supabaseClient;

  // CRUD Operations
  Future<List<DepartmentModel>> getDepartments();
  Future<DepartmentModel> getDepartment(String id);
  Future<DepartmentModel> createDepartment(DepartmentModel department);
  Future<DepartmentModel> updateDepartment(DepartmentModel department);
  Future<void> deleteDepartment(String id);
  Future<void> deleteBulkDepartments(List<String> ids);
  
  // Search/Filter
  Future<List<DepartmentModel>> searchDepartments(String query);
  
  // CSV Export
  Future<String> exportToCSV(List<DepartmentModel> departments);
}
```

## 2. State Management

### 2.1 Department Provider (`lib/features/department/providers/department_provider.dart`)
```dart
class DepartmentNotifier extends StateNotifier<DepartmentState> {
  final DepartmentRepository _repository;
  
  // State Management
  Future<void> loadDepartments();
  Future<void> createDepartment(DepartmentModel department);
  Future<void> updateDepartment(DepartmentModel department);
  Future<void> deleteDepartment(String id);
  Future<void> deleteBulkDepartments(List<String> ids);
  Future<void> searchDepartments(String query);
  Future<void> exportToCSV();
  
  // Selection Management
  void toggleSelection(String id);
  void clearSelection();
  void selectAll();
}

@freezed
class DepartmentState with _$DepartmentState {
  const factory DepartmentState({
    required List<DepartmentModel> departments,
    required Set<String> selectedIds,
    required bool isLoading,
    required String? errorMessage,
    required String searchQuery,
  }) = _DepartmentState;
}
```

## 3. UI Layer

### 3.1 Department Page (`lib/features/department/presentation/pages/department_page.dart`)
```dart
class DepartmentPage extends ConsumerWidget {
  // UI Components:
  // 1. Search bar
  // 2. Data table
  // 3. Bulk action buttons
  // 4. CSV export button
  // 5. Add department button
  
  // State Management:
  // - Department list
  // - Selected departments
  // - Loading state
  // - Error handling
}
```

### 3.2 Department Form (`lib/features/department/presentation/widgets/department_form.dart`)
```dart
class DepartmentForm extends ConsumerWidget {
  // Form Fields:
  // 1. Name input
  // 2. Code input
  
  // Validation:
  // - Required fields
  // - Code format
  // - Unique code check
  
  // Actions:
  // - Submit (Create/Update)
  // - Cancel
}
```

### 3.3 Enhanced DataTable (`lib/features/department/presentation/widgets/department_table.dart`)
```dart
class DepartmentTable extends ConsumerWidget {
  // Features:
  // 1. Sortable columns
  // 2. Row selection
  // 3. Bulk actions
  // 4. Search integration
  
  // Columns:
  // - Selection checkbox
  // - Code
  // - Name
  // - Created At
  // - Actions
}
```

## 4. File Structure
```
lib/features/department/
├── data/
│   ├── models/
│   │   └── department_model.dart
│   └── repositories/
│       └── department_repository.dart
├── presentation/
│   ├── pages/
│   │   └── department_page.dart
│   └── widgets/
│       ├── department_form.dart
│       └── department_table.dart
└── providers/
    ├── department_provider.dart
    └── department_state.dart
```

## 5. Implementation Steps

1. **Data Layer Setup**
   - Create department model
   - Implement repository with Supabase integration
   - Add error handling and validation

2. **State Management**
   - Create provider with state management
   - Implement CRUD operations
   - Add selection management
   - Implement search functionality

3. **UI Components**
   - Create department table widget
   - Implement department form
   - Add search bar and filters
   - Implement bulk operations UI
   - Add CSV export functionality

4. **Testing**
   - Unit tests for model and repository
   - Widget tests for form and table
   - Integration tests for CRUD operations

## 6. Additional Features

### 6.1 CSV Export Format
```csv
Code,Name,Created At
CS,Computer Science,2024-03-24
EE,Electrical Engineering,2024-03-24
```

### 6.2 Search/Filter
- Search by name or code
- Case-insensitive search
- Debounced input (300ms)

### 6.3 Bulk Operations
- Select all/none
- Delete selected
- Confirmation dialogs

### 6.4 Error Handling
- Duplicate code validation
- Network error handling
- Loading states
- User-friendly error messages