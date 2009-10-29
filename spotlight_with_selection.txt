(*
選択中のテキストでスポットライト検索する
	Quicksilver等でショートカットを割り当てて利用する

	関連日記：
		GUIスクリプティングなAppleScript環境を快適にする
			http://d.hatena.ne.jp/zariganitosh/20090218/1235018953
*)

property GUI : load script file ((path to scripts folder as text) & "_gui.scpt")

GUI's init()
GUI's shortcut("", "command-c")
GUI's shortcut("", "control-space")
GUI's shortcut("", "command-V")

