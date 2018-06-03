## `0.6.0-rc.1` - WIP

* Breaking: Dart 2.
* Breaking: Revert back to `DocumentFileEngine` as default.
* Refactor.

## `0.5.0` - 2018-03-18

* Breaking: Fix typo `sharedPreference` to `sharedPreferences`
  (and `SharedPreferenceEngine` to `SharedPreferencesEngine`).
  You will need to rename if you are using it explicitly.

## `0.4.6` - 2018-03-14

* Fix library export.

## `0.4.5` - 2018-03-13

* Update load listener from `loadStream.listen` to Future.

## `0.4.4` - 2018-03-12

* Update `redux_persist` dependency.

## `0.4.3` - 2018-03-12

* Fix load bug (loaded JSON instead of string)

## `0.4.2` - 2018-03-10

* Breaking: Change PersistorGate `child` to `builder`.

## `0.4.1` - 2018-03-10

* Breaking: Change PersistorGate from Widget to WidgetBuilder.

## `0.4.0` - 2018-03-10

* Initial decoupling.
