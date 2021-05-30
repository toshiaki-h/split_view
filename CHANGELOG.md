## 3.0.0

* This version contains breaking changes.
* Fields in view1 and view2 changed to children.
* Added the SplitviewController class due to controlling views weights and limits.
* Removed fields minWidthSidebar/maxWidthSidebar/minHeightSidebar/maxHeightSidebar and initialWeight. Instead, Added the WeightLimit class so that we can specify the weight.
* The argument of the onWeightChanged handler now has multiple weights.

## 2.1.1+1

* Formatted by dartfmt.

## 2.1.1

* The color of the split bar is now highlighted when the mouse hovered when used on the web.

## 2.1.0

* Added optional field for split bar color while dragging.

## 2.0.1+2

* Formatted by dartfmt.

## 2.0.1+1

* Add comments for dartdoc.

## 2.0.1

* Added optional fields for limit the sidebar size. (efraespada)
* Fix bug: Initial weight was used when calling `setState()`. (efraespada)
* Improvement: The `ValueNotifier<double?>` is initialized once. (efraespada)

## 2.0.0

* Migrate to null safety (GroovinChip)

## 1.0.4.+1

* Add identifier field to read/writeState methods. In order to identify the weight of each Splitview.

## 1.0.4

* Add key field to SplitView's constructor in order to save the split bar position.

## 1.0.3+1

* Fix bug.

## 1.0.3

* For Positioned widgets that wrap view1 and view2, adjust either the left, right, bottom, or top fields, taking into account widget.gripSize. (cedarbob)

## 1.0.2

* Set mouse cursor for Desktop & Web (jpnurmi)

## 1.0.1

* Add weight change event

## 1.0.0

* Change version number
* Modify description in pubspec.yaml

## 0.0.1

* Initial Release
