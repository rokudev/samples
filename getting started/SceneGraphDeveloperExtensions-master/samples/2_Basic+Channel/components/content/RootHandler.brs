sub GetContent()
    ' url = CreateObject("roUrlTransfer")
    ' url.SetUrl("FEED_URL")
    ' url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    ' url.AddHeader("X-Roku-Reserved-Dev-Id", "")
    ' url.InitClientCertificates()
    ' feed = url.GetToString()
    ' this is for a sample, usually feed is retrieved from url using roUrlTransfer
    feed = ReadAsciiFile("pkg:/feed/feed.json")
    Sleep(2000)

    if feed.Len() > 0
        json = ParseJson(feed)
        if json <> invalid ' and json.rows <> invalid and json.rows.Count() > 0
            rootChildren = []
            for each item in json
                value = json[item]
                if item = "movies" or item = "series"
                    children = []
                    for each arrayItem in value
                        itemNode = CreateObject("roSGNode", "ContentNode")
                        Utils_ForceSetFields(itemNode, {
                            hdPosterUrl: arrayItem.thumbnail
                            Description: arrayItem.shortDescription
                            id: arrayItem.id
                            Categories: arrayItem["genres"][0]
                            title : arrayItem.title
                        })
                        if item = "movies"
                            ' Add 4k option
                            'Never do like this, it' s better to check if all fields exist in json, but in sample we can skip this step
                            itemNode.Url = arrayItem.content.videos[0].url
                        end if
                        if item = "series"
                            seasonArray = []
                            for each season in arrayItem.seasons
                                episodeArray = []
                                for each episode in season.episodes
                                    episodeNode = CreateObject("roSGNode", "ContentNode")

                                    episodeNode.setFields({
                                        title : episode.title
                                        url: episode.content.videos[0].url
                                        hdPosterUrl: episode.thumbnail
                                        Description: episode.shortDescription
                                    })

                                    episodeArray.Push(episodeNode)
                                end for
                                seasonArray.Push(episodeArray)
                            end for
                            Utils_ForceSetFields(itemNode, {"seasons": seasonArray})
                        end if
                        children.Push(itemNode)
                    end for
                    rowNode = CreateObject("roSGNode", "ContentNode")
                    rowNode.SetFields({
                        title: item
                    })
                    rowNode.AppendChildren(children)

                    rootChildren.Push(rowNode)
                    m.top.content.AppendChildren(rootChildren)
                end if
            end for
        end if
    end if
end sub
