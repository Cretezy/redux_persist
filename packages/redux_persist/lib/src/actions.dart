/// Action being dispatched when done loading the state from disk.
class LoadedAction<T> {
  final T state;

  LoadedAction(this.state);
}

/// Action being dispatched to load the state from disk.
class LoadAction<T> {}

/// Action being dispatched when error loading/saving to disk
class PersistorErrorAction {}
