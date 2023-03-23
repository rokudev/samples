Function Main() as void
    this = {
        screen: CreateObject("roListScreen")
        port: CreateObject("roMessagePort")
        store: CreateObject("roChannelStore")
        store_items: []
	purchased_items: []
        MakePurchase: make_purchase
	GetUserPurchases: get_user_purchases
	GetChannelCatalog: get_channel_catalog
        GetContentList: get_content_list
	DumpResponse: dump_response
	DumpResponseDlg: dump_response_dlg
	OrderStatusDialog: order_status_dialog
    }
    this.screen.SetMessagePort(this.port)
    this.store.SetMessagePort(this.port)
    this.store.FakeServer(true)
    this.screen.SetTitle("In App Purchase Sample")
    this.screen.Show()
    this.GetUserPurchases()
    this.GetChannelCatalog()
    
    while (true)
        msg = wait(0, this.port)
        print type(msg)
        if (type(msg) = "roListScreenEvent")
            if (msg.isListItemSelected())
                index = msg.GetIndex()
                this.MakePurchase(index)
            endif
	else if (type(msg) = "roChannelStoreEvent")
	    this.DumpResponse(msg.GetResponse())
        end if
    end while
End Function

Function make_purchase(index as integer) as void
    result = m.store.GetUserData()
    if (result = invalid)
        return
    endif
    order = [{
        code: m.store_items[index].code
        qty: 1        
    }]
    print  "***** Placing Order, item code: " + toStr(order[0].code) + " quantity: " + toStr(order[0].qty)
    val = m.store.SetOrder(order)
    res = m.store.DoOrder()
    if (res = true)
        m.OrderStatusDialog(true, m.store_items[index].Title)
    else
        m.OrderStatusDialog(false, m.store_items[index].Title)
    endif
End Function

Function get_content_list(items) as void
    i = 0
    arr = []
    for each item in items
        print "********************* Item " + Stri(i) + " *********************" 
        print item
        i = i+1
	owned = false
	for each purchased_item in m.purchased_items
	    if (item.code = purchased_item.code)
	        owned = true
		exit for
	    end if
	end for
	list_item = {
                Title: item.name
                ID: stri(i)
                code: item.code
                cost: item.cost
	}
	if (owned = true)
	    list_item.HDSmallIconUrl = "pkg:/images/checkmark.png"
	    list_item.SDSmallIconUrl = "pkg:/images/checkmark.png"
	end if
	m.store_items.Push(list_item)
    end for
End Function

Function get_user_purchases() as void
    print "***** Purchased Items *****"
    m.store.GetPurchases()
    while (true)
        msg = wait(0, m.port)
        if (type(msg) = "roChannelStoreEvent")
            if (msg.isRequestSucceeded())
	        for each item in msg.GetResponse()
		    m.purchased_items.Push({
			Title: item.name
			code: item.code
			cost: item.cost
		     }) 
	        end for
		exit while
	    else if (msg.isRequestFailed())
		print "***** Failure: " + msg.GetStatusMessage() + " Status Code: " + stri(msg.GetStatus()) + " *****"
            end if
        end if
    end while
End Function

Function get_channel_catalog() as void
    m.store.GetCatalog()
    while true
	msg = wait(0, m.port)
        if (type(msg) = "roChannelStoreEvent")
            if (msg.isRequestSucceeded())
	        m.DumpResponse(msg.GetResponse())
                m.GetContentList(msg.GetResponse())
                m.screen.SetContent(m.store_items)
                m.screen.Show()
            endif
	    exit while	
        else if (msg.isRequestFailed())
	    print "***** Failure: " + msg.GetStatusMessage() + " Status Code: " + stri(msg.GetStatus()) + " *****"
        end if
    end while
	
End Function

