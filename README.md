# ThinktankPS2

# TODO
## 処理中
- 複数選択item対象の処理として、逐次処理、に加え、一括処理を加えたい。（select_actions_then_invoke）
　すべてのアクションに$itemsを渡すことにする。

## 未処理
- PopupMenuをカーソル位置またはマウス位置に
　参：Mouse.GetPosition(IInputElement) メソッド
　参：DataGridコントロールでクリックされたセルの位置を取得するには？

- 文字を表示した場合の幅・高
　参：[C# WPF] テキストのサイズを算出する

- Configs表示の更新（Panel.Focusが表示されない）


## 謎
- Alt+DでDeskからWorkplaceにFocusするときに、Editorが2度 focusされる謎 [220712]

## 要件等
- [TTEditorController]saveでMemosのcacheをupdateするかどうかについて

## 一旦固定
- Focus状態はタブに表示（背景色、枠色を使わない）
- KeyEvent処理はGlobalで処理（クラスインスタンスを使わない）
- Highlightは3Editorに各々設定できるが同様に設定する
  カンマ区切りで、Editor毎に割り当ててもいいな
  正規表現を使えるようにするか？
- 

## 方針
### Editorでは編集Ctrl-、モード変更等Alt-、の傾向を持たせる
### 日付入力（） ⇒まだ途中
  年、月、日をNon-Menuで変更（tentative-mode?）
  曜日対応
  時間対応

### クリップボード入力　　⇒まだ途中
　クリップボード画像
　画僧ファイル→phopto
　Memo以外のCopy → Search, 

### Actionタグ　　⇒まだ途中
・ メモタグ, 文書内ジャンプ、全メモ検索でも同じになるように
  [memo:xxxx-xx-xx-xxxxxx]          
  [memo:xxxx-xx-xx-xxxxxx:30:12]        [go:30]
  [memo:xxxx-xx-xx-xxxxxx:head:keyword] [go:head:keyword]   
  [memo:xxxx-xx-xx-xxxxxx:keyword]      [go:keyword]        
　[memo:keyword]
　[memo:head:keyword]

・ Ctrl+SpaceでOnCursorでタグがない場合、キーワードを拾って検索サイトのメニューを出す

### キーワード取得
　　


### 全文検索
　memoに結果を残すと全文検索時にヒットしまくって面倒だな、半面、Editorで開いて書き込めるのは便利装、タイトルで対象から外すか

Thinktank:SEARCH:キーワード
===============================================================
SearchDate: xxxx-xx-xx-xxxxxx

[memo:xxxx-xx-xx-xxxxxx] Title Snipet 
[memo:xxxx-xx-xx-xxxxxx] Title Snipet 

### 検索結果取り込み


## 不具合
- メモ削除でエラー
- マウスでMemo選択loadするとEditor2/3が一緒になってしまう。
- メモ中にThinktank:URI: があるとデータ回収できず落ちる
- Panel非表示時にtentative表示すると、脱mode後に再非表示されない
- StatusでCurrent.Workspace/Toolが正しく表示されない　→設定ミス or 表示エラー

# STATUS 
## 対応済・修正済
- PopupMenuはtentativeモード化した、tentative Library/Index/Shelf時にtentativeの再入になるが、まとめてcancelされてよし、とする

- PopupMenu, Cabinetで、Alt-ESCで終了するよう設定すること
　Alt-ESCはタスク切替のシステムショートカットで、キー入力に入ってこない。
　Applicationレベルで定義しても同じ、調べるとUser32.Dllを書き換えるとか出てくる
　⇒あきらめたほうがよさそう

- TTEditorController.paste(): 特殊ペーストのインターフェイス
- Panelでソートすると落ちる　
  → 社用PCでのみ発生：　$script: →$global: 変更で完了

- メモloadのあとカーソルが見えるようにscrollすること

- TTTagAction:　当日のみ入力可

- TTEditorsManager.History
  View内で処理する、Control側ではindexにForward/Back指定。

- route_tag, mail_tag, memo_tagの一部

- TTGroupController.event_highlight_text_on_editor：　ハイライトで正規表現対応

- TTGroupController.event_highlight_text_on_editor：　ハイライト

- TTPanelManager.Keywords:　カンマでグループ、スペースでキーワードを区切る。　カーソル位置でグループ選択

- Editor Load時にTTMemo[] flagへ読込済みEditorを設定
- Shelf設定時にTTResources[] flagへ読込済みPanelを設定
- Index設定時にTTResources[] flagへ読込済みPanelを設定
- Cabinet設定時にTTResources[] flagへ読込済みPanelを設定

- Editor.Save時にEditingが保存されない
- Editor.Load時にEditingが反映されない

- Library Panelの選択アイテム色変更
- TTGroupController.refresh：   TTResources.flagに表示Panel頭文字記入 
  TTGroupController.load：      TTGroupController.refresh('Library')を呼び出し
- TTGroupController.refresh：   TTMemo.flagに表示Editor番号記入
  TTEditorController.on_load：  TTGroupController.refreshを呼び出し

- DataGridの項目選択において、マウスダブルクリックでinvoke、Shift+ダブルクリックでselect&invoke

- Viewクラスのイベント(TTEditorsManager::OnSave/OnLoad)を定義して動作を確認
- Editor focus時にDesk captionにindexとtitleを表示
- AppMan.Document.Editor.MoveTo()の'nextkeyword'/'prevkeyword'で検索語をselect
- Editorから他のPanelにAlt+XでFocusに移行できない　→修正
- Editorから他PanelにマウスでFocus移動するとエラー　→修正

- AppMan.Document.Editor.MoveTo()にlevelを区別しない'nextnode-'/'prevnode-'を設定
- 同上、'nextkeyword'/'prevkeyword'のkeyowrd無し動作を'nextnode-'/'prevnode-'に変更
- ttcmd_panel_collapse_multi_panel　動作確認
- ttcmd_panel_collapse_multi_work　動作確認

# KNOWLEDGE
## 注意点
- KeyEventにクラスインスタンス関数を使うのは不吉 

## アイデア
- 
- カーソル位置固定モード（文字入力によるカーソル位置変更時に、Panel内縦座標はスクロールで維持する）
- 単語レベルカーソル移動、Selection

