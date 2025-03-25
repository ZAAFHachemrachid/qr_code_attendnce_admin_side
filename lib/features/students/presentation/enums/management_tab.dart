enum ManagementTab {
  view('View'),
  create('Create'),
  update('Update'),
  delete('Delete'),
  details('Details');

  final String label;
  const ManagementTab(this.label);
}
