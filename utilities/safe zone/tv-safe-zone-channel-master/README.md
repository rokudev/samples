# TV Safe Zone Channel

This channel is a basic demo of Action Safe and Title Safe Zones for FHD and HD.

Preparing for how various TVs render your channel requires an understanding of Title and Action "Safe Zones". These are the recommended areas to ensuring the edges of your TV screen do not cut off the interface.

HD Safe Zones  | FHD Safe Zones
:-------------------------:|:-------------------------:
![](https://raw.githubusercontent.com/rokudev/docs/master/images/Roku-Safe-Zones-HD.png)  |  ![](https://raw.githubusercontent.com/rokudev/docs/master/images/Roku-Safe-Zones-FHD.png)

_Some things to keep in mind_

### Title Safe Zone
Keep text that you intend the audience to read within the **Title Safe Zone - 80% scale of UI resolution**

* The FHD Title Safe Zone is 1534x866, offset from the upper left corner (0,0) by 192, 106.
* The HD Title Safe Zone is 1022X578, offset from the upper left corner (0,0) by 128,70.
* The SD Title Safe Zone is 576X384, offset from the upper left corner (0,0) by 72,48.

### Action Safe Zone
Keep important visual elements within the **Action Safe Zone**, content outside the Action Safe Zone risks being cut off by the edge of the screen - **90% scale of UI resolution**

* The FHD Action safe zone is 1726x970, offset from the upper left corner (0,0) by 96, 53.
* The HD Action safe zone is 1150X646, offset from the upper left corner (0,0) by 64,35.
* The SD Action safe zone is 648X432, offset from the upper left corner (0,0) by 36,24.


#### Tool: Safe Zones Overlay
To help developers with testing their titles and action spaces, we've created a simple function that overlays these screens on their channel. Great for UX testing on FHD and HD.

You can find the project at https://github.com/rokudev/safe-zone-overlay

_Here's a sample of the tool in action_
![Safe Zones Overlay](https://raw.githubusercontent.com/rokudev/docs/master/images/safe-zone-overlay-example.png)
