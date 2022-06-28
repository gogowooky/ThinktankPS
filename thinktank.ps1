

#region　履歴
<#
実:  実装のみ
確:  動作確認済み
未:  未着手

[2202/06/20 22:16]
  Alt,Shift+S:（フォーカス＋表示スタイル変更）
  Alt+S:（表示・消去トグル）　Alt+L/I/S/D/C    
  フォーカス無しチラ見
  Panelモード

[2202/06/19 18:25]
確: *.FocusはFocus eventで書き換える
    *.Focus             値

    Focus.Panel         Library/Index/Shelf/Desk/Cabinaet
    Focus.Application   Focus.Panel + Focus.Tool
    Focus.Workspace     Work(123)
    Work(123).Tool      Editor/Browser/Grid
    Focus.Tool          Editor(123)/Browser(123)/Grid(123)

    未: ttcmd_tool_focus_work_single_toggleエラー
未: ttcmd_panel_focus_desk_and_work: DeskとWorkが切り替わらない
実: FloatPanel表示しても、"FloatPanel.*" のStatusが設定されない。
    設定されてるけどDataGridのデータとして更新されていない感じ
    おそらく、新規にStatus.Add()された後のCollection⇒DataGridのアイテム移行ができていない
    [TTGroupController] reload() ⇒ ttcmd_panel_reload() を設置
    
[2202/06/16 7:54]
確: FloatPanel表示直後にSortのAlertが出るのを消したい
    [TTPanelManager]::DisplayAlert を設置。　[TTGroupController] resource内で一時的にAlert表示不可に設定

確: TTGroupController :: [bool] float()
    確: 表示前に現フォーカスを退避、表示後に戻す
    確: 違う場所に戻る
    確: 戻るが●が表示されない
    　治ってるし、●も表示される。

確: 起動直後にフォーカスがない
    　治ってる。

確: FloatPanel表示中はMainWindowは触れないようにしたい
    TTFloatPanelManager :: [object[]] Show()
    　Dispatcher.Invoke()でShowDialog()するとモードレスになってしまう。
    　直接呼び出すように変更

確: [TTFloatPanelManager] Title()
    確: FloatPanel表示後textboxにフォーカス移動
    確: FloatPanel表示直後に●表示されるが、すぐに消えてしまう。
        [TTPanelManager] Alert()アラート表示～テキスト戻す、までに変更があれば、テキストは戻さない、ように変更

#>
#endregion###############################################################################################################









#region　外部読み込み
#########################################################################################################################
using namespace System.Windows 
using namespace System.Windows.Controls
using namespace System.Windows.Documents
using namespace System.IO
using namespace System.Xml
using namespace System.Data
using namespace System.Dynamic
using namespace System.Drawing
using namespace ICSharpCode.avalonEdit
using namespace System.Text.RegularExpressions

#　external library
#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, System.Drawing, System.Xml.ReaderWriter, System.Text.RegularExpressions, System.Web
. .\script\avalon-editor.ps1            #  ICSharpCode.AvalonEdit.dll の読み込み

#　external script
#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
. .\script\thinktank-tool.ps1           #  支援
. .\script\thinktank-view.ps1           #  .NET Framework（UI出力）
. .\script\thinktank-model.ps1          #　データ管理クラス
. .\script\thinktank-control.ps1        #　データ-UI連携
. .\script\thinktank-event.ps1          #  .NET Framework（UI入力）
. .\script\thinktank-command.ps1        #　コマンド

#endregion###############################################################################################################

#region system folder setup 
#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
$global:TTRootDirPath =     $PSScriptRoot
$global:TTScriptDirPath =   $global:TTRootDirPath + "\script"
$global:TTMemoDirPath =     $global:TTRootDirPath + "\text"
$lines = @(
    Get-ChildItem -Path "$global:TTRootDirPath\thinktank.md" | `
    Select-String "^Thinktank:設定@?(?<pcname>.*)?:MemoFolder" | `
    Select-Object -Property Filename, LineNumber, Matches, Line
)
foreach ( $line in $lines ) {
    [void]( $line.Line -match "Thinktank:設定(@(?<pcname>[^:]+)\s*)?:MemoFolder,\s*(?<description>[^,]+)\s*,\s*(?<value>[^,]+)\s*" )
    if ( $null -eq $Matches.pcname ) {
        $global:TTMemoDirPath = $Matches.value
    }else{
        if ( $Env:COMPUTERNAME -eq $Matches.pcname ) { 
            $global:TTMemoDirPath = $Matches.value
            break
        }
    }
}

[void]( $myInvocation.MyCommand.Name -match 'thinktank(?<num>.?)\.ps1' )
$global:TTCacheDirPath = "$($global:TTMemoDirPath)\cache" + $Matches.num
$global:TTBackupDirPath = "$($global:TTMemoDirPath)\backup"
[void]( New-Item $global:TTMemoDirPath -ItemType Directory -Force )
[void]( New-Item $global:TTCacheDirPath -ItemType Directory -Force )
[void]( New-Item $global:TTBackupDirPath -ItemType Directory -Force )

#endregion###############################################################################################################

#region timer setup 
#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
$global:TTTimerExpiredMessage = $true
$global:TTTimerResistMessage = $true
$global:TTTimerRunDirect = $false
$global:tt_mutex = $false
$global:tt_tasks = @{}
$global:tt_timer = [System.Windows.Threading.DispatcherTimer]::new()
$global:tt_timer.interval = [System.TimeSpan]::new( 0, 0, 0, 1 ) # countdown for every 1sec
$global:tt_timer.add_tick({
    if( $global:tt_mutex -eq $false){
        $global:tt_mutex = $true

        $keys = $global:tt_tasks.keys.where{
            $global:tt_tasks[$_].countdown -= 1
            $global:tt_tasks[$_].countdown -le 0

        }.where{
            & $($global:tt_tasks[$_].script)
            $global:tt_tasks[$_].countdown = $global:tt_tasks[$_].rewind
            $global:tt_tasks[$_].countdown -le 0

        }
        $keys.foreach{
            $global:tt_tasks.Remove( $_ )
            if( $global:TTTimerExpiredMessage ){ [TTTool]::debug_message( $_, "task expired") }
        }
    }
    $global:tt_mutex = $false
})
$global:tt_timer.Start()
function TTTimerResistEvent( [string]$name, [long]$countdown, [long]$rewind, [ScriptBlock]$script ){
    if( $global:TTTimerRunDirect ){ &$script; return  }
        
    if( $global:tt_tasks.Contains( $name ) ){ return }

    $global:tt_mutex = $true
    if( $global:TTTimerResistMessage ){ [TTTool]::debug_message( "Task.Register", $name ) }
    $global:tt_tasks[$name] = @{ 
        countdown = $countdown
        rewind = $rewind
        script = $script
    }
    $global:tt_mutex = $false

}
#endregion###############################################################################################################

#　View
$global:AppMan =        [TTAppManager]::new()

#　Model
$global:TTResources =   [TTResources]::new().Initialize()

#　Control
$global:datetag =       [TTTagFormat]::new()
$global:appcon =        [TTApplicationController]::new()

$global:AppMan.Show()

