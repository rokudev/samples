sub GetContent()
    url = CreateObject("roUrlTransfer")
    url.SetUrl("http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/1cfd09ab38e54f48be8498e0249f5c83/media.rss")
    rsp = url.GetToString()

    responseXML = ParseXML(rsp)
    responseXML = responseXML.GetChildElements()
    responseArray = responseXML.GetChildElements()
    rootChildren = []
    children = []

    itemCount = 0
    rowCount = 0

    for each xmlItem in responseArray
        print "xmItem Name: " + xmlItem.getName()
        if xmlItem.getName() = "item"
            itemAA = xmlItem.GetChildElements() 'itemAA contains a single feed <item> element
            if itemAA <> invalid
                for each xmlItem in itemAA
                    item = {}
                    if xmlItem.getName() = "media:content"
                        item.url = xmlItem.getAttributes().url
                        xmlTitle = xmlItem.GetNamedElements("media:title")
                        item.title = xmlTitle.GetText()
                        xmlDescription = xmlItem.GetNamedElements("media:description")
                        item.description = xmlDescription.GetText()
                        item.streamFormat = "mp4"
                        xmlThumbnail = xmlItem.GetNamedElements("media:thumbnail")
                        item.HDPosterUrl = xmlThumbnail.GetAttributes().url
                        itemNode = CreateObject("roSGNode", "ContentNode")
                        itemNode.SetFields(item)

                        itemNode.addFields({
                            handlerConfigRAF: {
                                name: "HandlerRAF"
                                fields: {
                                    contentId: "ID"
                                }
                            }
                        })

                        children.Push(itemNode)
                    end if
                end for
            end if
            itemCount++
            if (itemCount = 4)
                print "Creating a new row"
                itemCount = 0
                rowCount++
                rowNode = CreateObject("roSGNode", "ContentNode")
                rowNode.SetFields({ title: "Row " + stri(rowCount) })
                rowNode.AppendChildren(children)
                rootChildren.Push(rowNode)
                children = []
            end if
        end if
    end for

    'Insert the last incomplete row if children array is not empty
    if (children.Count() > 0)
        rowCount++
        rowNode = CreateObject("roSGNode", "ContentNode")
        rowNode.SetFields({ title: "Row " + stri(rowCount)})
        rowNode.AppendChildren(children)
        rootChildren.Push(rowNode)
    end if
    m.top.content.appendChildren(rootChildren)
end sub

Function ParseXML(str As String) As dynamic
    if str = invalid return invalid
    xml = CreateObject("roXMLElement")
    if not xml.Parse(str) return invalid
    return xml
End Function
