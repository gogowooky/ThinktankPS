




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
. .\script\thinktank-view.ps1           #  .NET Framework（UI出力）
. .\script\thinktank-model.ps1          #　データ管理クラス
. .\script\thinktank-control.ps1        #　データ-UI連携
. .\script\thinktank-command.ps1        #　コマンド

#endregion###############################################################################################################

#region　[TOOL]
#########################################################################################################################
[TTTask]::Initialize()
[TTSusModMode]::Initialize()
#endregion###############################################################################################g################

#region　[MODEL]
#########################################################################################################################
$script:TTScriptName = $myInvocation.MyCommand.Name

$script:TTResources = [TTResources]::new()
$script:TTConfigs   = [TTConfigs]::new()
$script:TTStatus    = [TTStatus]::new()
$script:TTCommands  = [TTCommands]::new()
$script:TTSearchs   = [TTSearchMethods]::new()
$script:TTLinks     = [TTExternalLinks]::new()
$script:TTMemos     = [TTMemos]::new()
$script:TTEditings  = [TTEditings]::new()

$script:TTResources.Initialize()
$script:TTResources.AddChild( $script:TTConfigs )
$script:TTResources.AddChild( $script:TTStatus )
$script:TTResources.AddChild( $script:TTCommands )
$script:TTResources.AddChild( $script:TTSearchs )
$script:TTResources.AddChild( $script:TTLinks )
$script:TTResources.AddChild( $script:TTMemos )
$script:TTResources.AddChild( $script:TTEditings )
# $script:TTResources.AddChildren( 'ExMemo' )

#endregion###############################################################################################################

#region  [VIEW]
#########################################################################################################################
$script:DocMan      = [TTDocumentManager]::new()

[TTWindowManager]::Initialize()

$script:Editor1         = [TTWindowManager]::FindName("Editor1")
$script:Editor2         = [TTWindowManager]::FindName("Editor2")
$script:Editor3         = [TTWindowManager]::FindName("Editor3")
$script:Browser1        = [TTWindowManager]::FindName("Browser1")
$script:Browser2        = [TTWindowManager]::FindName("Browser2")
$script:Browser3        = [TTWindowManager]::FindName("Browser3")
$script:Grid1           = [TTWindowManager]::FindName("Grid1")
$script:Grid2           = [TTWindowManager]::FindName("Grid2")
$script:Grid3           = [TTWindowManager]::FindName("Grid3")
$script:Work1           = [TTWindowManager]::FindName("Work1")
$script:Work2           = [TTWindowManager]::FindName("Work2")
$script:Work3           = [TTWindowManager]::FindName("Work3")
$script:ThinktankGrid   = [TTWindowManager]::FindName('Thinktank')
$script:GuideGrid       = [TTWindowManager]::FindName('Guide')
$script:WorkplaceGrid   = [TTWindowManager]::FindName('Workplace')
$script:LRDivdDeskGrid  = [TTWindowManager]::FindName('LRDivdDeskGrid')
$script:ULDivdDeskGrid  = [TTWindowManager]::FindName('ULDivdDeskGrid')

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


[TTWindowManager]::Show()
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

