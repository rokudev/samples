# Scene Graph Developer Extensions

> 02.15.2019

## v.1.1

### Features

#### VideoView

* To help minimize the amount of time buffer screens are visible, the VideoView has a new _preloadContent_ field that enables preflight execution of ContentHandlers and prebuffering of content both before the view is displayed and while endcards are visible.

#### GridView

* The GridView has been updated to use ZoomRowList instead of RowList to improve performance of the component in most scenarios. This change is transparent to developers, it *does not* change the existing GridView interfaces.
* The GridView has a new "zoom" style that leverages ZoomRowList to enable a zoom effect when scrolling between rows.

#### DetailsView

* The DetailsView has a new _itemLoaded_ field that can be observed to find out when the content of the view has changed.

### Sample Channels

* The Roku Billing / SVOD sample has been updated to work with the latest firmware.
* The videos used in the sample channels have been updated to fix some broken stream URLs.
* Fixed an issue in some samples where the video HUD would not appear as expected.

## v.1.0

### Features

 * Initial release.
