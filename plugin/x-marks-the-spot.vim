let s:X_MARKS_THE_SPOT_VERSION = "0.0.1"

if exists("g:loaded_x_marks_the_spot")
	finish
endif

if !exists("g:X_MARKS_THE_SPOT_MODE")
	let g:X_MARKS_THE_SPOT_MODE = 2
endif
let g:loaded_x_marks_the_spot = 1
let s:ALLOWED_MARKS = "a b c d e f g h i j k l m n o p q r s t u v w x y z"

function! s:InitVariables()
	if !exists("b:last_visited_mark")
		let b:last_visited_mark = ""
	endif
	if !exists("b:next_available_mark")
		let b:next_available_mark = "a"
	endif
	if !exists("b:assigned_marks")
		echom "Initializing assigned_marks"
		let b:assigned_marks = {}
		let l:allowedmarks = split(s:ALLOWED_MARKS, " ")
		echom join(l:allowedmarks, ",")
		for i in l:allowedmarks
			echom i
			let l:pos = getpos("'" . i)
			echom join(l:pos, ",")
			if l:pos[1] > 0 && l:pos[2] > 0
				let b:assigned_marks[i] = l:pos[1:2]
				let b:last_visited_mark = i
				let b:next_available_mark = <SID>GetNextChar(i)
			endif
		endfor
	endif
	echom "End Initializing"
	echo b:assigned_marks
endfunction

function! s:GotoPreviousMark()
	if g:X_MARKS_THE_SPOT_MODE == 1
		execute "normal! ['"
	elseif g:X_MARKS_THE_SPOT_MODE == 2
		let l:prev_mark = <SID>GetPreviousMark()
		if l:prev_mark !=# "0"
			execute "normal! '" . l:prev_mark
			let b:last_visited_mark = l:prev_mark
			echo "GotoPreviousMark " . l:prev_mark
		endif
	endif
endfunction

function! s:GotoNextMark()
	if g:X_MARKS_THE_SPOT_MODE == 1
		execute "normal! ]'"
	elseif g:X_MARKS_THE_SPOT_MODE == 2
		let l:next_mark = <SID>GetNextMark()
		if l:next_mark !=# "0"
			execute "normal! '" . l:next_mark
			let b:last_visited_mark = l:next_mark
			echo "GotoPreviousMark " . l:next_mark
		endif
	endif
endfunction

function! s:AddMarkOnLine()
	let l:next_mark = <SID>GetNextAvailableMark()
	execute "normal! m" . next_mark
	let l:mark_pos = getpos("'" . next_mark)[1:2]
	let b:assigned_marks[next_mark] = l:mark_pos
	let b:next_available_mark = l:next_mark
	let b:last_visited_mark = l:next_mark
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

augroup x_marks_the_spot_augroup
	autocmd!
	autocmd BufAdd,BufEnter,BufNew,BufNewFile,BufRead * call <SID>InitVariables()
augroup END

" Mappings
"
nnoremap <leader>x :call <SID>AddMarkOnLine()<cr>
nnoremap <leader>X :call <SID>RemoveMarksOnLine()<cr>

nnoremap <silent> <BS> :call <SID>GotoPreviousMark()<cr>
nnoremap <silent> <S-BS> :call <SID>GotoNextMark()<cr>

