---
layout: post
title: Advanced Vim Tutor
tags: vim
---

```
This article introduce advanced tips using Vim
editor, common to many Unix and Unix-like operating systems.
~
~
~
~
"Advanced Vim Tutor" [New file].
```

<!--more-->

## Table of Contents

* TOC
{:toc}

## Mode

### Ex-mode

```shell
vim -E -s Makefile <<-EOF
    :%substitute/CFLAGS = -g$/CFLAGS = -fPIC -g/
    :%substitute/CFLAGS =$/CFLAGS = -fPIC/
    :update
    :quit
EOF
```

## Modify buffer

A very nice feature of vim is its integration with terminal programs to modify the current buffer.

syntax: type `:%! <command>` in command mode

* `:%! sort -k2` will sort the buffer based on column 2
* `:%! column -t` will format text in columns
* `:%! markdown` will convert current file to html
* `:w !sudo tee %` save file with sudo

## Find and Replace

### Replace

```viml
s//text_to_replace_with
# or
s/prev_searched_text/text_to_replace_with
```

## `vimrc`

```viml
" prevent vi from reading .vimrc
if ! version >= 500
    finish
endif
set nocompatible
" allow backspacing over everything in insert mode
set backspace=indent,eol,start
set backupdir=~/.vim/backup
if &t_Co == 256 && $COLORTERM == 'gnome-terminal'
    set t_Co=256
endif
```

## Scripting

### VimL

```viml
if exists("g:OxnzToolkitVersion") || &cp
    finish
endif
let g:OxnzToolkitVersion = '1.0.0'

if v:version < 700
    call <SID>OxnzToolkitErrMsgFunc('OxnzToolkit requires vim >= 7.0')
    finish
endif

" check for Ruby functionality
if !has('ruby')
   call <SID>OxnzToolkitWarnFunc('requires vim compiled with +ruby for some functionality')
endif

let s:OxnzToolkitVimScript = resolve(expand('<sfile>:p'))
let s:OxnzToolkitPluginPath =
            \ fnamemodify(s:OxnzToolkitVimScript, ':h')
let s:OxnzToolkitRubyScript =
            \ fnamemodify(s:OxnzToolkitVimScript, ':r') . '.rb'
let s:OxnzToolkitOptions = &cpo
set cpo&vim

function <SID>OxnzUpdateTimeStampFunc()
    let l:lineno = search("Last-update:", "n")
    if l:lineno
        let l:line = getline(l:lineno)
        let l:line = substitute(l:line,
                    \ "\\d\\{4\\}-\\d\\{2\\}-\\d\\d \\d\\d:\\d\\d:\\d\\d$",
                    \ strftime("%F %T"), "")
        call setline(l:lineno, l:line)
    endif
endfunction

function <SID>OxnzToolkitRubyFunc(cmd, ...)
    try
        execute 'rubyfile' s:OxnzToolkitRubyScript
    catch
        echohl WarningMsg | echo v:exception | echohl None
    endtry
endfunction

command -nargs=0 OxnzModeLine           :call <SID>OxnzAppendModeLineFunc()
command -nargs=0 OxnzInsertLineNumbers  :call <SID>OxnzInsertLineNumbersFunc()

if !hasmapto('<Plug>OxnzToolkit')
    map <unique> <Leader>nz <Plug>OxnzToolkit
endif

if has('autocmd')
    augroup OxnzToolkit
        autocmd!
        autocmd BufWrite *.* call <SID>OxnzUpdateTimestampFunc()
    augroup END

let &cpo = s:OxnzToolkitOptions
unlet s:OxnzToolkitOptions
```

### Python

```python
class OxnzToolkit(object):
    def exec(self, cmd, args):
        return self.dispatch(cmd)(args)

if __name__ == '__main__':
    try:
        cmdname = vim.eval('a:cmd')
        cmdargs = vim.eval('a:000')
        OxnzToolkit.exec(cmdname, cmdargs)
    except vim.error as e:
        print >> sys.stderr, e
```

### Ruby

```ruby
def VIM::has ident
    return VIM::evaluate("has('#{ident}')") != '0'
end

class OxnzToolkit
    def msg lvl = 'info', msg
        msg = '"' + msg + '"'
        case lvl
        when 'info'
            VIM::command "echo #{msg}"
        when 'warn'
            VIM::command "echohl WarningMsg | echo #{msg} | echohl None"
        when 'error'
            VIM::command "echohl ErrorMsg | echo #{msg} | echohl None"
        else
            msg 'error', "invalid message level: #{lvl}, message: #{msg}"
        end
    end
    def eval expr
        VIM::evaluate expr
    end
    def do
        cmdname = VIM::eval 'a:cmd'
        cmdargs = VIM::eval 'a:000'
        cmd = cmdname cmdargs
        if cmdargs.length == 0
            cmd.call
        else
            cmd.call args
        end
    end
end

if __FILE__ == $0 or 'vim-ruby' == $0
    begin
        OxnzToolkit.new.do
    rescue => e
        $stderr.puts "#{$0}: #{e}"
    rescue
        raise
    end
end
```

## References

* [Learning the vi Editor/Vim/VimL Script language](https://en.wikibooks.org/wiki/Learning_the_vi_Editor/Vim/VimL_Script_language)
* [Vim Tips](https://www.vi-improved.org/vim-tips/)
