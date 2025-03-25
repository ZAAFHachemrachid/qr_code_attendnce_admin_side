# Groups Feature Implementation Plan

## Overview
Split the groups functionality from the students feature into its own independent feature with dedicated navigation and event-based communication.

## Feature Structure
```
lib/features/groups/
├── groups.dart                    # Barrel file
├── data/
│   ├── models/
│   │   └── group_model.dart
│   └── repositories/
│       └── group_repository.dart
├── providers/
│   └── group_provider.dart
└── presentation/
    ├── pages/
    │   └── groups_page.dart
    └── widgets/
        ├── group_form.dart
        ├── group_form_dialog.dart
        └── groups_table.dart
```

## Implementation Steps

1. Feature Structure Setup
   - Create the above directory structure
   - Move existing files to their new locations
   - Create groups.dart barrel file

2. Update Navigation
   - Add groups page index in navigation_provider.dart
   - Create groups page route
   - Remove groups tab from students management view

3. Communication Layer
   - Create GroupEvents class for inter-feature communication
   - Implement event emission for group changes
   - Set up event listeners in student feature

4. Move and Update Files
   - Move all groups-related files to new structure
   - Update import paths
   - Add event emission on group changes

5. Student Feature Updates
   - Remove groups-specific code
   - Add group selection through events
   - Update student forms to use group selection dialog

