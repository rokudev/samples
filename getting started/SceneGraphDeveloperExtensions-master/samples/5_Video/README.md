# SGDEX Guide: Video

## Part 1: Creating the video view

Create the file "VideoPlayerLogic.brs" in the components folder.  We will be creating two functions, OpenVideoPlayer(content, index, isContentList) and OpenVideoPlayer(contentItem).  The function with three arguments is used to play videos launched from a menu, the one with one argument is used for playing videos during autoplay, which we will get to in another guide.  We will start with the one with one argument.  Like the other views, we need to start by creating the object, setting values, and calling show() then returning the object.  Your function should look like the one below

```
function OpenVideoPlayerItem(contentItem) as Object
    video = CreateObject("roSGNode", "VideoView")
    video.content = contentItem
    video.isContentList = false
    video.control = "play"

    m.top.ComponentController.callFunc("show", {
        view: video
    })

    return video
end function
```

Now the one with three arguments is primarily the same but you assign a few more fields in video.  It should like like the one below

```
function OpenVideoPlayer(content, index, isContentList) as Object
    video = CreateObject("roSGNode", "VideoView")
    video.content = content
    video.jumpToItem = index
    video.isContentList = isContentList
    video.control = "play"

    m.top.ComponentController.callFunc("show", {
        view: video
    })

    return video
end function
```

One important distinction between these two functions is that OpenVideoPlayer is for when the content is a ContentList (it will auto play the next piece of content in list), OpenVideoPlayerItem is for just a single piece of content.  When it is a ContentList, video.content will not have the content meta-data for the first piece content, it will instead look like this:

```
<Component: roSGNode> =
{
    change: <Component: roAssociativeArray>
    focusable: false
    focusedChild: <Component: roInvalid>
    id: ""
    CM_focusedItem: 0
    cm_row_id_index: 1
    isFailed: false
    isLoaded: true
    isLoading: false
    TITLE: "movies"
}
```

and each piece of content will be a child of this object and will look something like this:

```
<Component: roSGNode> =
{
    change: <Component: roAssociativeArray>
    focusable: false
    focusedChild: <Component: roInvalid>
    id: "123456789"
    ACTORS: <Component: roArray>
    BOOKMARKPOSITION: 0
    CATEGORIES: <Component: roArray>
    content: <Component: roAssociativeArray>
    DESCRIPTION: "With the Twitch channel, you can watch the most popular broadcasts of the day, browse live broadcasts by the games you love and follow your favorite Twitch broadcasters."
    genres: <Component: roArray>
    HDPOSTERURL: "https://blog.roku.com/developer/files/2016/10/twitch-poster-artwork.png"
    id: "123456789"
    LENGTH: 0
    RATING: ""
    releaseDate: "2015-06-11"
    shortDescription: "With the Twitch channel, you can watch the most popular broadcasts of the day, browse live broadcasts by the games you love and follow your favorite Twitch broadcasters."
    SHORTDESCRIPTIONLINE1: ""
    SHORTDESCRIPTIONLINE2: ""
    STARRATING: 0
    tags: <Component: roArray>
    thumbnail: "https://blog.roku.com/developer/files/2016/10/twitch-poster-artwork.png"
    title: "Live Gaming Sample Content 1"
    URL: "http://roku.cpl.delvenetworks.com/media/59021fabe3b645968e382ac726cd6c7b/decbe34b64ea4ca281dc09997d0f23fd/aac0cfc54ae74fdfbb3ba9a2ef4c7080/117_segment_2_twitch__nw_060515.mp4"
}
```

## Part 2: Calling OpenVideoPlayer()

Now we go back to the DetailsViewLogic.brs file.  In the ShowDetailsView() function we need to add the following line after you create the details object,

```
details.ObserveField("buttonSelected", "OnButtonSelected")
```

In your OnButtonSelected function, you need to get the details object, from that get the buttons, then you can see what the buttons are.  If the button’s id is "play" we call OpenVideoPlayer with the corresponding arguments.  We will handle other cases in later guides.

```
sub OnButtonSelected(event as Object)
    details = event.GetRoSGNode()
    selectedButton = details.buttons.GetChild(event.GetData())

    if selectedButton.id = "play"
        OpenVideoPlayer(details.content, details.itemFocused, details.isContentList)
    else
        ' handle all other button presses
    end if
end sub
```

At this point your channel should be able to play videos that aren't part of a series.

###### Copyright (c) 2018 Roku, Inc. All rights reserved.
