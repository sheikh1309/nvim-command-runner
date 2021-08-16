# nvim-command-runner
> Run project commands inside nvim

# Intro
A small Vim plugin for detect and run commands for projects.



https://user-images.githubusercontent.com/24428816/129565687-a919a13d-a233-49c6-b083-f8d7968b2a4f.mov



# Installation
Use your preferred plugin manager. 
Run `install.sh` as a post-installation step, which will download and install the pre-built binary.

For example, for `vim-plug`, you can put in the following line into your `.vimrc`:
```vim
Plug 'sheikh1309/nvim-command-runner', { 'do': 'bash install.sh' }
```

Note: When updating this plugin, please restart Vim before runnning the commands to make the plugin use the updated binaries.


# Requirements
make sure you have [coc.nvim](https://github.com/neoclide/coc.nvim)


# Usage
`:Detect` which toggle the commands list

# Options
<a name='nvim_command_runner_commands_file'></a>
### The `nvim_command_runner_commands_file` option

By default, this plugin read `commands.json` file to get commands list.

Default: `'commands.json'`

Example: Mapping To Package.json.
```vim
let nvim_command_runner_commands_file='package.json'
```
<a name='nvim_command_runner_commands_file_key'></a>
### The `nvim_command_runner_commands_file_key` option

By default, this plugin read `scripts` key from the `nvim_command_runner_commands_file` file.

Default: `'scripts'`

Example: Mapping To commands.
```vim
let nvim_command_runner_commands_file_key='commands'
```
Example file `commands.json`
```json
{
    "scripts": {
        "echo": "echo 'Test'",
        ...
    }
}
```
# License
MIT 
