' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub init()
    m.top.functionName = "ContentGetter__GetContentWrapper"
end sub

sub ContentGetter__GetContentWrapper()
    if m.top.content <> invalid then m.top.content.queueFields(true)
    GetContent()
    if m.top.content <> invalid then m.top.content.queueFields(false)
    m.top.finished = true
end sub

' developer needs to override this function in the component
' extended from ContentGetter.
' Returned value will be used as a content for a view.
function GetContent() as Object
    ? "SGDEX: you need to have GetContent() function in "m.top.Subtype()" component"
    return invalid
end function
