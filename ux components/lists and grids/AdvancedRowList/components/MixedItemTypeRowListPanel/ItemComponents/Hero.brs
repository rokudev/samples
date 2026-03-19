sub init()
    m.border = m.top.findNode("border")
    m.poster = m.top.findNode("hero_poster")
    m.info_bg = m.top.findNode("info_bg")
    m.info = m.top.findNode("info")
end sub

sub itemContentChanged()
    m.info.drawingStyles = {
        "RokuTextPurpleBold":{
            "fontUri": "pkg:/fonts/RokuText-Bold.otf",
            "fontSize":26,
            "color": "#662d91"
        },
        "RokuTextWhite": {
           "fontUri": "pkg:/fonts/RokuText-Medium.otf"
           "fontSize":26
           "color": "#FFFAFA"
        }
    }
    m.info.text = "<RokuTextPurpleBold>U</RokuTextPurpleBold> • <RokuTextWhite>S10 E12</RokuTextWhite>"
end sub

sub onSizeChanged()
    w = m.top.width
    h = m.top.height
    m.border.width = w
    m.border.height = h
    m.poster.width = w - 8
    m.poster.height = h - 4
    ' Info bar overlaid at the bottom of the poster
    info_h = 46
    m.info_bg.width = w
    m.info_bg.height = info_h
    m.info_bg.translation = [0, h - info_h]
    m.info.width = w
    m.info.height = info_h
    m.info.translation = [4, h - info_h]
end sub
