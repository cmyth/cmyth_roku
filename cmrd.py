#!/usr/bin/python
#
# cmrd - The cmyth Roku daemon
#
#  Copyright (C) 2012-2013, Jon Gettler
#  http://www.mvpmc.org/
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#

import sys
import getopt
import SocketServer
import SimpleHTTPServer
import base64
import re
import time
import cmyth

from xml.dom.minidom import Document

conn = None
server = None
port = None
progs = None

def connect():
    global conn
    global server
    global progs

    if conn:
        print 'Reconnect to server %s' % server
    else:
        print 'Connect to server %s' % server

    while True:
        try:
            conn = cmyth.connection(server)
            print 'connection established'
            progs = conn.get_proglist()
            print 'got program list with %d recordings' % progs.get_count()
            return
        except:
            print 'connection failed!'
            time.sleep(1)

class httpd(SimpleHTTPServer.SimpleHTTPRequestHandler):
    def verify_connection(self):
        global progs
        global conn

        e = conn.get_event(0)
        while e:
            if e.name() == 'connection closed':
                connect()
            elif e.name() == 'recording list change' or \
                    e.name() == 'recording list change add' or \
                    e.name() == 'recording list change update' or \
                    e.name() == 'recording list change delete' or \
                    e.name() == 'done recording':
                progs = conn.get_proglist()
                print 'got program list'
            e = conn.get_event(0)

    def do_GET(self):
        global server

        self.protocol_version = 'HTTP/1.1'
        parts = self.path.split('/')
        if parts[1] == 'cmyth_roku':
            self.verify_connection()
            if parts[2] == server:
                parts = parts[0:2] + parts[3:]
            if parts[2] == 'list.xml':
                self.get_list()
            elif parts[2] == 'backends.xml':
                self.get_backends()
            elif parts[2] == 'title':
                self.get_title(parts[3])
            elif parts[2] == 'episode':
                self.get_episode(parts[3], parts[4])
            else:
                self.not_found()
        else:
            self.not_found()

    def not_found(self):
        self.send_response(404)
        self.end_headers()

    def respond(self, pathname, image, start=-1, end=-1):
        global progs
        global conn

        for i in range(progs.get_count()):
            prog = progs.get_prog(i)
            if prog.pathname() == pathname:
                break
            prog.release()
            prog = None
        if prog:
            if not image:
                length = prog.length()
            if not image and start >= 0 and end >= 0:
                self.send_response(206)
                self.send_header('Content-Range',
                                 'bytes %d-%d/%d' % (start, end, length))
                self.send_header('Content-Length', '%d' % (end - start))
            elif not image and start >= 0:
                self.send_response(206)
                self.send_header('Content-Range',
                                 'bytes %d-%d/%d' % (start, length,
                                                     length))
                self.send_header('Content-Length', str(length - start))
            else:
                self.send_response(200)
                start = 0
                if not image:
                    self.send_header('Content-Length', str(length))
            self.send_header('Date', self.date_time_string())
            if not image:
                self.send_header('Accept-Ranges', 'bytes')
                self.send_header('Content-Type', 'video/mp4')
            self.send_header('Connection', 'close')
            self.end_headers()

            if image:
                file = prog.open(cmyth.FILETYPE_THUMBNAIL)
            else:
                file = prog.open()
            file.seek(start)
            if end >= 0:
                offset = start
                while offset < end:
                    rc,buf = file.read()
                    if rc < 0:
                        break
                    if len(buf) == 0:
                        break
                    if (end-offset) > len(buf):
                        try:
                            self.wfile.write(buf)
                        except:
                            print 'file write error at %d' % offset
                            return
                    else:
                        self.wfile.write(buf[:(end-offset)])
                    offset += len(buf)
            else:
                offset = start
                while True:
                    rc,buf = file.read()
                    if rc < 0:
                        print 'Error: %d at offset %d' % (rc,offset)
                        break
                    if len(buf) == 0:
                        break
                    try:
                        self.wfile.write(buf)
                    except:
                        print 'file write error: %d' % offset
                        return
                    offset += len(buf)
        else:
            self.send_response(404)
            self.end_headers()

    def get_episode(self, title, file):
        parts = file.split('.')
        pathname = base64.urlsafe_b64decode(parts[0])
        image = (parts[1] == 'png')
        range = self.headers.get('range')
        if range != None:
            range = range.split('=')[1]
            start,end = range.split('-')
            if end == '':
                self.respond(pathname, image, int(start))
            else: 
                self.respond(pathname, image, int(start), int(end))
        else:
            self.respond(pathname, image)

    def get_title(self, file):
        global progs
        global conn

        self.send_response(200)
        self.end_headers()

        doc = Document()
        episodes = doc.createElement("episodes")
        doc.appendChild(episodes)

        t = file.split('.')[0]
        title = base64.urlsafe_b64decode(t)
        for i in range(progs.get_count()):
            prog = progs.get_prog(i)
            if prog.title() == title:
                episode = self.create_episode(prog, doc)
                episodes.appendChild(episode)

        self.wfile.write(doc.toprettyxml(indent="  "))

    def get_list(self):
        global progs
        global conn

        self.send_response(200)
        self.end_headers()

        doc = Document()
        recordings = doc.createElement("recordings")
        doc.appendChild(recordings)

        pl = []
        titles = []

        for i in range(progs.get_count()):
            prog = progs.get_prog(i)
            if not prog.title() in titles:
                pl += [ prog ]
                titles += [ prog.title() ]
            else:
                prog.release()

        for i in pl:
            recording = self.create_recording(i, doc)
            recordings.appendChild(recording)
            i.release()

        self.wfile.write(doc.toprettyxml(indent="  "))

    def get_backends(self):
        global server
        global progs

        self.send_response(200)
        self.end_headers()

        doc = Document()
        backends = doc.createElement("backends")
        doc.appendChild(backends)

        description = "%d recordings" % progs.get_count()

        backend = doc.createElement("backend")
        backend.setAttribute("address", server)
        backend.setAttribute("description", description)
        backends.appendChild(backend)

        self.wfile.write(doc.toprettyxml(indent="  "))

    def create_recording(self, prog, doc):
        global server

        title = base64.urlsafe_b64encode(prog.title())
        path = base64.urlsafe_b64encode(prog.pathname())
        
        f = '/cmyth_roku/%s/title/%s.xml' % (server,title)
        image = '/cmyth_roku/%s/episode/%s/%s.png' % (server,title,path)

        recording = doc.createElement("recording")

        recording.setAttribute("title", prog.title())
        recording.setAttribute("file", f)
        recording.setAttribute("image", image)

        return recording

    def create_episode(self, prog, doc):
        global server

        title = base64.urlsafe_b64encode(prog.title())
        path = base64.urlsafe_b64encode(prog.pathname())
        e = prog.pathname().split('.')
        
        recording = '/cmyth_roku/%s/episode/%s/%s.%s' % (server,title,path,e[1])
        image = '/cmyth_roku/%s/episode/%s/%s.png' % (server,title,path)

        episode = doc.createElement("episode")

        episode.setAttribute("title", prog.title())
        episode.setAttribute("subtitle", prog.subtitle())
        episode.setAttribute("description", prog.description())
        episode.setAttribute("file", recording)
        episode.setAttribute("image", image)
        episode.setAttribute("start", prog.start_str())
        episode.setAttribute("end", prog.end_str())
        episode.setAttribute("seconds", str(prog.seconds()))
        episode.setAttribute("bytes", str(prog.length()))
        episode.setAttribute("channel", prog.channel_name())

        return episode

def usage(code):
    print 'Usage: cmrd.py [options]'
    print '       --help              print this help'
    print '       --port number       port number to listen on'
    print '       --server name       MythTV server'
    sys.exit(code)

def main():
    global server
    global port

    server = None
    port = 6801
    
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'hp:s:',
                                   [ 'help', 'port=', 'server=' ])
    except getopt.GetoptError:
        usage(1)

    for o, a in opts:
        if o in ('-h', '--help'):
            usage(0)
        if o in ('-p', '--port'):
            port = int(a)
        if o in ('-s', '--server'):
            server = a

    if server == None:
        print 'No server provided!'
        usage(1)

    connect()

    s = SocketServer.ThreadingTCPServer(('', port), httpd)
    print 'http server created'

    s.serve_forever()

if __name__ == '__main__':
    main()
