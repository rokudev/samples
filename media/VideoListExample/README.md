## Video List Markup

**Node Class References:** **Video**, **LabelList**

You can create a dynamic screen that allows a user to browse through a list of video items, look at some details about each video item, then select a particular video for playback. This will show you the methods used to implement video-on-demand in a Roku application.

We've already seen how to select audio from a list of sounds in [**Audio List Markup**](https://github.com/rokudev/samples/tree/master/media), and you want to use the same basic techniques to integrate the **Video** node with a **LabelList** node (which could be any of the list and grid nodes described in [**Creating Lists and Grids**](https://github.com/rokudev/samples/tree/master/ux%20components/lists%20and%20grids)). But for this example, we'll use several more **Content Meta-Data** descriptive attributes in the **ContentNode** node for the screen. This allows the application to display the text and images set in the attributes as the user scrolls down the list of video items.

You will note that the `videolistscene.xml` file in `VideoListExample.zip` is set up in a very similar manner to the `audiolistscene.xml` file of `AudioListExample.zip` (see [**Audio List Markup**](https://github.com/rokudev/samples/tree/master/media) above). This is because the **Audio** and **Video** nodes are very similar, and both examples use a **LabelList** node to select the media playback items. So the **Task** node **Content Meta-Data** URL transfer, list selection, and media playback control callback functions are *mostly* the same. Both examples use a similar **<children>** element, containing the XML **Group** node layout of the scene visual elements.

But the user interface is enhanced by the addition of two lines to the `setvideo()` callback function (equivalent to `setaudio()` in `audiolistscene.xml`), triggered by the **LabelList** node `itemFocused` field:

```
sub init()
  ...
  m.videolist.observeField("itemFocused", "setvideo")
  ...
end sub
....
sub setvideo()
  videocontent = m.videolist.content.getChild(m.videolist.itemFocused)
  m.videoposter.uri = videocontent.hdposterurl
  m.videoinfo.text = videocontent.description
  m.video.content = videocontent
end sub
```

This is where we set the `hdposterurl` and `description` **Content Meta-Data** attributes, as the `m.videoposter` **Poster** node `uri`, and `m.videoinfo` **Label** node `text` fields, respectively. As the user scrolls down the list of videos, each change of the **LabelList** node `itemFocused` field triggers a `setvideo()` callback. The index number for the currently-focused video item in the `itemFocused` field is used to get the **ContentNode** node child containing the **Content Meta-Data**for the item. This allows all the **Content Meta-Data** for the focused video item to be assigned to various node fields in the application. As each video item is focused, these node field values are reassigned with the **Content Meta-Data** for that item.
 
![img](https://image.roku.com/ZHZscHItMTc2/videolistdoc.jpg)

You can see how the content meta-data for the **LabelList** node is used to set the video item strings in the list using the **Content Meta-Data** `title` attribute, as well as setting the other descriptive and media playback **Content Meta-Data** attributes in the videocontent.xml file.

```
<Content >
  <item 
    title = "Puppies and Kittens" 
    description = "So Cute!" 
    hdposterurl = "http://s2.content.video.llnw.net/lovs/images-prod/.../ZLh.540x304.jpeg" 
    streamformat  =  "mp4" 
    url = "http://roku.cpl.delvenetworks.com/media/.../rr_123_segment_1_072715.mp4" />
  ...
```
