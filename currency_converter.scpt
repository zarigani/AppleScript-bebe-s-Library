(*
通貨両替機（サンプルコード）

	関連日記：
		AppleScriptで通貨両替計算機を作ってみる
			http://d.hatena.ne.jp/zariganitosh/20090212/1234442419
		オブジェクト指向AppleScript言語
			http://d.hatena.ne.jp/zariganitosh/20090210/1234233639
*)

property LIB : load script file ((path to scripts folder as text) & "_lib.scpt")
property kind_list : {"米ドル", "ユーロ", "英ポンド", "スイスフラン"}

(*
init()
input_rate()
repeat
	exchange()
end repeat
*)
init()
repeat
	input_rate()
	repeat
		try --キャンセル ボタンを捕まえるため
			exchange()
		on error msg number num from obj partial result try_obj to class_name
			--display dialog msg & space & num
			if num is 128 then --キャンセルならループを抜ける
				exit repeat
			else --キャンセル以外はそのままエラー
				error msg number num from obj partial result try_obj to class_name
			end if
		end try
	end repeat
end repeat




--必要なだけ両替機を生成する
on init()
	if my exchanger's all() is {} then
		repeat with aKind in kind_list
			my exchanger's new(aKind)
		end repeat
	end if
end init

--変換レートを入力する
on input_rate()
	repeat with aExchanger in my exchanger's all()
		set msg to "交換レート: 1" & aExchanger's currency & "は 何円？"
		display dialog msg default answer aExchanger's rate
		aExchanger's set_rate(text returned of result)
	end repeat
end input_rate

--両替の計算をする
on exchange()
	display dialog "金額を入力してください。" default answer "" buttons {"キャンセル", "外貨→円", "円→外貨"}
	if button returned of result is "外貨→円" then
		display dialog my exchanger's all_yen_from(text returned of result) as text
	else if button returned of result is "円→外貨" then
		display dialog my exchanger's all_other_from(text returned of result) as text
	end if
end exchange


--通貨両替機クラス（Exchangerクラスは、_Exchangerインスタンスを生成・管理する能力を持っている）
--このクラスにnewを送信すると、ある外貨の両替に対応した両替機が一つ生成される。
--生成された両替機は、プロパティitem_listに追加され、このクラスでまとめて管理される。
script exchanger
	property item_list : {}
	
	on new(aCurrency)
		set aItem to _new(aCurrency)
		set item_list to item_list & aItem
		aItem
	end new
	
	on _new(aCurrency)
		script _Exchanger
			property currency : aCurrency
			property rate : 0
			
			on set_currency(amounts)
				set currency to amounts
			end set_currency
			
			on set_rate(theRate)
				set rate to theRate
			end set_rate
			
			--外貨から円に変換する
			on yen_from(other)
				--表示例："1,000米ドル → 100,000.99円"
				my LIB's number_to_currency(other, 0) & my LIB's t_left(currency, 6, "　") & " → " & my LIB's number_to_currency(other * rate, 2) & "円" & return
				--other & currency & " → " & (other * rate) & "円" & return
			end yen_from
			
			--円から外貨に変換する
			on other_from(yen)
				--表示例："100,000円 → 1,000.99米ドル"
				my LIB's number_to_currency(yen, 0) & "円" & " → " & my LIB's number_to_currency(yen / rate as text, 2) & currency & return
				--yen & "円" & " → " & (yen / rate) & currency & return
			end other_from
		end script
	end _new
	
	on all()
		item_list
	end all
	
	on all_yen_from(other)
		set msg_list to {}
		repeat with aItem in item_list
			set msg_list to msg_list & aItem's yen_from(other)
		end repeat
		msg_list
	end all_yen_from
	
	on all_other_from(yen)
		set msg_list to {}
		repeat with aItem in item_list
			set msg_list to msg_list & aItem's other_from(yen)
		end repeat
		msg_list
	end all_other_from
end script

