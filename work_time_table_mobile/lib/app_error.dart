// ignore_for_file: constant_identifier_names

enum AppError {
  data_dao_unknownUser('Tried to perform an action for an unknown user.'),

  service_noUserLoaded('No user is loaded yet.'),

  service_user_unknownUser('Tried to perform an action for an unknown user.'),
  service_user_invalidBlankName('The username cannot be blank.'),
  service_user_duplicateName('This name is already used.'),
  service_user_forbiddenDeletion('Deletion of this user is not allowed.'),
  service_user_unconfirmedDeletion('Deleting the user was not confirmed.'),

  service_weekSettings_invalid('The week settings are invalid.'),
  service_weekSettings_invalidTargetWorktime(
      'The target work time must be smaller than or equal to the sum of the time equivalents per day.'),

  service_eventSettings_invalid('The event settings must be valid.'),
  service_eventSettings_unconfirmedDeletion(
      'Deleting the event was not confirmed.'),
  service_eventSettings_unknown('There exists no event with that given id.'),

  service_globalSettings_int_invalid('The setting must be a valid integer.'),
  service_globalSettings_scrollInterval_invalid(
      'The scroll interval must be a valid integer.'),

  service_timeInput_invalid('The inserted values are invalid.'),
  service_timeInput_alreadyClosed('The week is already finished.'),
  service_timeInput_unconfirmedReset('Resetting the week was not confirmed.'),
  service_timeInput_missingPredecessorClose(
      'The preceeding week must be closed first.'),
  service_timeInput_earlyClose('The week cannot be closed yet.'),
  service_timeInput_unconfirmedClose('Finishing the week was not confirmed.'),

  service_export_error_export('Exporting the data failed.'),
  service_export_error_export_aborted('Export aborted.'),
  service_export_error_import('Importing the data failed.'),
  service_export_error_import_duplicate('The user already exists.'),
  service_export_error_import_invalid(
      'The imported file contains invalid data.'),
  service_export_error_import_aborted('Import aborted.'),
  ;

  final String displayText;

  const AppError(this.displayText);
}
