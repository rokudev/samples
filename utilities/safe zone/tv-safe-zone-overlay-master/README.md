# TV Safe Zone Overlay
This brightscript file contains a function to overlay your current UI in your SceneGraph scene with a transparent safezone markup

#### Tool: Safe Zones Overlay
To help developers with testing their titles and action spaces, we've created a simple function that overlays these screens on their channel. Great for UX testing on FHD and HD.

_Here's a sample of the tool in action_
![Safe Zones Overlay](https://raw.githubusercontent.com/rokudev/docs/master/images/safe-zone-overlay-example.png)

## Use case
This BrightScript file can be added to a channel before publishing to avoid issues with truncated overhangs, posters, etc. **Note:** Works with channels built in Roku SceneGraph

## How to run this sample
- Add the `SafeZone.brs` file to your source folder in your SceneGraph app
- Call the method `SafeZone(scene)` underneath your `screen.show()` line in your `main.brs`

## Features
- Creates a transparent SafeZone markup on top of any SceneGraph app

## Channel Flow
- Event: Once the channel starts, a transparent overlay will show on top of the app UI
