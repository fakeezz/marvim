" vim: et sw=2 sts=2

" Plugin:      https://github.com/fakeezz/marvim
" Description: MAcro Repository Vim Plugin
" Creator:     Chamindra de Silva <chamindra@gmail.com>
" Maintainer:  Alexandre Barbieri <fakeezz@gmail.com>

if exists('g:autoloaded_marvim') || &compatible
  finish
endif
let g:autoloaded_marvim = 1

" Init: values {{{1

let g:marvim_register = get(g:, 'marvim_register', 'q')
let g:marvim_prefix_on_load = get(g:, 'marvim_prefix_on_load', 1)
let g:marvim_prefix_on_save = get(g:, 'marvim_prefix_on_save', 1)

" Function: #get_separator {{{1
function! marvim#get_version()
  return strpart(v:version, 0, 1)
endfunction

" Function: #get_separator {{{1
function! marvim#get_separator() abort
  return !exists('+shellslash') || &shellslash ? '/' : '\'
endfunction

let s:sep = marvim#get_separator()
let s:ext = '.mv'.marvim#get_version()
let s:text = '.mvt'

" Function: #get_macro_dir {{{1
function! marvim#get_marvim_dir() abort
  let l:marvim_dir = get(g:, 'marvim_dir', has('win32') ? '$HOME\vimfiles\marvim' : '$HOME/.marvim')
  return resolve(expand(l:marvim_dir)).s:sep
endfunction

let s:marvim_dir = marvim#get_marvim_dir()

" Function: #path_to_namespace {{{1
function! marvim#path_to_namespace(path)
  return tr(a:path, s:sep, ":")
endfunction

" Function: #namespace_to_path {{{1
function! marvim#namespace_to_path(ns)
  return tr(a:ns, ":", s:sep)
endfunction

" Function: #get_namespace {{{1
function! marvim#get_namespace()
  return &filetype == ''  ? '' : &filetype.':'
endfunction

" Function: #input_macro_name {{{1
function! marvim#input_macro_name(prompt, ns)
  let l:show_namespace = !a:ns ? '' : marvim#get_namespace()
  return input(a:prompt, l:show_namespace, 'customlist,marvim#completion')
endfunction

" Function: #get_directory {{{1
function! marvim#get_directory(absolute_path)
  let l:last_part = strridx(a:absolute_path, s:sep)
  return strpart(a:absolute_path, 0, l:last_part)
endfunction

" Function: #get_filename {{{1
function! marvim#get_filename(absolute_path)
  let l:last_part = strridx(a:absolute_path, s:sep)
  return strpart(a:absolute_path, l:last_part+1)
endfunction

" Function: #completion {{{1
function! marvim#completion(ArgLead, CmdLine, CursorPos)
  let l:completion_list = []
  let l:macro_name = marvim#namespace_to_path(a:ArgLead)
  let l:search_dir = marvim#get_directory(s:marvim_dir.l:macro_name)
  let l:search_name = marvim#get_filename(s:marvim_dir.l:macro_name)

  let l:macro_list = filter(split(glob(l:search_dir.s:sep.'**'), '\n'), 'v:val =~ ".mv"')

  let l:count = 0
  for l:item in l:macro_list

    let l:count = l:count + 1

    let l:file_part = strpart(l:item, strlen(s:marvim_dir))
    let l:filename = marvim#path_to_namespace(l:file_part)

    call add(l:completion_list, split(l:filename, '\.')[0])

  endfor

  return filter(l:completion_list, 'v:val =~ "'.l:search_name.'"')

endfunction

" Function: #get_macro_type {{{1
function! marvim#get_macro_type(macro)
  return split(a:macro, '\.')[-1]
endfunction

" Function: #get_absolute_path {{{1
function! marvim#get_absolute_path(name)
  let l:name = marvim#namespace_to_path(a:name)
  return glob(s:marvim_dir.l:name.".mv?")
endfunction

" Function: #run {{{1
function! marvim#run(macro)
  let l:macro_file = marvim#get_absolute_path(a:macro)
  let l:is_macro = filereadable(l:macro_file)

  if (l:is_macro == 0)
    echo 'Macro does not exist'
    return
  endif

  let l:macro_type = marvim#get_macro_type(l:macro_file)

  if (l:macro_type == 'mvt')
    silent execute 'read '.l:macro_file
  else
    let l:content = readfile(l:macro_file, 'b')
    call setreg(g:marvim_register, l:content[0])
    silent execute 'normal @'.g:marvim_register
  endif

endfunction

" Function: #search {{{1
function! marvim#search()

  let l:macro_name = marvim#input_macro_name('Macro search: ', g:marvim_prefix_on_load)

  if (l:macro_name != '')
    try
      call marvim#run(l:macro_name)
      echo 'Macro '.l:macro_name.' run'
    catch
      echoerr v:exception
    endtry
  endif

endfunction

" Function: #save_file {{{1
function! marvim#save_file(macro_name, content, macro_type)
  let l:name = marvim#namespace_to_path(a:macro_name)
  let l:fullname = s:marvim_dir.l:name.a:macro_type

  let l:dirname = marvim#get_directory(l:fullname)
  if (!isdirectory(l:dirname))
    call mkdir(l:dirname, "p")
  endif

  if (a:macro_type == s:ext)
    call writefile(a:content, l:fullname, 'b')
  else
    call writefile(a:content, l:fullname)
  endif
endfunction

" Function: #store_macro {{{1
function! marvim#store_macro()
  let l:name = marvim#input_macro_name('Enter macro name: ', g:marvim_prefix_on_save)

  let l:tmp_content = [getreg(g:marvim_register)]

  call marvim#save_file(l:name, l:tmp_content, s:ext)

  echo "\nMacro ".l:name." saved"
endfunction

" Function: #store_template {{{1
function! marvim#store_template()
  let l:name = marvim#input_macro_name('Enter template name: ', g:marvim_prefix_on_save)
  let l:tmp_content = split(@@, '\n')

  call marvim#save_file(l:name, l:tmp_content, s:text)

  echo "\nTemplate ".l:name." saved"
endfunction
