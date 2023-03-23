' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

' Returns top parent scene. Can be used for displaying dialogs over the scene etc. 
function GetParentScene() as Object
    m.parentScene = m.top.GetParent()
    while m.parentScene <> invalid
        grandParent = m.parentScene.GetParent()
        if grandParent = invalid then
            exit while
        end if
        m.parentScene = grandParent
    end while
    return m.parentScene
end function