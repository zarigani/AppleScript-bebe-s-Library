(*
LIBライブラリ
	ロード方法の例（このライブラリをユーザースクリプトフォルダに"_lib.scpt"で保存した場合）
		property LIB : load script file ((path to scripts folder as text) & "_lib.scpt")
	あるいは動的に...
		set LIB to load script file ((path to scripts folder as text) & "_lib.scpt")

	開発＆テスト環境
		MacBook OSX 10.5.6
		AppleScript 2.0.1
		Script Editor 2.2.1 (100.1)
*)

--rubyコードを実行して結果を返す
--do_ruby_script({"require 'uri'", "URI.escape(%q|" & "tell application \"System Events\" --ショートカット操作をする限り" & "|)"})
on do_ruby_script(ruby_code)
	set ruby_code to ruby_code as list
	set last_code to ruby_code's last item
	if (count of ruby_code) ≥ 2 then
		set pre_code to join(ruby_code's items 1 thru -2, ";") & ";"
	else
		set pre_code to ""
	end if
	set shell_code to "ruby -e \"" & pre_code & "puts(" & last_code & ")\""
	log shell_code
	do shell script shell_code
end do_ruby_script

--URIエンコードして結果を返す
--uri_escape("set lib to load script file ((path to scripts folder as text) & \"_lib.scpt\")")
--uri_escape(the clipboard)
on uri_escape(str)
	str
	replace(result, "\"", "__DQT__")
	replace(result, "\\", "__BSL__")
	replace(result, "__DQT__", "\\\"")
	--log result
	do_ruby_script({"require 'uri'", "URI.escape(%q|" & result & "|)"})
	replace(result, "__BSL__", "%5C")
end uri_escape

--正規表現の比較をして真偽値を返す
--re("/\\d/", "abc1")
--re("/^[\\+\\-]?[\\d\\.\\,]+$/", "+123,456.789")
on reg(reg_text, str)
	try
		do_ruby_script(reg_text & " =~ '" & str & "'") as integer
		true
	on error
		false
	end try
end reg

--数値を3桁区切りのテキストにする
on number_with_delimiter(num)
	--注意：バックスラッシュは、バックスラッシュでエスケープすること（\\）。AppleScriptでは特殊な文字として扱われるため。
	--(num.to_s =~ /[-+]?¥d{4,}/) ? (num.to_s.reverse.gsub(/¥G((?:¥d+¥.)?¥d{3})(?=¥d)/, '¥1,').reverse) : num.to_s
	--(num.to_s =~ /[-+]?\\d{4,}/) ? (num.to_s.reverse.gsub(/\\G((?:\\d+\\.)?\\d{3})(?=\\d)/, '\\1,').reverse) : num.to_s
	do_ruby_script("('" & num & "' =~ /[-+]?\\d{4,}/) ? ('" & num & "'.reverse.gsub(/\\G((?:\\d+\\.)?\\d{3})(?=\\d)/, '\\1,').reverse) : '" & num & "'")
end number_with_delimiter

--printfコマンド
--printf("%3d:", 1)
--"  1:"
on printf(format, value)
	do shell script "printf" & space & format & space & value
end printf

--金額の書式を整える
--number_to_currency(金額, 小数点以下の桁数, 先頭文字, 末尾文字)
--lib's number_to_currency(1000.5, 2, "￥", "円")
--"￥1,000.50円"
--on number_to_currency(num, decimal_place, header, footer)
on number_to_currency(num, decimal_place)
	--do shell script "printf" & space & "%" & "." & decimal_place & "f" & space & num
	printf("%" & "." & decimal_place & "f", num)
	number_with_delimiter(result)
	--header & result & footer
end number_to_currency
(*
	on number_to_currency(arg)
		do shell script "printf" & space & "%" & "." & arg's decimal_place & "f" & space & arg's num
		number_with_delimiter(result)
		arg's header & result & arg's footer
	end number_to_currency
*)

--xが何者であるか判定する
(*
	x's class is integer
	x's class is real
	x's class is text
	x's class is list
	x's class is record
*)

--数値かどうか真偽値を返す
--is_number("1")
on is_number(num)
	num's class is integer or num's class is real
	(*
	if num = {} or num = "" then
		false
	else
		(count of num) is 0
	end if
	*)
end is_number

--数字（数値に変換できるテキスト）かどうか真偽値を返す
on is_number_text(str)
	try
		str as number
		true
	on error
		false
	end try
end is_number_text

--テキストを数値に変換する
--数値に変換できない場合は、そのままテキストを返す
on number_from(str)
	try
		str as number
	on error
		str
	end try
end number_from

--10進数値と桁数を指定して、16進数文字列を返す
--利用例：
--hex_from(123, 2)
--	"7B"
on hex_from(num, digit)
	set a_list to {}
	repeat while num > 0
		set a_list to a_list & num mod 16
		set num to num div 16
	end repeat
	
	repeat digit - (count a_list) times
		set a_list to a_list & 0
	end repeat
	
	""
	repeat with hex in a_list's reverse
		result & "0123456789ABCDEF"'s item (hex + 1)
	end repeat
end hex_from

--二重のリストに補正する
--本来、リストの中にリストを指定する想定なのだが...
--	{{"class","AppleScript"}, {"style","color:rgb(0,0,0);"}}
--リスト一つだけでは以下のように書いてしまいがち
--	{"class","AppleScript"}
--そのような状況で、本来の二重リストに修正する
--	{{"class","AppleScript"}}
on double_list_from(aList)
	if aList's item 1's class is list then
		aList
	else
		{aList}
	end if
end double_list_from

--文字を繰り返し、連結して返す
--t_repeat(文字, 繰り返し回数)
--t_repeat("*", 3) as text
on t_repeat(str, aCount)
	set t to ""
	repeat aCount times
		set t to t & str
	end repeat
	t
end t_repeat

--文字列を中央寄せ
--t_center(文字列, 文字列幅, 埋める文字)
--t_center("123", 6, "*")
on t_center(str, width, padding)
	set len to str's length
	set len_L to round_down((width - len) / 2, 0) --端数は切り捨て
	set len_R to width - len_L - len
	t_repeat(padding, len_L) & str & t_repeat(padding, len_R)
end t_center

--文字列を左寄せ
--t_left(文字列, 文字列幅, 埋める文字)
--t_left("123", 4, " ")
on t_left(str, width, padding)
	--(str & t_repeat(padding, width))'s text 1 thru width
	set str to str as text
	str & t_repeat(padding, width - (count str))
end t_left

--文字列を右寄せ
--t_right(文字列, 文字列幅, 埋める文字)
--t_right("123", 4, " ")
on t_right(str, width, padding)
	--(t_repeat(padding, width) & str)'s text -1 thru -width
	set str to str as text
	t_repeat(padding, width - (count str)) & str
end t_right

--sourceTextをseparatorでリストに変換する
--split("1,2,3,4", ",")
--	結果：{"1", "2", "3", "4"}
on split(sourceText, separator)
	if sourceText = "" then return {}
	set oldDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to {separator}
	set theList to text items of sourceText
	set AppleScript's text item delimiters to oldDelimiters
	return theList
end split

--sourceListをseparatorで区切ったテキストに変換する
--join({"1", "2", "3", "4"}, ",")
--	結果："1,2,3,4"
--join({{1, 2}, {3, 4}}, ",")
--	結果："1,2,3,4"
on join(sourceList, separator)
	set oldDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to {separator}
	set theText to sourceList as text
	set AppleScript's text item delimiters to oldDelimiters
	return theText
end join

--sourceText中の全てのtext1をtext2に置き換える
--replace("abcdefg", "bc", "_bc_")
--	結果："a_bc_defg"
on replace(sourceText, text1, text2)
	join(split(sourceText, text1), text2)
end replace

--sourceText中の全てのlist1をlist2に置き換える
--every_replace("abcdefg", {"bc", "e", "g"}, {"_bc_", "_e_", "_g_"})
--	結果："a_bc_d_e_f_g_"
on every_replace(sourceText, list1, list2)
	repeat with i from 1 to list1's number
		set sourceText to replace(sourceText, list1's item i, list2's item i)
	end repeat
end every_replace

--sourceText中の最初のtext1をtext2に置き換える
--replace_first("--tell application \"APP_NAME\" to activate--必要に応じて、アプリケーション\"APP_NAME\"をアクティブにする", "--", "--<span>")
--replace_first("end tell", "--", "--<span>")
on replace_first(sourceText, text1, text2)
	set aList to split(sourceText, text1)
	if (count aList) < 2 then
		return sourceText
	end if
	
	set topText to join(aList's items 1 thru 2, text2)
	if (count aList) = 2 then
		topText
	else
		join({topText} & aList's items 3 thru -1, text1)
	end if
end replace_first

--大文字に変換
on upcase(aText)
	do_ruby_script("'" & aText & "'.upcase")
end upcase

--小文字に変換
on downcase(aText)
	do_ruby_script("'" & aText & "'.downcase")
end downcase

--四捨五入する、丸め位置指定可能
--round_mid(数値, 丸め位置)
--小数位置は10の指数で指定する
-- −2: 10^-2...小数第2位まで求める
-- 3: 10^3...千の位まで求める
on round_mid(num, place)
	if place ≥ 0 then
		set p to 10 ^ place as integer
	else
		set p to 10 ^ place
	end if
	(round num / p rounding as taught in school) * p
end round_mid

--切り上げする、丸め位置指定可能
--round_up(数値, 丸め位置)
on round_up(num, place)
	if place ≥ 0 then
		set p to 10 ^ place as integer
	else
		set p to 10 ^ place
	end if
	(round num / p rounding up) * p
end round_up

--切り捨てする、丸め位置指定可能
--round_down(数値, 丸め位置)
on round_down(num, place)
	if place ≥ 0 then
		set p to 10 ^ place as integer
	else
		set p to 10 ^ place
	end if
	(round num / p rounding down) * p
end round_down

(*速い
set a_time to current date
repeat 100000 times--10万回で5秒
	offset_in({"ab", "cde", 1, 108, {}}, {})
end repeat
(current date) - a_time--5
*)
--offset_in({"ab", "cde", 1, 108, {}}, 108)
on offset_in(src_list, find_item)
	set i to 0
	repeat with a_item in src_list
		set i to i + 1
		if a_item as list is find_item as list then return i
	end repeat
	0
end offset_in

(*遅い
set a_time to current date
repeat 10000 times--1万回で5秒
	offset_in2({"ab", "cde", 1, 108, {}}, {})
end repeat
(current date) - a_time --5
*)
--offset_in2({"ab", "cde", 1, 108, {}}, 108)
on offset_in2(src_list, find_item)
	set delimiter to "__,__"
	set src_text to "__" & join(src_list, delimiter) & "__"
	set find_item to "__" & find_item & "__"
	set i to offset of find_item in src_text
	(src_text's items 1 thru i as text) & "_"
	count split(result, delimiter)
end offset_in2

--max({3, 2, 5, 1, 4})
on max(a_list)
	a_list's item 1
	repeat with a_item in a_list
		if a_item > result then
			a_item
		else
			result
		end if
	end repeat
	result's contents
end max

--max_offset({3, 2, 5, 1, 4})
on offset_of_max(a_list)
	set max_i to 1
	repeat with i from 1 to a_list's number
		if a_list's item i > a_list's item max_i then
			set max_i to i
		end if
	end repeat
	max_i
end offset_of_max

--min({3, 2, 5, 1, 4})
on min(a_list)
	a_list's item 1
	repeat with a_item in a_list
		if a_item < result then
			a_item
		else
			result
		end if
	end repeat
	result's contents
end min

--min_offset({3, 2, 5, 1, 4})
on offset_of_min(a_list)
	set min_i to 1
	repeat with i from 1 to a_list's number
		if a_list's item i < a_list's item min_i then
			set min_i to i
		end if
	end repeat
	min_i
end offset_of_min

