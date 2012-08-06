nnoremap <leader>x :call <SID>AddMarkOnLine()<cr>
nnoremap <leader>X :call <SID>RemoveMarksOnLine()<cr>

nnoremap <silent> <BS> :call <SID>GotoPreviousMark()<cr>
nnoremap <silent> <S-BS> :call <SID>GotoNextMark()<cr>

let b:assigned_marks = {}
let b:last_visited_mark = ""
let b:next_available_mark = "a"

function! s:GotoPreviousMark()
	execute "normal! ['"
	echom "GotoPreviousMark"
endfunction

function! s:GotoNextMark()
	execute "normal! ]'"
	echom "GotoPreviousMark"
	echom "GotoNextMark"
endfunction

function! s:AddMarkOnLine()
	let next_mark = <SID>GetNextAvailableMark()
	execute "normal! m" . next_mark
	let mark_pos = getpos("'" . next_mark)[1:2]
	let b:assigned_marks[next_mark] = mark_pos
	let b:next_available_mark = next_mark
	echo b:assigned_marks
endfunction

function! s:RemoveMarksOnLine()
	let lnum = getpos(".")[1]
	let deleted_marks = ""
	" Get all marks on the current line
	for marc in items(b:assigned_marks)
		if marc[1][0] == lnum
			let deleted_marks .= marc[0] . " "
		endif
	endfor
	if len(deleted_marks)
		unlet marc
		execute "delmarks " . deleted_marks
		echom "Deleted marks [" . deleted_marks[:-2] . "] on line " . lnum

		for marc in split(deleted_marks, " ")
			unlet b:assigned_marks[marc]
		endfor
	else
		echom "No marks on line " . lnum
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
