## Video Markup

**Node Class Reference:** **Video**

It's time to actually play a video. The **Video** node, like the **Audio** node, requires a **ContentNode** node to be assigned as the value of the `content` field. The **ContentNode** node must contain all of the required **Content Meta-Data** attributes for playback of a video, but can also contain additional descriptive **Content Meta-Data** attributes, some of which are used in the **Video** node user interface.

The `videoscene.xml` component file in `VideoExample.zip` shows close to the minimum amount of markup required to play a video:

**Video Markup Example**

```
<component name = "VideoExample" extends = "Scene" >

  <script type = "text/brightscript" >
    <![CDATA[
    sub init()
      videocontent = createObject("RoSGNode", "ContentNode")
      videocontent.title = "Example Video"
      videocontent.streamformat = "mp4"
      videocontent.url = "http://roku.cpl.delvenetworks.com/.../rr_123_segment_1_072715.mp4"
 
      video = m.top.findNode("exampleVideo")
      video.content = videocontent
      video.setFocus(true)
      video.control = "play"
    end sub
    ]]>
  </script>
 
  <children >
    <Video id = "exampleVideo"/>
  </children>
</component>
```

First, we create a **ContentNode** node that contains the **Content Meta-Data** attributes for the video. Actually, of the three attributes added to the **ContentNode** node, only one is actually required: `url`, the location of the video file. The `streamformat` attribute is quite often not required because the **Video** node can determine the streaming file format based on the file suffix, `mp4` in this case. But you should include it in your server video content meta-data files to avoid any possible problems. And the `title` attribute is only used for parts of the **Video** node user interface, and the video will play without it.

Once the required and optional playback attributes are set in a **ContentNode** node, we assign the **ContentNode** node to the `content` field of the **Video** node that was created in the **<children>** element of the **<component>**. After that, we activate the **Video** node user interface by setting focus on the **Video** node, and set the `control` field to `play` to start playback. In this simple example, the video will play to completion unless the **Back** key is pressed to exit the application. If the video plays to completion, you will have to press the **Back** key to exit the application.