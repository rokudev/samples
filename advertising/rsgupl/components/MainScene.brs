' ********** Copyright 2017 Roku,Inc.  All Rights Reserved. ********** 
function init()
    m.video = m.top.findNode("myVideo")
    m.video.notificationInterval = 1
    addTestItems()
    m.testItems = m.top.findNode("testItems")
    m.testItems.setFocus(true)
    m.testItems.observeField("itemSelected", "onTestItemSelected")
    m.testItems.observeField("itemFocused",  "onTestItemFocused")
    m.description = m.top.findNode("description")
    m.plyrTask = invalid
end function

function addTestItems()
    contentList = m.top.findNode("contentList")
    items = parsejson(readAsciiFile("pkg:/assets/contents.json"))
    if invalid <> items and invalid <> items["contents"]
        for each itemInfo in items["contents"]
            itm = createObject("roSGNode", "TestContent")
            itm.setFields(itemInfo)
            contentList.appendChild(itm)
        end for
    end if
end function

function onTestItemFocused(msg as Object)
    itemIdx = msg.getData()
    cont = m.testItems.content.getChild(itemIdx)
    if invalid <> cont and invalid <> m.description
        m.description["text"] = cont.description
    end if
end function
function onTestItemSelected(msg as Object)
    if invalid = m.plyrTask
        m.plyrTask = createObject("roSGNode", "playerTask")
        m.plyrTask.observeField("state", "onTaskStateUpdated")
    end if
    if invalid = m.prplyTask
        m.prplyTask = createObject("roSGNode", "PreplayTask")
        m.prplyTask.observeField("state", "onTaskStateUpdated")
    end if
    itemIdx = msg.getData()
    cont = m.testItems.content.getChild(itemIdx)
    ' ~~~ Let adapter know test data
    testConfig = {url: cont.url, title: cont.title, type: "vod"}
    if cont.live then testConfig["type"] = "live"
    ' ~~~ Optional, with or without calling stich
    if not cont.useStitched then testConfig["useStitched"] = false

    tsk = m.plyrTask
    if 0 < cont.title.inStr("preplay")
        tsk = m.prplyTask
    end if
    tsk.testConfig = testConfig
    tsk.video = m.video
    tsk.control = "run"
end function

function onTaskStateUpdated(msg as Object)
    if msg.getData() = "stop"
        backToMainMenu()
    end if
end function

function backToMainMenu() as Void
    m.video.visible = false
    m.testItems.setFocus(true)
    m.testItems.observeField("itemSelected", "onTestItemSelected")
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press then
        if key = "back" then
            if m.plyrTask.adPlaying = false
                m.video.control = "stop"
            end if
            return true
        end if
    end if
    return false
end function
