' ********** Copyright 2016 Roku Inc.  All Rights Reserved. **********

Sub Init()
    m.top.functionName = "loadContent"
End Sub

Sub loadContent()
    array = loadContentFeed()
    content = GetContentFeed(array)
    list = [ {
                Title:"Streams"
                ContentList : content
             } ]
    m.top.content = ParseContentFeed(list)
End Sub

Function ParseContentFeed(list As Object)
    RowItems = createObject("RoSGNode","ContentNode")

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

Function GetContentFeed(array as Object)
    result = []
    for each element in array
        item = {}
        item.Title = element.Title
        item.streamFormat = element.streamFormat
        item.HDPosterUrl = element.Logo
        item.Url = element.Stream
        result.push(item)
    end for
    return result
End Function
