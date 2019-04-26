## Audio Markup

**Node Class Reference:** **Audio**

To play streaming media files in a Roku SceneGraph application, add one or both of the following media playback nodes to the application:

- **Audio**
- **Video**

These two media playback nodes both have very similar uses and markup.
The **Audio** node just needs to be created, and then have the URL of an MP3 audio file as a **Content Meta-Data** attribute in a **ContentNode** node assigned to the `content` field. Then set the **Audio** node `control` field to `play`, and listen to the sound of non-silence, as shown in the `audioscene.xml` component file in `AudioExample.zip`:

**Audio Markup Example**

```
<component name = "AudioExample" extends = "Scene" > 
  <script type = "text/brightscript" >
    <![CDATA[
    sub init()
      m.top.backgroundURI = "pkg:/images/rsgde_bg_hd.jpg"
      audio = createObject("roSGNode", "Audio")
      audiocontent = createObject("RoSGNode", "ContentNode")
      audiocontent.url = "http://www.sdktestinglab.com/Tutorial/sounds/audionode.mp3"
      audio.content = audiocontent
      m.top.appendChild(audio)
      audio.control = "play"
      m.top.setFocus(true)
    end sub
    ]]>
  </script>
</component>
```

For this example, we've used a very simple **ContentNode** node, and for some **Audio** node use cases, that may be exactly what you want. You might only want to play single sound effect over a scene in your application, with no additional visual element associated with the sound, so something like this example is all you need. The **Audio** node was designed not to have any visual user interface elements built into the node for this reason. This example is so simple, the audio will play to completion unless the **Back** key is pressed to exit the application, and if the audio plays to completion, you'll have to press the **Back** key to exit the application.

But if you want to play a number of sounds, and show some visual elements that are associated with the sounds, you'll need a **ContentNode** node with several more **Content Meta-Data** attributes...and you'll have to build your own custom visual user interface elements in markup.