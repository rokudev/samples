' ********** Copyright 2019 Roku Corp.  All Rights Reserved. ********** 

Sub init()
    m.port = createObject("roMessagePort")
    m.top.functionName = "getContent"
end Sub

Function getContent()
    urlTransfer = createObject("roUrlTransfer")
    urlTransfer.setMessagePort(m.port)
    urlTransfer.setUrl(m.top.requestUrl)
    urlTransfer.asyncGetToString()

    while true
        msg = wait(0, m.port)

        if type(msg) = "roUrlEvent"
            handleResponse(msg.getString())
            exit while
        end if
    end while
end Function

Sub handleResponse(data as Object)
    responseXML = ParseXML(data)
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

    m.top.response = createResponse(result)
end Sub

Function ParseXML(str As String) As dynamic
    if str = invalid return invalid
    xml=CreateObject("roXMLElement")
    if not xml.Parse(str) return invalid
    return xml
End Function

Function createResponse(parsedData as Object)
    list = [
        {
            TITLE : "First row"
            ContentList : parsedData
        }
        {
            TITLE : "Second row"
            ContentList : parsedData
        }
    ]

   return list
end Function