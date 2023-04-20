' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub init()
    m.debug = false
    m.currentFocusedNode = invalid
    m.top.observeField("focusedChild", "onFocusedChild")
    m.top.observeField("layoutDirection", "layoutChanged")
    layoutChanged()
end sub

Sub onFocusedChild()
    if m.top.hasFocus()
        foc = m.top.focusedChild
        if m.debug AND foc <> invalid then ?"focused now="foc.id
        
        if m.currentFocusedNode = invalid ANd m.top.getchildCount() > 0 AND (m.top.focusedChild = invalid OR m.top.issameNode(m.top.focusedChild))
            firstFocusableChild = GetFirstFocusable(0, 1)
            if m.debug then ?"set focus to first focusable"
            if firstFocusableChild <> invalid
                if m.debug then ?"firstFocusableChild.setFocus(true)"
                firstFocusableChild.setFocus(true)
            end if
        else if m.currentFocusedNode <> invalid and m.top.isInFocusChain() and not m.currentFocusedNode.hasFocus()
            m.currentFocusedNode.setFocus(true)
            if m.debug then ?"m.currentFocusedNode.setFocus(true)"
        end if
    end if
    
    if m.currentFocusedNode = invalid OR (m.top.focusedChild <> invalid AND NOT m.currentFocusedNode.isSameNode(m.top.focusedChild))
        if m.debug then ?"set current focused node"m.top.focusedChild.id
        m.currentFocusedNode = m.top.focusedChild
    end if
end Sub

Sub layoutChanged()
    if m.top.layoutDirection = "vert"
        m.buttonsTohandle = {up : -1, down : 1}
    else
        m.buttonsTohandle = {right : 1,left : -1}
    end if
end sub

function onKeyEvent(key as String, press as Boolean)
    handled = false

    if press AND m.currentFocusedNode <> invalid AND m.buttonsTohandle[key] <> invalid 
        if m.top.getchildCount() > 0 then
            childCount = m.top.getchildCount()
            for index = 0 to childCount - 1
                child = m.top.getChild(index) 
                if child <> invalid AND m.currentFocusedNode.isSameNode(child)
                    indexToMove = index + m.buttonsTohandle[key]
                    if m.debug then 
                        ?"!index="index
                        ?"!indexToMove="indexToMove
                    end if
                    if (indexToMove >= 0 AND indexToMove < childCount) or m.top.allowCarousel
                        if indexToMove < 0 then 
                            index = childCount - 1
                        else if indexToMove >= childCount
                            index = 0
                        end if

                        newchild = GetFirstFocusable(index, m.buttonsTohandle[key]) 
                        
                        if m.debug then 
                            if newchild <> invalid
                                ?"newFocus:"newchild.subType() " id="newchild.id
                            else
                                ?"focused child not found"
                            end if
                        end if

                        if newchild <> invalid AND (m.currentFocusedNode = invalid OR not m.currentFocusedNode.isSameNode(newchild))
                            if m.currentFocusedNode <> invalid 
                                m.currentFocusedNode.setFocus(false)
                            end if
                            m.currentFocusedNode = newchild
                            newchild.setFocus(true)
                            handled = true
                        end if
                    end if
                    exit for
                end if 
            end for
        end if
    else if press
        if m.debug then ?"error found"
    end if
    
    
    return handled
end function

function GetFirstFocusable(startIndex, stepIndex)
    if m.debug 
        ?"startIndex:"startIndex
        ?"stepIndex:"stepIndex
    end if
    
    index = startIndex

    while(index >= 0 AND index < m.top.getChildCount())
        index = index + stepIndex

        child = m.top.getChild(index)
        if child <> invalid AND child.focusable
            return child
        end if
    end while

    child = m.top.getChild(startIndex)
    if child <> invalid then return child

    return invalid
end function
