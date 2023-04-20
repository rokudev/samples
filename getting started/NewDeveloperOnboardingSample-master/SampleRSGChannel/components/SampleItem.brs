' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'
' Initialize the item in the home screen rowlist that will hold the sample.
' Each item in the rowlist will contain a poster of what the example will
' look like and a label of the name of the example.
sub init()
    ? "[SampleItem] init"
    m.itemposter = m.top.findNode("itemPoster") 
    m.itemlabel = m.top.findNode("itemLabel")
end sub

' Display the sample's poster and label. If the example does not have an
' image, a default image will be displayed for that sample item.
sub showContent()
    ? "[SampleItem] showContent"
    itemcontent = m.top.itemContent
    
    if itemcontent.HDPosterUrl = invalid or itemcontent.HDPosterUrl = ""
        m.itemposter.uri = "pkg:/images/overhangRokuLogo.png"
    else
        m.itemposter.uri = itemcontent.HDPosterUrl
    end if

    m.itemlabel.text = itemcontent.title
end sub