" let s:asciitree = ['line1', 'line2', 'line3']

function! s:new_obj(obj) abort
    let newobj = deepcopy(a:obj)
    call newobj.Init()
    return newobj
endfunction

function! s:exec_silent_cmd(cmd) abort
    let ei_bak= &eventignore
    set eventignore=BufEnter,BufLeave,BufWinLeave,InsertLeave,CursorMoved,BufWritePost
    silent exe a:cmd
    let &eventignore = ei_bak
endfunction

function! s:exec_cmd(cmd) abort
    silent exe a:cmd
endfunction

let s:cntr = 0
function! s:get_unique_id() abort
    let s:cntr = s:cntr + 1
    return s:cntr
endfunction

function! s:panelTreeAction() abort
    call t:detector.ActionEnter()
endfunction

" =========================== DETECTOR CLASS ===========================
let s:scripts_keys = []
let s:scripts_values = []
let s:detector = {}
let s:terminal_bufnr = 0

function! s:detector.Init() abort
    let self.bufname = "detector".s:get_unique_id()
    let t:detector = self
endfunction

function! s:detector.ActionEnter() abort
    let index = line('.')
    if index < 0
        return
    endif
    if s:terminal_bufnr != 0
        exe 'silent! bd! '.s:terminal_bufnr
    endif
    call self.Hide()
    let opts = {}
    let opts.autoclose = 0
    let opts.keepfocus = 1
    let opts.position = 'right'
    let opts.cwd = ''
    let opts.cmd = s:scripts_values[index - 1]
    let s:terminal_bufnr = coc#util#open_terminal(opts)
    let g:terminal_id = win_findbuf(s:terminal_bufnr)
    call win_execute(g:terminal_id[0], 'vertical resize 80' )
   
endfunction

function! s:detector.BindKeys() abort
    let map_options = '<nowait> <silent> <buffer> '
    nnoremap <nowait> <silent> <buffer> <Enter> :call <sid>panelTreeAction()<cr>
endfunction

function! s:detector.draw() abort
    let savedview = winsaveview()
    call s:exec_cmd('1,$ d _')
    call append(0, s:scripts_keys)
    "remove the last empty line
    call s:exec_cmd('$d _')
    call winrestview(savedview)
endfunction

function! s:detector.SetFocus() abort
    let winnr = bufwinnr(self.bufname)
    " already focused.
    if winnr == winnr()
        return
    endif
    if winnr == -1
        echoerr "Fatal: window does not exist!"
        return
    endif
    " wincmd would cause cursor outside window.
    call s:exec_silent_cmd("norm! ".winnr."\<c-w>\<c-w>")
endfunction

function! s:detector.IsVisible() abort
    if bufwinnr(self.bufname) != -1
        return 1
    else
        return 0
    endif
endfunction

function! s:detector.Hide() abort
    if !self.IsVisible()
        return
    endif
    call self.SetFocus()
    call s:exec_cmd("quit")
endfunction

function s:detector.Toggle()
    if self.IsVisible()
        call self.Hide()
    else
        call self.Show()
    endif
endfunction

function s:detector.Show()
    call self.create_main_panel()
    call self.BindKeys()
    " call self.create_output_panel()
endfunction

function! s:detector.create_main_panel() abort
    let cmd = "botright vertical 24 new " . self.bufname
    call s:exec_cmd("silent keepalt ".cmd)
    call self.SetFocus()
    setlocal winfixwidth
    setlocal noswapfile
    setlocal buftype=nowrite
    setlocal bufhidden=delete
    setlocal nowrap
    setlocal foldcolumn=0
    setlocal nobuflisted
    setlocal nospell
    setlocal nonumber
    setlocal norelativenumber
    setlocal cursorline
    call self.draw()
    setlocal nomodifiable
endfunction

function! s:detector.create_output_panel() abort
    let cmd = 'belowright 10 new paneltree_2'
    call s:exec_silent_cmd(cmd)
    setlocal winfixwidth
    setlocal winfixheight
    setlocal noswapfile
    setlocal buftype=nowrite
    setlocal bufhidden=delete
    setlocal nowrap
    setlocal nobuflisted
    setlocal nospell
    setlocal nonumber
    setlocal norelativenumber
    setlocal nocursorline
    setlocal nomodifiable
endfunction

let s:detectortree = s:new_obj(s:detector)

function detector#ToggleScriptsPannel(map) abort
    let s:scripts_keys = keys(a:map)
    let s:scripts_values = values(a:map)
    call s:detectortree.Toggle()
endfunction

