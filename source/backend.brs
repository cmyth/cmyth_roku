'*
'* Backends screen
'*
'* Copyright (C) 2013, Jon Gettler
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
function createBackendScreen(xml as Object) as Object

    print "createBackendScreen()"

    if xml.backends = invalid then
        print "no backends"
    end if
    if xml.backend = invalid then
        print "no backend"
    end if

    backends = xml.GetChildElements()
    print "number of backends: " + Stri(backends.Count())

    root = init_homescreen_item("", "MythTV")

    for each b in backends
    	item = init_backend_item(b@address, b@description)
        root.AddKid(item)
    next

    print "xml parsed"

    return root

end function

'*
'*
'*
function showBackendScreen()

    print "showBackendScreen()"

    port = CreateObject("roMessagePort")
    screen = CreateObject("roPosterScreen")
    screen.SetMessagePort(port)
    screen.SetListStyle("flat-category")
    screen.setAdDisplayMode("scale-to-fit")

    xml=CreateObject("roXMLElement")
    backends = getBackends()
    if not xml.Parse(backends) then
        print "Can't parse feed"
        return invalid
    end if
    backends = xml.GetChildElements()

    m.backends = createBackendScreen(xml)

    screen.SetBreadcrumbText("Backends", "")
    screen.SetContentList(m.backends.Kids)
    screen.SetFocusedListItem(0)
    screen.Show()

    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roPosterScreenEvent" then
            if msg.isListItemSelected() then
                print "item selected | index = "; msg.GetIndex()
		item = backends[msg.GetIndex()]
                print "loading backend: " + item@address
		showMythTVScreen(item@address)
            else if msg.isScreenClosed() then
	    	print "closing backend screen"
                return -1
	    end if
	end if
    end while

end function

'*
'*
'*
function getBackends() as Object

    print "getBackends()"

    conn = CreateObject("roAssociativeArray")

    conn.UrlPrefix = getURLPrefix()
    conn.UrlCategoryFeed = conn.UrlPrefix + "/cmyth_roku/backends.xml"

    print "URL: " + conn.UrlCategoryFeed

    conn.Timer = CreateObject("roTimespan")
    http = NewHttp(conn.UrlCategoryFeed)
    rsp = http.GetToStringWithRetry()

    print "XML loaded"

    return rsp

end function

Function init_backend_item(title, description) As Object
    o = CreateObject("roAssociativeArray")
    o.Title       = title
    o.ShortDescriptionLine1       = title
    o.ShortDescriptionLine2       = description
    o.Type        = "normal"
    o.Description = description
    o.Kids        = CreateObject("roArray", 100, true)
    o.Parent      = invalid
    o.Feed        = ""
    o.IsLeaf      = cn_is_leaf
    o.AddKid      = cn_add_kid
    o.SDPosterURL = "pkg:/images/mythtv.png"
    o.HDPosterURL = "pkg:/images/mythtv.png"
    return o
End Function

