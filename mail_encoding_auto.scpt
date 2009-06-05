(*
メール送信後にテキストエンコーディングを自動に設定して文字化け対策
	フォルダアクションから利用する

	関連日記：
		GUIスクリプティングなAppleScript環境を快適にする
			http://d.hatena.ne.jp/zariganitosh/20090218/1235018953
*)

property GUI : load script file ((path to scripts folder as text) & "_gui.scpt")

on adding folder items to this_folder after receiving added_items
	tell application "Finder" to open added_items
	
	GUI's init()
	GUI's check()
	GUI's shortcut("Mail", "command-option-1")
	GUI's shortcut("", "command-W")
	GUI's click_menu("", "ウインドウ/メッセージビューア")
	GUI's shortcut("", "command-W")
	GUI's shortcut("", "command-option-N")
end adding folder items to