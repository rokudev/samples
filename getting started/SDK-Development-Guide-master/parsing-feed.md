# Parsing an XML Feed

### Overview

This guide covers how to parse an XML content feed using a task node in SceneGraph. This is a continuation from [Setting up a project](/project-setup.md) of the [SDK Development Guide](https://github.com/rokudev/SDK-Development-Guide).

Parsing an XML feed is one of the most common ways to retrieve content for Roku channels. This guide will be using this [sample MRSS feed](http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/1cfd09ab38e54f48be8498e0249f5c83/media.rss).

**Steps:**

1. [Create Task node](#1-create-task-node)
2. [Retrieve XML content feed](#2-retrieve-xml-content-feed)
3. [Parse XML content feed](#3-parse-xml-content-feed)
4. [Setup Task thread](#4-setup-task-thread)
5. [Addendum: Customizing grid size](#5-addendum-customizing-grid-size)

---

## 1. Create Task Node

First create a new XML file in the `components` folder called `FeedParser.xml`. All XML files need to be prefixed with:

```xml
<?xml version="1.0" encoding="UTF-8"?>
```

Create a new `component` within this file called `FeedParser` that extends from the `Task` node class.

```xml
<component name="FeedParser" extends="Task">
```

Next, create an interface field called `content` of type `node` that will be used to store each content item from the parsed XML feed.

```xml
<interface>
    <field id="content" type="node" />
</interface>
```

We also want to keep BrightScript code separate of SceneGraph. We can do this by referencing a separate `.brs` file using the `<script>` tag.

In the `components` folder, create a new file named `FeedParser.brs`. Now in `FeedParser.xml`, we can reference `FeedParser.brs` with the following `<script>` tag:

```xml
<script type="text/brightscript" uri = "pkg:/components/FeedParser.brs"/>
```

`FeedParser.xml` should look like below:
```xml
<?xml version="1.0" encoding="UTF-8"?>

<component name="FeedParser" extends="Task">

    <interface>
        <field id="content" type="node" />
    </interface>

    <script type="text/brightscript" uri = "pkg:/components/FeedParser.brs"/>
</component>
```

## 2. Retrieve XML content feed

Next, we need to retrieve the feed and convert it to a string so that it can be parsed. In `FeedParser.brs`, create a new `function` called `GetContentFeed()` using the code below:

```brightscript
Function GetContentFeed() 'This function retrieves and parses the feed and stores each content item in a ContentNode
    url = CreateObject("roUrlTransfer") 'component used to transfer data to/from remote servers
    url.SetUrl("http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/1cfd09ab38e54f48be8498e0249f5c83/media.rss")
    rsp = url.GetToString() 'convert response into a string

    responseXML = ParseXML(rsp) 'Roku includes it's own XML parsing method
End Function
```

In the last line, we'll pass the response string to a `ParseXML()` function that we'll cover next.

## 3. Parse XML content feed

We now have to parse the response string using the `ParseXML` method. `ParseXML` is a function that will try to parse the response string on the `XMLElement` or return `invalid` if it fails.

```brightscript
Function ParseXML(str As String) As dynamic 'Takes in the content feed as a string
    if str = invalid return invalid  'if the response is invalid, return invalid
    xml = CreateObject("roXMLElement") '
    if not xml.Parse(str) return invalid 'If the string cannot be parsed, return invalid
    return xml 'returns parsed XML if not invalid
End Function
```

In `GetContentFeed()`, it will need to be modified to handle what `ParseXML()` returns:

```brightscript
Function GetContentFeed() 'This function retrieves and parses the feed and stores each content item in a ContentNode
    url = CreateObject("roUrlTransfer") 'component used to transfer data to/from remote servers
    url.SetUrl("http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/1cfd09ab38e54f48be8498e0249f5c83/media.rss")
    rsp = url.GetToString() 'convert response into a string

    responseXML = ParseXML(rsp) 'Roku includes it's own XML parsing method

    if responseXML<>invalid then  'Fall back in case Roku's built in XML Parse method fails
        responseXML = responseXML.GetChildElements() 'Access content inside Feed
        responseArray = responseXML.GetChildElements()
    End if
End Function
```

### Manually parse feed if ParseXML() is invalid

In a fallback case when `invalid` is returned, the response string will have to be parsed manually. We'll modify `GetContentFeed()` one more time using the code below:

```brightscript
Function GetContentFeed() 'This function retrieves and parses the feed and stores each content item in a ContentNode
    url = CreateObject("roUrlTransfer") 'component used to transfer data to/from remote servers
    url.SetUrl("http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/1cfd09ab38e54f48be8498e0249f5c83/media.rss")
    rsp = url.GetToString() 'convert response into a string

    responseXML = ParseXML(rsp) 'Roku includes it's own XML parsing method

    if responseXML<>invalid then  'Fall back in case Roku's built in XML Parse method fails
        responseXML = responseXML.GetChildElements() 'Access content inside Feed
        responseArray = responseXML.GetChildElements()
    End if

    'manually parse feed if ParseXML() is invalid
    result = [] 'Store all results inside an array. Each element represents a row inside our RowList stored as an Associative Array (line 63)

    for each xmlItem in responseArray 'For loop to grab content inside each item in the XML feed
        if xmlItem.getName() = "item" 'Each individual channel content is stored inside the XML header named <item>
            itemAA = xmlItem.GetChildElements() 'Get the child elements of item
            if itemAA <> invalid 'Fall back in case invalid is returned
                item = {} 'Creates an Associative Array for each row
                for each xmlItem in itemAA 'Goes through all content of itemAA
                    item[xmlItem.getName()] = xmlItem.getText()
                    if xmlItem.getName() = "media:content" 'Checks to find <media:content> header
                        item.stream = {url : xmlItem.url} 'Assigns all content inside <media:content> to the  item AA
                        item.url = xmlItem.getAttributes().url
                        item.streamFormat = "mp4"

                        mediaContent = xmlItem.GetChildElements()
                        for each mediaContentItem in mediaContent 'Looks through MediaContent to find poster images for each piece of content
                            if mediaContentItem.getName() = "media:thumbnail"
                                item.HDPosterUrl = mediaContentItem.getattributes().url 'Assigns images to item AA
                                item.hdBackgroundImageUrl = mediaContentItem.getattributes().url
                            end if
                        end for
                    end if
                end for
                result.push(item) 'Pushes each AA into the Array
            end if
        end if
    end for
    return result ' Returns the array
End Function
```

> :information_source: The following code is specific to the schema of the sample feed used in this example. Your own content feed may vary.

## 4. Setup Task thread

Next, we setup the task node to call these functions when initialized. Because the `init()` method spawns on the render thread and we want the task node to run on a separate task thread, we setup the `init()` function to spawn a separate function on the task thread so that content can be loaded asynchronously.

```brightscript
Sub Init()
    m.top.functionName = "loadContent"
End Sub

Sub loadContent()
    list = GetContentFeed()
    m.top.content = ParseXMLContent(list)
End Sub
```

`list` is passed into a separate function named `ParseXMLContent` that takes all of the content and assigns them to content nodes that can be passed into a `RowList` component. The formatted content node is then passed into the content field of the task node so it can accessed from outside the scope of the task thread.

```brightscript
Function ParseXMLContent(list As Object) 'Formats content into content nodes so they can be passed into the RowList
    RowItems = createObject("RoSGNode","ContentNode")
    'Content node format for RowList: ContentNode(RowList content) --<Children>-> ContentNodes for each row --<Children>-> ContentNodes for each item in the row)
    for each rowAA in list
        row = createObject("RoSGNode","ContentNode")
        row.Title = rowAA.Title

        for each itemAA in rowAA.ContentList
            item = createObject("RoSGNode","ContentNode")
            item.SetFields(itemAA)
            row.appendChild(item)
        end for
        RowItems.appendChild(row)
    end for
    return RowItems
End Function
```

## Building a User Interface in SceneGraph

Continue to the next guide on [Building a User Interface in SceneGraph](/scenegraph-ui.md).
