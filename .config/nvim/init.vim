lua require "init"

let s:localrcup = expand('../../../.nvimrc.local')
if filereadable(s:localrcup)
  " echo 'source ' . s:localrcup
   exec 'source ' . s:localrcup
endif

let s:localrcup = expand('../../.nvimrc.local')
if filereadable(s:localrcup)
  " echo 'source ' . s:localrcup
  exec 'source ' . s:localrcup
endif

let s:localrcup = expand('../.nvimrc.local')
if filereadable(s:localrcup)
  " echo 'source ' . s:localrcup
  exec 'source ' . s:localrcup
endif

let s:localrc = expand('./.nvimrc.local')
if filereadable(s:localrc)
  " echo 'source ' . s:localrc
  exec 'source ' . s:localrc
endif
