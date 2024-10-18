// ignore_for_file: constant_identifier_names

enum AppError {
  data_dao_unknownUser('Tried to perform an action for an unknown user.'),

  service_user_unknownUser('Tried to perform an action for an unknown user.'),
  service_user_invalidName('This name is invalid.'),
  service_user_duplicateName('This name is already used.'),
  service_user_forbiddenDeletion('Deletion of this user is not allowed.'),
  service_user_unconfirmedDeletion('Deleting the user was not confirmed.'),
  ;

  final String displayText;

  const AppError(this.displayText);
}
