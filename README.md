# ThinktankPS2

# TODO
## 処理中
- desk_textbox_on_textchanged
- 複数選択item対象の処理として、逐次処理、に加え、一括処理を加えたい。（select_actions_then_invoke）
　すべてのアクションに$itemsを渡すことにする。
- Shift+左ダブルクリックを右シングルクリックに変更（datagrid_on_previewmousedown）

## 未処理
- PopupMenuをカーソル位置またはマウス位置に
　参：Mouse.GetPosition(IInputElement) メソッド
　参：DataGridコントロールでクリックされたセルの位置を取得するには？

- 文字を表示した場合の幅・高
　参：[C# WPF] テキストのサイズを算出する

- Configs表示の更新（Panel.Focusが表示されない）

## 不具合
- Panel非表示時にtentative表示すると、脱mode後に再非表示されない
- StatusでCurrent.Workspace/Toolが正しく表示されない　→設定ミス or 表示エラー

## 謎
- Alt+DでDeskからWorkplaceにFocusするときに、Editorが2度 focusされる謎 [220712]

## 要件等
- [TTEditorController]saveでMemosのcacheをupdateするかどうかについて

## 一旦固定
- Focus状態はタブに表示（背景色、枠色を使わない）
- KeyEvent処理はGlobalで処理（クラスインスタンスを使わない）

## 方針
- 日付
- Actionタグ
- 全文検索

# STATUS 
## 対応済・修正済
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

