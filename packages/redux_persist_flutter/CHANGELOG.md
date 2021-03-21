## `0.9.0` - 2021-03-21

- Add null-safety support. Required Dart >=2.12

## `0.8.3` - 2020-08-28

* Add Web Note
* Update with backup note
* Update dependencies

## `0.8.2` - 2019-08-12

* Upgrade dependencies

## `0.8.1` - 2019-02-11

* Upgrade dependencies

## `0.8.0` - 2018-11-27

* Release v0.8.0. Last v0.x release line.

## `0.8.0-rc.0` - 2018-11-06

* Breaking: Changed required parameter `key` to optional named parameter.
* Breaking: Remove gate. Load initial state before calling `runApp`.

## `0.6.0` - 2018-08-10

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
