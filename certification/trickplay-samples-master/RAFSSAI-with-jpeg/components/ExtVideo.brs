' ********** Copyright 2016-2019 Roku Corp.  All Rights Reserved. **********

Function onKeyEvent(key as String, press as Boolean) as Boolean  'Maps back button to leave video
    if press
		print "Ext - key= ", key
        if key = "back"  'If the back button is pressed
          if m.Video <> invalid and m.Video.visible = true
            m.Video.visible = false   'Hide video
            m.Video.control = "stop"  'Stop video from playing
            return true
          else
            return false
          end if
        end if
    end if

	return false
end Function
