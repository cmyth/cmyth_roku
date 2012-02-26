'*
'* about screen
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

function createAboutScreen(port as Object) as Object

    screen = CreateObject("roParagraphScreen")
    screen.SetMessagePort(port)

    screen.AddParagraph("libcmyth MythTV frontend for Roku")
    screen.AddParagraph("http://cmyth.github.com/")

    screen.AddButton(0, "Done")

    return screen

end function

function showAboutScreen()

    port = CreateObject("roMessagePort")
    screen = createAboutScreen(port)

    screen.Show()

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
		        done = true
		        exit while
		    end if
		end if
	    end if
        end while
    end while

end function
