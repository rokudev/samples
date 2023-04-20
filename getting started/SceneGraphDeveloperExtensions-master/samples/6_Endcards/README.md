# SGDEX Guide: Endcards

## Part 1: Setting Up Endcards

The endcard is a part of the VideoView component.  We add this in function OpenVideoPlayer() right before we show it.  We add it by adding a ContentHandler and passing in the current video details that are stored video.content.  It is bad to pass in the reference directly however, so we make a deep copy using the clone() function.  You want to add it before setting video.control = "play".  Create EndcardHandler.brs and EndcardHandler.xml.  In the xml extend ContentHandler and create an interface which contains "currentItemContent" of type node.  The xml should look like this

```
<?xml version="1.0" encoding="UTF-8"?>
<component name="EndcardHandler" extends="ContentHandler">
  <interface>
    <field id="param" type="string" />
    <field id="currentItemContent" type="node" />
  </interface>

  <script type="text/brightscript" uri="pkg:/components/content/EndcardHandler.brs" />
</component>
```

Going to the EndcardHandler.brs file, we need to get the content that we passed in.  . The simpliest case is adding simple content node with some movie. API Call can be done the same way as in other ContentHandlers.

```
sub GetContent()
    row = Utils_ContentList2Node([{
        title: "Cult Scary Movies"
        shortDescriptionLine1: "Cult Scary Movies"
        hdPosterUrl: "http://img.delvenetworks.com/WQIfq-O2RZYjjgqxybNbHs/ac5Asmj6R2YqhYSExqnSJg/thp.540x302.jpeg"
        url: "http://roku.cpl.delvenetworks.com/media/59021fabe3b645968e382ac726cd6c7b/69ce40b268fa4766aa1612131aa74898/f9402439b3bb46028bcb3421821cadbf/roku-recommends_new.mp4"
    }])
    row.title = "ROW!"
    m.top.content.appendChild(row)
end sub
```

## Part 2: Back to GridHandler

Our goal is to save pointers to the next episode and the episode after that to each episode, as well as the first episode in the next season and tracking whether or not an episode is the last episode in the series.  To do this we will create our own type that extends ContentNode and includes an interface with all of those items.  Like when we first fetched the information, this will differ depending on the type of feed that you have.  If you are interested in our GetContent(), please take a look at the link to the code provided at the end of this guide.  Now go back to CGEndcard.brs.  When we override GetContent(), we check to see if it's the last episode of a season, the second to last episode of a season, or the last episode of the series.  This determines which info we add the the row, which we then append to m.top.content.  Please take note that we include "info :content.nextSeasonEp1".  This line is important because it allows us to pass all of the information through the endcard, rather than just the endcard relevant information (title, url, thumbnail).  

## Part 3: Triggering the Endcard

In the VideoPlayerLogic, you need to observe the field "endcardItemSelected" on video.    In the event function we get the endcard item, get the video, unobserve the field, close the video, then if the url exists, call the function, OpenVideoPlayerItem(item), and observe the field again.  The two functions should look like this below

```
sub OnEndcardItemSelected(event as Object)
    item = event.getData()
    video = event.GetRoSGNode()
    video.unobserveField("endcardItemSelected")
    video.close = true

    if item.url <> invalid
        video = OpenVideoPlayerItem(item)
        video.observeField("endcardItemSelected", "OnEndcardItemSelected")
    end if
end sub
```
###### Copyright (c) 2018 Roku, Inc. All rights reserved.
