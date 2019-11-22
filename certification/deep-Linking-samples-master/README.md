# Deep Linking

## **Overview**

This sample demonstrates how to launch content with deep links. It provides video content items that you can use to test deep linking via cURL commands and the External Control Protocol (ECP). It also shows you how you can design your application to deep link into content when both launching a channel and while the channel is already running.

### **Components**

The **FeedParser** component retrieves the video content items used in this sample from an XML feed and then indexes and transforms them into ContentNodes so they can be displayed in BrightScript components. This process is useful if you do not have a web service for pulling content IDs from your feed (for example, your feed is maintained in an Amazon S3 bucket).

Specifically, the **FeedParser** component stores the stream URLs and other meta data for each content item in the feed in an array of associative arrays. The captured meta data includes a thumbnail image (used for the channel&#39;s poster and background images), description, and title. Importantly, it stores the items&#39; GUIDs as content IDs and links them to the metadata. This enables you to pass the GUIDs in ECP cURL commands and deep link into the associated content. To display the content items on the screen, it formats the items into ContentNodes and then populates them in a RowItem.

The **HomeScene** component creates the scene used by the sample (a RowItem with four rows of Posters displaying the content&#39;s thumbnails), and it plays the video content item linked to the deep link it receives. The module contains an observer that listens for when a deep link is received. Upon receiving one, it validates the stream URL, content ID, and media type, and then launches the channel and plays the video specified by the content ID in the deep link.

The **InputTask** component listens for **roInputEvent** events to check whether a deep link has been received while the channel is already running. When one is received, it updates a global variable being monitored by the **HomeScene** module, which cues and plays the specified content.

## **Installation**

To run this sample, follow these steps:

1. Download and then extract the sample.

2. In the extracted **DeepLinkingSamples-master** folder, expand the **Basic\_DeepLink\_roInput\_Sample** folder. Compress the contents in this folder to a ZIP file.

3.  Follow the steps in [Loading and Running Your Application](https://sdkdocs.roku.com/display/sdkdoc/Loading+and+Running+Your+Application) to enable developer mode on your device and sideload the ZIP file containing the sample onto it.

4.  Optionally, you can launch the sample channel via the device UI to view the scene and video content items. The sample channel is named FirstApp (dev).

5.  Run the following cURL commands to test deep linking into the video content items n your development channel via ECP POST requests:

  - Deep linking upon channel launch:  curl -d &#39;&#39; &#39;http://\<Roku Device IP Address\>:8060/launch/dev?        contentID=2c4e8ea1ad2f4a8d9d244f5dd4cc47b6&amp;mediaType=movie&#39;

  - Deep linking while channel is running: curl -d &#39;&#39; &#39;http://\<Roku Device IP Address\>:8060/input?    contentID=2c4e8ea1ad2f4a8d9d244f5dd4cc47b6&amp;mediaType=movie&#39;
  
    When testing deep links on your production channel, replace &quot;dev&quot; with your channel ID. The syntax to use is    therefore: curl -d &#39;&#39; &#39;http://\<Roku Device IP Address\>:8060/\<command\>/<channelId\>?contentID=\<contentIdValue\>&amp;mediaType=\<mediaTypeValue>&#39;

6.  You can go to the [feed URL](http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/1cfd09ab38e54f48be8498e0249f5c83/media.rss) used in this sample to view the content IDs that you can pass into the ECP commands.  Alternatively, you can launch the sample channel and use the developer console to view a list of the content IDs. For convenience, a few of the content IDs are provided:
  
  - **Twitch**. 2c4e8ea1ad2f4a8d9d244f5dd4cc47b6
  - **Paula Dean**. 6c9d0951d6d74229afe4adf972b278dd
  - **TED**.  7405a8c101ee4c9da312c426e6067044
