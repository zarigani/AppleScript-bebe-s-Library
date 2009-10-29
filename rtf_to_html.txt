(*
リッチテキストをシンタックスハイライトなHTMLに変換する

	関連日記：
		シンタックスハイライトなHTMLに変換するオブジェクト指向AppleScript その1
			http://d.hatena.ne.jp/zariganitosh/20090222/1235458945
		シンタックスハイライトなHTMLに変換するオブジェクト指向AppleScript その2
			http://d.hatena.ne.jp/zariganitosh/20090223/1235459255
		シンタックスハイライトなHTMLに変換するオブジェクト指向AppleScript その3
			http://d.hatena.ne.jp/zariganitosh/20090224/1235460563
		シンタックスハイライトなHTMLに変換するオブジェクト指向AppleScript その4
			http://d.hatena.ne.jp/zariganitosh/20090225/1235510758
*)

property LIB : load script file ((path to scripts folder as text) & "_lib.scpt")
property RTF : load script file ((path to scripts folder as text) & "_rtf.scpt")
property FIND_TEXTS : {"\t", "&", "<", ">", "¬"} --"\t" = tab
property PUTS_TEXTS : {"  ", "&amp;", "&lt;", "&gt;", "&not;"}

property defaultFontFamily : "CourierNewPSMT"
property defaultFontSize : "12px"
property defaultColor : missing value

set RTF_OBJ to RTF's new("", "")
set defaultColor to most_hex_color(RTF_OBJ's everyText, RTF_OBJ's everyColor)
--set line_num_format to "%" & (count (RTF_OBJ's everyText's number as text)) & "d:"

set html to ""
repeat with i from 1 to RTF_OBJ's everyText's number
	set line_text to RTF_OBJ's everyText's item i
	set line_font to RTF_OBJ's everyFont's item i
	set line_size to RTF_OBJ's everySize's item i
	set line_color to RTF_OBJ's everyColor's item i
	
	set html to html & space
	--set html to html & LIB's printf(line_num_format, i) & space
	repeat with j from 1 to line_text's number
		set aText to line_text's item j
		set aFont to line_font's item j
		set aSize to line_size's item j
		set aColor to line_color's item j
		
		set html to html & text_or_tag(aText, aFont, aSize, aColor)
	end repeat
end repeat

set the clipboard to tag("pre" & return, html, {"style", default_css()})



(*
htmlに変換するハンドラ
*)
--見えない文字はそのまま、見える文字はタグで囲って返す
on text_or_tag(aText, aFont, aSize, aColor)
	--if  reg("/^[\\t\\s\\r]+$/", originalText) then--処理が遅過ぎ
	if is_invisible(aText) then
		content_text(aText)
	else
		tag(tag_by_font(aFont), content_text(aText), {"style", css(aFont, aSize, aColor)})
	end if
end text_or_tag

--見えない文字の連続かどうか真偽値で返す（見えない：true）
on is_invisible(str)
	str's item 1 & LIB's replace(str, str's item 1, "")
	result is in {tab, space, return}
end is_invisible

--タグで囲って返す
--利用例：
--	tag("span", "ABC", {{"class","AppleScript"}, {"style","color:rgb(0,0,0);"}})
--	<span class="AppleScript" style="color:rgb(0,0,0);">ABC</span>
--ペアリストが一つだけの場合は下記でもOK
--利用例：
--	tag("span", "ABC", {"style","color:rgb(0,0,0);"})
--		<span style="color:rgb(0,0,0);">ABC</span>
--	tag("pre", "ABC", "")
--		<pre>ABC</pre>
--	tag("pre"&return, "ABC", "")
--		<pre>
--		ABC
--		</pre>
--		
on tag(tag_name, str, attr_pair_list)
	if tag_name's item -1 is in {return, "\n"} then
		return tag(tag_name's items 1 thru -2 as text, return & str & return, attr_pair_list) & return
	end if
	attr_text(double_list_from(attr_pair_list))
	if result ≠ "" then
		"<" & tag_name & result & ">" & str & "</" & tag_name & ">"
	else if tag_name is not in {"span"} then
		"<" & tag_name & ">" & str & "</" & tag_name & ">"
	else
		str
	end if
end tag

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

--ペアリストから属性を指定するテキストを返す
--ペアリストとは{キー,値}のリストから構成されるリストを想定している
--{{"key1", "value1"}, {"key2", "value2"}, {"key3", "value3"}}
--利用例：
--	attr_text({{"class","AppleScript"}, {"style","color:rgb(0,0,0);"}})
--		" class=\"AppleScript\" style=\"color:rgb(0,0,0);\""
on attr_text(pair_list)
	set aText to ""
	repeat with pair in pair_list
		if pair's item 2 ≠ "" then
			set aText to aText & space & pair's item 1 & "=\"" & pair's item 2 & "\""
		end if
	end repeat
	aText
end attr_text

--必要な置き換えをしたテキストを返す
on content_text(str)
	LIB's every_replace(str, FIND_TEXTS, PUTS_TEXTS)
end content_text

--デフォルトのインラインスタイルを返す
on default_css()
	"color:" & defaultColor & ";" & "font-size:" & defaultFontSize & ";" & "font-family:" & defaultFontFamily & ";"
end default_css

--インラインスタイルを返す
on css(aFont, aSize, aColor)
	--css_color(aColor) & css_font_size(aSize) & css_font_weight(aFont)
	--css_color(aColor) & css_font_size(aSize) & css_font_family(aFont)
	css_color(aColor) -- & css_font_weight(aFont)
	
end css

--フォントの色の設定コードを返す　color:rgb(255,255,255);
on css_color(aColor)
	hex_color(aColor)
	if result = defaultColor then
		return ""
	else
		"color:" & result -- & ";"
	end if
end css_color

--フォントサイズの設定コードを返す　font-size:12px;
on css_font_size(aSize)
	aSize & "px"
	if result = defaultFontSize then
		return ""
	else
		"font-size:" & result & ";"
	end if
end css_font_size

--フォントの太さの設定コードを返す　font-weight:bold;
on css_font_weight(aFont)
	if "bold" is in aFont then
		"font-weight:bold;"
	end if
end css_font_weight

--フォントの種類の設定コードを返す　font-family:Osaka
on css_font_family(aFont)
	aFont
	if result = defaultFontFamily then
		return ""
	else
		"font-family:" & result & ";"
	end if
end css_font_family

--フォントに応じたタグを返す
on tag_by_font(aFont)
	if "bold" is in aFont then
		"b"
	else
		"span"
	end if
end tag_by_font

--RGB指定のカラー文字列を返す
--利用例：
--rgb_color({65535, 65535, 65535})
--	結果："rgb(255,255,255)"
on rgb_color(color_list)
	set R to (color_list's item 1) div 256
	set G to (color_list's item 2) div 256
	set B to (color_list's item 3) div 256
	"rgb(" & R & "," & G & "," & B & ")"
end rgb_color

--16進数のカラー文字列を返す
--利用例：
--hex_color({65535, 65535, 65535})
--	結果："#FFFFFF"
on hex_color(color_list)
	""
	repeat with i in color_list
		--result & LIB's hex_from(i div 256, 2)
		result & LIB's hex_from(i div 4096, 1)
	end repeat
	"#" & result
end hex_color

--一番多く出現する16進数カラーを返す
on most_hex_color(every_text, every_color)
	sum_every_color(every_text, every_color)
	hex_color(result's item 1's item (LIB's offset_of_max(result's item 2)))
end most_hex_color

--カラー値を集計して、カラーと出現回数のリストで返す（見えない文字のカラーは集計しない）
--返されるリストの例：
--	{
--	{{65535, 52428, 26214}, {46003, 46003, 46003}, {10530, 0, 65535}, {16383, 32767, 0}, {0, 0, 65535}, {0, 0, 0}}, 
--	{404, 59, 203, 238, 72, 79}
--	}
on sum_every_color(every_text, every_color)
	set sum_colors to {}
	set sum_counts to {}
	repeat with i from 1 to every_text's number
		set line_text to every_text's item i
		set line_color to every_color's item i
		
		repeat with j from 1 to line_text's number
			set a_text to line_text's item j
			set a_color to line_color's item j
			
			if is_invisible(a_text) is false then
				set colors_i to LIB's offset_in(sum_colors, a_color)
				if colors_i = 0 then
					set sum_colors to sum_colors & {a_color}
					set sum_counts to sum_counts & 1
				else
					set sum_counts's item colors_i to (sum_counts's item colors_i) + 1
				end if
			end if
		end repeat
	end repeat
	{sum_colors, sum_counts}
end sum_every_color

