" ===================================================
" Synopsis: Text drawing syntax extension
"
" Author: Dylan Doxey <dylan.doxey@gmail.com>
" Date: 07/24/2021
"
" ===================================================
" Configuration:
"
"     ~/.vim/syntax/draw.vim
"
"     ~/.vim/ftdetect/draw.vim
"
" ===================================================
"

if exists("b:current_syntax")
  finish
endif

let b:current_syntax = "draw"

set laststatus=2
set statusline=PEN:MOVE

let g:LEFT  = 'h'
let g:DOWN  = 'j'
let g:UP    = 'k'
let g:RIGHT = 'l'

let g:HORZ_C   = '-'
let g:VERT_C   = '|'
let g:CROSS_C  = '+'
let g:TLEFT_C  = '+'
let g:BLEFT_C  = '+'
let g:TRIGHT_C = '+'
let g:BRIGHT_C = '+'
let g:TTEE_C   = '+'
let g:BTEE_C   = '+'
let g:LTEE_C   = '+'
let g:RTEE_C   = '+'
let g:SPACE_C  = ' '
let g:pen_state = 0

function! TogglePen()
    set statusline=
    if g:pen_state == 0
        let g:pen_state = 1
        set statusline+=PEN:DRAW
    elseif g:pen_state == 1
        let g:pen_state = 2
        set statusline+=PEN:ERASE
    else
        let g:pen_state = 0
        set statusline+=PEN:MOVE
    endif
endfunction

function! CursorCR()
    let l:pos = getcurpos()
    return {'c': l:pos[2], 'r': l:pos[1]}
endfunction

function! CharAt(c, r)
    let l:c = {'min': 1, 'max': col('$')}
    let l:r = {'min': 1, 'max': line('$')}
    if a:c < l:c['min'] || a:c > l:c['max']
        return ""
    endif
    if a:r < l:r['min'] || a:r > l:r['max']
        return ""
    endif
    let l:txt = getline(a:r)
    let l:char = strpart(l:txt, a:c - 1, 1)
    return l:char
endfunction

function! GetChar(cur, heading)
    let l:up    = CharAt(a:cur['c'], a:cur['r'] - 1)
    let l:right = CharAt(a:cur['c'] + 1, a:cur['r'])
    let l:down  = CharAt(a:cur['c'], a:cur['r'] + 1)
    let l:left  = CharAt(a:cur['c'] - 1, a:cur['r'])

    let l:connected_up    = l:up    == g:VERT_C || l:up    == g:CROSS_C || l:up    == g:TTEE_C || l:up    == g:TLEFT_C  || l:up    == g:TRIGHT_C
    let l:connected_right = l:right == g:HORZ_C || l:right == g:CROSS_C || l:right == g:RTEE_C || l:right == g:TRIGHT_C || l:right == g:BRIGHT_C
    let l:connected_down  = l:down  == g:VERT_C || l:down  == g:CROSS_C || l:down  == g:TTEE_C || l:down  == g:BRIGHT_C || l:down  == g:BLEFT_C
    let l:connected_left  = l:left  == g:HORZ_C || l:left  == g:CROSS_C || l:left  == g:LTEE_C || l:left  == g:BRIGHT_C || l:left  == g:TRIGHT_C


    if a:heading == "up"

        if      l:connected_left &&  l:connected_right &&  l:connected_down
            return g:CROSS_C
        elseif  l:connected_left &&  l:connected_right && !l:connected_down
            return g:BTEE_C
        elseif  l:connected_left && !l:connected_right &&  l:connected_down
            return g:LTEE_C
        elseif  l:connected_left && !l:connected_right && !l:connected_down
            return g:BRIGHT_C
        elseif !l:connected_left &&  l:connected_right &&  l:connected_down
            return g:RTEE_C
        elseif !l:connected_left &&  l:connected_right && !l:connected_down
            return g:BLEFT_C
        elseif !l:connected_left && !l:connected_right &&  l:connected_down
            return g:VERT_C
        elseif !l:connected_left && !l:connected_right && !l:connected_down
            return g:VERT_C
        endif

    elseif a:heading == "right"

        if      l:connected_up &&  l:connected_left &&  l:connected_down
            return g:CROSS_C
        elseif  l:connected_up &&  l:connected_left && !l:connected_down
            return g:BTEE_C
        elseif  l:connected_up && !l:connected_left &&  l:connected_down
            return g:LTEE_C
        elseif  l:connected_up && !l:connected_left && !l:connected_down
            return g:BLEFT_C
        elseif !l:connected_up &&  l:connected_left &&  l:connected_down
            return g:TTEE_C
        elseif !l:connected_up &&  l:connected_left && !l:connected_down
            return g:HORZ_C
        elseif !l:connected_up && !l:connected_left &&  l:connected_down
            return g:TLEFT_C
        elseif !l:connected_up && !l:connected_left && !l:connected_down
            return g:HORZ_C
        endif

    elseif a:heading == "down"

        if      l:connected_left &&  l:connected_up &&  l:connected_right
            return g:CROSS_C
        elseif  l:connected_left &&  l:connected_up && !l:connected_right
            return g:LTEE_C
        elseif  l:connected_left && !l:connected_up &&  l:connected_right
            return g:TTEE_C
        elseif  l:connected_left && !l:connected_up && !l:connected_right
            return g:TRIGHT_C
        elseif !l:connected_left &&  l:connected_up &&  l:connected_right
            return g:RTEE_C
        elseif !l:connected_left &&  l:connected_up && !l:connected_right
            return g:VERT_C
        elseif !l:connected_left && !l:connected_up &&  l:connected_right
            return g:TLEFT_C
        elseif !l:connected_left && !l:connected_up && !l:connected_right
            return g:VERT_C
        endif


    elseif a:heading == "left"

        if      l:connected_up &&  l:connected_right &&  l:connected_down
            return g:CROSS_C
        elseif  l:connected_up &&  l:connected_right && !l:connected_down
            return g:BTEE_C
        elseif  l:connected_up && !l:connected_right &&  l:connected_down
            return g:TRIGHT_C
        elseif  l:connected_up && !l:connected_right && !l:connected_down
            return g:BRIGHT_C
        elseif !l:connected_up &&  l:connected_right &&  l:connected_down
            return g:TTEE_C
        elseif !l:connected_up &&  l:connected_right && !l:connected_down
            return g:HORZ_C
        elseif !l:connected_up && !l:connected_right &&  l:connected_down
            return g:TRIGHT_C
        elseif !l:connected_up && !l:connected_right && !l:connected_down
            return g:HORZ_C
        endif

    endif
    return g:SPACE_C
endfunction

function! GrowLine(line_n, target_width)
    let l:save = winsaveview()
    if a:line_n > line('$')
        " should never need more than one
        call append(line('$'), g:SPACE_C)
    endif
    call setpos('.', [0, a:line_n, 1000000, 0])
    let l:cur = CursorCR()
    let l:n = a:target_width - l:cur['c']
    while l:n > 0
        " Add a space char
        execute ':normal! A' . g:SPACE_C
        let l:n = l:n - 1
    endwhile
    call winrestview(l:save)
endfunction

function! MoveUp()
    let l:cur = CursorCR()
    if l:cur['r'] == 1
        return
    endif
    call GrowLine(l:cur['r'] - 1, l:cur['c'])
    if g:pen_state == 1
        " replace current char
        execute ':normal r' . GetChar(l:cur, 'up')
        " move up
        normal! k
        " replace current char
        execute ':normal r' . g:VERT_C
    elseif g:pen_state == 2
        " replace current char
        execute ':normal r' . g:SPACE_C
        " move up
        normal! k
    else
        " move up
        normal! k
    endif
endfunction

function! MoveRight()
    let l:cur = CursorCR()
    call GrowLine(l:cur['r'], l:cur['c'] + 1)
    if g:pen_state == 1
        " replace current char
        execute ':normal r' . GetChar(l:cur, 'right')
        " move right
        normal! l
        " replace current char
        execute ':normal r' . g:HORZ_C
    elseif g:pen_state == 2
        " replace current char
        execute ':normal r' . g:SPACE_C
        " move right
        normal! l
    else
        " move right
        normal! l
    endif
endfunction

function! MoveDown()
    let l:cur = CursorCR()
    call GrowLine(l:cur['r'] + 1, l:cur['c'])
    if g:pen_state == 1
        " replace current char
        execute ':normal r' . GetChar(l:cur, 'down')
        " move down
        normal! j
        " replace current char
        execute ':normal r' . g:VERT_C
    elseif g:pen_state == 2
        " replace current char
        execute ':normal r' . g:SPACE_C
        " move down
        normal! j
    else
        " move down
        normal! j
    endif
endfunction

function! MoveLeft()
    let l:cur = CursorCR()
    if g:pen_state == 1
        " replace current char
        execute ':normal r' . GetChar(l:cur, 'left')
        " move left
        normal! h
        " replace current char
        execute ':normal r' . g:HORZ_C
    elseif g:pen_state == 2
        " replace current char
        execute ':normal r' . g:SPACE_C
        " move left
        normal! h
    else
        " move left
        normal! h
    endif
endfunction

nnoremap <SPACE> :call TogglePen()<CR>
nnoremap <Up>    :call MoveUp()<CR>
nnoremap <Right> :call MoveRight()<CR>
nnoremap <Down>  :call MoveDown()<CR>
nnoremap <Left>  :call MoveLeft()<CR>
