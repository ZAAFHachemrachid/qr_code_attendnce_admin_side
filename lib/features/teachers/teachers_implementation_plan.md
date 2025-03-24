# Teachers CRUD Implementation Plan

## Overview
This document outlines the plan for implementing CRUD (Create, Read, Update, Delete) operations for managing teachers in the QR Code Attendance System.

## Data Layer

### Teacher Model
```mermaid
classDiagram
    class TeacherModel {
        +String id
        +String firstName
        +String lastName
        +String? phone
        +String employeeId
        +String departmentId
        +DateTime createdAt
        +DateTime updatedAt
        +TeacherModel fromJson()
        +Map<String, dynamic> toJson()
    }

    class TeacherRepository {
        -SupabaseClient _client
        +Future<List<TeacherModel>> getAllTeachers()
        +Future<TeacherModel> createTeacher()
        +Future<TeacherModel> updateTeacher()
        +Future<void> deleteTeacher()
    }
```

## UI Flow

### Sequence Diagram
```mermaid
sequenceDiagram
    participant TeachersPage
    participant TeacherProvider
    participant TeacherRepository
    participant Supabase

    TeachersPage->>TeacherProvider: Initialize
    TeacherProvider->>TeacherRepository: getAllTeachers()
    TeacherRepository->>Supabase: SELECT from profiles JOIN teacher_profiles
    Supabase-->>TeacherRepository: Teachers data
    TeacherRepository-->>TeacherProvider: List<TeacherModel>
    TeacherProvider-->>TeachersPage: Update UI with teachers

    Note over TeachersPage: User clicks Add/Edit/Delete
    TeachersPage->>TeacherProvider: CRUD Operation
    TeacherProvider->>TeacherRepository: Perform Operation
    TeacherRepository->>Supabase: Execute SQL
    Supabase-->>TeacherRepository: Result
    TeacherRepository-->>TeacherProvider: Updated Data
    TeacherProvider-->>TeachersPage: Refresh UI
```

## Implementation Steps

1. Create Teacher Model:
   - Create `TeacherModel` class with all necessary fields
   - Implement `fromJson` and `toJson` methods
   - Add model validation

2. Create Teacher Repository:
   - Implement CRUD operations following admin repository pattern
   - Handle proper joins between profiles and teacher_profiles tables
   - Implement error handling and cleanup

3. Create Teacher Provider:
   - Use Riverpod for state management
   - Handle loading, error, and success states
   - Cache teacher data and provide CRUD methods

4. Update Teachers Page:
   - Use `DataTableWidget` for displaying teachers
   - Define columns: Name, Employee ID, Department, Phone, Actions
   - Implement sorting and filtering
   - Add floating action button for creating new teachers

5. Create Teacher Form:
   - Form for adding/editing teachers
   - Fields: First Name, Last Name, Email, Phone, Employee ID, Department
   - Form validation
   - Department dropdown selector

6. Add Dialog Confirmations:
   - Delete confirmation dialog
   - Success/Error feedback dialogs

## Architectural Principles

- Clean separation of concerns (data, business logic, UI)
- Consistent error handling and data validation
- Reuse of existing components (DataTableWidget)
- Follow existing patterns from admin implementation
- Type safety and null safety