' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 
 
 sub RunUserInterface()
    screen = CreateObject("roSGScreen")
    scene = screen.CreateScene("HomeScene")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    screen.Show()
    
    
    
    
    LabelList = [
        {title : "Movies"},
        {title : "TV"},
        {title : "Category 1"},
        {title : "Category 2"},
        {title : "Category 3"},
        {title : "Category 4"},
        {title : "Category 5"}
    ]
    OptionsList = [{Title:"Play"},
                   {Title:"Play video too"}]             
    scene.Content = ContentList2Node(GetApiArray())
    scene.LabelContent = ContentList2Node(LabelList)
    scene.OptionsContent = ContentList2Node(OptionsList)
    while true
        msg = wait(0, port)
        print "------------------"
        print "msg = "; msg
    end while
    
    if screen <> invalid then
        screen.Close()
        screen = invalid
    end if
    
end sub


Function ParseXMLContent(list As Object)
    RowItems = createObject("RoSGNode","ContentNode")
    
    for each rowAA in list
        row = ContentList2Node(rowAA.ContentList)
        row.Title = rowAA.Title
        RowItems.appendChild(row)
    end for

    return RowItems
End Function

function ContentList2Node(contentList as Object) as Object
    result = createObject("roSGNode","ContentNode")
    
    for each itemAA in contentList
        item = createObject("roSGNode", "ContentNode")
        item.SetFields(itemAA)
        result.appendChild(item)
    end for
    
    return result
end function

Function GetApiArray()
    url = CreateObject("roUrlTransfer")
    url.SetUrl("http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/1cfd09ab38e54f48be8498e0249f5c83/media.rss")
    rsp = url.GetToString()

    responseXML = ParseXML(rsp)
    If responseXML <> invalid then
         responseXML   = responseXML.GetChildElements()
         responseArray = responseXML.GetChildElements()
    End if     

    result = []

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


Function ParseXML(str As String) As dynamic
    if str = invalid return invalid
    xml = CreateObject("roXMLElement")
    if not xml.Parse(str) return invalid
    return xml
End Function