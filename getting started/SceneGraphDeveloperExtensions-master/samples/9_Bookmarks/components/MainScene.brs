' ********** Copyright 2017 Roku Corp.  All Rights Reserved. **********

sub Show(args as Object)
    ' details will be load by DetailsHandler content handler
    detailsContent = Utils_AAToContentNode({
        HandlerConfigDetails: {
            name: "DetailsHandler"
    }})

    ShowDetailsView(detailsContent, 0)
end sub
