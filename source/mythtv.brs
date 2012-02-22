'*
'* cmyth roku channel
'*
'* Copyright (C) 2012, Jon Gettler
'* http://www.mvpmc.org/
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
    	rec = init_homescreen_item(rec@title, rec@title, "pkg:/images/mythtv.png")
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

    server = getServerName()
    portnum = getPortNum()

    conn.UrlPrefix = "http://" + server + ":" + portnum
    conn.UrlCategoryFeed = conn.UrlPrefix + "/list.xml"

    print "URL: " + conn.UrlCategoryFeed

    conn.Timer = CreateObject("roTimespan")
    http = NewHttp(conn.UrlCategoryFeed)
    rsp = http.GetToStringWithRetry()

    print "XML loaded"

    return rsp

end function
