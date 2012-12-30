'*
'* Episode Screen
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
function createEpisodesScreen(xml as Object) as Object

    print "createEpisodesScreen()"

    if xml.episodes = invalid then
        print "no episodes"
    end if
    if xml.episode = invalid then
        print "no episode"
    end if

    episodes = xml.GetChildElements()
    print "number of episodes: " + Stri(episodes.Count())

    root = init_homescreen_item("", "MythTV")

    for each rec in episodes
        url = getURLPrefix() + rec@image
    	rec = init_episode_item(rec@title, rec@subtitle, rec@description, rec@start, rec@end, url)
        root.AddKid(rec)
    next

    print "xml parsed"

    return root

end function

'*
'*
'*
function showEpisodeScreen(title as String, file as String)

    port = CreateObject("roMessagePort")
    screen = CreateObject("roPosterScreen")
    screen.SetMessagePort(port)
    screen.SetListStyle("flat-episodic")

    xml=CreateObject("roXMLElement")
    ep = getEpisodes(file)
    if not xml.Parse(ep) then
        print "Can't parse feed"
        return invalid
    end if
    episodes = xml.GetChildElements()

    m.episodes = createEpisodesScreen(xml)

    screen.SetBreadcrumbText(title, "")
    screen.SetContentList(m.episodes.Kids)
    screen.SetFocusedListItem(0)
    screen.Show()

    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roPosterScreenEvent" then
            if msg.isListItemSelected() then
                print "item selected | index = "; msg.GetIndex()
		item = episodes[msg.GetIndex()]
                print item@file
		showVideoScreen(item)
		print "playback stopped"
            else if msg.isScreenClosed() then
		print "episode screen closed"
                return -1
	    end if
	end if
    end while

end function

'*
'*
'*
function getEpisodes(file as String) as Object

    print "getEpisodes()"

    conn = CreateObject("roAssociativeArray")

    url = getURLPrefix() + file

    print "URL: " + url

    conn.Timer = CreateObject("roTimespan")
    http = NewHttp(url)
    rsp = http.GetToStringWithRetry()

    print "XML loaded"

    return rsp

end function

Function init_episode_item(title, subtitle, description, start, ends, image) As Object
    o = CreateObject("roAssociativeArray")
    o.Title       = title
    o.ShortDescriptionLine1       = subtitle
    o.ShortDescriptionLine2       = start
    o.Type        = "normal"
    o.Description = description
    o.Kids        = CreateObject("roArray", 100, true)
    o.Parent      = invalid
    o.Feed        = ""
    o.IsLeaf      = cn_is_leaf
    o.AddKid      = cn_add_kid
    o.SDPosterURL = image
    o.HDPosterURL = image
    return o
End Function

