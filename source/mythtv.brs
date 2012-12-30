'*
'* Titles Screen
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
function createMythtvScreen(xml as Object) as Object

    print "createMythtvScreen()"

    if xml.recordings = invalid then
        print "no recordings"
    end if
    if xml.recording = invalid then
        print "no recording"
    end if

    recordings = xml.GetChildElements()
    print "number of titles: " + Stri(recordings.Count())

    root = init_homescreen_item("", "MythTV")

    for each rec in recordings
        url = getURLPrefix() + rec@image
    	rec = init_recording_item(rec@title, url)
        root.AddKid(rec)
    next

    print "xml parsed"

    return root

end function

'*
'*
'*
function showMythtvScreen()

    print "showMythtvScreen()"

    port = CreateObject("roMessagePort")
    screen = CreateObject("roPosterScreen")
    screen.SetMessagePort(port)
    screen.SetListStyle("flat-category")
    screen.setAdDisplayMode("scale-to-fit")

    xml=CreateObject("roXMLElement")
    rec = getRecordings()
    if not xml.Parse(rec) then
        print "Can't parse feed"
        return invalid
    end if
    recordings = xml.GetChildElements()

    m.titles = createMythtvScreen(xml)

    screen.SetContentList(m.titles.Kids)
    screen.SetFocusedListItem(0)
    screen.Show()

    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roPosterScreenEvent" then
            if msg.isListItemSelected() then
                print "item selected | index = "; msg.GetIndex()
		item = recordings[msg.GetIndex()]
                print item@title
		showEpisodeScreen(item@title, item@file)
            else if msg.isScreenClosed() then
                return -1
	    end if
	end if
    end while

end function

'*
'*
'*
function getRecordings() as Object

    print "getRecordings()"

    conn = CreateObject("roAssociativeArray")

    conn.UrlPrefix = getURLPrefix()
    conn.UrlCategoryFeed = conn.UrlPrefix + "/cmyth_roku/list.xml"

    print "URL: " + conn.UrlCategoryFeed

    conn.Timer = CreateObject("roTimespan")
    http = NewHttp(conn.UrlCategoryFeed)
    rsp = http.GetToStringWithRetry()

    print "XML loaded"

    return rsp

end function

Function init_recording_item(title, image) As Object
    o = CreateObject("roAssociativeArray")
    o.Title       = title
    o.ShortDescriptionLine1       = title
    'o.ShortDescriptionLine2       = start
    o.Type        = "normal"
    'o.Description = description
    o.Kids        = CreateObject("roArray", 100, true)
    o.Parent      = invalid
    o.Feed        = ""
    o.IsLeaf      = cn_is_leaf
    o.AddKid      = cn_add_kid
    o.SDPosterURL = image
    o.HDPosterURL = image
    return o
End Function

