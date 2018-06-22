if !exists('g:googurl_api_key')
    let g:googurl_api_key = ''
endif

map <leader>gu :py3 googurl()<CR>

python3 << EOF
import vim
import re
import json
import urllib
from urllib.request import urlopen,Request
import ssl

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
        data = json.dumps({'longUrl':longurl}).encode('utf-8')
        if vim.eval('g:googurl_api_key'):
            api_url += '?key='+vim.eval('g:googurl_api_key')
        req = Request(api_url, data, {'Content-Type':'application/json'})
        scontext=ssl.SSLContext(ssl.PROTOCOL_TLS)
        res = urlopen(req,context=scontext)
        new_data = json.loads(res.read())
        if 'id' in new_data:
            short_url = new_data['id']
            vim.current.buffer[crow-1]= line[:ccol] + short_url + afterurl
    else:
        print ('no url')

EOF
