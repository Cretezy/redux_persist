import 'package:flutter/widgets.dart';
import 'package:redux_persist/redux_persist.dart';

/// PersistorGate waits until state is loaded to render the child [builder]
class PersistorGate extends StatefulWidget {
  /// Persistor to gate (wait on).
  final Persistor persistor;

  /// Widget to build once state is loaded.
  final WidgetBuilder builder;

  /// widget to show while waiting for state to load.
  final Widget loading;

  PersistorGate({
    this.persistor,
    this.builder,
    Widget loading,
  }) : this.loading = loading ?? Container(width: 0.0, height: 0.0);

  @override
  State<PersistorGate> createState() => _PersistorGateState();
}

class _PersistorGateState extends State<PersistorGate> {
  bool _loaded;

  @override
  initState() {
    super.initState();

    // Pre-loaded state
    _loaded = widget.persistor.loaded;

    if (!_loaded) {
      // Wait for load
      widget.persistor.loadStream.first.then((dynamic _) {
        setState(() {
          _loaded = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show [builder] if loaded, else show [loading] if it exist
    return _loaded ? widget.builder(context) : widget.loading;
  }
}
