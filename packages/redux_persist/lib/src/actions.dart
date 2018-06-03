abstract class PersistAction {}

/// Action being dispatched when done loading the state from disk.
class PersistLoadedAction<T> extends PersistAction {
  /// Loaded state.
  final T state;

  PersistLoadedAction(this.state);
}

/// Action being dispatched when loading the state from disk.
class PersistLoadingAction extends PersistAction {}

class PersistSavedAction extends PersistAction {}

class PersistSavingAction extends PersistAction {}

/// Action being dispatched when error loading/saving to disk.
class PersistErrorAction extends PersistAction {
  final dynamic error;

  PersistErrorAction(this.error);
}
