Roku Advertising Framework.  
This is a universal video ad solution integrated directly into the core Roku SDK.  
This framework natively integrates baseline & advanced advertising capabilities.
Here are few examples for integrating RAF to channel with support of Nielsen Digital Ad Ratings
in a simple channel based on list and video screen.

I. Description
	1. Full RAF integration
	
		At first configure (initialize) RAF, turn on Nielsen and configure it with documented parameters genre, program id and content.
	Then configure ad url with some passed parameters via Macros and set Ad URL with setAdUrl() method. After that
	get ads with getAds() (in example used VAST format) and render them with showAds().

	2. Custom Ad Parsing
	
	   In this implementation ads are imported from non-standard feed (neither VMAP, VAST or SMartXML).
	RAF is configured in a standard way, with backfill ads disabled and extra debug output enabled.	Ads are parsed
	from local JSON file, then formatted as ad pods array and imported into RAF using importAds() method.
	   After that check for particular ads to play by passing fake video events created with createPlayPosMsg()
	to RAF getAds() method before event-loop (preroll ads) and inside it (midroll/postroll ads). If any ads were
	returned from getAds(), they are rendered using RAF showAds() method.