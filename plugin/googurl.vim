if !has('python')
    echo 'Error: +python required'
    finish
endif
if !exists('g:googurl_api_key')
    let g:googurl_api_key = ''
endif

map <leader>gu :python googurl()<CR>

python << EOF
import vim
import re
import json
import urllib
import urllib2

def googurl():
    """
    shortens string from cursor to next whitespace
    """
    line = vim.current.line
    crow,ccol = vim.current.window.cursor
    nextspace = line.find(' ',ccol)
    if nextspace == -1:
        longurl = line[ccol:]
        afterurl = ""
    else:
        longurl = line[ccol:nextspace]
        afterurl = line[nextspace:]
    row = vim.current.window.cursor[0]
    api_url = 'https://www.googleapis.com/urlshortener/v1/url'
    if longurl:
        data = json.dumps({'longUrl':longurl})
        if vim.eval('g:googurl_api_key'):
            api_url += '?key='+vim.eval('g:googurl_api_key')
        req = urllib2.Request(api_url, data, {'Content-Type':'application/json'})
        res = urllib2.urlopen(req)
        new_data = json.loads(res.read())
        if 'id' in new_data:
            short_url = new_data['id']
            vim.current.buffer[crow-1]= line[:ccol] + short_url + afterurl
    else:
        print 'no url'

EOF
