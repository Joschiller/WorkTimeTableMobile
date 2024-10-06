import 'package:work_time_table_mobile/streamed_dao_helpers/dao_stream.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/identifiable.dart';

class ListDaoStream<T extends Identifiable> extends DaoStream<List<T>> {
  ListDaoStream(super.state);

  /// Pushes a full reload to the stream.
  @override
  void emitReload(List<T> elements) => super.emitReload(elements);

  /// Pushes a stream extended by the new elements.
  void emitInsertion(List<T> elements) => _emitChange(addedElements: elements);

  /// Pushes a stream where the updated elements are replaced with updated values. (Can also be used for upsert-statements.)
  void emitUpdate(List<T> elements) =>
      _emitChange(removedElements: elements, addedElements: elements);

  /// Pushes a stream where the deleted elements are removed.
  void emitDeletion(List<T> elements) => _emitChange(removedElements: elements);

  void _emitChange({List<T>? removedElements, List<T>? addedElements}) =>
      super.emitReload([
        ...state.where((e) =>
            removedElements == null ||
            !removedElements.any((u) => u.identity == e.identity)),
        ...(addedElements ?? []),
      ]);
}
