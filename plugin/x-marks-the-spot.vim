" X Marks the Spot
" Vim marks for pirates. Arr!
" Easy mappings for creating and navigating through lower-case marks.
" Last Change: 2012 Aug 18
" Maintainer: John Louis Del Rosario <john2x@gmail.com>
" Repository: https://github.com/john2x/x-marks-the-spot
" License: See `License` section in the file README.md

let s:X_MARKS_THE_SPOT_VERSION = "0.0.1"

if exists("g:loaded_x_marks_the_spot")
	finish
endif

if !exists("g:X_MARKS_NAVIGATION_MODE")
	let g:X_MARKS_NAVIGATION_MODE = 1
endif
if !exists("g:X_MARKS_RESET_MARKS_ON_BUF_READ")
	let g:X_MARKS_RESET_MARKS_ON_BUF_READ = 0
endif
if !exists("g:X_MARKS_SHOW_SIGNS")
	let g:X_MARKS_SHOW_SIGNS = 1
endif
let g:loaded_x_marks_the_spot = 1
let s:ALLOWED_MARKS = "a b c d e f g h i j k l m n o p q r s t u v w x y z"

function! ResetXMarksOnBuffer()
	call <SID>Initialize(0)
endfunction

function! s:Initialize(auto)
	if !a:auto
		echom "Initializing X Marks The Spot on current buffer..."
	endif
	if exists("g:X_MARKS_RESET_MARKS_ON_BUF_READ") && g:X_MARKS_RESET_MARKS_ON_BUF_READ
		execute "delmarks!"
	endif
	if !exists("b:last_visited_mark") || !a:auto
		let b:last_visited_mark = ""
	endif
	if !exists("b:next_available_mark") || !a:auto
		let b:next_available_mark = "a"
	endif
	let l:allowedmarks = split(s:ALLOWED_MARKS, " ")
	if !exists("b:assigned_marks") || !a:auto
		let b:assigned_marks = {}
		for l:marc in l:allowedmarks
			" Define sign
			execute "sign define xmarks_" . l:marc . " text=" . l:marc
			let l:pos = getpos("'" . l:marc)
			if l:pos[1] > 0 && l:pos[2] > 0
				let b:assigned_marks[marc] = l:pos[1:2]
				let b:last_visited_mark = l:marc
				let b:next_available_mark = <SID>GetNextChar(l:marc)
				if g:X_MARKS_SHOW_SIGNS
					" Place sign
					call <SID>AddSign(l:marc, l:pos[1])
				endif
			endif
		endfor
	endif
endfunction

function! s:GotoPreviousMark()
	if g:X_MARKS_NAVIGATION_MODE == 1
		execute "normal! ['"
	elseif g:X_MARKS_NAVIGATION_MODE == 2
		let l:prev_mark = <SID>GetPreviousMark()
		if l:prev_mark !=# "0"
			execute "normal! '" . l:prev_mark
			let b:last_visited_mark = l:prev_mark
			echo "Jumped to mark '" . l:prev_mark . "'"
		endif
	endif
endfunction

function! s:GotoNextMark()
	if g:X_MARKS_NAVIGATION_MODE == 1
		execute "normal! ]'"
	elseif g:X_MARKS_NAVIGATION_MODE == 2
		let l:next_mark = <SID>GetNextMark()
		if l:next_mark !=# "0"
			execute "normal! '" . l:next_mark
			let b:last_visited_mark = l:next_mark
			echo "Jumped to mark '" . l:next_mark . "'"
		endif
	endif
endfunction

function! s:AddMarkOnLine()
	if <SID>IsLineMarked(getpos(".")[1])
		echo "Line already marked. "
		return
	endif
	let l:next_mark = <SID>GetNextAvailableMark()
	execute "normal! m" . next_mark
	let l:mark_pos = getpos("'" . l:next_mark)[1:2]
	let b:assigned_marks[next_mark] = l:mark_pos
	let b:next_available_mark = l:next_mark
	let b:last_visited_mark = l:next_mark
	if g:X_MARKS_SHOW_SIGNS
		" Add sign
		call <SID>AddSign(l:next_mark, l:mark_pos[0])
	endif
	echo "Assigned mark '" . l:next_mark . "' at line " . l:mark_pos[0]
endfunction

function! s:IsLineMarked(lnum)
	for l:marc in items(b:assigned_marks)
		if l:marc[1][0] == a:lnum
			return 1
		endif
	endfor
	return 0
endfunction

function! s:RemoveMarksOnLine()
	let l:lnum = getpos(".")[1]
	let l:deleted_marks = ""
	" Get all marks on the current line
	for l:marc in items(b:assigned_marks)
		if l:marc[1][0] == l:lnum
			let l:deleted_marks .= l:marc[0] . " "
		endif
	endfor
	if len(l:deleted_marks)
		unlet l:marc
		execute "delmarks " . l:deleted_marks
		echom "Deleted marks [" . l:deleted_marks[:-2] . "] on line " . l:lnum

		for l:marc in split(l:deleted_marks, " ")
			unlet b:assigned_marks[l:marc]
		endfor
		if g:X_MARKS_SHOW_SIGNS
			" remove sign
			call <SID>RemoveSign(l:lnum)
		endif
	else
		echom "No marks on line " . l:lnum
	endif
endfunction

function! s:GetNextAvailableMark()
	if b:next_available_mark ==# "z"
		return "a"
	endif

	if len(b:assigned_marks)
		return <SID>GetNextChar(b:next_available_mark)
	endif

	return "a"
endfunction

function! s:GetPreviousMark()
	if !len(b:assigned_marks)
		return "0"
	endif
	let l:marcs = sort(keys(b:assigned_marks))
	let l:pos = index(l:marcs, b:last_visited_mark) - 1
	return l:marcs[l:pos]
endfunction

function! s:GetNextMark()
	if !len(b:assigned_marks)
		return "0"
	endif
	let l:marcs = sort(keys(b:assigned_marks))
	let l:pos = index(l:marcs, b:last_visited_mark) + 1
	if l:pos > len(l:marcs) - 1
		let l:pos = 0
	endif
	return l:marcs[l:pos]
endfunction

function! s:GetNextChar(char)
	if a:char ==# "z"
		return "a"
	endif
	let l:next_char = nr2char(char2nr(a:char) + 1)
	return l:next_char
endfunction

function! s:GetPrevChar(char)
	if a:char ==# "a"
		return "z"
	endif
	let l:prev_char = nr2char(char2nr(a:char) - 1)
	return l:prev_char
endfunction

function! s:AddSign(name, lnum)
	execute "sign place " . a:lnum . " line=" . a:lnum . " name=xmarks_" . a:name . " buffer=" . bufnr("%")
endfunction

function! s:RemoveSign(signid)
	execute "sign unplace " . a:signid . " buffer=" . bufnr("%")
endfunction

augroup x_marks_the_spot_augroup
	autocmd!
	autocmd BufRead * call <SID>Initialize(1)
augroup END

" Mappings

if !hasmapto('<Plug>XmarksthespotAddmark')
	nmap <unique> <leader>x <Plug>XmarksthespotAddmark
endif
if !hasmapto('<Plug>XmarksthespotRemovemarks')
	nmap <unique> <leader>X <Plug>XmarksthespotRemovemarks
endif
if !hasmapto('<Plug>XmarksthespotNextmark')
	nmap <unique> <S-BS> <Plug>XmarksthespotNextmark
endif
if !hasmapto('<Plug>XmarksthespotPreviousmark')
	nmap <unique> <BS> <Plug>XmarksthespotPreviousmark
endif

nnoremap <unique> <script> <Plug>XmarksthespotAddmark <SID>AddMarkOnLine
nnoremap <unique> <script> <Plug>XmarksthespotRemovemarks <SID>RemoveMarksOnLine
nnoremap <unique> <script> <Plug>XmarksthespotNextmark <SID>GotoNextMark
nnoremap <unique> <script> <Plug>XmarksthespotPreviousmark <SID>GotoPreviousMark
nnoremap <SID>AddMarkOnLine :call <SID>AddMarkOnLine()<cr>
nnoremap <SID>RemoveMarksOnLine :call <SID>RemoveMarksOnLine()<cr>
nnoremap <silent> <SID>GotoPreviousMark :call <SID>GotoPreviousMark()<cr>
nnoremap <silent> <SID>GotoNextMark :call <SID>GotoNextMark()<cr>

