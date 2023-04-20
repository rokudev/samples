function itemContentChanged()
    m.itemPoster.uri = m.top.itemContent.HDPOSTERURL

    trackCount = m.top.itemContent.getChildCount()

    m.numTracks.text = trackCount.tostr() + " Items"

    updateLayout()
end function

function widthChanged()
    updateLayout()
end function

function heightChanged()
    updateLayout()
end function

function focusPercentChanged()
    m.itemOverlay.opacity = m.top.focusPercent

    m.itemOverlay.visible = m.top.rowListHasFocus and (m.itemOverlay.opacity > 0)
end function

function updateLayout()
    if m.top.height > 0 and m.top.width > 0 
        posterSize = m.top.height

        m.itemPoster.width  = posterSize
        m.itemPoster.height = posterSize

            m.overlayBG.width  = posterSize
        m.overlayBG.height = posterSize / 3
        m.overlayBG.translation = [0, posterSize - m.overlayBG.height ]

        m.overlayContent.translation = [ 5, (m.overlayBG.height - m.playIcon.height) / 2 ]
    end if
end function

function init()
    m.itemPoster  = m.top.findNode("itemPoster")
    m.itemOverlay = m.top.findNode("itemOverlay")
    m.overlayContent = m.top.findNode("overlayContent")
    m.overlayBG   = m.top.findNode("overlayBG")
    m.playIcon    = m.top.findNode("playIcon")
    m.numTracks   = m.top.findNode("numTracks")
end function