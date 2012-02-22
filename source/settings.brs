'*
'* cmyth roku channel
'*
'* Copyright (C) 2012, Jon Gettler
'* http://www.mvpmc.org/
'*

function createSettingsScreen(port as Object) as Object

    screen = CreateObject("roParagraphScreen")
    screen.SetMessagePort(port)

    server = getServerName()
    portnum = getPortNum()
    if server = invalid then
       server = ""
    end if
    if portnum = invalid then
       portnum = ""
    end if

    screen.AddParagraph("Current Settings:")
    screen.AddParagraph("  Server: " + server)
    screen.AddParagraph("  Port: " + portnum)

    screen.AddButton(0, "Set Server Address")
    screen.AddButton(1, "Set Server Port")
    screen.AddButton(2, "Done")

    return screen

end function

function showSettingsScreen()

restart:
    port = CreateObject("roMessagePort")
    screen = createSettingsScreen(port)

    screen.Show()

    server = getServerName()
    portnum = getPortNum()

    done = false
    while done = false
        while true
            msg = wait(0, port)
            if type(msg) = "roParagraphScreenEvent" then
                if msg.isScreenClosed() then
		    done = true
		    exit while
		else if msg.isButtonPressed() then
		    if msg.getIndex() = 0 then
		        print "set server address"
			value = GetInfo("Enter the server hostname or IP address", server)
			setServerName(value)
			goto restart
		    else if msg.getIndex() = 1 then
		        print "set server port"
			value = GetInfo("Enter the server port number", portnum)
			setPortNum(value)
			goto restart
		    else if msg.getIndex() = 2 then
		        done = true
		        exit while
		    end if
		end if
	    end if
        end while
    end while

end function
