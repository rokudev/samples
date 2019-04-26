## Audio List Markup

**Node Class References:** **Audio**, **LabelList**

For some applications that use an **Audio** node, a user interface to allow selection from a set of audio items, and visual indicators of the currently-selected audio item, is required.

For these applications, the **ContentNode** node that is assigned to the **Audio** node `content` field can contain as many **Content Meta-Data** descriptive attributes as needed to meet the user interface requirements of the application.

For this **Audio** node example, we'll just allow a user to select an audio item from a **LabelList** node list. We could use any of the list and grid nodes described in [**Creating Lists and Grids**](https://github.com/rokudev/samples/tree/master/ux%20components/lists%20and%20grids), but for this example we'll use a simple list. We also could set up a more elaborate user interface, that would show more descriptive text and images for each audio item as the user scrolls down the list. For example, we could show information about each song in a list of songs, such as the length, musicians, songwriters, and so forth. For ideas on how to implement that type of interface, see [**Video List Markup**](https://github.com/rokudev/samples/tree/master/media) below.

But we will add some additional control functions for the audio playback compared to the very simple [**AudioExample**](https://github.com/rokudev/samples/tree/master/media)  to allow users to stop an audio item during playback, and reset the **Audio** node after an audio item has completed playback. From `audiolistscene.xml` in `AudioListExample.zip`, note the `playaudio()` and `controlaudio()` callback functions, triggered by the **LabelList** node `itemselected` and **Audio** node `state` fields respectively:

```
sub init() 
  ...
  m.audiolist.observeField("itemSelected", "playaudio")
  ...
  m.audio.observeField("state", "controlaudioplay")
  ...
end sub
...

sub playaudio()
  m.audio.control = "stop"
  m.audio.control = "none"
  m.audio.control = "play"
end sub

sub controlaudioplay()
  if (m.audio.state = "finished")
    m.audio.control = "stop"
    m.audio.control = "none"
  end if
end sub
```

Remember [**Observed Fields Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/events%20and%20observers)? So when the user selects the audio item from the list, the `playaudio()` function is called. When the audio item has a playback state change, the `controlaudioplay()` function is called to reset the **Audio** node if the playback has completed. And we'll need a remote key event handler if the user presses the **Back** key to stop an audio item playback (review [**Key Events Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/events%20and%20observers) if needed):

```
function onKeyEvent(key as String,press as Boolean) as Boolean
  if press then
    if key = "back"
      if (m.audio.state = "playing")
        m.audio.control = "stop"
        return true
      end if
    end if
  end if
  return false
end function
```

The remainder of the `audiolistscene.xml` file is the **<children>** element, containing the XML **Group** node layout of the scene visual elements: the **LabelList** and **Poster** nodes.

![img](https://sdkdocs.roku.com/download/attachments/4262787/audiolistdoc.jpg?version=3&modificationDate=1472838970945&api=v2)

You can see how the content meta-data for the **LabelList** node is used to set the audio item strings in the list using the **Content Meta-Data** `title` attribute, as well as setting the `streamFormat` and `Url` **Content Meta-Data** attributes for audio playback:

<http://www.sdktestinglab.com/Tutorial/content/audiocontent.xml>

```
<Content >
  <item 
    title = "Main Menu" 
    streamformat = "mp3" 
    url = "http://www.sdktestinglab.com/Tutorial/sounds/mainmenu.mp3" />
  ...
```