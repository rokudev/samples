' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 

function init()
    'attaching variables for nodes
    m.background = m.top.findNode("background")
    m.hudGroup = m.top.findNode("hudgroup")
    m.SlideAnimation = m.top.findNode("slideanimation")
    m.SlideAnimationInterpolator = m.top.findNode("slideanimationinterpolator")
    'Labels
    m.title = m.top.findNode("title")
    m.durationGroup = m.top.findNode("durationgroup")
    
    'extra info
    m.description = m.top.findNode("description")
    
    m.infoGroup = m.top.findNode("infogroup")
    
end function

sub OnOffsetChange()
    m.infoGroup.translation = [m.top.offset[0], 38]
end sub

sub OnContentChanged()
    item = m.top.content
    if item <> invalid AND item.metadata <> invalid   
        SetValue(m.title, item.metadata, "title")   
        SetValue(m.description, item.metadata, "description") 
    else
        ?"hud failed to set item"
    end if
end sub

function SetValue(node, item, field as String, defaultValue = "" as String)
    value = defaultValue
    if item.get(field) <> invalid then
        value = item.get(field) 
    end if
'    ?"value="value
    node.text = value
end function

Function onHeightChanged()
    m.hudGroup.translation = [0, m.background.height - m.top.height + 1] 'adjust
End Function

'Animation
Function OnVisibilityChanged()
    if m.top.show then
        m.SlideAnimationInterpolator.keyValue = [m.hudGroup.opacity, 1]
    else
        m.SlideAnimationInterpolator.keyValue = [m.hudGroup.opacity, 0]
    end if        
    m.SlideAnimation.control = "start"
End Function