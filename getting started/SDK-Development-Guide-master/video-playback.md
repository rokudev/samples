# Playing Video in SceneGraph

This guide demonstrates adding video to a SceneGraph project which is a continuation from [Building a UI in SceneGraph](/scenegraph-ui.md). This guide will use the same example project.

**Steps:**

1. [Create a video node](#1-create-a-video-node)
2. [Setup the video content](#2-setup-the-video-content)
3. [Map the back button](#3-map-the-back-button)

> :information_source: The following nodes and methods are used in this guide.
* [Video Node](https://sdkdocs.roku.com/display/sdkdoc/Video)
* [Content Node](https://sdkdocs.roku.com/display/sdkdoc/ContentNode)
* [OnKeyEvent()](https://sdkdocs.roku.com/pages/viewpage.action?pageId=1608547)

---

## 1. Create a video node

Video playback in SceneGraph is handled using the [Video Node](https://sdkdocs.roku.com/display/sdkdoc/Video).

In the `components` folder, open the `HomeScene.xml` file and the following code within the `<children>` tag:

```brightscript
<children>
    <Video
        id = "Video"
        height = "1080"
        width = "1920"
        enableUI = "false"
        loop = "true"
        visible = "false"/>
</children>
```

This creates a Video Node sized for FHD (1920x1080).

> :information_source: This is added to the end of the `.xml` file because we want the video to show in front of the other nodes in `HomeScene.xml`.

## 2. Setup the video content

The video content will be set up in BrightScript in the `HomeScene.brs` file that was created when designing the channel's UI.

In `HomeScene.brs`, it’s important to set a pointer when the channel is loading that references the Video Node. After doing this, we also create a Content Node (containing the meta-data for a piece of content) that we can assign to our Video Node later on.

Add the following lines to the `init()` function in `HomeScene.brs`:

```brightscript
m.Video = m.top.findNode("Video")
m.videoContent = createObject("roSGNode", "ContentNode")
```

We also need to set an observer function that waits for an item to be selected in the RowList so that the content's meta-data can be mapped to the Video Node. Add the line below to the `init()` function:

```brightscript
m.RowList.observeField("rowItemSelected", "playVideo")
```

This observer calls a function called `playVideo()` when an item is selected in our `RowList`.

The function `playVideo()` takes our content node named `m.videoContent` that we created earlier and assigns the video stream (mp4) to the field `videoContent.url`. It’s also important to set the `streamFormat` to one that matches the feed. In our case, set `m.videoContent.streamFormat` to `mp4`. Add the code below to `HomeScene.brs`:

```brightscript
Sub playVideo()
    m.videoContent.url = m.RowList.content.getChild(m.RowList.rowItemFocused[0]).getChild(m.RowList.rowItemFocused[1]).URL
    'rowItemFocused[0] is the row and rowItemFocused[1] is the item index in the row

    m.videoContent.streamFormat = "mp4"
    m.Video.content = m.videoContent
    m.Video.visible = "true"
    m.Video.control = "play"
End Sub
```

Now when an item in the `RowList` is selected, it will show a Video Node and play the content.

## 3. Map the back button

Lastly, to make sure the user is able to navigate back to the UI, we need a function that maps the Back button on the remote to leave the video. To do this, we'll create a function responding to an `onKeyEvent()` back button press. With the function below, the video will stop playing and be hidden when the back button is pressed and return to the UI. Add the following code to the end of `HomeScene.brs`:

```brightscript
Function onKeyEvent(key as String, press as Boolean) as Boolean 'Maps back button to leave video
    if press
    	if key = "back" 'If the back button is pressed
		m.Video.visible = "false" 'Hide video
		m.Video.control = "stop" 'Stop video from playing
		return true
        end if
    end if
end Function
```
