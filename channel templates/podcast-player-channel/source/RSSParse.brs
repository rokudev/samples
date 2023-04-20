Function RSSParse()
       m.glb.Addfield("warning", "int", true)
       MyContent = GetPodCastInfo(m.feed)  'Parses through feed given by config.brs file
       if MyContent = invalid
       m.glb.warning = 2
       return invalid
       end if
       m.glb.Addfield("PodcastTitle", "string", true) 'Adds content for UI. This was not put in a content node because it requires less accessors to get the UI info
       m.glb.Addfield("uri", "string", true)
       m.glb.Addfield("summary", "string", true)
       m.glb.Addfield("author", "string", true)
       m.glb.PodcastTitle = MyContent["Title"].getText()
       m.glb.uri = MyContent["itunes:image"].getAttributes()["href"]
       if MyContent.DoesExist("tunes:summary")
            m.glb.summary = MyContent["itunes:summary"].getText()
       end if
       m.glb.author = MyContent["itunes:author"].getText()
       m.glb.warning = 0

       m.ChildContent = GetEpisodes(m.feed)

' #### Problem with RSS Feed will be in this for loop ####
       m.TopContent = createObject("roSGNode", "ContentNode") 'Appends all Podcast episodes to a single content node
       for each item in m.ChildContent
            row = createObject("roSGNode", "ContentNode")
            row.title = item["title"].getText()
            row.ContentType = "audio"
            row.streamFormat = "mp3"
            if item.DoesExist("itunes:duration")
                duration = 1
                row.Length = item["itunes:duration"].getText().ToInt()
                if item["itunes:duration"].getText().split(":").count() = 3
                    x = item["itunes:duration"].getText().split(":")
                    row.Length = x[0].toInt()*360 + x[1].toInt() *60 + x[2].toInt()
                else if item["itunes:duration"].getText().split(":").count() = 2
                    x = item["itunes:duration"].getText().split(":")
                    row.Length = x[0].toInt()*60 + x[1].toInt()
                end if
            else
                duration = 0
                m.glb.warning = 1
            end if
            if item.DoesExist("itunes:summary")
                row.Description = item["itunes:summary"].getText()
            end if
            row.URL = item["enclosure"].getAttributes()["url"]
            if item.DoesExist("itunes:explicit")
                if  item["itunes:explicit"].getText() = "yes"
                    row.Rating = "R"
                end if
            end if
            if duration = 1
                m.TopContent.appendChild(row)
            end if
      end for
end Function

Function GetPodCastInfo(PodcastUrl as String) as object'Used to get main info.. Podcast Title, Podcast Artwork, Summary, etc...
    url = createObject("roUrlTransfer")
    url.setUrl(PodcastUrl)
    urlString = url.GetToString()

    XML = checkXML(urlString)
    if XML = invalid
        m.glb.warning =2
        return invalid
    end if
    XML = XML.GetChildElements()
    XMLArray = XML.GetChildElements()

    result = {}

    for each item in XMLArray
        result[item.getName()] = item
    end for
    return result
End Function


Function GetEpisodes(PodcastUrl as String) as object 'Used for episodes, separated for now until Global issue is fixed
    url = createObject("roUrlTransfer")
    url.setUrl(PodcastUrl)
    urlString = url.GetToString()

    XML = checkXML(urlString)
    if XML = invalid
        m.glb.warning = 2
        return invalid
    end if
    XML = XML.GetChildElements()
    XMLArray = XML.GetChildElements()

    episodelist = []
    for each item in XMLArray
        if item.getName() = "item"
        episodes = {}
        episodesArray = item.getChildElements()
        for each episode in episodesArray
            episodes[episode.getName()] = episode
        end for
        episodelist.Unshift(episodes)
        end if
    end for
    return episodelist
End Function


Function checkXML(str as String) as dynamic 'Checks to make sure that feed is working
    if str = invalid return invalid
    xml = createObject("roXMLElement")
    if not xml.Parse(str) return invalid
    return xml
End Function
