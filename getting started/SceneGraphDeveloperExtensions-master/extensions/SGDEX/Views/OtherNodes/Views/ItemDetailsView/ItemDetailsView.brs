' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub Init()
    m.titleLabel = m.top.findNode("title")
    m.descriptionLabel = m.top.findNode("description")
end sub

sub onMaxWidthChange()
    m.titleLabel.width = m.top.maxWidth
    m.descriptionLabel.width = m.top.maxWidth
end sub

sub onContentSet()
    content = m.top.content
    if content <> invalid
        titleLabelText = content.title
        if content.releaseDate <> invalid and val(content.releaseDate) > 0
            titleLabelText += " | " + content.releaseDate
        end if 
        if content.StarRating <> invalid and content.StarRating > 0
            titleLabelText += " | " + generateStarsRating(content.StarRating)
        end if 
        m.titleLabel.text = titleLabelText
        m.descriptionLabel.text = content.description
    end if
end sub

function generateStarsRating(starRating as Integer, maxRating = 100 as Integer, maxCount = 5 as Integer) as String
    stars = {
        empty : chr(9734)
        full  : chr(9733)
    }
    result = ""
    pointsPerStar = maxRating / maxCount
    fullCount = starRating / pointsPerStar
    if fullCount - int(fullCount) > 0.5 then 
        fullCount = int(fullCount) + 1
    else
        fullCount = int(fullCount)
    end if
    emptyCount = maxCount - fullCount
    
    while fullCount > 0
        result+=stars.full
        fullCount--
    end while
    while emptyCount > 0
        result+=stars.empty
        emptyCount--
    end while
    
    return result
end function
