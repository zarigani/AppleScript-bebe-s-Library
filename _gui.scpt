(*
GUIライブラリ
	ロード方法の例（このライブラリをユーザースクリプトフォルダに"_gui.scpt"で保存した場合）
		property GUI : load script file ((path to scripts folder as text) & "_gui.scpt")
	あるいは動的に...
		set GUI to load script file ((path to scripts folder as text) & "_gui.scpt")

	開発＆テスト環境
		MacBook OSX 10.5.6
		AppleScript 2.0.1
		Script Editor 2.2.1 (100.1)
*)

--初期化処理（Quicksilverからの起動なら、ひと呼吸置いて実行する）
on init()
	if is_from_quicksilver() then
		delay 0.2
	end if
end init

--GUIスクリプティングが無効なら、有効にすることを勧めるメッセージを出力する
on check()
	tell application "System Events"
		if UI elements enabled is false then
			tell application "System Preferences"
				activate
				set current pane to pane "com.apple.preference.universalaccess"
				set msg to "GUIスクリプティングが利用可能になっていません。\n\"補助装置にアクセスできるようにする\" にチェックを入れて続けますか？"
				--display dialog msg buttons {"OK"} default button "OK" with icon note --giving up after 10
				display dialog msg buttons {"キャンセル", "チェックを入れて続ける"} with icon note
			end tell
			--error "中断しました。"
			set UI elements enabled to true
			delay 1
			tell application "System Preferences" to quit
			delay 1
		end if
	end tell
end check

--click_menu(app_name, menu_path)
--メニュー操作をシンプルに実行する
--app_nameは、操作対象のアプリケーション名
--app_nameを""にすると、実行時にアクティブなアプリケーションに対する操作となる
--menu_pathは、テキストまたはリスト
--	click_menu("", "編集/検索/検索...") --OK
--	click_menu("Script Editor", {"編集", "検索", "検索..."}) --OK
--	click_menu("Script Editor", "編集", "検索", "検索...")--NG（リストでないので、編集をクリックする操作になってしまう）
--…または...の種類に注意
--	click_menu("Script Editor", "Apple/システム環境設定…") --全角記号1文字
--	click_menu("Script Editor", "スクリプトエディタ/環境設定...") --半角ドット3文字
--小さいカナ文字に注意（×ウィンドウ　○ウインドウ）
--アップルメニューの場合はpath_menuに"Apple"を指定する
--	click_menu("", "Apple/この Mac について")
--アイテム番号による指定も可能
--アイテム番号では区切り線も1と数える
--アイテム番号とアイテム名称の混在可能
--	click_menu("Script Editor", "スクリプトエディタ/サービス/テキストエディット/選択部分を含む新しいウインドウを開く")
--	click_menu("Script Editor", "2/5/32/2") --=="スクリプトエディタ/サービス/テキストエディット/選択部分を含む新しいウインドウを開く"
--	click_menu("", "2/環境設定...") --"スクリプトエディタ/環境設定..."
--アイコンメニューは、メニューバーのアイテム番号の選択とキー操作で行う
--アイコンメニューのapp_nameは"SystemUIServer"
--"SystemUIServer"以外のアイコンメニューを操作する方法は、現状分からない...
--例：ログインウィンドウを表示する（ログインユーザーが１人だけの場合）
(*
		click_menu("SystemUIServer", "16")
		shortcut("↓")
		shortcut("↓")
		shortcut("space")
*)
on click_menu(app_name, menu_path)
	if menu_path is "" then
		error "menu_path が入力されていません。"
	end if
	if app_name is "" then
		set app_name to frontmost_app()
	end if
	set mp to split(menu_path, "/")
	
	tell application "System Events"
		tell process app_name
			if "AppleScript Runner" is in my every_process() or ¬
				frontmost is false then
				set frontmost to true
			end if
			
			if mp's length = 1 then
				menu bar 1's (menu bar item (my number_from(mp's item 1)))
			else
				--menu bar 1's menu bar item (mp's item 1)'s menu (mp's item 1)
				menu bar 1's (menu bar item (my number_from(mp's item 1)))'s menu 1
				repeat with i from 2 to mp's length
					if i < mp's length then
						--result's menu item (mp's item i)'s menu (mp's item i)
						result's (menu item (my number_from(mp's item i)))'s menu 1
					else
						result's (menu item (my number_from(mp's item i)))
					end if
				end repeat
			end if
			
			click result --click:クリックする／pick:選択する--ほぼ同等だが、アイコンメニューにはclickが必須
			delay 0.1 --連続してメニューを操作する時、ひと呼吸必要
		end tell
	end tell
end click_menu

--shortcut(app_name, key_text)
--キーボードショートカット操作をシンプルに実行する
--引数のkey_textには、ハイフンで区切った文字列、もしくはリストで指定する
-- 	shortcut("", "command-option-L")
--	shortcut("", {"command", "option", "L"})
--文字列やリストの最後は必ず、一般キーかキーコードにする必要あり
--一般キーとは、command, option, control, shift, fn以外のキー
--キーコードは3桁の数字で指定する
--	shortcut("", "003") --f
--	shortcut("", "3") --3
--fnキーはキー操作文字列には利用できない
--ファンクションキー等は、キーコードで指定する
--	f1:122 f2:120 f3:99 f4:118 f5:96 f6:97 f7:98 f8:100 f9:101 f10:109 f11:103 f12:111
--一般キーとして以下のキーワードを利用可能
--	delete esc ← → ↓ ↑ space tab return
--利用例：
--	shortcut("", "command-option-control-shift-A") --==keystroke "a" using {command down, option down, control down, shift down}
--	shortcut("", "command-126") --==key code 126 using {command down}
--	shortcut("", "command-1") --==keystroke "1" using {command down}
--	shortcut("Finder", "control-space")
on shortcut(app_name, key_text)
	if key_text is "" or key_text is {} then
		error "key_text が入力されていません。"
	end if
	if (count of key_text) = 1 then
		set key_list to split(key_text's first item, "-")
	else
		set key_list to split(key_text, "-")
	end if
	set last_key to downcase(key_list's last item)
	
	set modifier_key to {}
	if "command" is in key_list then set modifier_key to modifier_key & command down
	if "option" is in key_list then set modifier_key to modifier_key & option down
	if "control" is in key_list then set modifier_key to modifier_key & control down
	if "shift" is in key_list then set modifier_key to modifier_key & shift down
	
	if last_key is "delete" then
		set last_key to 51 --delete
	else if last_key is "esc" then
		set last_key to 53 --esc
	else if last_key is "←" then
		set last_key to 123 --←
	else if last_key is "→" then
		set last_key to 124 --→
	else if last_key is "↓" then
		set last_key to 125 --↓
	else if last_key is "↑" then
		set last_key to 126 --↑
	else if last_key is "space" then
		set last_key to space
	else if last_key is "tab" then
		set last_key to tab
	else if last_key is "return" then
		set last_key to return
	else if last_key's length is 3 then
		try
			set last_key to last_key as number
		end try
	end if
	
	press_key(app_name, last_key, modifier_key)
end shortcut

--キー操作を実行する
--利用例：
--	press_key("1", command down)
--	press_key(126, command down)
on press_key(app_name, normal_key, modifier_key)
	--delay 0.2 --環境によって、必要なひと呼吸が変わってくる可能性がある
	if app_name is "" then
		set app_name to frontmost_app()
	end if
	
	tell application "System Events"
		tell process app_name
			if "AppleScript Runner" is in my every_process() or ¬
				frontmost is false then
				set frontmost to true
			end if
			
			if my is_number(normal_key) then
				key code normal_key using modifier_key
			else
				keystroke normal_key using modifier_key
			end if
			--delay 0.1
		end tell
	end tell
end press_key



--Quicksilverから起動しているかどうか
on is_from_quicksilver()
	try
		my name as text
		false
	on error
		true
	end try
end is_from_quicksilver

--起動中のアプリケーション名をリストで取得する
on every_process()
	tell application "System Events"
		--name of every process
		--every process's name
		processes's name
	end tell
end every_process

--最前面のアプリケーション名（拡張子なし）を取得する
on frontmost_app()
	--short name of (info for (path to frontmost application)) -- short name属性がない場合、missing valueが返ってくる
	--name of (path to frontmost application) --拡張子が付属してしまう。"Script Editor.app"
	tell application "System Events"
		set name_list to processes's name whose frontmost is true
		name_list's first item
	end tell
end frontmost_app

--1番上の書類ウィンドウを取得する（1番上の書類ウィンドウが存在しない場合、書類ウィンドウに限らず一番上のウィンドウを取得する）
on front_window()
	tell application "System Events"
		tell process (my frontmost_app())
			try
				set topWindow to item 1 of (every window whose subrole is "AXStandardWindow") --1番上の書類ウィンドウ
				topWindow --1番上の書類ウィンドウが存在しない場合、以下のエラー処理になる。
			on error
				front window --set topWindow to front window --window 1
			end try
		end tell
	end tell
end front_window



--このライブラリが依存する_lib.scptのコピー
on do_ruby_script(ruby_code)
	set shell_code to "ruby -e \"puts(" & ruby_code & ")\""
	do shell script shell_code
end do_ruby_script

on downcase(str)
	do_ruby_script("'" & str & "'.downcase")
end downcase

on split(sourceText, separator)
	if sourceText = "" then return {}
	set oldDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to {separator}
	set theList to text items of sourceText
	set AppleScript's text item delimiters to oldDelimiters
	return theList
end split

on is_number(num)
	num's class is integer or num's class is real
end is_number

on is_number_text(str)
	try
		str as number
		true
	on error
		false
	end try
end is_number_text

on number_from(str)
	try
		str as number
	on error
		str
	end try
end number_from



(*
on click_menu(app_name, menu_path)
	set mp to split(menu_path, "/")
	
	tell application "System Events"
		tell process app_name
			set frontmost to true --必ず、アクティブにしておく
			
			tell menu bar 1
				tell menu bar item (mp's item 1)
					tell menu (mp's item 1)
						
						if mp's length is 2 then
							pick ¬
								menu item (mp's item 2)
						else if mp's length is 3 then
							pick ¬
								menu item (mp's item 2)'s ¬
								menu (mp's item 2)'s ¬
								menu item (mp's item 3)
							(*
							tell menu item (mp's item 2)
								tell menu (mp's item 2)
									pick menu item (mp's item 3)
								end tell
							end tell
							*)
						else if mp's length is 4 then
							pick ¬
								menu item (mp's item 2)'s ¬
								menu (mp's item 2)'s ¬
								menu item (mp's item 3)'s ¬
								menu (mp's item 3)'s ¬
								menu item (mp's item 4)
							(*
							tell menu item (mp's item 2)
								tell menu (mp's item 2)
									tell menu item (mp's item 3)
										tell menu (mp's item 3)
											pick menu item (mp's item 4)
										end tell
									end tell
								end tell
							end tell
							*)
						else
							error "メニューパス \"" & menu_path & "\" を認識できません。"
						end if
						
					end tell
				end tell
			end tell
			
			delay 0.1 --連続してメニューを操作する時、ひと呼吸必要
		end tell
	end tell
end click_menu
*)
(*
on click_menu2(app_name, menu_name1, menu_name2)
	tell application "System Events"
		tell process app_name
			set frontmost to true --必ず、アクティブにしておく
			
			tell menu bar 1
				tell menu bar item menu_name1
					tell menu menu_name1
						pick menu item menu_name2
					end tell
				end tell
			end tell
			
			delay 0.1 --連続してメニューを操作する時、ひと呼吸必要
		end tell
	end tell
end click_menu2

on click_menu3(app_name, menu_name1, menu_name2, menu_name3)
	tell application "System Events"
		tell process app_name
			set frontmost to true --必ず、アクティブにしておく
			
			tell menu bar 1
				tell menu bar item menu_name1
					tell menu menu_name1
						tell menu item menu_name2
							tell menu menu_name2
								pick menu item menu_name3
							end tell
						end tell
					end tell
				end tell
			end tell
			
			delay 0.1 --連続してメニューを操作する時、ひと呼吸必要
		end tell
	end tell
end click_menu3
*)

