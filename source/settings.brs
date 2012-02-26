'*
'* Application Settings
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

    screen.AddButton(0, "Done")
    screen.AddButton(1, "Set Server Address")
    screen.AddButton(2, "Set Server Port")

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
		    if msg.getIndex() = 1 then
		        print "set server address"
			value = GetInfo("Enter the server hostname or IP address", server)
			setServerName(value)
			goto restart
		    else if msg.getIndex() = 2 then
		        print "set server port"
			value = GetInfo("Enter the server port number", portnum)
			setPortNum(value)
			goto restart
		    else if msg.getIndex() = 0 then
		        done = true
		        exit while
		    end if
		end if
	    end if
        end while
    end while

end function
