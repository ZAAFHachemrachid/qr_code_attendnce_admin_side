/// The groups feature handles all functionality related to student groups.
///
/// This includes:
/// * Group management (CRUD operations)
/// * Group list display
/// * Group form handling
/// * Communication with other features through events

export 'data/models/group_model.dart';
export 'data/repositories/group_repository.dart';
export 'providers/group_provider.dart';
export 'presentation/pages/groups_page.dart';
export 'presentation/widgets/group_form.dart';
export 'presentation/widgets/group_form_dialog.dart';
export 'presentation/widgets/groups_table.dart';
