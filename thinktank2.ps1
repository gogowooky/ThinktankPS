




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
. .\script\thinktank-event.ps1          #  .NET Framework（UI入力）
. .\script\thinktank-view2.ps1           #  .NET Framework（UI出力）
. .\script\thinktank-model2.ps1          #　データ管理クラス
. .\script\thinktank-control2.ps1        #　データ-UI連携
. .\script\thinktank-command.ps1        #　コマンド

#endregion###############################################################################################################

#region initialize folder 
#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
$script:TTRootDirPath =     $PSScriptRoot
$script:TTScriptDirPath =   $script:TTRootDirPath + "\script"
$script:TTMemoDirPath =     $script:TTRootDirPath + "\text"
$lines = @(
    Get-ChildItem -Path "$script:TTRootDirPath\thinktank.md" | `
    Select-String "^Thinktank:設定@?(?<pcname>.*)?:MemoFolder" | `
    Select-Object -Property Filename, LineNumber, Matches, Line
)
foreach ( $line in $lines ) {
    [void]( $line.Line -match "Thinktank:設定(@(?<pcname>[^:]+)\s*)?:MemoFolder,\s*(?<description>[^,]+)\s*,\s*(?<value>[^,]+)\s*" )
    if ( $null -eq $Matches.pcname ) {
        $script:TTMemoDirPath = $Matches.value
    }else{
        if ( $Env:COMPUTERNAME -eq $Matches.pcname ) { 
            $script:TTMemoDirPath = $Matches.value
            break
        }
    }
}

[void]( $myInvocation.MyCommand.Name -match 'thinktank(?<num>.?)\.ps1' )
$script:TTCacheDirPath = "$($script:TTMemoDirPath)\cache" + $Matches.num
$script:TTBackupDirPath = "$($script:TTMemoDirPath)\backup"
[void]( New-Item $script:TTMemoDirPath -ItemType Directory -Force )
[void]( New-Item $script:TTCacheDirPath -ItemType Directory -Force )
[void]( New-Item $script:TTBackupDirPath -ItemType Directory -Force )
#endregion###############################################################################################################
# [TTPopupMenu]::Show( @("ega","yoko","@shin"), "てすと" )
# [TTPopupMenu]::Initialize().items( @("ega","yoko","@shin") ).title( "てすと" ).show()


#region　[TOOL]
#########################################################################################################################
[TTTask]::Initialize()
[TTSusModMode]::Initialize()
#endregion###############################################################################################g################

#region　[MODEL]
#########################################################################################################################
$script:TTResources = [TTResources]::new()
$script:TTResources.Initialize()
$script:TTResources.AddChild( [TTConfigs]::new() )
$script:TTResources.AddChild( [TTStatus]::new())
$script:TTResources.AddChild( [TTCommands]::new() )
$script:TTResources.AddChild( [TTSearchMethods]::new() )
$script:TTResources.AddChild( [TTExternalLinks]::new() )
$script:TTResources.AddChild( [TTMemos]::new() )
$script:TTResources.AddChild( [TTEditings]::new() )
$script:TTResources.InitializeChildren()

#endregion###############################################################################################################

#region  [VIEW]
#########################################################################################################################
$script:AppMan =        [TTAppManager]::new()

$script:LibraryMan =    [TTLibraryManager]::new()
$script:IndexMan =      [TTIndexManager]::new()
$script:ShelfMan =      [TTShelfManager]::new()
$script:DeskMan =       [TTDeskManager]::new()
$script:DocMan =        [TTDocumentManager]::new()


$script:Editor1         = $script:AppMan.FindName("Editor1")
$script:Editor2         = $script:AppMan.FindName("Editor2")
$script:Editor3         = $script:AppMan.FindName("Editor3")
$script:Browser1        = $script:AppMan.FindName("Browser1")
$script:Browser2        = $script:AppMan.FindName("Browser2")
$script:Browser3        = $script:AppMan.FindName("Browser3")
$script:Grid1           = $script:AppMan.FindName("Grid1")
$script:Grid2           = $script:AppMan.FindName("Grid2")
$script:Grid3           = $script:AppMan.FindName("Grid3")
$script:Work1           = $script:AppMan.FindName("Work1")
$script:Work2           = $script:AppMan.FindName("Work2")
$script:Work3           = $script:AppMan.FindName("Work3")

$script:Editors     = @( $script:Editor1, $script:Editor2, $script:Editor3 )
$script:Browsers    = @( $script:Browser1, $script:Browser2, $script:Browser3 )
$script:Grids       = @( $script:Grid1, $script:Grid2, $script:Grid3 )
$script:Works       = @( $script:Work1, $script:Work2, $script:Work3 )

$script:EditorIDs   = @( 'Editor1', 'Editor2', 'Editor3' )
$script:BrowserIDs  = @( 'Browser1', 'Browser2', 'Browser3' )
$script:GridIDs     = @( 'Grid1', 'Grid2', 'Grid3' )
$script:WorkIDs     = @( 'Work1', 'Work2', 'Work3' )
$script:Work1IDs    = @( 'Work1', 'Editor1', 'Browser1', 'Grid1' )
$script:Work2IDs    = @( 'Work2', 'Editor2', 'Browser2', 'Grid2' )
$script:Work3IDs    = @( 'Work3', 'Editor3', 'Browser3', 'Grid3' )

#endregion###############################################################################################################

#region  [CONTROL]
#########################################################################################################################
$script:datetag     = [TTTagFormat]::new()

$script:app         = [TTApplication]::new()
$script:library     = [TTLibrary]::new()
$script:index     = [TTIndex]::new()
$script:shelf       = [TTShelf]::new()
$script:desk        = [TTDesk]::new()

#endregion###############################################################################################################

#region  initialize(Model, Tool,) & start
#########################################################################################################################
$script:TTConfigs.Initialize()
$script:TTStatus.Initialize()
$script:TTCommands.Initialize()
$script:TTSearchs.Initialize()
$script:TTLinks.Initialize()
$script:TTMemos.Initialize()
$script:TTEditings.Initialize()






# $script:AppMan.Show()
#endregion###############################################################################################################

#region finalize
#########################################################################################################################
$script:datetag     = $null

$script:app         = $null
$script:library     = $null
$script:shelf       = $null
$script:desk        = $null


$script:TTStatus    = $null

$script:TTConfigs   = $null
$script:TTLinks     = $null
$script:TTCommands  = $null
$script:TTSearchs   = $null
$script:TTMemos     = $null
$script:TTEditings  = $null
$script:TTResources = $null
#endregion###############################################################################################################

