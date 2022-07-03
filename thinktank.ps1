









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

#region system folder セットアップ 
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

#region timer セットアップ 
#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
$global:TTTimerExpiredMessage = $false
$global:TTTimerResistMessage = $false
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

#region KeyEvents/EventKeys セットアップ 
#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
$global:TTKeyEvents = @{}
$global:TTEventKeys = @{}

$keybinds = ( @(  
    $global:KeyBind_Application,    $global:KeyBind_Cabinet,    $global:KeyBind_Library, 
    $global:KeyBind_Index,          $global:KeyBind_Shelf,      $global:KeyBind_Misc, 
    $global:KeyBind_Desk,           $global:KeyBind_Editor,     $global:KeyBind_PopupMenu  ) -join "`n" )
$keybinds.split("`n").foreach{
    if( $_ -match "(?<mode>[^ ]+)\s{2,}(?<mod>[^ ]+( [^ ]+)?)\s{2,}(?<keyname>[^ ]+)\s{2,}(?<command>[^\s]+)\s*" ){
        $global:TTKeyEvents[$Matches.mode] += @{}
        $global:TTKeyEvents[$Matches.mode][$Matches.mod] += @{}
        $global:TTKeyEvents[$Matches.mode][$Matches.mod][$Matches.keyname] = $Matches.command
        $global:TTEventKeys[$Matches.command] += @()
        $global:TTEventKeys[$Matches.command] += @( @{ Mode = $Matches.mode; Key = "[$($Matches.mod)]$($Matches.key)" } )
    }
}
#endregion###############################################################################################################

#region 本体
#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
#　View
$global:AppMan =        [TTAppManager]::new()

#　Model
$global:TTResources =   [TTResources]::new().Initialize()

#　Control
$global:datetag =       [TTTagFormat]::new()
$global:appcon =        [TTApplicationController]::new()

$global:AppMan.Show()

#endregion###############################################################################################################

