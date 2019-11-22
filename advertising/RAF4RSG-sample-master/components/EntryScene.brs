'*********************************************************************
'** (c) 2016-2017 Roku, Inc.  All content herein is protected by U.S.
'** copyright and other applicable intellectual property laws and may
'** not be copied without the express permission of Roku, Inc., which
'** reserves all rights.  Reuse of any of this content for any purpose
'** without the permission of Roku, Inc. is strictly prohibited.
'*********************************************************************

sub init()
    'we use a simple LabelList for a menu
    m.list = m.top.FindNode("list")
    m.list.observeField("itemSelected", "onItemSelected")
    m.list.SetFocus(true)

    'descriptor for the menu items
    itemList = [
        {
            title: "Roku ad server (default server URL, single pre-roll)"
            url: "" 'point to your own ad server if doing "inventory split" revenue share
        }
    ]

    ' compile into a ContentNode structure
    listNode = CreateObject("roSGNode", "ContentNode")
    for each item in itemList:
        nod = CreateObject("roSGNode", "ContentNode")
        nod.setFields(item)
        listNode.appendChild(nod)
    next
    m.list.content = listNode

end sub

sub onItemSelected()
    m.list.SetFocus(false) ' un-set focus to avoid creating multiple players on user tapping twice
    menuItem = m.list.content.getChild(m.list.itemSelected)

    videoContent = {

        streamFormat: "mp4",
        titleSeason: "Art21 Season 3",
        title: "Place",
        url:  "http://roku.cpl.delvenetworks.com/media/59021fabe3b645968e382ac726cd6c7b/decbe34b64ea4ca281dc09997d0f23fd/aac0cfc54ae74fdfbb3ba9a2ef4c7080/117_segment_2_twitch__nw_060515.mp4",

        'used for raf.setContentGenre(). For ads provided by the Roku ad service, see docs on 'Roku Genre Tags'
        categories: ["Documentary"]

        'Roku mandates that all channels enable Nielsen DAR
        nielsen_app_id: "P2871BBFF-1A28-44AA-AF68-C7DE4B148C32" 'required, put "P2871BBFF-1A28-44AA-AF68-C7DE4B148C32", Roku's default appId if not having ID from Nielsen
        nielsen_genre: "DO" 'required, put "GV" if dynamic genre or special circumstances (e.g. games)
        nielsen_program_id: "Art21" 'movie title or series name
        length: 3220 'in seconds;

    }
    ' compile into a VideoContent node
    content = CreateObject("roSGNode", "VideoContent")
    content.setFields(videoContent)
    content.ad_url = menuItem.url

    if m.Player = invalid:
        m.Player = m.top.CreateChild("Player")
        m.Player.observeField("state", "PlayerStateChanged")
    end if

    'start the player
    m.Player.content = content
    m.Player.visible = true
    m.Player.control = "play"
end sub

sub PlayerStateChanged()
    print "EntryScene: PlayerStateChanged(), state = "; m.Player.state
    if m.Player.state = "done" or m.Player.state = "stop"
        m.Player.visible = false
        m.list.setFocus(true) 'NB. the player took the focus away, so get it back
    end if
end sub
