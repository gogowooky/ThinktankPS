Thinktank



# 仕様書
## 名称
Thinktank。　考え（Think）を蓄えるもの（tank）。

## 概要
考えたこと、学んだこと、知りえた情報、参考資料を保管し活用する方法を提供する。
目的は、記憶をたぐりよせるためのきっかけ、を複数提供することです。
そのために、
　テキスト、イメージ、リンク、をタイムスタンプ付で記録します。


### 管理
テキスト：プレーンテキストのみを対象
　メモ
イメージ：特定拡張子のファイルを管理します。内容は管理しません。
　写真、スクリーンショット
リンク：
　ファイルリンク、WEBリンク、検索サイト
日時：
　データには日時
　
## 画面構成
### ライブラリーパネル

### インデックスパネル

### シェルフパネル

### デスクパネル

#### ワーク１パネル、ワーク２パネル、ワーク３パネル

#### ツール：エディタ

#### ツール：ブラウザ

#### ツール：グリッド

### キャビネットパネル

### パーツ
#### テキストボックス

#### データグリッド

#### メニュー

#### ボーダー

## タグ
### memo
[memo:nnnn-nn-nn-nnnnnn]
[memo:nnnn-nn-nn-nnnnnn:nn]
[memo:nnnn-nn-nn-nnnnnn:nn:nn]
[memo:nnnn-nn-nn-nnnnnn:ccccc]
[memo:nnnn-nn-nn-nnnnnn:mccccc]
[memo:ccccc]
[memo:mccccc]

### ref
[ref:nn]
[ref:nn:nn]
[ref:ccccc]
[ref:mccccc]

### mail
[mail:nnnn-nn-nn-nnnnnn]
[mail:ccccc]

### photo
[photo:nnnn-nn-nn-nnnnnn]

### 検索
[Route:xx,xx,xx]
[google:xxxxx]

### パネル
[index:tag:ccccc]
[shelf:tag:ccccc]
[cabinet:tag:ccccc]


## テキスト情報
### リソース（Thinktank）

### メモ（Memos）

### 編集（Editings）


### 検索（Searchs）


### リンク（Links）


### 設定（Configs）


### 状態（Status）


### コマンド（Commands）




# 設定値
## URL
Thinktank:URI:AvalonEdit, http://avalonedit.net/documentation/ , CSharp:AvalonEdit:Documentation
Thinktank:URI:dotNet APIブラウザ, https://docs.microsoft.com/ja-jp/dotnet/api/?view=net-5.0, Microsoft:dotNet
Thinktank:URI:Googleニュース, https://news.google.com/topstories?hl=ja&tab=wn&gl=JP&ceid=JP:ja, News:Google
Thinktank:URI:MSNニュース, https://www.msn.com/ja-jp/news/, News:Microsoft
Thinktank:URI:時事ニュース, https://www.jiji.com/?google_editors_picks=true, News:Jiji
Thinktank:URI:Edgeのお気に入り
Thinktank:URI:Chromeのお気に入り
Thinktank:URI:特定フォルダのリンク

## レコード
Thinktank:レコード:
[分類名]　住所録
[住所]
[名前]
[携帯電話]
[電話]
[その他]
(空行)

## 設定
Thinktank:設定:OutlookBackupFolder, 			    引用メールの保存先フォルダ, 個人用フォルダ (2019-01-)
Thinktank:設定:PhotoFolder,						    写真フォルダ, 個人用フォルダ (2019-01-)
Thinktank:設定:PDFFolder, 							PDFフォルダ, 個人用フォルダ (2019-01-)
Thinktank:設定:CaptureFolder, 						クリップボード画像の保存先フォルダ, MyPicture
Thinktank:設定:CaptureFolder, 						メモフォルダ, MyPictures
Thinktank:設定@LAPTOP-5FOVA1SU:OutlookBackupFolder,	引用メールの保存先フォルダ, 個人用フォルダ (2019-01-)
Thinktank:設定@LAPTOP-5FOVA1SU:PhotoFolder,			写真フォルダ, C:\Users\shin\Pictures\thinktank
Thinktank:設定@LAPTOP-5FOVA1SU:MemoFolder, 			メモフォルダ, C:\Users\shin\Documents\Thinktank
Thinktank:設定@HPH1N0299:MemoFolder, 				メモフォルダ, C:\TEMP\Remote\Thinktank\original.txt
Thinktank:設定@HPH1N0299:OutlookBackupFolder, 		引用メールの保存先フォルダ, 個人用フォルダ (2021-02-)
Thinktank:設定:Window,                      max
Thinktank:設定:Layout.Guide.Width,          12
Thinktank:設定:Layout.Library.Height,       25
Thinktank:設定:Layout.Shelf.Height,         25
Thinktank:設定:Config.CacheSavedMessage,    False
Thinktank:設定:Config.MemoSavedMessage,     True
Thinktank:設定:Config.TaskExpiredMessage,   False
Thinktank:設定:Config.KeyDownMessage,       False
Thinktank:設定:Config.TaskResisterMessage,  False

## Keywords
Thinktank:Keywords:_M)業務:_R)再生医療:_R)レギュレーション,	再生,細胞,申請,承認,安全確保法,条件期限付
Thinktank:Keywords:_M)業務:_R)再生医療:_P)Rec細胞,			REC細胞,PuREC,低ホスファターゼ
Thinktank:Keywords:_M)業務:_R)再生医療:_S)SHED,			GTS,KWB,SHED,歯髄
Thinktank:Keywords:_M)業務:_O)事務手続き:_H)健康,		人間ドッッグ,健康保険
Thinktank:Keywords:_M)業務:_O)事務手続き:_S)給与,		給与明細, ボーナス, 賞与
Thinktank:Keywords:_M)業務:_O)事務手続き:_P)年末調整,		年末調整,源泉徴収
Thinktank:Keywords:_M)業務:_A)学会参加,			学会参加,参加報告書
Thinktank:Keywords:_I)PC:_T)Thinktank,			WPF, Powershell, AvalonEdit, VSCode
Thinktank:Keywords:_I)PC:_P)プログラミング,			Microsoft, VBA, Word, Excels
Thinktank:Keywords:_A)旅行:_C)車キャンプ,		車中泊, キャンプ場, キャンピングカー, RecVee, RVLand, RVPark, 車旅行
Thinktank:Keywords:_A)旅行:_B)バイク,		レンタル, 自動車学校
Thinktank:Keywords:_P)制作:_C)切り絵・紙工作,	切り絵, レーザーカッター, 図案, 安野光雅, ペーパークラフト, 紙工作
Thinktank:Keywords:_P)制作:_F)折り紙,			折り紙, 立体, ユニット
Thinktank:Keywords:_P)制作:_P)版画・判子,		版画, 判子, ゴム版, レーザーカッター, 木版画, 消しゴム
Thinktank:Keywords:_P)制作:_E)電子工作,		電子工作, Raspberry, 秋月電機, ブレッドボード
Thinktank:Keywords:_P)制作:_M)音楽,			Ableton, Live, PropellerHead, Reason, MIDI
Thinktank:Keywords:_H)ホーム:_P)パスワード,		パスワード, ID, password, PSWD, PW
Thinktank:Keywords:_H)ホーム:_H)家,			配電図


## URIタグ
Thinktank:URI:コボット, https://platform.kobot.jp/support/solutions/articles/47001150388-outlook%E3%83%A1%E3%83%BC%E3%83%AB%E5%8F%96%E5%BE%97%E6%99%82%E3%81%AE%E3%83%95%E3%82%A3%E3%83%AB%E3%82%BF%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6, Program:Microsoft:VBA:Outlook
Thinktank:URI:Excel, https://docs.microsoft.com/ja-jp/office/vba/api/overview/excel/object-model, Program:Microsoft:VBA:Excel
Thinktank:URI:Word, https://docs.microsoft.com/ja-jp/office/vba/api/overview/word/object-model, Program:Microsoft:VBA:Word
Thinktank:URI:Outlook, https://docs.microsoft.com/ja-jp/office/vba/api/overview/outlook/object-model, Program:Microsoft:VBA:Outlook
Thinktank:URI:Powershell, https://docs.microsoft.com/ja-jp/powershell/scripting/overview?view=powershell-5.1, Program:Microsoft:Powershell
Thinktank:URI:Powershell, https://docs.microsoft.com/ja-jp/powershell/scripting/overview?view=powershell-5.1, Program:Microsoft:Powershell
Thinktank:URI:System.Windows.Controls, https://docs.microsoft.com/ja-jp/dotnet/api/system.windows.controls?view=net-5.0, Program:Windows:Controls
Thinktank:URI:AvalonEdit, http://avalonedit.net/documentation/, Program:WPF:TextEditor

## 検索サイト
Thinktank:検索:Google,      グーグル検索,           http://www.google.co.jp/search?q=[param], Google:Japan
Thinktank:検索:GoogleE,     グーグル検索（英）,     http://www.google.co.jp/search?q=[param]&lr=lang_en, Google:English
Thinktank:検索:GoogleJE,    グーグル英訳,           https://translate.google.com/?hl=ja#view=home&op=translate&sl=ja&tl=en&text=[param], Google:JE
Thinktank:検索:GoogleEJ,    グーグル和訳,           https://translate.google.com/?hl=ja#view=home&op=translate&sl=en&tl=ja&text=[param], Google:EJ
Thinktank:検索:GoogleJC,    グーグル中訳,           https://translate.google.com/?hl=ja#view=home&op=translate&sl=ja&tl=zh-CN&text=[param], Google:JC
Thinktank:検索:GoogleMap,   グーグルマップ検索,     https://www.google.co.jp/maps/place/[param], Google:Map:Japan
Thinktank:検索:GScholar,    グーグルスカラー,       https://scholar.google.co.jp/scholar?q=[param], Google:Scholar
Thinktank:検索:Youtube,     Youtube,                https://www.youtube.com/results?search_query=[param], Youtube
Thinktank:検索:Pubmed,      Pubmed検索,             https://pubmed.ncbi.nlm.nih.gov/?term=[param], Science:Clinical:Pubmed
Thinktank:検索:Yahoo,       Yahoo検索,              https://search.yahoo.co.jp/search?p=[param], Yahoo:Japan
Thinktank:検索:NIPH,        国立保健医療科学院,     https://rctportal.niph.go.jp/s/result?q=[param]&t=chiken, Clinical:Trials:NIPH
Thinktank:検索:CTG,         ClinicalTrials.gov,     https://clinicaltrials.gov/ct2/results?cond=[param]&term=&cntry=&state=&city=&dist=, Clinical:Trials:CTG
Thinktank:検索:Cortellis,   コルテリス,             https://www.cortellis.com/intelligence/qsearch/[param]?indexBased=true&searchCategory=ALL, Clinical:Database:Cortellis
Thinktank:検索:PMDA,        医薬品医療機器総合機構,  https://ss.pmda.go.jp/ja_all/search.x?q=[param]&ie=UTF-8&page=1, Clinical:Database:PMDA
Thinktank:検索:KAKEN,       日本学術振興会 科研費,   https://kaken.nii.ac.jp/ja/search/?kw=[param], Clinical:Database:KAKEN
Thinktank:検索:EMA,         欧州医薬品庁,           https://www.clinicaltrialsregister.eu/ctr-search/search?query=[param], Clinical:Trials:EMA
Thinktank:検索:JST,         科学技術振興機構,       https://www.jstage.jst.go.jp/result/global/-char/ja?globalSearchKey=[param], Clinical:Database:JStage
Thinktank:検索:PMC,         PubMed Central,         https://www.ncbi.nlm.nih.gov/pmc/?term=[param], Clinical:Database:PMC
Thinktank:検索:MHLW,        厚生労働省,             https://www.mhlw.go.jp/search.html?q=[param], Clinical:Database:MHLW
Thinktank:検索:MHLWG,       厚労省科研DB,           https://mhlw-grants.niph.go.jp/search?kywd=[param], Clinical:Database:MHLWGrants
Thinktank:検索:Spotify,     Spotify,                https://open.spotify.com/search/[param], Music:Spotify
Thinktank:検索:Wikipedia,   ウィキペディア,         https://ja.wikipedia.org/wiki/[param], Wikipedia:Japan
Thinktank:検索:WikipediaE,  ウィキペディア（英）,   https://en.wikipedia.org/wiki/[param], Wikipedia:English
Thinktank:検索:NET,         .NET API Browser,       https://docs.microsoft.com/ja-jp/dotnet/api/?view=net-5.0&term=[param], Program:Microsoft:.NET :API
Thinktank:検索:VBAOutlook,  VBAOutlook,             https://docs.microsoft.com/ja-jp/search/?search=[param]&category=outlook, Program:Microsoft:Outlook:VBA
Thinktank:検索:VBAExcel,    VBAExcel,               https://docs.microsoft.com/ja-jp/search/?search=[param]&category=excel, Program:Microsoft:Excel:VBA
Thinktank:検索:VBAWord,     VBAWord,                https://docs.microsoft.com/ja-jp/search/?search=[param]&category=word, Program:Microsoft:Word:VBA
Thinktank:検索:VBAObject,   VBAObject,              https://docs.microsoft.com/ja-jp/search/?search=[param]&category=objects-visual-basic-for-applications, Program:Microsoft:Object:VBA

## 履歴
Thinktank:設定:Application.Author,      制作者, Shinihciro Egashira
Thinktank:設定:Application.UpdateDate,  更新日, 2022/05/22 16:28
Thinktank:設定:Application.Version,     バージョン, 0.1.102
Thinktank:設定:Application.Content,     [TTPopupMenu] を tool化他

