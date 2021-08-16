" Initialize the channel
if !exists('s:detectorJobId')
	let s:detectorJobId = 0
endif

let s:Detect = 'detect'
let s:terminal_bufnr = 0

let s:scriptdir = resolve(expand('<sfile>:p:h') . '/..')
" The path to the binary that was created out of 'cargo build' or 'cargo build --release". This will generally be 'target/release/name'
let s:bin = s:scriptdir . '/target/release/nvim-command-runner'

" Entry point. Initialize RPC. If it succeeds, then attach commands to the `rpcnotify` invocations.
function! s:connect()
    call s:configureCommands()
endfunction

function! s:configureCommands()
    command! -nargs=0 Detect :call s:detect()
endfunction

function! s:detect()
    call rpcnotify(jobstart([s:bin], { 'rpc': v:true }), s:Detect, g:nvim_command_runner_commands_file, g:nvim_command_runner_commands_file_key)
endfunction

function ToggleScriptsPannel(map)
    :call detector#ToggleScriptsPannel(a:map)
endfunction

if !exists("g:nvim_command_runner_commands_file")
    let g:nvim_command_runner_commands_file='commands.json'
endif

if !exists("g:nvim_command_runner_commands_file_key")
    let g:nvim_command_runner_commands_file_key='scripts'
endif

call s:connect()
