function ShowEpisodePickerView(seasonContent = invalid as Object)
    ' Create an CategoryListView object and set the posterShape field
    episodePicker = CreateObject("roSGNode", "CategoryListView")
    episodePicker.posterShape = "16x9"
    content = CreateObject("roSGNode", "ContentNode")
    ' This gets the seasonContent we parsed out in GridHandler
    content.Addfields({
        HandlerConfigCategoryList: {
            name: "SeasonsHandler"
            seasons: seasonContent
        }
    })
    episodePicker.content = content
    episodePicker.ObserveField("selectedItem", "OnEpisodeSelected")
    ' This will show the CategoryListView to the View and call SeasonsHandler
    m.top.ComponentController.CallFunc("show", {
        view: episodePicker
    })
    return episodePicker
end function

sub OnEpisodeSelected(event as Object)
    ' GetRoSGNode returns the object that was being observed
    categoryList = event.GetRoSGNode()
    ' GetData returns the field that was being observed
    itemSelected = event.GetData()
    category = categoryList.content.GetChild(itemSelected[0])
    details = ShowDetailsView(category.GetChild(itemSelected[1]), 0, false)
end sub
