sub GetContent()
    seasons = m.top.HandlerConfig.Lookup("seasons")
    rootChildren = []
    seasonNumber = 1
    for each season in seasons
        children = []
        for each episode in season
            children.Push(episode)
        end for
        seasonNode = CreateObject("roSGNode", "ContentNode")
        strSeasonNumber = StrI(seasonNumber)
        seasonNode.SetFields({
            title: "Season " + strSeasonNumber
            contentType: "section"
        })
        seasonNumber = seasonNumber + 1
        seasonNode.AppendChildren(children)
        rootChildren.Push(seasonNode)
    end for
    m.top.content.AppendChildren(rootChildren)
end sub
