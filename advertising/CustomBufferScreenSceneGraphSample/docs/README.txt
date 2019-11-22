Roku Advertising Framework.  
This is a universal video ad solution integrated directly into the core Roku SDK.  
This framework natively integrates baseline & advanced advertising capabilities.
Here are few examples for integrating RAF to channel with support of Nielsen Digital Ad Ratings
in a simple channel based on list and video screen.

I. Description
	1. Full RAF integration
		At first we configure(initialize) RAF, turn on Nielsen and configure it with documented parameters genre, program id and content.
	Then we can configure ad url with some passed parameters via Macros and set Ad URL with setAdUrl() method. After that
	we can get ads with getAds() (in example used VAST format) and render them with showAds().

	2. Server Stitched ads
	
		At first we configure(initialize) RAF, turn on Nielsen, and set Ad URL by function of RAF
	setAdUrl(). After that we call by getAds() function to adPods data structure. In further 
	processing is more easy to have in each ad fields : renderTime(it is absolute time where ad have to start) 
	and viewed(is equal "true" when ad has been processed).
		After initialization we start video event loop. At first stage of it we gets current events 
	by setting values to ctx variable, at second stage depending on this ctx we parse all ad in all
	adPods, and make the appropriate fire tracking calls. As we can see from RAF we use only next key fucntion:
	setAdURl(), getAds() and fireTrackingEvents().

	3. RAF implementation for non-standard ad responses
	
	   In this implementation ads are imported from non-standard feed (neither VMAP, VAST or SMartXML).
	RAF is configured in a standard way, with backfill ads disabled and extra debug output enabled.	Ads are parsed
	from local JSON file, then formatted as ad pods array and imported into RAF using importAds() method.
	   After that we check for particular ads to play by passing fake video events created with createPlayPosMsg()
	to RAF getAds() method before event-loop (preroll ads) and inside it (midroll/postroll ads). If any ads were
	returned from getAds(), they are rendered using RAF showAds() method.