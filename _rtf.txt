(*
RTFクラス
	アプリケーション名と書類の名前あるいは番号を指定して、RTF情報にアクセスする
		アプリケーション名が""の場合は、その時アクティブなアプリケーションになる
		書類の名前が""の場合は、document 1（最前面のウィンドウの書類）になる

	利用例：
		set RTF_OBJ to new("", "")
		RTF_OBJ's everyText
		RTF_OBJ's everyFont
		RTF_OBJ's everySize
		RTF_OBJ's everyColor

	開発＆テスト環境
		MacBook OSX 10.5.6
		AppleScript 2.0.1
		Script Editor 2.2.1 (100.1)
*)

--インスタンスを生成する（コンストラクタ）
on new(app_name, doc_name_or_num)
	if app_name = "" then set app_name to frontmost_app()
	if doc_name_or_num = "" then set doc_name_or_num to 1
	
	script RTF_instance
		property parent : me
		--global everyText, everyFont, everySize, everyColor
		property everyText : missing value
		property everyFont : missing value
		property everySize : missing value
		property everyColor : missing value
		
		--初期化
		on initalize()
			--validate（検証）の順序大事
			validate_presence_of_document()
			parse()
			validate_rtf()
			validate_presence_of_text()
			me
		end initalize
		
		--リッチテキスト情報を取得する（都度、メソッド呼び出しで処理すると、とっても遅くなったので、変数に代入することに）
		on parse()
			try
				tell application app_name
					tell document doc_name_or_num's paragraph
						set everyText to (every attribute run)
						set everyFont to (every attribute run)'s font
						set everySize to (every attribute run)'s size
						set everyColor to (every attribute run)'s color
					end tell
				end tell
			end try
		end parse
		
		--documentの存在を検証
		on validate_presence_of_document()
			tell application app_name
				try
					if (count document) > 0 then return
				end try
				"ドキュメントがありません。"
				--display dialog result buttons "OK" default button "OK" giving up after 10
				display alert result giving up after 10
				error
			end tell
		end validate_presence_of_document
		
		--テキストの存在を検証
		on validate_presence_of_text()
			tell application app_name
				try
					if everyText's number > 0 then return
				end try
				"変換するテキストがありません。"
				--display dialog result buttons "OK" default button "OK" giving up after 10
				display alert result giving up after 10
				error
			end tell
		end validate_presence_of_text
		
		--変換できるリッチテキストかどうか検証
		on validate_rtf()
			tell application app_name
				try
					if everyText's number = everyFont's number and ¬
						everyText's number = everySize's number and ¬
						everyText's number = everyColor's number then return
				end try
				"リッチテキストでないため変換できません。"
				--display dialog result buttons "OK" default button "OK" giving up after 10
				display alert result giving up after 10
				error
			end tell
		end validate_rtf
	end script
	result's initalize()
end new

--最前面のアプリケーション名（拡張子なし）を取得する
on frontmost_app()
	--short name of (info for (path to frontmost application)) -- short name属性がない場合、missing valueが返ってくる
	--name of (path to frontmost application) --拡張子が付属してしまう。"Script Editor.app"
	tell application "System Events"
		set name_list to processes's name whose frontmost is true
		name_list's first item
	end tell
end frontmost_app

