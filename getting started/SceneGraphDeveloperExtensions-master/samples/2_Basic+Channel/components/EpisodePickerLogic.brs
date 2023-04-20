function ShowEpisodePickerView(seasonContent)
    episodePicker = CreateObject("roSGNode", "CategoryListView")
    episodePicker.posterShape = "16x9"
    content = CreateObject("roSGNode", "ContentNode")
    content.addfields({
        HandlerConfigCategoryList: {
            name: "SeasonsHandler"
            seasons: seasonContent
        }
    })
    episodePicker.content = content
    episodePicker.ObserveField("selectedItem", "OnEpisodeSelected")
    'this will trigger job to show this View
    m.top.ComponentController.callFunc("show", {
        view: episodePicker
    })
    return episodePicker
end function

sub OnEpisodeSelected(event as Object)
    'show details view with selected episode content
    categoryList = event.GetRoSGNode()
    itemSelected = event.GetData()
    category = categoryList.content.GetChild(itemSelected[0])
    ShowDetailsView(category.GetChild(itemSelected[1]), 0, false)
end sub
