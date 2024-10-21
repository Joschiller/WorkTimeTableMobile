import 'package:work_time_table_mobile/stream_helpers/identifiable.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_dao_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';

class ContextDependentListDaoStream<T extends Identifiable>
    extends ContextDependentDaoStream<List<T>> {
  /// Pushes a new state extended by the new elements.
  void emitInsertion(List<T> elements) => _emitChange(addedElements: elements);

  /// Pushes a new state where the updated elements are replaced with updated values. (Can also be used for upsert-statements.)
  void emitUpdate(List<T> elements) =>
      _emitChange(removedElements: elements, addedElements: elements);

  /// Pushes a new state where the deleted elements are removed.
  void emitDeletion(List<T> elements) => _emitChange(removedElements: elements);

  void _emitChange({List<T>? removedElements, List<T>? addedElements}) =>
      super.emitReload(switch (state) {
        NoContextValue() => ContextValue(addedElements ?? []),
        ContextValue(value: var stateValue) => ContextValue([
            ...removedElements == null
                ? stateValue
                : stateValue.where(
                    (e) =>
                        !removedElements.any((u) => u.identity == e.identity),
                  ),
            ...(addedElements ?? []),
          ]),
      });
}
