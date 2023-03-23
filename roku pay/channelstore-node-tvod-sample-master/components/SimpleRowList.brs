'********** Copyright 2017 Roku Inc.  All Rights Reserved. **********
function init()
  m.top.itemComponentName = "SimpleRowListItem"
  m.top.drawFocusFeedback = false
  m.top.numRows = 2
  m.top.itemSize = [196 * 3 + 20 * 2, 315]
  m.top.rowHeights = [315]
  m.top.rowItemSize = [ [196, 315], [196, 315], [196, 315] ]
  m.top.itemSpacing = [ 0, 80 ]
  m.top.rowItemSpacing = [ [20, 0] ]
  m.top.rowLabelOffset = [ [0, 30] ]
  m.top.showRowLabel = [true, true]
  m.top.rowLabelColor="0xffffffff"
  GetRowListContent()
        m.top.content = m.data
  m.top.visible = true
  m.top.SetFocus(true)
  m.top.observeField("rowItemSelected", "onRowItemSelected")
end function

function GetRowListContent() as void
  'Populate the RowList content here
  m.data = CreateObject("roSGNode", "ContentNode")
  movies = m.data.CreateChild("ContentNode")
  movies.title = "Movies"
  for i = 1 to 3
      item = movies.CreateChild("SimpleRowListItemData")
item.product_id = "free-trial-test"
item.content_key = "123456"
      item.posterUrl = "https://devtools.web.roku.com/samples/images/Landscape_1.jpg"
      item.title = "Movie" + stri(i)
item.price = "12.99"
item.priceDisplay = "$" + item.price
  end for

  tv = m.data.CreateChild("ContentNode")
  tv.title = "TV Shows"
  for i = 1 to 3
      item = tv.CreateChild("SimpleRowListItemData")
item.product_id = "free-trial-test"
item.content_key = "123456"
      item.posterUrl = "https://devtools.web.roku.com/samples/images/Landscape_2.jpg"
      item.title = "TV Show" + stri(i)
item.price = "5.99"
item.priceDisplay = "$" + item.price
  end for
end function

function onRowItemSelected() as void
    row = m.top.rowItemFocused[0]
    col = m.top.rowItemFocused[1]
metadata = m.data.GetChild(row).GetChild(col)
m.top.selectedContent = {
  product_id : metadata.product_id,
  content_key : metadata.content_key,
  title : metadata.title,
        price : metadata.price
  priceDisplay: metadata.priceDisplay
}
end function
