'*
'* Video Playback
'*
'* Copyright (C) 2012, Jon Gettler
'* http://www.mvpmc.org/
'*
'* This program is free software; you can redistribute it and/or modify
'* it under the terms of the GNU General Public License as published by
'* the Free Software Foundation; either version 2 of the License, or
'* (at your option) any later version.
'*
'* This program is distributed in the hope that it will be useful,
'* but WITHOUT ANY WARRANTY; without even the implied warranty of
'* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'* GNU General Public License for more details.
'*
'* You should have received a copy of the GNU General Public License
'* along with this program; if not, write to the Free Software
'* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
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

    url = getURLPrefix() + item@file

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
