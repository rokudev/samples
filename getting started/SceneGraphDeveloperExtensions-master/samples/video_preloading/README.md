# SGDEX Sample Channel

## Video Preloading (Requires SGDEX v1.1)

This sample demonstrates using the SGDEX VideoView in playlist mode with endcards and preloading.
Preloading enables pre-flight execution of ContentHandlers and prebuffering of content
to minimize the amount of time the video buffer screen is visible.

### GridView

The GridView displays a single row of videos parsed from an RSS feed.

### DetailsView and VideoView

In this sample, the DetailsView and VideoView are more tightly integrated than if we weren't preloading.
When the DetailsView is shown, we also create a VideoView and begin preloading the content.
The VideoView is not shown until the user selects the "Play" button on the DetailsView.

###### Copyright (c) 2019 Roku, Inc. All rights reserved.
