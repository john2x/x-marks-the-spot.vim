let s:X_MARKS_THE_SPOT_VERSION = "0.0.1"

if exists("g:loaded_x_marks_the_spot")
	finish
endif
let g:loaded_x_marks_the_spot = 1
let s:ALLOWED_MARKS = "a b c d e f g h i j k l m n o p q r s t u v w x y z"

function! s:InitVariables()
	if !exists("b:assigned_marks")
		let b:assigned_marks = {}
		let marks = split(s:ALLOWED_MARKS, " ")
		for i in marks
			let pos = getpos("'" . i)
			if pos[1] > 0 && pos[2] > 0
				let b:assigned_marks[i] = pos[1:2]
			endif
		endfor
	endif
	if !exists("b:last_visited_mark")
		let b:last_visited_mark = ""
	endif
	if !exists("b:next_available_mark")
		let b:next_available_mark = "a"
	endif
endfunction

function! s:GotoPreviousMark()
	execute "normal! ['"
	echom "GotoPreviousMark"
endfunction

function! s:GotoNextMark()
	execute "normal! ]'"
	echom "GotoNextMark"
endfunction

function! s:AddMarkOnLine()
	let l:next_mark = <SID>GetNextAvailableMark()
	execute "normal! m" . next_mark
	let l:mark_pos = getpos("'" . next_mark)[1:2]
	let b:assigned_marks[next_mark] = l:mark_pos
	let b:next_available_mark = l:next_mark
	echo b:assigned_marks
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
	else
		echom "No marks on line " . l:lnum
	endif
endfunction

function! s:GetNextAvailableMark()
	if b:next_available_mark ==# "z"
		return "a"
	endif

	if len(b:assigned_marks)
		return nr2char(char2nr(b:next_available_mark) + 1)
	endif

	return "a"
endfunction

nnoremap <leader>x :call <SID>AddMarkOnLine()<cr>
nnoremap <leader>X :call <SID>RemoveMarksOnLine()<cr>

nnoremap <silent> <BS> :call <SID>GotoPreviousMark()<cr>
nnoremap <silent> <S-BS> :call <SID>GotoNextMark()<cr>

augroup x_marks_the_spot_augroup
	autocmd!
	autocmd BufAdd,BufEnter,BufNew,BufNewFile,BufRead * call <SID>InitVariables()
augroup END

