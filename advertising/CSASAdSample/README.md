# Client-Side Ad Stitching

## **Overview**

This sample demonstrates how to create and render a client-side stitched stream using the Roku Advertising Framework (RAF). It shows you how you can combine a video with ads to create a stitched stream, and then render the stitched stream in a SceneGraph node. 

### **Workflow**

The sample first creates a screen and configures the Scene node in which the stitched stream will be rendered. It then passes the Scene node into a method (**PlayContentWithCSAS**) that specifies the URLs of the video and ads to be stitched together, instantiates the RAF library, and enables and configures the audience identifiers for the impression measurement tags that are fired when the ads are displayed. 

This method then sets the ad server request URL, gets the ads, which are specified in a video ad response XML file, and then stores the retrieved ads in an object. It also stores the metadata of the video to be played in a ContentNode. 

Finally, the **PlayContentWithCSAS** method calls the RAF **constructStitchedStream()** method to stitch the video meta data in the ContentNode with the ads, and then calls the RAF **renderStitchedStream()** method to render the stitched stream in the Scene node. 

## **Installation**

To run this sample, follow these steps:

1. Download and then extract the sample.

2. Expand the extracted **CSASAdSample** folder, and then compress the contents to a ZIP file.

3. Follow the steps in [Loading and Running Your Application](https://sdkdocs.roku.com/display/sdkdoc/Loading+and+Running+Your+Application) to enable developer mode on your device and sideload the ZIP file containing the sample onto it.

4. Optionally, you can launch the sample channel via the device UI to view the scene and video content items. The sample channel is named CSASAdSample (dev).

