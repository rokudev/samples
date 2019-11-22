Sub Init()
    m.top.functionName = "loadContent"
End Sub

Function ParseXML(str As String) As dynamic  'Takes in the content feed as a string
    if str = invalid return invalid  'if the response is invalid, return invalid
    xml = CreateObject("roXMLElement")  '
    if not xml.Parse(str)  return invalid  'if the string cannot be parse, return invalid
    return xml  'returns parsed XML if not invalid
End Function


Function GetContentFeed()  'This function retrieves and parses the feed and stores the content item in a ContentNode
    url = CreateObject("roUrlTransfer")  'component used to transfer data to/from remote servers
    url.SetUrl("http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/1cfd09ab38e54f48be8498e0249f5c83/media.rss")
    rsp = url.GetToString()  'convert response into a string

    responseXML = ParseXML(rsp)  'Roku includes its own XML parsing method

    if responseXML <> invalid then 'Fall back in case Roku's built in XML parse method fails
        responseXML = responseXML.GetChildElements()  'Access content inside Feed
        responseArray = responseXML.GetChildElements()
    End if

    'manually parse feed if ParseXML() is invalid
    result = []  'Store all results inside an array. Each element respresents a row inside our RowList stored as an Associative Array (line 63)
    mediaindex={}
    for each xmlItem in responseArray  'For loop to grab contents inside each item in XML feed
        if xmlItem.getName() = "item"  'Each individual channel content is stored inside the XML header named <item>
            itemAA = xmlItem.getChildElements()  'Get the child elements of item
            if itemAA <> invalid  'Fall bak in case invalid is returned
                item = {}  'Creates an associative array for each row
                for each xmlItem in itemAA  ' Goes thru all contents of itemAA
                    item[xmlItem.getName()] = xmlItem.getText()
                    if xmlItem.getName() = "media:content"  'Checks to find <media:content> header
                        item.stream = {url: xmlItem.url}  ' Assigns all content inside <media:content> to the item AA
                        item.url = xmlItem.getAttributes().url
                        item.streamFormat = "mp4"


                        mediaContent = xmlItem.GetChildElements()
                        for each mediaContentItem in mediaContent  'Looks through meiaContent to find poster image for each piece of content
                            if mediaContentItem.getName() = "media:thumbnail"
                                item.HDPosterURL = mediaContentItem.getattributes().url  'Assign image to item AA
                                item.HDBackgroundImageUrl = mediaContentItem.getattributes().url
                            end if
                        end for

                    else if xmlitem.getname()="guid"
                      item.guid=xmlitem.getText()
                    end if
                end for
                result.push(item)  'Pushes each AA into the Array
                mediaindex[item.guid] = item
                ''? "mediaindex= "; mediaindex
            end if
        end if
    end for
    return  {contentarray:result:index:mediaindex} 'Returns the array
End Function


Function ParseXMLContent(list As Object)  'Formats content into content nodes so they can be passed into the RowList
    RowItems = createObject("RoSGNode","ContentNode")
    'Content node format for RowList: ContentNode(RowList content) --<Children>-> ContentNodes for each row --<Children>-> ContentNodes for each item in the row)
    for each rowAA in list
        row = createObject("RoSGNode","ContentNode")
        row.Title = rowAA.Title

        for each itemAA in rowAA.ContentList
            item = createObject("RoSGNode","ContentNode")
            'Don't do item.SetFields(itemAA), as it doesn't cast streamFormat to proper value
            'for each key in itemAA
		' ?"key = ", key, itemAA[key]
                'item[key] = itemAA[key]
	    'end for
	    item.setFields(itemAA)
            row.appendChild(item)
        end for
        RowItems.appendChild(row)
    end for
    return RowItems
End Function



Function SelectTo(array as Object, num=25 as Integer, start=0 as Integer) as Object  'This method copies an array up to the defined number 'num' (default 25)
    result = []
    for i = start to array.count()-1
        result.push(array[i])
        if result.Count() >= num
            exit for
        end if
    end for
    return result
End Function

Sub loadContent()
  bundle=GetContentFeed()
    oneRow = bundle.contentArray
    'stop
    list = [
       'first row in the grid with 3 items across
       {
           Title:"Row One"
           ContentList: SelectTo(oneRow, 3)
       }
       'second row in the grid with 5 items across
       {
           Title:"Row Two"
           ContentList: SelectTo(oneRow, 5, 3)
       }
       'third row in the grid with 5 items across
       {
           Title:"Row Three"
           ContentList: SelectTo(oneRow, 5, 8)
       }
       'fourth row in the grid with remaining 2 items
       {
           Title:"Row Four"
           ContentList: SelectTo(oneRow, 5, 13)
       }
    ]
    m.top.content = ParseXMLContent(list)
    sleep(1000)
    m.top.mediaIndex=bundle.index
    ''? "m.top.mediaIndex= "; m.top.mediaIndex
End Sub
