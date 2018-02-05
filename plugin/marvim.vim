" vim: et sw=2 sts=2

" Plugin:      https://github.com/fakeezz/marvim
" Description: Remember all macros
" Creator:     Chamindra de Silva <chamindra@gmail.com>
" Maintainer:  Alexandre Barbieri <fakeezz@gmail.com>

if exists('g:loaded_marvim') || &compatible
  finish
endif

let g:loaded_marvim = 1

let g:marvim_register = get(g:, 'marvim_register', 'q')
let g:marvim_find_key = get(g:, 'marvim_find_key', '<F2>')
let g:marvim_store_key = get(g:, 'marvim_store_key', '<F3>')

" Marvim definitions
command! -nargs=? -bar MarvimSearch :call marvim#search()
command! -nargs=? -bar MarvimStore :call marvim#store_macro()

" Mappings for commands
exec 'nnoremap '.g:marvim_find_key.' :MarvimSearch<CR>'
exec 'nnoremap '.g:marvim_store_key.' :MarvimStore<CR>'

exec 'vnoremap '.g:marvim_find_key.' :norm@'.g:marvim_register.'<CR>'
exec 'vnoremap '.g:marvim_store_key.' y:call marvim#store_template()<CR>'
