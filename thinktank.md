= Thinktank
# メモ
## [2022-03-15] 便利そうなコントロール
　https://mseeeen.msen.jp/wpf-multi-tag-combo-box/
 
　結果を返すとき、[* WPFではUIスレッドをそのまま使うのではなく[ディスパッチャ]を介して使う]
　https://scrapbox.io/kadoyau/エラー：このオブジェクトは別のスレッドに所有されているため、呼び出しスレッドはこのオブジェクトにアクセスできません

## action 

[memo:2022-03-20-092038]
[memo:2022-03-20-092038:12]
[memo:2022-03-20-092038:12:30]
[memo:2022-03-20-092038:エマーソン]
[memo:2022-03-20-092038:#コネクタ]
[memo:shelf:旅行]
[memo:shelf:工作]
[memo:練習]
[memo:#練習]



[1]AvalonEdit, http://avalonedit.net/documentation/ 

Thinktank:URI:AvalonEdit, http://avalonedit.net/documentation/, :Program:WPF:TextEditor 

"C:\Users\shin\Pictures\thinktank\2021-11-16\2021-11-16-215052.png" 


"https://docs.microsoft.com/ja-jp/dotnet/api/system.windows.threading.dispatcher.invoke?view=windowsdesktop-6.0#system-windows-threading-dispatcher-invoke(syste　m-action)"

[mail:2021-11-10-084942]  (セブンマイルプログラム) 
[mail:セブン]
[Route:苫小牧,札幌,小樽]


[memo:2007-09-28-131843] 
[thinktank:dsadasdasd]  
[mail:井澤]
[ref:asdadasd]
 
[mail:2021-11-09-180125]:毎日が発見ネット
"C:\Users\shin\Pictures\thinktank\2021-11-11\2021-11-11-221448.png"


## date  
令和03年11月04日（木） 
[2018-08-01]
[2021-11-04]
2021/11/04
[Google:test]

## event
     (^[\s　]*\[([0-9]{4}\-[0-9]{2}\-[0-9]{2}):(\w+)(:\d+[dmy])?\]) 

- 前置
　[0000-00-00:todo] 予定の定まっていないTODO
  [xxxx-xx-xx:todo] イベント日
  [xxxx-xx-xx:todo] イベント開始日
  [xxxx-xx-xx:15d] イベント期間

- 後置
  [xxxx-xx-xx:done] 完了日
  [xxxx-xx-xx:cancel] キャンセル日
  [xxxx-xx-xx:stop] 中断日



## check
[_]
## url
http://google.com, http://yahoo.com



## path
c:\windows,c:\windows\addins
## 予備
    
    static [psobject[]] $Actions = @(
        @{
            Action = 'Edit'; Description = "E) 編集する"; Default = 'True'
            Exits = @(
                @{ Exit = 'Editor1'; Description = "1) Editor1" },
                @{ Exit = 'Editor2'; Description = "2) Editor2" },
                @{ Exit = 'Editor3'; Description = "3) Editor3" },
                @{ Exit = 'Editor'; Description = "E) カレントエディター"; Default = 'True ' }
            )
        },
        @{
            Action = 'Export'; Description = "X) エクスポートする"
            Exits = @(
                @{ Exit = 'Desktop'; Description = "D) デスクトップ" },
                @{ Exit = 'Clipoard'; Description = "C) クリップボード" },
                @{ Exit = 'Mail'; Description = "M) メール" }
            )
        },
        @{
            Action = 'Encrypt'; Description = "Y) 暗号化する"
            Exits = @(
                @{ Exit = 'Desktop'; Description = "D) デスクトップ" },
                @{ Exit = 'Clipoard'; Description = "C) クリップボード" },
                @{ Exit = 'Mail'; Description = "M) メール" }
            )
        },
        @{
            Action = 'Show'; Description = "S) 表示する"
            Exits = @(
                @{ Exit = 'Browser1'; Description = "Browser1" },
                @{ Exit = 'Browser2'; Description = "Browser2" },
                @{ Exit = 'Browser3'; Description = "Browser3" },
                @{ Exit = 'Browser'; Description = "カレントブラウザー" },
                @{ Exit = 'ExternalBrowser'; Description = "外部ブラウザー" }
            )
        },
        @{
            Action = 'Tag'; Description = "G) タグ"
            Exits = @(
                @{ Exit = 'Editor'; Description = "カレントエディター" },
                @{ Exit = 'Clipboard'; Description = "クリップボード" }
            )
        },
        @{
            Action = 'Title'; Description = "T) タイトル"
            Exits = @(
                @{ Exit = 'Editor'; Description = "カレントエディター" },
                @{ Exit = 'Clipboard'; Description = "クリップボード" }
            )
        }
    )
    static Edit( $object, $exit ){ Write-Host "$object, $exit" }
    static Export( $object, $exit ){ Write-Host "$object, $exit" }
    static Encrypt( $object, $exit ){ Write-Host "$object, $exit" }
    static Show( $object, $exit ){ Write-Host "$object, $exit" }
    static Tag( $object, $exit ){ Write-Host "$object, $exit" }
    static Title( $object, $exit ){ Write-Host "$object, $exit" }



 
# 課題
## [2022-06-17] menu
DeskMeuを 0)xxxxx, 1)xxxxx, 2)xxxxx, 3)xxxxx, 4)xxxxx, 5)xxxxx と表示
　0 は汎用
　1,2,3はWork1/2/3の表示Indexと履歴
　4以降はSideDeskの表示Indexと履歴
　履歴はEditingsに記録

## [2022-06-14] FocusとStyle
- Focus 指定 panel が Focusable ではなかった場合
Library/Index/Shelf/Deskl：     Focusしない
Editor/Browser/Grid：           同一workplaceでは切り替えてFocusする

- Focused panel が Style変更により、Focusable ではなくなった場合
採用:　 DeskにFocusする

### [220617] Library
- IndexのSelectedItemsメモに記載のリンクのみをShelfに表示する
- 選択ワードの検索タグを入力する
- 選択アイテムをメモに書き出す
- 
### [220617] 表示styleについて
- LibraryやIndexはあまりstyle変更しない
- shelfはMemoを選択するために頻繁にstyle変更する。
　- もう少し便利にしたい　
  　⇒ Cabinetで選ぶのが楽なのかも
  　⇒ 下のMenuシステムがLoad/Saveできるようになれば、Index/Shelf/Cabinetで選ぶことは減りそう
- 0)xxxxx, 1)xxxxx, 2)xxxxx, 3)xxxxx, 4)xxxxx, 5)xxxxx と表示し、0 は汎用、1,2,3はWork1/2/3、4以降はSideDesk、とかは！ 
　- DeskMenuをWork1/Work2/Work3のIndex、SubMenuを履歴、Desk.FocusのWorkを選択色表示にしてしまえば、Workplace単独表示で運用便利かも
　- Workplaceは、Work1/ Work2/ Work3 で独立で使うことが多い、左右分割・上下分割・３面はほぼ使わない
　- DeskMenuをTab、SabMenuを履歴にしてしまえば、Work1のみで運用可能か？　
- SideDesk(別windowのWorkplace)をつくって、MultiEditorにも対応（画面分割問題を気にしなくて済む）

- ■ 対等で動くの前提でつくり、運用で偏らせよう。
　- Work1/ Work2/ Work3 は対等とするか？　Work1をメインにしてしまうか？
　　- Work3は、Editor→Terminal、Browser→辞書、Grid→統計にする
　　- Work2は、Editor→

## [2022-06-04] 構造を大きく変更中
 - Fxキーでソートしたとき、カラム名を一時的に表示したい


## [2022-05-09] 
・ Panel毎のイベント

・ Model
 - DoAction / SelectActions / DiscardResources
 - Initialize() で @menu 変更
 - [TTTool]::ttcollection_onsavecache

## [2022-05-05] 
全文検索@TTExMemosが一応動くが、以下対応が必要
・ Shelf/Indexの操作のうち、TTMemosを前提としていたものを書き換えること 
・ Libraryの整備
　Ctrl+DでCacherが消えない、　Ctrl+Shift+Dでthinktank.cacheを削除
・ DoActionとSelectiActionsを管理しやすい様にする
・ TTConfigにTTStatusを設定、TTStatus読み込み時に一部パラメータは状態を設定する。
・ TTConfigsは保存するパラメータを決めて、読み込み時に反映させること


## [2022-04-20] 
・ ERROR:mark_columnで引数1はあり得ない。　 control.ps1:512:17
・ open時のdebug_messageにはメモタイトルあるが、save時にはないので付ける

## [2022-04-15] 
・ EditorからIndexにかってにフォーカスが移ってしまう（）
・ Editor Keywordを変更しても、ハイライトが変わらない
・ Editorのカーソル行はunderlineにならないかな、

## [2022-04-13] 
・ PDF整理機能
・ 音楽データ整理機能
・ 写真整理機能
　左テキストの photo タグを右 browser で見る。
　そのとき、コメントも付けられるようにする
　photo browser
・ DeskのMenuを実装
・ 機種ごとの設定の記述方法を変更したい
これまで：Thinktank:設定:CaptureFolder@HPH1N0299, 			MyPicture, クリップボード画像の保存先フォルダ
変更語：   Thinktank:設定@LAPTOP-5FOVA1SU:MemoFolder, 			C:\Users\shin\Documents\Thinktank, メモフォルダ
・ TTMemo.menusは thinktank.mdから読み込むように変更すること、

## [2022-04-13] 
・ Invoke と Activate は不穏なので再考する

## [2022-04-06]  
Indexのソート方法を考える
・ WordWrapがtoggleになってない

## [2022-04-03] 
・ 検索はInvokeからTTTagActionへ繋がるように組む
・ Sortingが美しくなるように名前を変更
・ 各モデルのSortings/Invokeを実装
・ Editingsが機能していない

## [2022-03-25] 
・ Status変更を即時反映できるが、ちらつく
　→ DataGridのRefreshには方法がいくつかあるので、要

## [2022-03-21] 整理
・ InvokeItemの拡充
・ メニュー
 - Command：単純にメニュー化できる
 - Link：
 - Memo：タグ抽出、出現数、最近のタグ、
・ 全文検索
・ [memo]タグ
・ Shelf、日付と曜日、更新日に対応する〇日前、  
・ フォルダ選択
・ tag は クラス化 



## [2020-02-20]
・DataGridのカラム幅をもう少し広げる
・DataGridの最大幅と最小幅を設定する

## [2020-02-16]
= 読み込み時
(cacheなし)
↓ リソースからモデル構築

(cacheあり)
↓ chache 読込
↓ cache更新日以降のリソースを取得
↓ 差分リソースからモデルに追加

= 書き込み時
リソース更新の確認を毎回する場合、cache更新無くてよい
リソース更新を毎回確認しない場合、Task登録→cache更新

## [2022-02-14] DataTableとは？　Linq？
→ DataTableよりもListのほうが速い、との記載あり。　http://www.moonmile.net/blog/archives/2228
遅さが気になるまでは、現行のHashtable.Valuesを表示させる方法でいってみる

https://resanaplaza.com/2020/09/25/%E3%80%90c%E3%80%91datatable-%E3%81%ABlinq%E3%82%92%E4%BD%BF%E3%81%86%E3%81%A8%E3%80%81%E3%82%81%E3%81%A3%E3%81%A1%E3%82%83%E4%BE%BF%E5%88%A9%EF%BC%815%E9%81%B8/

https://shinshin-log.com/csharp_datagrid/
https://www.fenet.jp/dotnet/column/%E8%A8%80%E8%AA%9E%E3%83%BB%E7%92%B0%E5%A2%83/294/　　←重要
https://www.spjeff.com/2015/04/21/datatable-in-powershell-for-crazy-fast-filters/　　←わかりやすい

## [2022-02-15] クロージャ　{}.GetNewClosure()
https://qiita.com/jca02266/items/ad35844ca6fcd2103185
https://winscript.jp/powershell/204

## [2022-02-14] DataGridへの変更
　sort  
　filter
　select
　setheader　https://atmarkit.itmedia.co.jp/bbs/phpBB/viewtopic.php?topic=12277&forum=7

　https://jpcodeqa.com/q/061004247cbe39f1887c3a82acaf5eda

## [2022-02-07] DataGridでいけそう。スタイルの微調整はあとですることにする　→　Row幅の制御、　テキストの左右・上下位置

## その他
[2022-02-04] Dispatcher.Invoke メソッドを使う https://mohmongar.net/?p=1403
[2022-02-03] 会社PCだと、何かのトリガーですぐにSh
[2022-02-01] httpリンクも　””　でくくれるようにする  
　→ xmlファイルは見た目だけなので、認識部の正規表現も変更すること
[2022-01-31] CurrentEditorのファイル名を表示
[2022-01-31] 選択Workをわかりやすく表示したい
[2022-01-31] Libraryで(件数)は日本語タイトルの後ろにして、順番を最初にする
[2022-01-26] Drug and Drop
[2022-01-29] 「要修正」の箇所
　キーワード：　key11 key12 key12, key21 key22, key31 key32 key33
　色を変える、カーソル移動
[2022-01-26] 写真
[2022-01-26] メモ全文検索 mail
[2022-01-26] メニュー
[2022-01-24] 文字サイズを可変にしたい
[2022-01-25] 登録フォルダを開く機能
[2022-01-25] Shelfのタイトル欄が狭い件 
　Head登録時に書き換えるしかないんだけどな、
[2022-01-25] キャッシュをクリアする機能
[2022-01-18] ListView選択したら、Statusに反映させるとことをつくるSyntaxHighlighting
[2022-01-18] Libraryを切り替えた後、ShelfのパラメータをRestroreする

・[2022-02-04] DataTableというのもある
　幅制御等もできないようで、使いにくいっぽい。　DeskのGrid実装で再検討

・[2022-02-04] DataGridの検討、後からDBと結合したいときとかに便利そう、　スタイル変更とかもListViewと同様にできるのか？
　[2022-02-07] 
　Styleもだいたい制御できた。
　微調整はあとですることにする　→　Row幅の制御、　テキストの左右・上下位置、
　[2022-02-04]　DataGridの検討、後からDBと結合したいときとかに便利そう、　スタイル変更とかもListViewと同様にできるのか？
　https://threeshark3.com/datagrid-often-use-property/　すごくよい
　https://qiita.com/kuro4/items/6be2e1e95db4714c8d7a
　https://noumenon-th.net/programming/2017/10/05/datagrid/  width="*"
　https://noumenon-th.net/programming/2017/10/22/datagrid-4/
　https://ameblo.jp/sql/entry-10230874417.html スタイル
　https://atmarkit.itmedia.co.jp/ait/articles/1410/21/news079.html
　https://marunaka-blog.com/wpf-datagrid/3169/


## 1/30以前 
・[2022-01-30] Statusの第二カラムのソートでエラー（多分、文字列以外に数値か$nullが含まれてしまっている）
　→　$script:UI.Sort( Status', '1', 'toggle' ) を '0' に変更してなおった。　非表示の'index'が含まれる場合は一つずれる。

・[2022-01-26] Drug and Drop　→要修正
　→　PreviewDropイベントでファイルのD&Dはキャプチャできた。写真ファイルをD&Dしてフォルダにしまうのはできそう、

・[2022-01-29] メモ内検索　→要修正
　→　実装できたがハイライトを含めて使いやすいように修正の必要あり

・[2022-01-26] 試装２：ハイライト、表示位置　→要修正
　これは、[IHighlightingDefinition]$editor.SyntaxHighlighting を直接変更知るだけで実装できるかもしれないね
　SyntaxHighlighting.NamedHighlightingColorsに定義したハイライトが、
　SyntaxHighlighting.MainRuleSetに定義したキーワードが入っていて、IListなので追加・削除できるっぽい
　→できた。

・[2022-01-29] 試装１：ハイライト、表示位置　
　→ C#クラス追加し、powershellから呼び出すと３行目だけ赤く表示されるようになった。
    [powershell] 呼び出し側
        $_.TextArea.TextView.LineTransformers.Add( [AvalonEdit.Sample.ThinktankLineColorizer]::new( 3 ) );

    [C#]クラス実装
        public class ThinktankLineColorizer : DocumentColorizingTransformer
        {
            int lineNumber;

            public ThinktankLineColorizer(int lineNumber)
            {
                this.lineNumber = lineNumber;
            }

            protected override void ColorizeLine(ICSharpCode.AvalonEdit.Document.DocumentLine line)
            {
                if (!line.IsDeleted && line.LineNumber == lineNumber) {
                    ChangeLinePart(line.Offset, line.EndOffset, ApplyChanges);
                }
            }

            void ApplyChanges(VisualLineElement element)
            {
                // This is where you do anything with the line
                element.TextRunProperties.SetForegroundBrush( System.Windows.Media.Brushes.Red );
            }
        }
    https://stackoverflow.com/questions/29008274/how-to-change-text-color-at-icsharpcode-avalonedit-texteditor

    ただし、呼び出しは行更新時のみで、先頭行削除によって４行目が３行目になるときには呼び出されない。
    また、TextView.LineTransformerに、powershell側のscript:変数に保管されているキーワードを渡す方法も思いつかん
　　その他の参考リンク
 　https://github.com/icsharpcode/SharpDevelop/blob/master/src/AddIns/DisplayBindings/AvalonEdit.AddIn/Src/CodeEditorView.cs
　https://stackoverflow.com/questions/5029724/avalonedit-wpf-texteditor-sharpdevelop-how-to-highlight-a-specific-range-of-t

・[2022-01-18] EditingのメモIDがおかしい件、[2022-01-25] Editingが反映されていないっぽい
　Model内でのeditorの参照方法がおかしかった(EditorEx1がまだあった)のを修正
　Mode内での$UI.configの参照方法がおかしかった(app.configがまだあった)のを修正
　別Editorで読み込み済みの場合Folding処理されなかった点を修正

・Section以外に、「・ 」「= 」「**」等もInsertできるようにする
　→ [2022-01-25]  できた
・Shelfで直接操作、ダブルクリック等
　→ [2022-01-25]  対応した
・文字化け問題、　Shelfのタイトルが化ける場合と化けない場合がある。　Memo.Chacheに登録されていないが、TTMemoには登録されているという不思議な状況、
　→ [2022-01-25]  新しいメモ作成して貼り付けると大丈夫なので、その対処法で様子見
・Filterに "-keyword" も追加
⇒ 追加した。　見たくないキーワードの指定、ができるようになった。
・Panelサイズ関連Statusは　Layout.xxx. にする
⇒ 対応した。
Modelを更新して、LitViewに反映させるところをつくる
⇒ $UI.Reloadを作成
　Reloadは元データの更新
　RestoreはDisplayItems以降（Filter,Sort,Select）の更新
・ [2022-01-16]　エラーメッセージが意味不明の時は、そのタイミングで発生するイベントでのエラーの可能性がある。
・ [2022-01-10]　ListViewに[psobject[]]を表示させたいが、クラス名だけが表示されてしまう
⇒配列とHashtable、または、[psobject]と[psobject[]]、または、@()と@{} が違っている場合がある

## [2022-01-09] 
ソート（Header Click, コマンド）
Folding

## [2022-01-07]
ThinkPadのみで、Alt-Sがトラップされている、⇒ 解決
　wormhoke3.exeという常駐アプリを削除したら認識するようになった。
　USBでPC同士を接続してファイル転送やマウス共有等をするやつだったが、いらん常駐アプリが登録されてしまっておった。
　タスクマネージャーで起動時無効にした。

## [2022-01-04]
各種イベントの整理  
ファイルを読み込んだら、MemoのDisplayItemの編集にフラグ立てる
Command:ShelfSorting
Link:ShelfSorting
Search:ShelfSorting
Filterのクリア　ショートカット
Grid-Showを直す

Alt+Mでメモ Collection選択、Alt維持+MでCollection切替、の動き
    Mod Key維持＋連打切替を汎化したいな
→ [2022-01-05] ModKeyModeで実現できている

Taskが削除されずずっとコールされてしまう問題
→ [2022-01-05] hashtableのvalueを削除していたところを、keyが削除されるよう修正

ファイル保存時の文字コード指定
→ [2021-01-04] Set-ContentではEncode設定不可、Out-Fileで実装する必要がある。
→ [2021-01-05] 保存時のエラー解消、正規表現の表記を修正

新規ファイル
→ [2021-01-04] 実装した、読込後の一覧ソート等の課題あり

## [2022-01-03]
Members選択→studies/editor開く
の他に、
studies/editorにロード→Members選択
の流れもつくる



## [2021-12-28]
・ Folding行右端の[...]マークを変更したいが変更できそうにない。　おそらくC#の ThinktankFoldingStrategy を変更する必要がある

## [2021-12-27]

⇒ ListView マウスオーバーでのカーソル表示やめる
 → [2021-12-28] はずした（以下）
            <Trigger Property="IsMouseOver" Value="true" >
                <Setter Property="BorderBrush" Value="{StaticResource TTListItemColorOnMouse}" />
                <Setter Property="Background" Value="{StaticResource TTListItemColorOnMouse}" />
                <Setter Property="Foreground" Value="{StaticResource TTListItemFntColorOnMouse}"/> 
            </Trigger>

⇒ TextEditorカーソル行のstyleで、BorderThicknessを0にすればよいよ　AvalonEdit/TextEditor.xaml at master · icsharpcode/AvalonEdit · GitHub
 → [2021-12-28] thinktank.xamlで設定した


⇒ Load中メモのアイテムを薄く色付け、フォーカス中メモのアイテムをSelectedにする
                            
・Modelは問題ない
    Class TTMemos / $script:TTMemos

・ViewはControl側に移動中で、thinktank-toolがView支援用でコンポーネント毎になっていてわかりやすい
    $script:LibraryItems

・Controlの住み分けが微妙な状態
    Control内では、ViewEventに直接マップできる関数と、支援ツールが混載している。
    Controlsメンバー関数、Controlsメンバー関数（支援用）、コマンド、コマンド（支援用）
    ⇒イベントにマップする目的であるなら、ScriptBlockで作成して、そのままAdd_Eventすればよいのでは？
    → [2021-12-28] そうするとview側で調整したいことをイベント内にかけなくなるんよ。
      今のまま、viewのeventからcontrol関数を呼ぶ形でゆきたいです。

・Controlはnamespace的な目的でclassで実装しているが、その意味あるか？
    ⇒ thinktank-commandは分けていた方がよいのかも
    → [2021-12-28] thinktank-command.ps1を復活した
    ⇒ Controlsメンバ関数はプロパティを操作するものに限ることにする

⇒ 関数をBindする方法を学ぶこと



## [2021-11-17] 
・メモ選択：　ダブルクリックまたはカーソル＋Return
・編集時のカーソルの動きを元に戻す


## 画面構成
Main:文書1		Side:不使用		Follow:不使用
Main:文書1		Side:文書1		Follow:不使用	

## ref問題
   [ega,1]

[1] Word, https://docs.microsoft.com/ja-jp/office/vba/api/overview/word/object-model  
Thinktank:URI:Word, https://docs.microsoft.com/ja-jp/office/vba/api/overview/word/object-model, :Program:Microsoft:VBA:Word

"https://news.google.com/articles/CAIiEG5NFZIFXrkRYu5rX8f1ZmUqGQgEKhAIACoHCAowv6KGCzDTkYQDMIH7mgc?hl=ja&gl=JP&ceid=JP%3Ajdqdqdqdqx:lpcm s:pdnm:pvn: cdpka"


## [2021-11-10]    
・ 行頭マーク入力キー
・ リマインダーのしくみ 
・メモ検索そろそろほしい
・過去のメールタグも開きたいかも
・文字サイズ
・メールタグ張り付け時のセクション記号はいらない
・見た目をOfficeっぽくする
・EditViewにもMenuとTextBoxを、Menuをぱんくずに使えるかも
・ブラウザのお気に入り取り込めない

## [2021-11-09] 
・ 大きいSelectMenuにもMenuを
・ Memo/Item  
　ショートカット：テキストボックスフォーカス、メニューフォーカス、テキストボックス消去、ソート
・ MITライセンス表示
・ 日付タグ入力時にやっぱりやめたくなったとき、元号確認だけしたかったようなときにキャンセルしたい
　もともとの日付に戻す
・ バージョニング⇒versionフォルダ
・ Collecion
　選択後の動きをきれいに
Memo
　項目選択（マウスクリック、選択＋リターン）⇒Editor表示
メニュー：項目を階層表示
メニュー選択⇒TextBoxに文字追加
テキストボックス⇒インクリメンタルフィルター

Config
　項目選択（マウスクリック、選択＋リターン）⇒Editor表示
メニュー：項目を階層表示
メニュー選択⇒TextBoxに文字追加
テキストボックス⇒インクリメンタルフィルター

ExternalLink
　項目選択（マウスクリック、選択＋リターン）⇒ブラウザ表示
メニュー：項目を階層表示
メニュー選択⇒TextBoxに文字追加
テキストボックス⇒インクリメンタルフィルター

SearchMethod
　項目選択（マウスクリック、選択＋リターン）⇒ブラウザ表示
メニュー：項目を階層表示
メニュー選択⇒TextBoxに文字追加
テキストボックス⇒インクリメンタルフィルター

ThinktankCommand
　項目選択（マウスクリック、選択＋リターン）⇒ブラウザ表示
メニュー：項目を階層表示
メニュー選択⇒TextBoxに文字追加
テキストボックス⇒インクリメンタルフィルター

・ カーソルが消えてしまうことがある
・ ソートが反転できない
・ (現場) cmd.exeからbatで、または、ISEからの起動では動かない。　コンテクストメニューから起動すれば動く
　⇒ powershell実行が制限される可能性あり。　Word版は継続[2021-11-10] asdasd 

## アイデア 
・ クリップボード   :thinktank_command_paste_clipboard  
   メールタグ作成
   リンク
・ 検索：　ttt_command_action_of_thinktank 
・ 文書内引用：　ttt_command_action_of_ref 
・ 写真：　ttt_command_action_of_photo
・ 日付         :ttt_command_tag_action_with_date
・ 編集状態の保存(カーソル,アウトライン,最上行)  :class TTEditing : TTObject {
・ イベントTODO     :ttt_command_tag_action_with_event
・ bookmark
  chrome:  C:\Users\username\AppData\Local\Google\Chrome\User Data\Default\Bookmarks
  edge:    C:\Users\username\AppData\Local\Microsoft\Edge\User Data\Default\Bookmarks
・ 履歴を戻る
  参照系
・ 新規メモ
・ メモの削除
・ カーソル位置の章タイトル　
  ⇒　VSCodeのMDでは最上にぱんくずがみえている、メニューも出る。
　  ⇒ VSCode上に作ったほうがよいような気がしてきたよ。。
・ 検索用Textboxはなくてよい → Filter用のメニュー
・ Ctrl-o → ctrl-Space に変更
・ コレクション生成
  term: xxxx-xx-xx - xxxx-xx-xx
  idea: all, (select)
  word: (search)
・ メモ連結一括編集
  TextAnchorクラス
・ ドラッグドロップ
  photo
  pdf
・ 次のメモの開き方
  PrimにLoad
  ExにLoad
・ メモの解析
・ 辞書
・ フォトアルバム
・ マニュアル
  陽子が使える版を早めに作る
  検索は全メモに対してのみ
  マウスで使えるメニュー

# できたこと　
[2022-05-09] 
・ modelを整備

[2022-05-05] 
 ・ [2022-04-20]  IndexにTTCommandsが表示されない
 → IndexFormatの設定ミス

[2022-04-20] 
・ Editor毎にHistoryを設定、Ctrl+BS/Ctrl+Shift+BSで前後できるようにした。
・ $script:deskの関数軍は、current_editorに対して操作する形になっていたが、current以外も編集できるようにした。

[2022-04-15] 
・ Editor Keywordを変更しても、ハイライトが変わらない
→ 複数色のハイライトを管理できるようにした

[2022-04-13] 
・ Shelfメニュー、Deskメニューへのフォーカス
・ Library内で、Link(Ctrl+L), Memo(Ctrl+Memo), Search(Ctrl+Search)を選択してPanelに表示するキーを設定＾
・ メモ選択時のmark/unmarkで複数Editorで選択されたメモの着色がおかしかったのを修正
・ Editorに読み込まれているメモには赤(Editor1)、青(Editor2)、黄色(Editor3)で着色した
・ 選択アイテムの背景色は変更しないことにし、フォントを黒ボールドにした
・ Panelに読み込まれているResourceは赤(Shelf)、青(Index)で着色した
・ LibraryカーソルとShelf選択を連動させていたのをやめた。
　Alt + Space → Shelf用に選択(invoke)
　Alt + Shift + Space → Index用に選択(activate)
・ 強制保存（Ctrl+S）を設定した
[Googleh:こんいちわ]

[2022-04-01] 
→  [2022-04-01] Monitor は Index に変更
　Monitor → Table、Overview
　Index, Title, Name, Items, 
　Rack, Table

[2022-03-30] 
・ Command選択Menuが異常
　→ いろいろあったが、AutoGenerateColumns="False" は２箇所設定するところがあったのをみおとしていた。
・ Command選択Shelfも異常
　→ selected_indexの返値を配列にしていたのを忘れていた
・ Status設定をresponsiveにするのをやめた
・ TTStatusかたTTTaskを、TTTaskからTTStatusを、TTSusModModeからTTStateをなくし、依存関係をなくした。

[2022-03-25] 
・ Status変更を即時反映

[2022-03-22] 
・ clipboard は クラス化
　→  クラス化した

[2022-03-21] 
・ セクション記号挿入、行頭記号挿入を view(DocMan)からcontrol(desk)に移した。
・ 行頭記号挿入に、逆向き、もできるように変更
・  [2022-02-27] GridViewからみ
　Seach/検索のModelが、thinktank.mdからの読込分を落としてしまう。　
　多分、thinktank.mdが更新されるとchacheが更新されてしまう。
　→ 現状問題ないけど、たまにおかしいような気もするな、　文字コードがらみだったのではないだろうか 
・ DataGridにItemsSourcesにないPeorpertyの列を創る
　→ このあたりはAutoで列を創らないようにしてから、制御できてる
・ LibraryKeywordのHightをShelfKeywordのHeightと同じにする
　→ xaml内のbindingで解決済み

[2022-03-16] 
・ shelfで既編集中アイテムを選択した際は、強制でcurrent editorに読み込むのではなく、編集Editorへフォーカス移動する
→ できた

[2022-03-16] 
・ 起動時に更新日・降順ソートでMemoを表示する
→ できた

[2022-03-07] 
・　ソートがおかしい。Headerクリックは動くけど、F1/F2/F3...が1回目だけ動いていその後動かなくなる。
・　Monitorでkeyword入力するとソートができなくなってしまう　→　これ全部共通だわさ
　→問題なくなった

・　別ライブラリを選択を選択したときの挙動  
　→DataGridの自動カラム作成をFalseにして手動設定にしたら治った。


[2022-02-27]  変更  
　→Windows側の変更で"Start-Process url" でurlが開かなくなったので、開くように変更

・　メモがutfで保存されていないっぽい
 　→　utf-8を指定するようにしたら、thinktank.mdの文字化けも治った。

・　Shelfでkeyword入力するとEditor/編集カラムが消えてしまう
　→　この問題は、DataGridに変更して、Editorカラムはなくして、対応できている

[2020-02-23]
・Ctrl + Tab で editor選択
　→　できた
・Alt + 1/2/3 で Editor1/2/3 に フォーカスするのが、2画面以上のときにおかしい。
　→　修正済み
・コマンド選択できるようにしないと、debugもできない
　→　ちょっとやっつけだができた

[2022-02-20] 
・DataGridの右端カラムを広げる
　→Width="*"設定した

・DataGridで編集できないようにする
　→Editモードにはなるが編集はできない。　コピーするためにそのままにしておく

・Ctrl+Tab, Ctrl,Shift+TabでEditorを変更できるようにする
　→対応した、　巡回するup+/down+を設定

・ShelfのDataGridでは、カーソルはカレントメモを指し示すこととし、残りの２つは薄く着色する。

・PopupMenuで、カーソル移動を「上下あり」と「巡回」を選べるようにして、Editor選択は巡回にしたい。
　→対応した、　up/downに加えて、巡回するup+/down+を設定

[2021-11-16] テキストペースト時（encode, decode）、urlペースト時（decode）
　 urlエンコード

[2021-11-16] TreeViewの選択項目、カラムヘッダーの色を変更できた
　XAMLの使い方を少し理解
　TreeViewの選択項目の背景色をグラデーションではなてPlainにしたい

[2021-11-14] 変数名等中心にリファクタリング
　CollectionAreaのTreeViewをListViewに変更
　
[2021-11-12]  miniメニュー
　modキーそのままで連打するとメニューが変更される。
　タイトル付けた
　デフォルト行頭に@
　miniメニューをCaret位置に表示

[2021-11-10] カーソル位置とスクロール
　改行後、カーソル下げずにスクロールアップ
　カーソル位置固定のままスクロール 

[2021-11-10] Editing collectionを導入、エディタの状態を保管する
　テキスト保存時に、カーソル位置・表示位置・表示アウトラインも保存する

[2021-11-08] コマンドライン引数の廃止　thinktank.md内で記載
  コレクションの設定をthinktank.ps1に移動

[2021-11-07] Outlookアイテムのコピー＆ペースト

[2021-11-07] メールタグによる、Outlookメール表示＆メール検索
　・ メール：　ttt_command_action_of_mail
  タグアクション　⇒メール開く、

[2021-11-06] TTConfigsを実装

[2021-11-03] 自作ポップアップメニューによる日時入力

[2021-11-01] アウトライン開閉コマンドを「自分ノード開閉」の次に「兄弟ノード開閉」に進むように変更した。
　thinktank_command_edit_fold_section / thinktank_command_edit_collapse_section
  PgUp,PgDnキーに全開閉をアサインしたがPC毎にキー配置が異なるため、開閉コマンドとまとめた

[2021-11-01] ExternalLinksを実装

[2021-10-29] メモリンクを実装

[2021-10-27] 編集後の自動遅延保存、アイテムの遅延フィルターを実装できた。

[2021-10-19] [ICSharpCode.AvalonEdit.Document.TextDocument]をEditor.DocumentにBindできた。

[2021-10-09] [psobject[]]からアイテム選択する機能を実装（TTSelect_SelectItems）

[2021-10-08] Thinktank, Thinktank, TTItems, TTEditView, TTSelect をクラスで管理するのを止め、グローバル変数で管理する方式に戻した。
　クラスのstatic関数/変数を使って名前空間管理していたが、
　1) VSCodeでのDebug時にスクリプト変更が反映されていないことが多発したため。
　2) 上記方法がネットで見つからない。　moduleを使った方法であれば見つかる。

# 優先度低い　　　
## OCR
 installが必要っぽい
 OCR https://codezine.jp/article/detail/10748?p=3
 [Route:苫小牧市][GoogleMap:苫小牧]
 [Route:苫小牧市,旭川市]
 [Route:苫小牧市,千歳市,札幌市,富良野市,旭川市]
 
 
 

# かんがえまとめ
## 運用
### MemoItemPanelの運用
MouseOver
Selected
Targetted　⇒　新たに作る
　編集対象Item、選択されると色が変わる
https://yoitaka.hatenablog.jp/entry/2016/11/28/144339
https://stackoverflow-com.translate.goog/questions/39379290/avalonedit-scroll-to-line?_x_tr_sl=en&_x_tr_tl=ja&_x_tr_hl=ja&_x_tr_pto=nui,sc

### Edit/View panelの運用
#### 3パネル同一メモモード
　初期状態　　編集作業している間はこのモード

#### サイドパネル参照モード
　メモタグクリックした時にサイドパネルにタグのメモ表示（リンク参照）
　　サイドパネルでのタグクリックはサイドパネルのメモ表示が更新
　Memo/Itemでのカーソル移動したときにサイドパネルにカーソル位置のメモ表示（一覧参照）
　urlリンクもサイドパネルで表示

#### ボトムパネル
①　ブラウザで機能パネルにする
　　辞書、Wikipedia
②　Terminalを表示できるようにする
③　エディタの上下分割用


## 毎時ファイル読み込み方式
カーソル位置、選択状態、表示位置、アウトライン開閉状態、が維持される必要がある
３画面とも、
同じファイルを３画面で表示し、各々でカーソル位置が異なる場合、どの画面のものを採用するか？
→カーソル位置キャッシュ
　ファイル名
　更新日
　行:桁
　表示エディター
　選択フラグ
　選択終了行:選択終了桁
　アウトライン展開行(CSV)


## Tab方式
異なるファイルを横並び、縦並びにする運用の際のタブ管理が
分割表示とTabは相性が悪い

# 知ったこと、わかったこと
## DataGridの理解、
DataGrid.Items は 設定された object[] のシャローコピーなので、代入時にはリンクだけコピーされて、中身の参照先は元のobject[]。
なので、Item内容の変更に関しては.Items.Refresh() で更新されるけど、Item自体が削除されたり上書きされたりすると、Refreshで更新されなくなる（リンクさきが変わってしまうため、）

## VSCode
Ctrl+K Ctrl+S       ショートカット設定
Alt V A             表示 > 外観
                    エディタを移る
Ctrl+K Ctrl+8       すべて折り畳む
Ctrl+K Ctrl+9       すべて展開
Ctrl+K Ctrl+(数字)  レベル(数字)で折り畳む
Ctrl+K Ctrl+_       選択以外折り畳む
Ctrl+K Ctrl+:       選択以外展開

## WPFの仕様
### 【WPF】よくわかるTimer処理（一定時間間隔イベント）
https://resanaplaza.com/%E3%80%90wpf%E3%80%91%E3%82%88%E3%81%8F%E3%82%8F%E3%81%8B%E3%82%8Btimer%E5%87%A6%E7%90%86%EF%BC%88%E4%B8%80%E5%AE%9A%E6%99%82%E9%96%93%E9%96%93%E9%9A%94%E3%82%A4%E3%83%99%E3%83%B3%E3%83%88%EF%BC%89/

## powershellの動作
### 単体実行の方法
先頭に
function test_thinktank_collection {}

最後に
if( $pwd -like "*script*"){ test_thinktank_collection }
## powershellのクラス
### クラスのstatic関数はAdd_xxxでイベントにアサインできた

# 勉強
## powershellでWPF
・ [WPF] XAMLでの文字列のフォーマット指定とバインディング
　https://qiita.com/koara-local/items/815eb5146b3ddc48a8c3

・ PowerShellでWPFを使う
　https://qiita.com/potimarimo/items/1eca0516bd8c690872dc
　データバインド：　PSCustomObjectでBindする例、PSのクラスでBindする例
　INotifyPropertyChanged：　ExpandoObjectでデータバインドを使ったデータの連携ができます。
　INotifyCollectionChanged：　スクリプト内でObservableCollectionを使って普通に実装可能
　INotifyPropertyChanged：　C#を使って実装　

・ WPFデータバインドの基礎知識まとめ　C#用
　http://blog.livedoor.jp/morituri/archives/54652766.html#54652766-h1-notifychange
　コードでデータバインディング

・ PowerShell で WPF
　http://harebare01.blogspot.com/



## WPF入門 https://atmarkit.itmedia.co.jp/ait/articles/1005/14/news105.html
### 第2回
・ WPFとXAMLの関係性
XAMLは、CLRオブジェクト(インスタンス)を生成するマークアップ言語

・ ユーザー定義クラスのインスタンス生成例
ユーザー定義のPointクラス（＝CLRオブジェクト）はXAMLコードにシリアライズ可能
    Dim x = New Sample.Point With {.X = 1, .Y = 2}
    Using stream = File.Open("test.xaml", FileMode.Create)
      XamlWriter.Save(x, stream)
    End Using

    <Point X="1" Y="2" xmlns="clr-namespace:Sample;assembly=SampleLibrary" />

・ プロパティ要素構文
    <Button Background="Blue" />

    <Button>
        <Button.Background>Blue</Button.Background >
    </Button>

### 第4回　WPFの「リソース、スタイル、テンプレート」を習得しよう
https://atmarkit.itmedia.co.jp/ait/articles/1009/07/news096.html

・ リソース
 　外部リソースの取り込み：　<Windows.Resources>タグ
 　システム・リソース：　
 
・ スタイル：
　HTMLでいうところのCSSのようなスタイル設定の機構
    <Style TargetType="Button">
        <Setter Property="Background" Value="DarkSeaGreen" />
        <Setter Property="Foreground" Value="LightPink" />
    </Style>

・ トリガー：　特定の条件下でのみ働くスタイル

・ コントロール・テンプレート:  「ボタンのクリック」などの機能を残したまま、外観だけを任意に変更可能

### 第5回　WPFの「データ・バインディング」を理解する
https://atmarkit.itmedia.co.jp/ait/articles/1010/08/news123.html

・ バインディング・ソース
特に何も指定しない場合、バインディング・ソースは、UI要素のDataContextプロパティに与えられたオブジェクト

・ 値の返還
　Bindingマークアップ拡張のConverterプロパティに
　IValueConverterインターフェイス（System.Windows.Data名前空間）を実装するクラスを渡す。

　C#を内包する方法で
　https://stackoverflow.com/questions/14281671/how-to-use-ivalueconverter-from-powershell
　http://harebare01.blogspot.com/



# VSCode 
Ctrl+K Ctrl+S       ショートカット設定  
Alt V A             表示 > 外観           
                    エディタを移る   ;
Ctrl+K Ctrl+8       すべて折り畳む 
Ctrl+K Ctrl+9       すべて展開  
Ctrl+K Ctrl+(数字)  レベル(数字)で折り畳む   
Ctrl+K Ctrl+_       選択以外折り畳む  
Ctrl+K Ctrl+:       選択以外展開


Ctrl+1              グループ１
Ctrl+2              グループ２_
Alt+F3              次の変更箇所 
Alt+Shift+F3        前の変更箇所
前の変更箇所


 


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
Thinktank:設定:OutlookBackupFolder, 					引用メールの保存先フォルダ, 個人用フォルダ (2019-01-)
Thinktank:設定:PhotoFolder,						写真フォルダ, 個人用フォルダ (2019-01-)
Thinktank:設定:PDFFolder, 							PDFフォルダ, 個人用フォルダ (2019-01-)
Thinktank:設定:CaptureFolder, 						クリップボード画像の保存先フォルダ, MyPicture
Thinktank:設定:CaptureFolder, 						メモフォルダ, MyPictures
Thinktank:設定@LAPTOP-5FOVA1SU:OutlookBackupFolder,		引用メールの保存先フォルダ, 個人用フォルダ (2019-01-)
Thinktank:設定@LAPTOP-5FOVA1SU:PhotoFolder,			写真フォルダ, C:\Users\shin\Pictures\thinktank
Thinktank:設定@LAPTOP-5FOVA1SU:MemoFolder, 			メモフォルダ, C:\Users\shin\Documents\Thinktank
Thinktank:設定@HPH1N0299:MemoFolder, 				メモフォルダ, C:\TEMP\Remote\Thinktank\original.txt
Thinktank:設定@HPH1N0299:OutlookBackupFolder, 			引用メールの保存先フォルダ, 個人用フォルダ (2021-02-)
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
Thinktank:検索:グーグル検索 [Google], http://www.google.co.jp/search?q=[param], Google:Japan
Thinktank:検索:グーグル検索（英） [GoogleE], http://www.google.co.jp/search?q=[param]&lr=lang_en, Google:English
Thinktank:検索:グーグル英訳 [GoogleJE], https://translate.google.com/?hl=ja#view=home&op=translate&sl=ja&tl=en&text=[param], Google:JE
Thinktank:検索:グーグル和訳 [GoogleEJ], https://translate.google.com/?hl=ja#view=home&op=translate&sl=en&tl=ja&text=[param], Google:EJ
Thinktank:検索:グーグル中訳 [GoogleJC], https://translate.google.com/?hl=ja#view=home&op=translate&sl=ja&tl=zh-CN&text=[param], Google:JC
Thinktank:検索:グーグルマップ検索 [GoogleMap], https://www.google.co.jp/maps/place/[param], Google:Map:Japan
Thinktank:検索:グーグルスカラー [GScholar], https://scholar.google.co.jp/scholar?q=[param], Google:Scholar
Thinktank:検索:Youtube [Youtube], https://www.youtube.com/results?search_query=[param], Youtube
Thinktank:検索:Pubmed検索 [Pubmed], https://pubmed.ncbi.nlm.nih.gov/?term=[param], Science:Clinical:Pubmed
Thinktank:検索:Yahoo検索 [Yahoo], https://search.yahoo.co.jp/search?p=[param], Yahoo:Japan
Thinktank:検索:国立保健医療科学院 [NIPH], https://rctportal.niph.go.jp/s/result?q=[param]&t=chiken, Clinical:Trials:NIPH
Thinktank:検索:ClinicalTrials.gov [CTG], https://clinicaltrials.gov/ct2/results?cond=[param]&term=&cntry=&state=&city=&dist=, Clinical:Trials:CTG
Thinktank:検索:コルテリス [Cortellis], https://www.cortellis.com/intelligence/qsearch/[param]?indexBased=true&searchCategory=ALL, Clinical:Database:Cortellis
Thinktank:検索:医薬品医療機器総合機構 [PMDA], https://ss.pmda.go.jp/ja_all/search.x?q=[param]&ie=UTF-8&page=1, Clinical:Database:PMDA
Thinktank:検索:日本学術振興会 科研費 [KAKEN], https://kaken.nii.ac.jp/ja/search/?kw=[param], Clinical:Database:KAKEN
Thinktank:検索:欧州医薬品庁 [EMA], https://www.clinicaltrialsregister.eu/ctr-search/search?query=[param], Clinical:Trials:EMA
Thinktank:検索:科学技術振興機構 [JST], https://www.jstage.jst.go.jp/result/global/-char/ja?globalSearchKey=[param], Clinical:Database:JStage
Thinktank:検索:PubMed Central [PMC], https://www.ncbi.nlm.nih.gov/pmc/?term=[param], Clinical:Database:PMC
Thinktank:検索:厚生労働省 [MHLW], https://www.mhlw.go.jp/search.html?q=[param], Clinical:Database:MHLW
Thinktank:検索:厚労省科研DB [MHLWG], https://mhlw-grants.niph.go.jp/search?kywd=[param], Clinical:Database:MHLWGrants
Thinktank:検索:Spotify [Spotify], https://open.spotify.com/search/[param], Music:Spotify
Thinktank:検索:ウィキペディア [Wikipedia], https://ja.wikipedia.org/wiki/[param], Wikipedia:Japan
Thinktank:検索:ウィキペディア（英） [WikipediaE], https://en.wikipedia.org/wiki/[param], Wikipedia:English
Thinktank:検索:.NET API Browser [NET], https://docs.microsoft.com/ja-jp/dotnet/api/?view=net-5.0&term=[param], Program:Microsoft:.NET :API
Thinktank:検索:Outlook, https://docs.microsoft.com/ja-jp/search/?search=[param]&category=outlook, Program:Microsoft:Outlook:VBA
Thinktank:検索:Excel, https://docs.microsoft.com/ja-jp/search/?search=[param]&category=excel, Program:Microsoft:Excel:VBA
Thinktank:検索:Word, https://docs.microsoft.com/ja-jp/search/?search=[param]&category=word, Program:Microsoft:Word:VBA
Thinktank:検索:Object, https://docs.microsoft.com/ja-jp/search/?search=[param]&category=objects-visual-basic-for-applications, Program:Microsoft:Object:VBA

# 履歴
Thinktank:設定:Application.Author,      制作者, Shinihciro Egashira
Thinktank:設定:Application.UpdateDate,  更新日, 2022/05/22 16:28
Thinktank:設定:Application.Version,     バージョン, 0.1.102
Thinktank:設定:Application.Content,     [TTPopupMenu] を tool化他

## 内容
0.1.102  2022/05/22 16:28  [TTPopupMenu] を tool化他
- モデルclass を機能別（本体/Display/Action）に再構築
- 　本体：　リソース管理関連
- 　Display：　DataGrid/Menuへの表示設定
- 　Action：　外部から呼び出されるアクション
- [TTPopupMenu] を tool化
0.1.101                    TTAppManagerをstatic class化を解除、$script:AppMan導入
0.1.100                    バージョン履歴を付加

