"=============================================================================
" File    : autoload/unite/sources/outline/pcet.vim
" Author  : thawk <thawk009@gmail.com>
" Updated : 2016-08-23
"
" Licensed under the MIT license:
" http://www.opensource.org/licenses/mit-license.php
"
"=============================================================================

function! unite#sources#outline#pcet#outline_info() abort
  return s:outline_info
endfunction

let s:Util = unite#sources#outline#import('Util')

"-----------------------------------------------------------------------------
" Tags

let s:tags = {
            \ 'protocol_suite':2,
            \ 'fields':3,
            \ 'typedefs':3,
            \ 'components':3,
            \ 'protocol':3,
            \ 'transport_message':4,
            \ 'header':5,
            \ 'trailer':5,
            \ 'message':4,
            \ 'component':6,
            \ 'converter_list':1,
            \ 'converter_suite':2,
            \ 'converter':3,
            \ 'indexer_list':4,
            \ 'indexer':5,
            \ 'convert_unit_list':4,
            \ 'convert_unit':5,
            \ }

let s:heading_pattern = '^\s*<\s*\(' . join(keys(s:tags), '\|') . '\)\>\(\|[^>]*[^/]\)>'
" let s:heading_pattern = '^\s*<\s*\(' . join(keys(s:tags), '\|') . '\)\>'

"-----------------------------------------------------------------------------
" Outline Info

let s:outline_info = {
      \ 'heading'  : s:heading_pattern,
      \}

function! s:outline_info.create_heading(which, heading_line, matched_line, context) abort
    let heading = {
                \ 'word' : a:heading_line,
                \ 'level': 0,
                \ 'type' : 'generic',
                \ }
    let matches = matchlist(a:heading_line, s:heading_pattern)
    let tag = matches[1]
    let attrs = matches[2]
    let m = matchlist(attrs, '\<\%(name\|ver\)\s*=\s*"\([^"]\+\)"')
    if len(m) > 0
        let heading.word = tag . ' ' . m[1]
    else
        echom attrs . " not match"
        let heading.word = tag
    endif

    let heading.level = s:tags[matches[1]]

    return heading
endfunction
