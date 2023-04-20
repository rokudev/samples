function ShowCustomView(hdPosterUrl)
    m.CustomView = CreateObject("roSGNode", "custom")
    m.CustomView.picPath = hdPosterUrl
    m.top.ComponentController.CallFunc("show", {
        View: m.CustomView
    })
end function
