'********** Copyright 2017 Roku Inc.  All Rights Reserved. **********
function itemContentChanged() as void
  itemData = m.top.itemContent
  m.itemPoster.uri = itemData.posterUrl
  m.itemTitle.text = itemData.title
  m.itemPriceDisplay.text = itemData.priceDisplay
end function

function init() as void
  m.itemPoster = m.top.findNode("itemPoster")
  m.itemTitle = m.top.findNode("itemTitle")
  m.itemPriceDisplay = m.top.findNode("itemPriceDisplay")
end function

function onFocusPercent() as void
    if m.top.focusPercent = 1.0
      m.top.findNode("focusRect").visible = true
    else if m.top.focusPercent = 0.0
      m.top.findNode("focusRect").visible = false
  end if
end function

function onRowFocusPercent() as void
    if m.top.focusPercent = 1.0
        m.top.findNode("focusRect").visible = true
    else if m.top.focusPercent = 0.0
       m.top.findNode("focusRect").visible = false
   end if
end function
