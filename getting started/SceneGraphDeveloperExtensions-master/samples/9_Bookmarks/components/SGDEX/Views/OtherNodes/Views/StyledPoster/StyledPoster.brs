' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub Init()
    m.availableShapes = {
        "portrait" : ""
        "4x3" : ""
        "16x9" : ""
        "square" : ""
    }

    m.top.loadDisplayMode="scaleToFit"
    m.top.observeField("shape", "UpdateSize")
end sub

sub UpdateSize()
    shape = m.top.shape
    if shape.trim().len() = 0 or m.availableShapes[shape] = invalid then return
    
    width       = invalid
    height      = invalid
    
    maxWidth    = m.top.maxWidth
    maxHeight   = m.top.maxHeight
    
    if maxWidth > 0 and maxHeight > 0
        width = GetPosterWidthByHeight(shape, maxHeight)
        height = maxHeight
        if width = 0 or width > maxWidth
            width = maxWidth
            height = GetPosterHeightByWidth(shape, maxWidth)
        end if
    else if maxWidth > 0 and maxHeight = 0
        width = maxWidth
        height = GetPosterHeightByWidth(shape, maxWidth)
    else if maxHeight > 0 and maxWidth = 0
        height = maxHeight
        width = GetPosterWidthByHeight(shape, maxHeight)
    end if
    if width <> invalid and height <> invalid
        m.top.width     = width
        m.top.height    = height
    end if
end sub

function GetPosterWidthByHeight(shape as String,height as Integer) as Integer
    width = 0
    if shape = "portrait"
        width = int(height / 1.6)
    else if shape = "4x3"
        width = int(height * 4 / 3)
    else if shape = "16x9"
        width = int(height * 16 / 9)
    else if shape = "square"
        width = height
    end if
    return width
end function

function GetPosterHeightByWidth(shape as String,width as Integer) as Integer
    height = 0
    if shape = "portrait"
        height = int(width * 1.6)
    else if shape = "4x3"
        height = int(width / 4 * 3)
    else if shape = "16x9"
        height = int(width / 16 * 9)
    else if shape = "square"
        height = width
    end if
    return height
end function
