Function LoadConfig()

'###########     MODIFY FOR DIFFERENT PODCASTS AND SETTINGS      ############
'#####################     RSS Feed for Podcast     #########################

        m.feed = "http://thisdamnworld.libsyn.com/rss" 'If there is a problem with the RSS feed, please see RSS Parse

'################    Modify to Change List Font Color     ###################

        m.ListColor = "0x000000FF"

'############# Modify to Change Podcast Description Font Color###############

        m.SummaryColor = "0x000000FF"

'#############     Modify to Change Podcast Sorting Order     ###############

        m.reverseOrder = false 'If true, feed is loaded bottom-to-top (content at the end of your feed would be the first item in the playlist)

end Function
