' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

Function init ()
    m.PodcastArt = m.top.findNode("PodcastArt") 'Album Artwork
    m.Background = m.top.findNode("Background") 'Background Artwork
    m.AlbumPlay = m.top.findNode("AlbumPlay") 'Bottom Playbar Artwork
    m.list = m.top.findNode("EpisodePicker") 'LabelList -- has wrapper class called "MyLabelList.xml
    m.Warning = m.top.findNode("Warning") 'Warning message to be displayed if invalid feed
    m.WarningTimer = m.top.findNode("WarningTimer") 'Timer node to display warning message
    if m.global.warning = 1
        m.Warning.visible = true
        m.WarningTimer.control = "start"
    else if m.global.warning = 2
        m.Warning.visible = true
        m.Warning.title = "Title"
        m.Warning.message = "Feed is incompatible or may be down at this time."
    end if

    m.Title = m.top.findNode("Title") 'Title Label
    m.Author = m.top.findNode("Author") 'Author/Artist Label

    m.Summary = m.top.findNode("Summary") ' Description/Summary Label under Album Artwork

    m.list.color = m.global.ListColor 'LabelList -- Changes colors of labels
    m.current = m.top.findNode("PodcastPlaying") ' Label for currently playing Podcast located at the bottom of the album artwork
    m.AlbumRect = m.top.findNode("AlbumRect") 'Background shading rectangle for Current Podcast playing label

    m.list.SetFocus(true) ' Set Focus on Label List

    m.PodcastArt.uri = m.global.uri 'All Posters use the same artwork at different sizes and resolutions
    m.Background.uri = m.global.uri
    m.AlbumPlay.uri = m.global.uri

    m.Summary.text = m.global.summary  'Description underneath Album artwork
    m.Summary.color = m.global.SummaryColor 'Text color of Description
    m.Title.text = m.global.PodcastTitle 'Podcast Label of title at top
    m.Author.text = m.global.author 'Podcast label of author at top

    m.TimerRect = m.top.findNode("TimeBarFront") 'Purple Time bar located in the playbar that moves as playback plays
    m.TimerAnim = m.top.findNode("TimerAnim") 'Animation to move Purple Time bar
    m.TimerInterp = m.top.findNode("TimerInterp") 'field interpolator for TimerAnim
    m.AudioCurrent = m.top.findNode("AudioCurrent") 'Current playback location time of Audio
    m.AudioDuration = m.top.findNode("AudioDuration") 'Length of selected Audio playback
    m.AudioTime = 0 'variable to keep playback time accurate. Fixes bug with mp3 files

    m.Play = m.top.findNode("Play") 'Play button
    m.FFAnim = m.top.findNode("FFAnim") 'FastForward Animation for trickplay
    m.RewindAnim = m.top.findNode("RewindAnim") 'Rewind Animation for trickplay

    m.Audio = createObject("roSGNode", "Audio")
    m.Audio.notificationInterval = 0.1
    m.AudioDuration.text = secondsToMinutes(0) 'toString Method to format playback string
    m.AudioCurrent.text = secondsToMinutes(0)

    m.PlayTime = m.top.findNode("PlayTime") 'One second timer to advance AudioCurrent every second
    m.PlayTime.ObserveField("fire", "TimeUpdate") 'Updates AudioCurrent string

    m.WarningTimer.observeField("fire", "closeWarning") 'Dismisses warning message
    m.list.observeField("itemFocused", "setaudio") 'Set's audio content to focused item in Labellist
    m.list.observeField("itemSelected", "playaudio") 'Plays audio content in Label List
    m.global.observeField("FF", "FF") 'Calls function for trickplay when FastForward button is pressed
    m.global.observeField("Rewind", "Rewind") 'Calls function for trickplay when Rewind button is pressed

    m.check = 0 'Initializes m.check before opening a podcast
end Function

sub closeWarning()
    m.Warning.visible = false
end sub

sub FF() 'FastForward function
    skip10Seconds(true)
end sub

sub Rewind() 'Rewind function
    skip10Seconds(false)
end sub

sub setaudio() 'Sets audio content
    audiocontent = m.list.content.getChild(m.list.itemFocused)
    m.Summary.text = audiocontent.Description
    m.Audio.content = audiocontent
end sub

sub controlaudioplay() 'Makes sure that audio stops when finished
    if (m.audio.state= "finished")
        m.audio.control = "stop"
        m.audio.control = "none"
    end if
end sub

sub TimeUpdate() ' Timer update for playback, current audio time, etc.
    m.AudioTime += 1
    m.AudioCurrent.text = secondsToMinutes(m.AudioTime)
    if m.AudioTime = m.check
        m.PlayTime.control = "stop"
    end if
end sub

sub playaudio() 'Plays audio and changes Currently playing parameter
    m.audiocontent = m.list.content.getChild(m.list.itemSelected)
    m.check = m.audiocontent.length 'Uses m.check as audiocontent.length to make access to audoicontent.length from other functions faster. m.check will store the length instead of having to re-access it
    print "this is"m.check
    m.audio.control = "stop"
    m.audio.control = "none"
    m.audio.control = "play"
    m.AlbumRect.opacity = "0.8"
    m.Play.text = "O" 'Resets currently playing time
    m.current.text = m.audiocontent.Title 'Changes title to new playback
    m.TimerAnim.duration = m.audiocontent.Length 'Sets animation duration for playbar
    m.TimerInterp.keyValue = "[0,1470]" 'Sets width for animations of playbar
    m.TimerAnim.control = "start"
    m.split = 1470.0/m.audiocontent.Length 'm.split will be used for trickplay. It will help reset the animation's for the trickplay bar rectangle based off of new remaining time of audio
    m.AudioDuration.text = secondsToMinutes(m.audiocontent.Length) 'toString to set audio playback length
    m.PlayTime.control = "start" ' starts audio
    m.AudioTime = 0'resets audiotime
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean 'Key functions for UI
    if press
        if key = "replay"
            if (m.Audio.state = "playing")
                playaudio()

                return true
            end if
        else if key = "play"
            if (m.Audio.state = "playing")
                m.Audio.control = "pause"
                m.TimerAnim.control = "pause"
                m.PlayTime.control = "stop"
                m.Play.text = "N"
            else
                m.Audio.control = "resume"
                m.TimerAnim.control = "resume"
                m.PlayTime.control = "start"
                m.Play.text = "O"
            end if
                return true
        else if key = "right"
                skip10Seconds(true)
                return true
        else if key = "left"
                skip10Seconds(false)
                return true
        end if
    end if
end Function

sub skip10Seconds(forward as Boolean) 'trickplay functions. 2 Functions for each FastForward and Rewind to account for edge cases. (Skipping or Rewinding 10 seconds past or before)
    if forward then
        if (m.check - 10) > m.AudioTime
            print m.check
            m.AudioTime += 10
            m.TimerInterp.KeyValue = [m.TimerRect.width + m.split*10, 1470] 'Calculates new trickplay animation values for rectangle
            m.TimerAnim.duration = m.check - (m.AudioTime + 10) 'Calculates remaining time of audio
            m.FFAnim.control = "start"
            m.Audio.seek = m.AudioTime
            m.TimerAnim.control = "start"
            print "1"
        else
            print m.AudioTime
            m.AudioTime = m.check
            m.AudioCurrent.text = secondsToMinutes(m.check)
            m.TimerAnim.control = "stop"
            m.TimerRect.width = 1470
            m.FFAnim.control = "start"
            m.PlayTime.control = "stop"
            m.Audio.seek = m.AudioTime
            print m.check
            print "2"

        end if
    else
        if m.AudioTime > 10
            m.AudioTime -= 10
            m.TimerInterp.KeyValue = [m.TimerRect.width - m.split*10, 1470]
            m.TimerAnim.duration = m.check - (m.AudioTime - 10)
            m.RewindAnim.control = "start"
            m.PlayTime.control = "start"
            m.Audio.seek = m.AudioTime
            m.TimerAnim.control = "start"
            print "3"
        else
            m.AudioTime = 0
            m.TimerInterp.KeyValue = [0, 1470]
            m.TimerAnim.duration = m.check
            m.TimerAnim.control = "start"
            m.RewindAnim.control = "start"
            m.PlayTime.control = "start"
            m.Audio.seek = m.AudioTime
            print "4"
        end if
    end if
end sub

Function secondsToMinutes(seconds as integer) as String 'toString method to convert any format of time to specific time format. ex: secondsToMinutes(66) prints "1:06"
    x = seconds\60
    y = seconds MOD 60
    if y < 10
        y = y.toStr()
        y = "0"+y
    else
        y = y.toStr()
    end if
    result = x.toStr()
    result = result +":"+ y
    return result
end Function
