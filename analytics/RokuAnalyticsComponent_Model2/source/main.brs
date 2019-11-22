' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 
 
 'Channel entry point
 sub RunUserInterface()
    'screen, scene and port initialization
    m.screen = CreateObject("roSGScreen")
    scene = m.screen.CreateScene("BaseScene")
    m.port = CreateObject("roMessagePort")
    
    'Set the roMessagePort to be used for all events from the screen.
    m.screen.SetMessagePort(m.port)

    'Show Scene Graph canvas that displays the contents
    'of a Scene Graph Scene node tree
    m.screen.Show()
    
    'Populating content for entire channel from external feed.
    '==========================================================================
    'This is a place where OnContent() function will be triggered(BaseScene.brs)
    'It is triggered, because we added observer call-back function 
    'to field with id="content" in BaseScene.xml:
    '      Code example: <field id="content" type="node" onChange="OnContent"/>
    'It is equivalent to calling ObserveField() in BrightScript code 
    'associated with the component as follows:
    '      Code example: m.scene.ObserveField("content", "OnContent")
    'Please keep in mind, that in general, from external resource you will 
    'probably recieve data in format like XML or JSON, that is why 
    'it should be parsed to Bright Script Objects and transformed 
    'to ContentNode (roSGNode) that can be used by any RSG Node further. 
    'GetApiArray() and Utils_ContentList2Node() will help us with that.
    
    content = Utils_ContentList2Node(GetApiArray())
    sleep(1000)
    ?"received content"
    scene.content = content  
    scene.content2 = content  
    ?"content set" scene.content
    'main channel loop
    while true
        msg = wait(0, m.port)
        if msg <> invalid
            print "------------------"
            print "msg = "; msg
        end if
        msgType = type(msg)

        if msgType = "roSGScreenEvent"
            'handle exit from channel
            if msg.isScreenClosed() then exit while
        else if msgType = "roSGNodeEvent"
            
        end if
    end while
    
    if m.screen <> invalid then
        m.screen.Close()
        m.screen = invalid
    end if
    
end sub

' Part of channel specific logic, where you will work with some 
' external resources, like REST API, etc. You may get raw data from feed, then
' parse it and return as a native BrightScript object(roAA, roArray, etc) 
' with some proper Content Meta-Data structure.
' 
' If you will have a complex parsing process with a lot of external resourses,
' then it will be a good practice to move all logic to separate files.
Function GetApiArray()
    url = CreateObject("roUrlTransfer")
    'External resource
    url.SetUrl("http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/1cfd09ab38e54f48be8498e0249f5c83/media.rss")
    rsp = url.GetToString()

    'Utility function for XML parsing.
    'Bassed on native Bright Script XML parser.
    responseXML = Utils_ParseXML(rsp)
    If responseXML <> invalid then
         responseXML   = responseXML.GetChildElements()
         responseArray = responseXML.GetChildElements()
    End if     

    'The result will be roArray object.
    result = []

    'Work with parsed XML and add to roArray some data.
    for each xmlItem in responseArray
        if xmlItem.getName() = "item"
            itemAA = xmlItem.GetChildElements()
            if itemAA <> invalid
                item = {}
                for each xmlItem in itemAA
                    item[xmlItem.getName()] = xmlItem.getText()
                    if xmlItem.getName() = "media:content"
                        item.stream = {url : xmlItem.url}
                        item.url = xmlItem.getAttributes().url
                        item.streamFormat = "mp4"
                        mediaContent = xmlItem.GetChildElements()
                        for each mediaContentItem in mediaContent
                            if mediaContentItem.getName() = "media:thumbnail"
                                item.HDPosterUrl = mediaContentItem.getattributes().url
                                item.hdBackgroundImageUrl = mediaContentItem.getattributes().url
                            end if
                        end for
                    end if
                end for
                result.push(item)
            end if
        end if
    end for
    return result
End Function

' Copies all fields from associative array to content node.
' Generally used for transforming parsed conetent from feed
' to special node type that is used by other RSG nodes.
' @param contentList As Object - associative array
' @return As Object - valid ContentNode
function Utils_ContentList2Node(contentList as Object) as Object
    result = createObject("roSGNode","ContentNode")
    
    for each itemAA in contentList
        item = createObject("roSGNode", "ContentNode")
        for each field in itemAA
            if item.hasField(field)
                item[field] = itemAA[field]
            end if
        end for
        result.appendChild(item)
    end for
    
    return result
end function

' Utils_ParseXML - parse string XML into object
' Checks if input is valid XML String and parse it to 
' valid roXMLElement that can be used to contain an XML tree.' 
' @param str As String - string to parse
' @return As Dynamic - roXmlElement object or invalid
Function Utils_ParseXML(str As String) As dynamic
    if str = invalid return invalid
    xml = CreateObject("roXMLElement")
    if not xml.Parse(str) return invalid
    return xml
End Function