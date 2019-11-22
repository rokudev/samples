# RAF4RSG Sample

This sample code demonstrates the use of Roku Advertising Framework in a Roku SceneGraph app. With v2 of RAF, the preferred way of use is by invoking the library from a Task node and passing a 3rd argument (`view`) to .ShowAds, which specifies where exactly in scene graph the ad content (video and interactive ad UI) should be attached.

## How does it work

main() creates an EntryScene (extends Scene), which only has a simplistic menu (LabelList). Selecting from there configures a VideoContent node with the video and ad information and starts playing it via a Player child node.

Player (extends Group) in turn creates a Video node child, sets the main content in it and delegates running the video and ad play to a PlayerTask.

PlayerTask (extends Task) in this sample is the only one "tasked" (pun intended) with playing the main content and the corresponding ads. It is also the only one that has to include the RAF library (`Library "Roku_Ads.brs"`). The runner function in PlayerTask - playContentWithAds() - makes the necessary library calls, the most notable being `.getAds()` to fetch ad pods and `.showAds()` to display them. Note that in RAF2 .showAds() has now a new, 3rd parameter - `view`, that is used to provide a renderable node in Roku Scene Graph, under which RAF should temporary attach its UI (incl. an ad video player node).

PlayContentWithAds() has an event loop, in which it keeps track of `position` events during playback of the main content, so that it could interrupt and insert mid-roll ads as appropriate (determined by repeat calls to .getAds()) - and when that is done, it resumes the main video. The event loop also handles other player state changes besides "position", for example it latches onto the video "finished" event for a chance to display post-roll ads.

## Pre-roll, mid-roll and post-roll ads

The code can handle pre-roll, mid-roll and post-roll ads on the same video content - subject to the ad server returning the pods configured that way during the .getAds() call.

Note that if invoked without a custom URL (as the sample does), only a single pre-roll ad will be shown, because that is the Roku ad server's default configuration. To change that behavior, .setAdUrl() pointing to customer's ad server has to be used (this falls under the "inventory split" model, see "Revenue Share" section in the documentation).

## Caveats

Notice this wrinkle - of PlayerTask having to manually set back the input focus after playing ads, since RAF UI has had the focus to be able to handle remote button presses.
