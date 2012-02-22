'*
'* cmyth roku channel
'*
'* Copyright (C) 2012, Jon Gettler
'* http://www.mvpmc.org/
'*

'*
'*
'*
function showVideoScreen(item as Object)

    print "showVideoScreen()"

    episode = create_video(item)

    port = CreateObject("roMessagePort")
    screen = CreateObject("roVideoScreen")
    screen.SetMessagePort(port)

    screen.SetPositionNotificationPeriod(30)
    screen.SetContent(episode)
    screen.Show()

    while true
        msg = wait(0, port)
	if type(msg) = "roVideoScreenEvent" then
            print "showVideoScreen | msg = "; msg.getMessage() " | index = "; msg.GetIndex()
            if msg.isScreenClosed()
                print "Screen closed"
                exit while
            else if msg.isRequestFailed()
                print "Video request failure: "; msg.GetIndex(); " " msg.GetData()
            else if msg.isStatusMessage()
                print "Video status: "; msg.GetIndex(); " " msg.GetData()
            else if msg.isButtonPressed()
                print "Button pressed: "; msg.GetIndex(); " " msg.GetData()
'            else if msg.isPlaybackPosition() then
'                nowpos = msg.GetIndex()
'                RegWrite(episode.ContentId, nowpos.toStr())
            else
                print "Unexpected event type: "; msg.GetType()
            end if

	end if
    end while

end function

'*
'*
'*
function create_video(item as Object) as Object

    o = CreateObject("roAssociativeArray")

    o.ContentId        = ""
    o.Title            = ""
    o.ContentType      = ""
    o.ContentQuality   = ""
    o.Synopsis         = ""
    o.Genre            = ""
    o.Runtime          = ""
    o.StreamQualities  = CreateObject("roArray", 5, true)
    o.StreamBitrates   = CreateObject("roArray", 5, true)
    o.StreamUrls       = CreateObject("roArray", 5, true)

    server = getServerName()
    portnum = getPortNum()

    prefix = "http://" + server + ":" + portnum
    url = prefix + item@file

    print url

    o.StreamBitrates.Push("1500")
    o.StreamQualities.Push("SD")
    o.StreamUrls.Push(url)
    o.StreamFormat = "mp4"

    e = {
        stream: {
            url: url
        }
    }

    return e

end function
