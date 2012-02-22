#!/usr/bin/python
#
# cmrd - The cmyth Roku daemon
#

import sys
import getopt
import SocketServer
import SimpleHTTPServer
import base64
import re
import cmyth

conn = None
server = None
port = None

class httpd(SimpleHTTPServer.SimpleHTTPRequestHandler):
    def do_GET(self):
        print 'GET %s' % self.path
        self.protocol_version = 'HTTP/1.1'
        list = self.path.split('/')
        if self.path == '/list.xml':
            self.get_list()
        elif list[1] == 'title':
            self.get_title(list[2])
        elif list[1] == 'episode':
            self.get_episode(list[2], list[3])
        else:
            self.not_found()

    def not_found(self):
        self.send_response(404)
        self.end_headers()

    def respond(self, pathname, start=-1, end=-1):
        print 'pathname: %s' % pathname
        list = conn.get_proglist()
        for i in range(list.get_count()):
            prog = list.get_prog(i)
            if prog.pathname() == pathname:
                print 'found program'
                break
            prog.release()
            prog = None
        if prog:
            length = prog.length()
            if start >= 0 and end >= 0:
                print 'respond with 206'
                self.send_response(206)
                self.send_header('Content-Range', 'bytes %d-%d' % (start, end))
                self.send_header('Content-Length', '%d' % (end - start))
            elif start >= 0:
                print 'respond with 206'
                self.send_response(206)
                self.send_header('Content-Range',
                                 'bytes %d-%d/%d' % (start, length,
                                                     length))
                self.send_header('Content-Length', str(length - start))
            else:
                print 'respond with 200'
                self.send_response(200)
                start = 0
                self.send_header('Content-Length', str(length))
            self.send_header('Date', self.date_time_string())
            self.send_header('Accept-Ranges', 'bytes')
            self.send_header('Content-Type', 'video/mp4')
            self.send_header('Connection', 'close')
            self.end_headers()

            file = prog.open()
            print 'seek to %d' % start
            file.seek(start)
            if end >= 0:
                offset = start
                while offset < end:
                    rc,buf = file.read()
                    if rc < 0:
                        break
                    if len(buf) == 0:
                        print 'End of file reached'
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
                        print 'End of file reached'
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
        encoded = file.split('.')[0]
        pathname = base64.urlsafe_b64decode(encoded)
        for h in self.headers:
            print "%s: %s" % (h, self.headers.get(h))
        range = self.headers.get('range')
        if range != None:
            range = range.split('=')[1]
            start,end = range.split('-')
            print 'Range: %s - %s' % (start,end)
            if end == '':
                self.respond(pathname, int(start))
            else: 
                self.respond(pathname, int(start), int(end))
        else:
            self.respond(pathname)

    def get_title(self, file):
        self.send_response(200)
        self.end_headers()
        self.wfile.write('<?xml version="1.0" encoding="UTF-8" '\
                         'standalone="yes"?>\n')
        self.wfile.write('<episodes>\n\n')

        t = file.split('.')[0]
        title = base64.urlsafe_b64decode(t)
        list = conn.get_proglist()
        for i in range(list.get_count()):
            prog = list.get_prog(i)
            if prog.title() == title:
                self.wfile.write(self.create_episode(prog))

        self.wfile.write('</episodes>')

    def get_list(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write('<?xml version="1.0" encoding="UTF-8" '\
                         'standalone="yes"?>\n')
        self.wfile.write('<recordings>\n\n')

        progs = []
        titles = []

        list = conn.get_proglist()
        for i in range(list.get_count()):
            prog = list.get_prog(i)
            if not prog.title() in titles:
                progs += [ prog ]
                titles += [ prog.title() ]
            else:
                prog.release()

        for i in progs:
            self.wfile.write(self.create_recording(i))
            i.release()

        list.release()

        self.wfile.write('</recordings>')

    def create_recording(self, prog):
        title = base64.urlsafe_b64encode(prog.title())
        
        f = '/title/%s.xml' % title
        str = '<recording '
        str += 'title="%s" ' % prog.title()
        str += 'file="%s" ' % f
        str += '>\n'
        str += '</recording>\n\n'
        return str

    def create_episode(self, prog):
        title = base64.urlsafe_b64encode(prog.title())
        path = base64.urlsafe_b64encode(prog.pathname())
        e = prog.pathname().split('.')
        
        f = '/episode/%s/%s.%s' % (title,path,e[1])
        str = '<episode '
        str += 'title="%s" ' % prog.title()
        str += 'subtitle="%s" ' % prog.subtitle()
        str += 'file="%s" ' % f
        str += '>\n'
        str += '</episode>\n\n'
        return str

def usage(code):
    print 'Usage: cmrd.py [options]'
    print '       --help              print this help'
    print '       --port number       port number to listen on'
    print '       --server name       MythTV server'
    sys.exit(code)

def main():
    global conn
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

    conn = cmyth.connection(server)

    s = SocketServer.ThreadingTCPServer(('', port), httpd)
    s.serve_forever()

if __name__ == '__main__':
    main()
