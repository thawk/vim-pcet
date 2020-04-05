if exists(":Tagbar")
    let g:tagbar_type_pcet = {
                \ 'ctagstype' : 'pcet',
                \ 'kinds' : [
                \     's:Table of Contents:1:1',
                \ ],
                \ 'sort' : 0,
                \ 'deffile' : expand('<sfile>:p:h:h') . '/ctags/pcet.cnf',
                \ }
endif

