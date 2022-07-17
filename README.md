# ThinktankPS2

# TOGO
## 未処理
- Configs表示の更新（Panel.Focusが表示されない）

## 不具合
- Panel非表示時にtentative表示すると、脱mode後に再非表示されない
- StatusでCurrent.Workspace/Toolが正しく表示されない　→設定ミス or 表示エラー

## 謎
- Alt+DでDeskからWorkplaceにFocusするときに、Editorが2度 focusされる謎 [220712]

## 要件等
- [TTEditorController]saveでMemosのcacheをupdateするかどうかについて

# KNOWLEDGE
## 注意点
- KeyEventにクラスインスタンス関数を使うのは不吉

## アイデア
- カーソル位置固定モード（文字入力によるカーソル位置変更時に、Panel内縦座標はスクロールで維持する）
- 単語レベルカーソル移動、Selection

# STATUS 
## 一旦固定
- Focus状態はタブに表示（背景色、枠色を使わない）
- KeyEvent処理はGlobalで処理（クラスインスタンスを使わない）


## 対応済・修正済
- ~~Viewクラスのイベント(TTEditorsManager::OnSave/OnLoad)を定義して動作を確認~~
- Editor focus時にDesk captionにindexとtitleを表示
- AppMan.Document.Editor.MoveTo()の'nextkeyword'/'prevkeyword'で検索語をselect
- Editorから他のPanelにAlt+XでFocusに移行できない　→修正
- Editorから他PanelにマウスでFocus移動するとエラー　→修正

- AppMan.Document.Editor.MoveTo()にlevelを区別しない'nextnode-'/'prevnode-'を設定
- 同上、'nextkeyword'/'prevkeyword'のkeyowrd無し動作を'nextnode-'/'prevnode-'に変更
- ttcmd_panel_collapse_multi_panel　動作確認
- ttcmd_panel_collapse_multi_work　動作確認
