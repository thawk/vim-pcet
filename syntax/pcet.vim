if exists("b:current_syntax")
    finish
endif

let s:pcet_cpo_save = &cpo
set cpo&vim

syn case match

" mark illegal characters
syn match pcetError "[<&]"

" strings (inside tags) aka VALUES
"
" EXAMPLE:
"
" <tag foo.attribute = "value">
"                      ^^^^^^^
syn region  pcetString contained start=+"+ end=+"+ contains=pcetEntity,@Spell display
syn region  pcetString contained start=+'+ end=+'+ contains=pcetEntity,@Spell display


" punctuation (within attributes) e.g. <tag xml:foo.attribute ...>
"                                              ^   ^
" syn match   pcetAttribPunct +[-:._]+ contained display
syn match   pcetAttribPunct +[:.]+ contained display

" no highlighting for pcetEqual (pcetEqual has no highlighting group)
syn match   pcetEqual +=+ display


" attribute, everything before the '='
"
" PROVIDES: @pcetAttribHook
"
" EXAMPLE:
"
" <tag foo.attribute = "value">
"      ^^^^^^^^^^^^^
"
syn match   pcetAttrib
    \ +[-'"<]\@1<!\<[a-zA-Z:_][-.0-9a-zA-Z:_]*\>\%(['">]\@!\|$\)+
    \ contained
    \ contains=pcetAttribPunct,@pcetAttribHook
    \ display


" namespace spec
"
" PROVIDES: @pcetNamespaceHook
"
" EXAMPLE:
"
" <xsl:for-each select = "lola">
"  ^^^
"
if exists("g:xml_namespace_transparent")
syn match   pcetNamespace
    \ +\(<\|</\)\@2<=[^ /!?<>"':]\+[:]\@=+
    \ contained
    \ contains=@pcetNamespaceHook
    \ transparent
    \ display
else
syn match   pcetNamespace
    \ +\(<\|</\)\@2<=[^ /!?<>"':]\+[:]\@=+
    \ contained
    \ contains=@pcetNamespaceHook
    \ display
endif


" tag name
"
" PROVIDES: @pcetTagHook
"
" EXAMPLE:
"
" <tag foo.attribute = "value">
"  ^^^
"
syn match   pcetTagName
    \ +<\@1<=[^ /!?<>"']\++
    \ contained
    \ contains=pcetNamespace,pcetAttribPunct,@pcetTagHook
    \ display


if exists('g:xml_syntax_folding')

    " start tag
    " use matchgroup=pcetTag to skip over the leading '<'
    "
    " PROVIDES: @pcetStartTagHook
    "
    " EXAMPLE:
    "
    " <tag id="whoops">
    " s^^^^^^^^^^^^^^^e
    "
    syn region   pcetTag
	\ matchgroup=pcetTag start=+<[^ /!?<>"']\@=+
	\ matchgroup=pcetTag end=+>+
	\ contained
	\ contains=pcetError,pcetTagName,pcetAttrib,pcetEqual,pcetString,@pcetStartTagHook


    " highlight the end tag
    "
    " PROVIDES: @pcetTagHook
    " (should we provide a separate @pcetEndTagHook ?)
    "
    " EXAMPLE:
    "
    " </tag>
    " ^^^^^^
    "
    syn match   pcetEndTag
	\ +</[^ /!?<>"']\+>+
	\ contained
	\ contains=pcetNamespace,pcetAttribPunct,@pcetTagHook


    " tag elements with syntax-folding.
    " NOTE: NO HIGHLIGHTING -- highlighting is done by contained elements
    "
    " PROVIDES: @pcetRegionHook
    "
    " EXAMPLE:
    "
    " <tag id="whoops">
    "   <!-- comment -->
    "   <another.tag></another.tag>
    "   <empty.tag/>
    "   some data
    " </tag>
    "
    syn region   pcetRegion
	\ start=+<\z([^ /!?<>"']\+\)+
	\ skip=+<!--\_.\{-}-->+
	\ end=+</\z1\_\s\{-}>+
	\ matchgroup=pcetEndTag end=+/>+
	\ fold
	\ contains=pcetTag,pcetEndTag,pcetCdata,pcetRegion,pcetComment,pcetEntity,pcetProcessing,@pcetRegionHook,@Spell
	\ keepend
	\ extend

else

    " no syntax folding:
    " - contained attribute removed
    " - pcetRegion not defined
    "
    syn region   pcetTag
	\ matchgroup=pcetTag start=+<[^ /!?<>"']\@=+
	\ matchgroup=pcetTag end=+>+
	\ contains=pcetError,pcetTagName,pcetAttrib,pcetEqual,pcetString,@pcetStartTagHook

    syn match   pcetEndTag
	\ +</[^ /!?<>"']\+>+
	\ contains=pcetNamespace,pcetAttribPunct,@pcetTagHook

endif


" &entities; compare with dtd
syn match   pcetEntity                 "&[^; \t]*;" contains=pcetEntityPunct
syn match   pcetEntityPunct  contained "[&.;]"

if exists('g:xml_syntax_folding')

    " The real comments (this implements the comments as defined by xml,
    " but not all xml pages actually conform to it. Errors are flagged.
    syn region  pcetComment
	\ start=+<!+
	\ end=+>+
	\ contains=pcetCommentStart,pcetCommentError
	\ extend
	\ fold

else

    " no syntax folding:
    " - fold attribute removed
    "
    syn region  pcetComment
	\ start=+<!+
	\ end=+>+
	\ contains=pcetCommentStart,pcetCommentError
	\ extend

endif

syn match pcetCommentStart   contained "<!" nextgroup=pcetCommentPart
syn keyword pcetTodo         contained TODO FIXME XXX
syn match   pcetCommentError contained "[^><!]"
syn region  pcetCommentPart
    \ start=+--+
    \ end=+--+
    \ contained
    \ contains=pcetTodo,@pcetCommentHook,@Spell


" CData sections
"
" PROVIDES: @pcetCdataHook
"
syn region    pcetCdata
    \ start=+<!\[CDATA\[+
    \ end=+]]>+
    \ contains=pcetCdataStart,pcetCdataEnd,@pcetCdataHook,@Spell
    \ keepend
    \ extend

" using the following line instead leads to corrupt folding at CDATA regions
" syn match    pcetCdata      +<!\[CDATA\[\_.\{-}]]>+  contains=pcetCdataStart,pcetCdataEnd,@pcetCdataHook
syn match    pcetCdataStart +<!\[CDATA\[+  contained contains=pcetCdataCdata
syn keyword  pcetCdataCdata CDATA          contained
syn match    pcetCdataEnd   +]]>+          contained


" Processing instructions
" This allows "?>" inside strings -- good idea?
syn region  pcetProcessing matchgroup=pcetProcessingDelim start="<?" end="?>" contains=pcetAttrib,pcetEqual,pcetString


if exists('g:xml_syntax_folding')

    " DTD -- we use dtd.vim here
    syn region  pcetDocType matchgroup=pcetDocTypeDecl
	\ start="<!DOCTYPE"he=s+2,rs=s+2 end=">"
	\ fold
	\ contains=pcetDocTypeKeyword,pcetInlineDTD,pcetString
else

    " no syntax folding:
    " - fold attribute removed
    "
    syn region  pcetDocType matchgroup=pcetDocTypeDecl
	\ start="<!DOCTYPE"he=s+2,rs=s+2 end=">"
	\ contains=pcetDocTypeKeyword,pcetInlineDTD,pcetString

endif

syn keyword pcetDocTypeKeyword contained DOCTYPE PUBLIC SYSTEM

" synchronizing
" TODO !!! to be improved !!!

syn sync match pcetSyncDT grouphere  pcetDocType +\_.\(<!DOCTYPE\)\@=+
" syn sync match pcetSyncDT groupthere  NONE       +]>+

if exists('g:xml_syntax_folding')
    syn sync match pcetSync grouphere   pcetRegion  +\_.\(<[^ /!?<>"']\+\)\@=+
    " syn sync match pcetSync grouphere  pcetRegion "<[^ /!?<>"']*>"
    syn sync match pcetSync groupthere  pcetRegion  +</[^ /!?<>"']\+>+
endif

syn sync minlines=100


" The default highlighting.
hi def link pcetTodo		Todo
hi def link pcetTag		Function
hi def link pcetTagName		Function
hi def link pcetEndTag		Identifier
if !exists("g:xml_namespace_transparent")
    hi def link pcetNamespace	Tag
endif
hi def link pcetEntity		Statement
hi def link pcetEntityPunct	Type

hi def link pcetAttribPunct	Comment
hi def link pcetAttrib		Type

hi def link pcetString		String
hi def link pcetComment		Comment
hi def link pcetCommentStart	pcetComment
hi def link pcetCommentPart	Comment
hi def link pcetCommentError	Error
hi def link pcetError		Error

hi def link pcetProcessingDelim	Comment
hi def link pcetProcessing	Type

hi def link pcetCdata		String
hi def link pcetCdataCdata	Statement
hi def link pcetCdataStart	Type
hi def link pcetCdataEnd		Type

hi def link pcetDocTypeDecl	Function
hi def link pcetDocTypeKeyword	Statement
hi def link pcetInlineDTD	Function

let b:current_syntax = "pcet"

let &cpo = s:pcet_cpo_save
unlet s:pcet_cpo_save
