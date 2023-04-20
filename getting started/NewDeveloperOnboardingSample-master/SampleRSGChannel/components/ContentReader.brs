' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 

' For task nodes, we specify what function gets called when the user
' starts the task, which is always done on initializing the task. In
' this case, "getSampleContent" is the function to run.
sub init()
    m.top.functionName = "getSampleContent"
end sub

' For this task node, we will be retrieving the necessary data from the url
' specified from the uri field of this task. This function will return
' the content as a tree of ContentNodes.
sub getSampleContent()
    url = CreateObject("roUrlTransfer")
    url.SetUrl(m.top.uri)
    rsp = url.GetToString()

    responseXML = ParseXML(rsp)
    responseXML = responseXML.GetChildElements()
    responseArray = responseXML.GetChildElements()

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

    rawContentContainer = [
              {
                  title: "First Row"
                  contentList: result
              }
              {
                  title: "Second Row"
                  contentList: result
              }
        ]

    m.top.content = parseXMLSampleContent(rawContentContainer)
end sub

' This is a helper function to parse the raw XML content (as 
' an Array) and convert it into a tree of ContentNodes.
Function parseXMLSampleContent(xmlContainer as Object)
    contentContainer = createObject("roSGNode", "ContentNode")

    for each rowAA in xmlContainer
        row = createObject("RoSGNode","ContentNode")
        row.Title = rowAA.Title

        for each itemAA in rowAA.ContentList
            item = createObject("RoSGNode","ContentNode")
            for each key in itemAA
                item[key] = itemAA[key]
            end for
            row.appendChild(item)
        end for
        contentContainer.appendChild(row)
    end for

    return contentContainer
end Function

' A helper function to parse the raw xml content (as a
' string) and convert it into an array that can be passed
' to parseXMLSampleContent.
Function ParseXML(str As String) As dynamic
    if str = invalid return invalid
    xml=CreateObject("roXMLElement")
    if not xml.Parse(str) return invalid
    return xml
End Function