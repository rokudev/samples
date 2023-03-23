function init()
    m.top.itemComponentName = "SimpleRowListItem"
    m.top.vertFocusAnimationStyle = "floatingFocus"
    m.top.numRows = 2
    m.top.itemSize = [196 * 5 + 20 * 4, 315]
    m.top.rowHeights = [315]
    m.top.rowItemSize = [ [196, 148] ]
    m.top.itemSpacing = [ 0, 20 ]
    m.top.rowItemSpacing = [ [20, 0] ]
    m.top.rowLabelOffset = [ [0, 20] ]
    m.top.showRowLabel = [true, true]
    m.top.rowLabelColor="0xffffffff"
    GetRowListContent()
    m.top.content = m.data
    m.top.visible = true
    m.top.SetFocus(true)
    m.top.observeField("rowItemSelected", "onRowItemSelected")
end function

function GetRowListContent() as void
    m.data = CreateObject("roSGNode", "ContentNode")

    'Populate Movies row
    movies = m.data.CreateChild("ContentNode")
    movies.title = "Movies"
    for i = 1 to 5
        item = movies.CreateChild("SimpleRowListItemData")
        item.product_id = "tvod-rental"
        item.posterUrl = "https://devtools.web.roku.com/samples/images/Landscape_1.jpg"
        item.title = "Movie" + stri(i)
        item.price = "4.99"
        item.priceDisplay = "$" + item.price
    end for

    'Populate TV Shows row
    tvshows = m.data.CreateChild("ContentNode")
    tvshows.title = "TV Shows"
    for i = 1 to 5
        item = tvshows.CreateChild("SimpleRowListItemData")
        item.product_id = "tvod-rental"
        item.posterUrl = "https://devtools.web.roku.com/samples/images/Landscape_2.jpg"
        item.title = "TV Show" + stri(i)
        item.price = "1.99"
        item.priceDisplay = "$" + item.price
    end for
end function

function onRowItemSelected() as void
    row = m.top.rowItemFocused[0]
    col = m.top.rowItemFocused[1]
    metadata = m.data.GetChild(row).GetChild(col)
    m.top.selectedContent = {
        product_id : metadata.product_id,
        title : metadata.title,
        price : metadata.price
        priceDisplay: metadata.priceDisplay
    }
end function
