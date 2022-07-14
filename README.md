# ThinktankPS2

# 未処理
- ttcmd_panel_collapse_multi_panel　中身つくってない
- ttcmd_panel_collapse_multi_work　中身つくってない
- Configs表示の更新（Panel.Focusが表示されない）
# 不具合
- Editorから他のPanelにAlt+XでFocusに移行できない
- Editorから他PanelにマウスでFocus移動するとエラー
- Panel非表示時にtentative表示すると、脱mode後に再非表示されない
# 謎
- Alt+DでDeskからWorkplaceにFocusするときに、Editorが2度 focusされる謎 [220712]
# 修正済

# 注意点
- KeyEventにクラスインスタンス関数を使うのは不吉

# 一旦固定
- Focus状態はタブに表示（背景色、枠色を使わない）
- KeyEvent処理はGlobalで処理（クラスインスタンスを使わない）

# アイデア
- カーソル位置固定モード（文字入力によるカーソル位置変更時に、Panel内縦座標はスクロールで維持する）
- 単語レベルカーソル移動、Selection
