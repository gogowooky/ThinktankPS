



using namespace System.Windows.Documents
using namespace System.Windows.Controls
using namespace System.Windows



#region TTAppManager
#########################################################################################################################
class TTAppManager {
    #region variables
    [System.Windows.Window]$_window
    [Grid] $_grid_window_lr
    [Grid] $_grid_lpanel_ul
    [Grid] $_grid_rpanel_ul
    [Grid] $_grid_desk_lr
    [Grid] $_grid_desk_ul
    #endregion

    TTAppManager(){

        [xml]$xaml = Get-Content ( $script:TTScriptDirPath + "\thinktank.xaml" )
        $this._window = [System.Windows.Markup.XamlReader]::Load( (New-Object XmlNodeReader $xaml) )

        $this._window.Add_Loaded( $script:Window_Loaded )
        $this._window.Add_PreviewKeyDown( $script:Window_PreviewKeyDown )
        $this._window.Add_PreviewKeyUp( $script:Window_PreviewKeyUp )

        $this._grid_window_lr = $this.FindName('GridWindowLR')
        $this._grid_lpanel_ul = $this.FindName('GridLPanelUL')
        $this._grid_rpanel_ul = $this.FindName('GridRPanelUL')
        $this._grid_desk_lr =   $this.FindName('GridDeskLR')
        $this._grid_desk_ul =   $this.FindName('GridDeskUL')
    
    }
    [void] Window( [string]$state ){ # max / min / normal / close 
        switch( $state ){
            'max'    { $this._window.WindowState = [System.Windows.WindowState]::Maximized }
            'min'    { $this._window.WindowState = [System.Windows.WindowState]::Minimized }
            'normal' { $this._window.WindowState = [System.Windows.WindowState]::Normal }
            'close'  { $this._window.Close() }
        }
    }
    [void] Border( [string]$id, [int]$percent ){ 
        switch( $id ){
            'Layout.Guide.Width' {
                $this.grid_window_lr.ColumnDefinitions[0].Width = "$percent*"
                $this.grid_window_lr.ColumnDefinitions[1].Width = "$(100-$percent)*"
            }
            'Layout.Library.Height' {
                $this.grid_lpanel_ul.RowDefinitions[0].Height = "$percent*"
                $this.grid_lpanel_ul.RowDefinitions[1].Height = "$(100-$percent)*"
            }
            'Layout.Shelf.Height' {
                $this.grid_rpanel_ul.RowDefinitions[0].Height = "$percent*"
                $this.grid_rpanel_ul.RowDefinitions[1].Height = "$(100-$percent)*"
            }
            'Layout.Work1.Width' {
                $this.grid_desk_lr.ColumnDefinitions[0].Width = "$percent*"
                $this.grid_desk_lr.ColumnDefinitions[1].Width = "$(100-$percent)*"
            }
            'Layout.Work1.Height' {
                $this.grid_desk_ul.RowDefinitions[0].Height = "$percent*"
                $this.grid_desk_ul.RowDefinitions[1].Height = "$(100-$percent)*"
            }
        }
        $script:app._set( $id, [string]$percent )
    }
    [void] Show(){
        $this._window.ShowDialog()
    }
    [object] FindName( [string]$name ){
        return $this._window.FindName( $name )
    }

    [void] Top( [int] $num ){ $this._window.Top = $num }
    [int]  Top(){ return $this._window.Top }
    [void] Left( [int] $num ){ $this._window.Left = $num }
    [int]  Left(){ return $this._window.Left }
    [void]   Title( $text ){ $this._window.Title = $text }
    [string] Title(){ return $this._window.Title }

}
#endregion###############################################################################################################

#region TTPanelManager
#########################################################################################################################
class TTLibraryManager {
    [TTApplicationManager] $_app
    [string] $_name
    
    TTLibraryManager( [TTApplicationManager]$app ){

        $this._app = $app
        $this._name = "Library"
        $this._app.FindName("$($this._name)Items").AutoGenerateColumns = $false

    }
    [TTLibraryManager] Caption( $caption ){
        $this._app.FindName("$($this._name)Caption").Content = $caption
        return $this
    }
    [TTLibraryManager] Items( $items ){

    }
    [TTLibraryManager] Keyword( $keyword ){
        $this._app.FindName("$($this._name)Keyword").Text = $keyword
        return $this
    }
    [TTLibraryManager] Sorting( $sorting ){
        # 【引数】 sorting = @( @{ Titles = (CSV); Value = (ScriptBlock) },,, )

        $this._sorting.Items.Clear()

        if( $null -ne $this._collection.menus ){
            foreach( $menu in $this._collection.menus ){
                $items = $this._sorting.Items
                $keys = $menu.keys.split(",")
                foreach( $key in $keys ){
                    if( 0 -eq $items.where{ $_.Header -eq $key }.count ){
                        $item = [MenuItem]::New()
                        $item.Header = $key
                        if( $keys[-1] -eq $key ){ $item.Add_Click( $menu.value ) }
                        $items.Add($item)
                        $items = $item.Items

                    }else{
                        $items = $items.where{ $_.Header -eq $key }[0].Items
                    }
                }
            }
        }

        return $this

    }

}

# class TTLibraryManager : TTPanelManager {

# }

class TTIndexManager : TTPanelManager {
    
}

class TTShelfManager : TTPanelManager {
    
}

class TTDeskManager : TTPanelManager {
    
}

#endregion###############################################################################################################


#region　TTDocumentManager / DocMan
#########################################################################################################################
class TTDocumentManager{
    hidden [ICSharpCode.AvalonEdit.Document.TextDocument[]]$documents = @()
    hidden [psobject]$config = @{}
    hidden [ICSharpCode.AvalonEdit.TextEditor]$current_editor
    hidden [object]$current_browser
    hidden [object]$current_grid
    hidden [int]$offset
    hidden [string]$target_tool

    #region エディタ動作
    #'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    [TTDocumentManager] Initialize(){
        # documents
        (1..3).foreach{
            $doc = [ICSharpCode.AvalonEdit.Document.TextDocument]::new()
            $doc.FileName = ""
            $this.documents += $doc 
        }

        # config
            $this.config = @{
            Editor1 = @{ index = ""; foldman = $null; foldstgy = $null; editor = $script:Editor1; hlrules = @(); history = new-object string[] 100; hispos = -1 }
            Editor2 = @{ index = ""; foldman = $null; foldstgy = $null; editor = $script:Editor2; hlrules = @(); history = new-object string[] 100; hispos = -1 }
            Editor3 = @{ index = ""; foldman = $null; foldstgy = $null; editor = $script:Editor3; hlrules = @(); history = new-object string[] 100; hispos = -1 }
            Browser1 = @{ url = ""; browser = $script:Browser1 }
            Browser2 = @{ url = ""; browser = $script:Browser2 }
            Browser3 = @{ url = ""; browser = $script:Browser3 }
            Grid1 = @{ gindex = ""; grid = $script:Grid1 }
            Grid2 = @{ gindex = ""; grid = $script:Grid2 }
            Grid3 = @{ gindex = ""; grid = $script:Grid3 }
        }
        $this.config.Keys.foreach{
            $this.Tool( $_ ).ResetTool()
        }

        return $this
    }
    [TTDocumentManager] Tool( $_tool ){ # $DocMan.Tool( 指定 ).XXXX で動かす。　current_editorは数字無しの'Editor'指定
        switch -regex ( $_tool ){
            '^(Editor|Browser|Grid)[123]$' { $this.target_tool = $_tool; break }
            '^Editor$'    { $this.target_tool = $this.current_editor.Name; break }
            '^Browser$'   { $this.target_tool = $this.current_browser.Name; break }
            '^Grid$'      { $this.target_tool = $this.current_grid.Name; break }
            default{
                $script:EditorIDs.where{ $this.config.$_.index -eq $_tool }.foreach{ $this.target_tool( $_ ) }
                $script:BrowserIDs.where{ $this.config.$_.url -eq $_tool }.foreach{ $this.target_tool( $_ ) }
                $script:GridIDs.where{ $this.config.$_.gindex -eq $_tool }.foreach{ $this.target_tool( $_ ) }
            }
        }

        return $this
    }
    [TTDocumentManager] Equip( [string]$work, [string]$tool ){ # id: Work1/Work2/Work3, $tool: Editor/Browser/Grid
        $n = @( 'Work1', 'Work2', 'Work3' ).IndexOf($work)
        if( $n -lt 0 ){ return $this }

        $script:Editors[$n].Visibility = if( $tool -eq 'Editor' ){ [Visibility]::Visible }else{ [Visibility]::Collapsed }
        $script:Browsers[$n].Visibility = if( $tool -eq 'Browser' ){ [Visibility]::Visible }else{ [Visibility]::Collapsed }
        $script:Grids[$n].Visibility = if( $tool -eq 'Grid' ){ [Visibility]::Visible }else{ [Visibility]::Collapsed }

        $script:app._set( "$work.Tool", $tool  )

        return $this
    }
    [TTDocumentManager] ResetTool(){ # Editor[123]/Browser[123]/Grid[123] or index/url
        $conf  = $this.config.($this.target_tool)

        switch -regex ( $this.target_tool ){
            'Editor[123]' {
                if( $null -ne $conf.foldman ){
                    [ICSharpCode.AvalonEdit.Folding.FoldingManager]::Uninstall( $conf.foldman )
                }
                $conf.foldman = $null
                $conf.foldstgy = $null
                $filepath = $conf.editor.Document.FileName
                if( $script:Editors.where{ $_.Document.FileName -eq $filepath }.count -eq 1 ){
                    $this.documents.where{ $_.FileName -eq $filepath }.foreach{
                        $_.Text = ""
                        $_.FileName = ""
                    }
                }
                $conf.editor.Document = $null
                $conf.index = ""
                $script:app._set( "($this.target_tool).Index", "" )
            }
            'Browser[123]' {
                $conf.url = ""
                $conf.browser.Source = $null
                $script:app._set( "($this.target_tool).Url", "" )
            }
            'Grid[123]' {
                $conf.index = ""
                $conf.filepath = ""
                $script:app._set( "($this.target_tool).Index", "" )
            }
        }

        return $this
    }
    [object] Save(){ # Editor[123]/Browser[123]/Grid[123]

        $conf  = $this.config.($this.target_tool)

        switch -regex ( $this.target_tool ){
            'Editor[123]' {
                $editor = $conf.editor
                $filepath = $editor.Document.FileName

                if( (0 -lt $filepath.length) -and ( $editor.IsModified ) ){
                    if(  $script:app._istrue( "Config.MemoSavedMessage" ) ){
                        $title = $editor.Text.split( "`r`n" )[0]
                        [TTTool]::debug_message( $this.target_tool, "Save Memo $($conf.index) : $title" )
                    }

                    $editor.Encoding = [System.Text.Encoding]::UTF8
                    $editor.Save( $filepath )
                    $script:shelf.refresh()

                    return $editor
                }
            }
            'Browser[123]' {
            }
            'Grid[123]' {
            }
        }

        return $null
    }
    [void] Load( $index ){ # Editor[123]/Browser[123]/Grid[123]

        $conf  = $this.config.($this.target_tool)

        switch -regex ( $this.target_tool ){
            'Editor[123]' {
                $editor = $conf.editor

                # history関連
                switch( $index ){
                    "previous" {
                        if( 0 -lt $conf.hispos ){
                            $conf.hispos -= 1
                            $index = $conf.history[$conf.hispos]
                        }else{
                            $index = $conf.index
                        }
                    }
                    "next" {
                        if( 0 -ne $conf.history[$conf.hispos+1].length ){
                            $conf.hispos += 1
                            $index = $conf.history[$conf.hispos]
                        }else{
                            $index = "nofile"
                        }
                    }
                    default {
                        if( $conf.history[$conf.hispos-1] -eq $index ){ 
                            $this.Load( "previous" )
                        }elseif( $conf.history[$conf.hispos+1] -eq $index ){ 
                            $this.Load( "next" )
                        }else{
                            $conf.hispos += 1
                            $conf.history[$conf.hispos] = $index
                            $conf.history[$conf.hispos+1] = ""
                        }
                    }
                }

                # ファイル読込の要否確認
                $filepath = [TTTool]::index_to_filepath( $index )

                if( -not (Test-Path $filepath) ){ 
                    [TTTool]::debug_message( $this, "error >> no such file: $filepath" )
                    return
                }
                if( $filepath -eq $editor.Document.FileName ){
                    [TTTool]::debug_message( $this, "caution >> read already: $filepath" )
                    return
                } 

                # ファイル読込のためのリセット
                $this.Tool( $this.target_tool ).ResetTool()

                $refdoc = @($this.documents.where{ $_.FileName -eq $filepath })[0]
                if( $null -ne $refdoc ){ 
                    # 他EditorのDocumentをシェア
                    $editor.Document = $refdoc
                }else{
                    # 本Editor用にDocument設定
                    $refdoc = @($this.documents.where{ $_.FileName -eq "" })[0]
                    $editor.Document = $refdoc
                    $editor.Document.FileName = $filepath
                    $editor.Load( $filepath )
                }

                # 折畳み設定
                $this.Tool( $this.target_tool ).InitializeFolding()

                $conf.index = $index
                $script:app._set( "($this.target_tool).Index", $index )
            }
            'Browser[123]' {
                return
            }
            'Grid[123]' {
                return
            }
        }
    }
    [TTDocumentManager] Modified( $modified ){

        $editor = $this.config.($this.target_tool).editor
        $editor.IsModified = $modified

        return $this
    }
    [TTDocumentManager] ConfigureEditor( $offset, $wordwrap, $foldings ){
        $conf  = $this.config.($this.target_tool)
        $conf.editor.CaretOffset = $offset
        $conf.editor.WordWrap    = $wordwrap
        $folds = $foldings.split(",")
        $conf.foldman.AllFoldings.foreach{ $_.IsFolded = ( $_.StartOffset -in $folds ) }

        return $this
    }
    [TTDocumentManager] InitializeFolding(){ # Editor[123]/Browser[123]/Grid[123]
        $conf  = $this.config.($this.target_tool)

        switch -regex ( $this.target_tool ){
            'Editor[123]' {
                $conf.foldman  = [ICSharpCode.AvalonEdit.Folding.FoldingManager]::Install( $conf.editor.TextArea )
                $conf.foldstgy = [AvalonEdit.Sample.ThinktankFoldingStrategy]::new()
                $conf.foldstgy.UpdateFoldings( $conf.foldman, $conf.editor.Document )
            }
        }

        return $this
    }
    [TTDocumentManager] UpdateEditorFolding(){
        $conf  = $this.config.($this.target_tool)

        switch -regex ( $this.target_tool ){
            'Editor[123]' {
                if( $null -ne $conf.foldstgy ){ $conf.foldstgy.UpdateFoldings( $conf.foldman, $conf.editor.Document ) }
            }
        }

        return $this
    }
    [TTDocumentManager] SetConfiguration( $key, $value ){
        $conf  = $this.config.($this.target_tool)

        switch -regex ( $this.target_tool ){
            'Editor[123]' {
                switch ( $key ){
                    'WordWrap' { 
                        switch -wildcard ( $value ){
                            'true'   { $conf.editor.WordWrap = $True }
                            'false'  { $conf.editor.WordWrap = $False }
                        }
                    }
                    'StayCursor' {
                        switch( $value ){
                            'true'   { $script:app._set( "($this.target_tool).StayCursor", 'true' ) }
                            'false'  { $False; $script:app._set( "($this.target_tool).StayCursor", 'false' ) }
                            'toggle' { $this.SetConfiguration( ($this.target_tool), 'ScrollToNewLine', $script:app._get( "($this.target_tool).StayCursor") -eq 'false' ) }
                        }
                    }
                }
            }
        #     # 'Browser[123]' {}
        #     # 'Grid[123]' {}
        }

        return $this
    }
    [string[]] EditingIndices(){
        return @( $this.config.Editor1.index, $this.config.Editor2.index, $this.config.Editor3.index )
    }
    #endregion''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

    #region カレントエディタ：　カーソル、スクロール、編集
    #'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    [TTDocumentManager] ScrollTo( $to ){
        $editor = $this.config.($this.target_tool).editor

        switch( $to ){
            'nextline' { $editor.LineUp() }
            'prevline' { $editor.LineDown() }
            'newline' {
                if( $script:app._get( "$($editor.name).StayCursor" ) -eq 'true' ){ 
                    $editor.LineDown()
                }
            }
        }

        return $this
    }
    [TTDocumentManager] SelectTo( $to, $following_action ){
        $editor = $this.config.($this.target_tool).editor
        $curpos  = $editor.CaretOffset

        switch( $to ){
            'all' {
                $editor.SelectAllItems
            }
            'lineend' { 
                $editor.SelectionStart = $curpos
                $editor.SelectionLength = $editor.Document.GetLineByOffset( $curpos ).EndOffset - $curpos
                $editor.CaretOffset = $curpos
            }
            'linestart' {
                $editor.SelectionStart = $editor.Document.GetLineByOffset( $curpos ).Offset
                $editor.SelectionLength = $curpos - $editor.SelectionStart            
            }
            'rightchar' {
                $editor.SelectionStart = $curpos
                $editor.SelectionLength = 1
            }
            'leftchar' {
                if( 0 -lt $curpos ){
                    $editor.SelectionStart = $curpos - 1
                    $editor.SelectionLength = 1
                }
            }
            'nextline' {
                [EditingCommands]::MoveDownByLine.Execute( $null, $editor.TextArea )
                $editor.SelectionStart = $curpos
                $editor.SelectionLength = $editor.CaretOffset - $curpos
            }
            'prevline' {
                [EditingCommands]::MoveUpByLine.Execute( $null, $editor.TextArea )
                $editor.SelectionStart = $curpos
                $editor.SelectionLength = $editor.CaretOffset - $curpos
            }
        }

        switch( $following_action ){
            'cut' { $editor.Cut() }
            'copy' { $editor.Copy() }
            default {}
        }

        return $this
    }
    [bool] MoveTo( $to ){
        $editor = $this.config.($this.target_tool).editor
        $curpos = $editor.CaretOffset
        $curlin = $editor.document.GetLineByOffset( $curpos )

        $text = $script:desk._keyword.Text.Trim().Split(",")[0]           # テキストボックスの最初の , までをキーワード認識
        $text = $text -replace "[\.\^\$\|\\\[\]\(\)\{\}\+\*\?]", '\$0'  # 正規表現記号をエスケープ 
        $text = $text -replace "[ 　\t]+", " "                          # 空白文字を半角に統一
    
        :Handled switch( $to ){
            'documentend'   { [EditingCommands]::MoveToDocumentEnd.Execute( $null, $editor.TextArea ) }
            'documentstart' { [EditingCommands]::MoveToDocumentStart.Execute( $null, $editor.TextArea ) }
            'lineend'   { [EditingCommands]::MoveToLineEnd.Execute( $null, $editor.TextArea ) }
            'linestart' { [EditingCommands]::MoveToLineStart.Execute( $null, $editor.TextArea ) }
            'rightchar' { [EditingCommands]::MoveRightByCharacter.Execute( $null, $editor.TextArea ) }
            'leftchar'  { [EditingCommands]::MoveLeftByCharacter.Execute( $null, $editor.TextArea ) }

            'lineend+' {
                if ( $curpos -eq $editor.Document.GetLineByOffset( $curpos ).EndOffset ){
                    [EditingCommands]::MoveToDocumentEnd.Execute( $null, $editor.TextArea )
                }else{
                    [EditingCommands]::MoveToLineEnd.Execute( $null, $editor.TextArea )
                }  
            }
            'linestart+' {
                if ( $curpos -eq $editor.Document.GetLineByOffset( $curpos ).Offset ){
                    [EditingCommands]::MoveToDocumentStart.Execute( $null, $editor.TextArea )
                }else{
                    [EditingCommands]::MoveToLineStart.Execute( $null, $editor.TextArea )
                }
            }
            'nextline' {
                [EditingCommands]::MoveDownByLine.Execute( $null, $editor.TextArea )
                if( $script:app._get( "$($editor.name).StayCursor" ) -eq 'true' ){ $this.ScrollTo( 'nextline' ) }
            }
            'prevline' {
                [EditingCommands]::MoveUpByLine.Execute( $null, $editor.TextArea )
                if( $script:app._get( "$($editor.name).StayCursor" ) -eq 'true' ){ $this.ScrollTo( 'prevline' ) }
            }
            'nextnode' {
                $level = if( $editor.document.GetText( $curlin.Offset, 15 ) -match "(?<tag>^#+) .*"  ){ $Matches.tag.length }else{ 10 }
                $curlin = $curlin.NextLine
                while( $null -ne $curlin ){
                    # scan document
                    if( $editor.document.GetText( $curlin.Offset, 15 ) -match "^(?<tag>#{1,$level}) .*" ){
                        if( ($level -eq $Matches.tag.length) -or ($level -eq 10) ){
                            $editor.CaretOffset = $curlin.Offset
                            $editor.ScrollToLine( $curlin.LineNumber )
                            break
                        }elseif( $Matches.tag.length -lt $level ){
                            break
                        }
                    }
                    $curlin = $curlin.NextLine
                }
            }
            'prevnode' {
                $level = if( $editor.document.GetText( $curlin.Offset, 15 ) -match "(?<tag>^#+) .*"  ){ $Matches.tag.length }else{ 10 }
                $curlin = $curlin.PreviousLine
                while( $null -ne $curlin ){
                    # scan document
                    if( $editor.document.GetText( $curlin.Offset, 15 ) -match "^(?<tag>#{1,$level}) .*" ){
                        if( ($level -eq $Matches.tag.length) -or ( $level -eq 10) ){
                            $editor.CaretOffset = $curlin.Offset
                            $editor.ScrollToLine( $curlin.LineNumber )
                            break
                        }elseif( $Matches.tag.length -lt $level ){
                            break
                        }
                    }
                    $curlin = $curlin.PreviousLine
                }
            }
            'nextkeyword' {
                if( "" -eq $text ){ return $false }
                $pos = ( $text.split(" ").foreach{
                    $editor.Document.IndexOf( $_, $editor.CaretOffset + 1, $editor.Text.Length - $editor.CaretOffset - 1, [System.StringComparison]::CurrentCultureIgnoreCase )
                } | Measure-Object -Minimum ).Minimum
            
                if( $pos -ne -1 ){
                    $editor.CaretOffset = $pos
                    $editor.ScrollTo( $editor.TextArea.Caret.Line, $editor.TextArea.Caret.Column )
                }else{
                    return $false
                }            
            }
            'prevkeyword' {
                if( "" -eq $text ){ return $false }
                $pos = ( $text.split(" ").foreach{
                    $editor.Document.LastIndexOf( $_, 0, $editor.CaretOffset, [System.StringComparison]::CurrentCultureIgnoreCase )
                } | Measure-Object -Maximum ).Maximum
            
                if( $pos -ne -1 ){
                    $editor.CaretOffset = $pos
                    $editor.ScrollTo( $editor.TextArea.Caret.Line, $editor.TextArea.Caret.Column )
                }else{
                    return $false
                }
            }
            'nextkeywordnode' {
                $lin = $curlin.NextLine 
                while( $null -ne $lin ){
                    $lintext = $editor.document.GetText( $lin.Offset, $lin.Length )
                    if( $lintext[0] -eq '#' ){
                        $pos = @( $text.split(" ").foreach{ $lintext.IndexOf( $_ ) }.where{ $_ -ne -1 } | Measure-Object -Max ).Maximum
                        if( $null -ne $pos ){
                            $editor.CaretOffset = $lin.Offset + $pos
                            $editor.ScrollToLine( $lin.Offset + $pos )
                            break :Handled
                        }
                    }
                    $lin = $lin.NextLine 
                }
                return $false
            }
            'prevkeywordnode' {
                $lin = $curlin.PreviousLine 
                while( $null -ne $lin ){
                    $lintext = $editor.document.GetText( $lin.Offset, $lin.Length )
                    if( $lintext[0] -eq '#' ){
                        $pos = @( $text.split(" ").foreach{ $lintext.IndexOf( $_ ) }.where{ $_ -ne -1 } | Measure-Object -Min ).Minimum
                        if( $null -eq $pos ){
                            $editor.CaretOffset = $lin.Offset + $pos
                            $editor.ScrollToLine( $lin.Offset + $pos )
                            break :Handled
                        }
                    }
                    $lin = $lin.PreviousLine 
                }
                return $false
            }
            default{
                switch -regex( $to ){
                    "^(?<line>\d+)$" {
                        $editor.CaretOffset = $editor.Document.GetLineByNumber( [int]($Matches.line) ).Offset - 1
                    }
                    "^(?<line>\d+):(?<column>\d+)$" {
                        $editor.CaretOffset = $editor.Document.GetLineByNumber( [int]($Matches.line) ).Offset + [int]($Matches.column) - 1
                    }
                    "^#(?<keyword>.+)$" {
                        
                    }
                    "^(?<keyword>.+)$" {}
                }
            }
        }

        return $true
    }
    [TTDocumentManager] NodeTo( $state ){
        $editor = $this.config.($this.target_tool).editor
        $curpos = $editor.CaretOffset
        $curlin = $editor.document.GetLineByOffset( $curpos )
        $foldman = $this.config.($editor.Name).foldman

        switch( $state ){
            'open_all'  { $foldman.AllFoldings.foreach{ $_.IsFolded = $false }; return $this }
            'close_all' { $foldman.AllFoldings.foreach{ $_.IsFolded = $true }; return $this }
        }

        # check not node
        if( -not ( $editor.document.GetText( $curlin.Offset, 10 ) -match "(?<tag>^#+) .*" ) ){ return $this }

        $level = $Matches.tag.length       
        $folding = $foldman.GetFoldingsAt( $curlin.EndOffset )[0]
        # check not folding
        if( $null -eq $folding ){ return $this }

        switch( $state ){
            'open' {
                if( $folding.IsFolded -ne $False ){
                    $folding.IsFolded = $False                  # open node
                }else{
                    $this.NodeTo( 'open_children' )     # open all child nodes
                }
            }
            'open_children' {
                $open_already = $true
                $endlin = $curlin.NextLine
                while( $null -ne $endlin ){
                    if( $editor.document.GetText( $endlin.Offset, 15 ) -match "^(?<tag>#{$level}) .*" ){ break }
                    $endlin = $endlin.NextLine
                }
                if( $null -eq $endlin ){ $endlin = $editor.Document.Lines[-1] }
                $foldman.AllFoldings.foreach{
                    if( ($curlin.Offset -lt $_.StartOffset) -and ($_.StartOffset -lt $endlin.Offset) ){
                        $_.IsFolded = $false                    # open all child nodes
                        $open_already = $false
                    } 
                }
                if( $open_already ){ 
                    $this.NodeTo( 'open_sibling' )      # open all sibling nodes
                }
            }
            'open_sibling' {
                $foldman.AllFoldings.foreach{
                    $lin = $editor.document.GetLineByOffset( $_.StartOffset )
                    if( $editor.document.GetText( $lin.Offset, 10 ) -match "^(?<tag>#{$level}) .*" ){
                        $_.IsFolded = $False                    # open all sibling nodes
                    }
                }
            }
            'close' {
                if( $folding.IsFolded -ne $True ){
                    $folding.IsFolded = $True                   # close node
                }else{
                    $this.NodeTo( 'close_sibling' )     # close all sibling nodes
                }
            }
            'close_sibling' {
                $foldman.AllFoldings.foreach{
                    $lin = $editor.document.GetLineByOffset( $_.StartOffset )
                    if( $editor.document.GetText( $lin.Offset, 10 ) -match "^(?<tag>#{$level}) .*" ){
                        $_.IsFolded = $True                    # close all sibling nodes
                    }
                }
            }
            'close_children' {
                $foldman.AllFoldings.foreach{
                    if( ($curlin.Offset -lt $_.StartOffset) -and ($_.StartOffset -lt $curli.EndOffset) ){
                        $_.IsFolded = $True                    # close all child nodes
                    } 
                }
            }
        }

        return $this
    }
    [TTDocumentManager] Insert( $text ){
        $editor = $this.config.($this.target_tool).editor
        $editor.Document.Insert( $editor.CaretOffset, $text )

        return $this
    }
    [TTDocumentManager] Edit( $subject ){
        $editor = $this.config.($this.target_tool).editor

        switch( $subject ){
            'delete'    { [EditingCommands]::Delete.Execute( $null, $editor.TextArea ) }
            'backspace' { [EditingCommands]::Backspace.Execute( $null, $editor.TextArea ) }
        }

        return $this
    }
    [TTDocumentManager] Writing( $subject ){　# 参照無し
        $editor = $this.config.($this.target_tool).editor

        switch( $subject ){
            'bullet'    {}
            'indent'    {}
        }

        return $this
    }
    [TTDocumentManager] Cursor( $action ){
        $editor = $this.config.($this.target_tool).editor

        switch( $action ){
            'save'      { $this.offset = $editor.CaretOffset }
            'restore'   { $editor.CaretOffset = $this.offset }
        }

        return $this
    }
    [string[]] AtCursor( $action ){
        $editor = $this.config.($this.target_tool).editor
        switch( $action ){
            'text'  { return $editor.SelectedText -split "`r?`n" }
            'lines' {
                $start = $editor.document.GetLineByOffset( $editor.SelectionStart ).Offset
                $end   = $editor.document.GetLineByOffset( $editor.SelectionStart + $editor.SelectionLength ).EndOffset
                return $editor.document.GetText( $start, $end - $start + 1 ) -split "`r?`n"   
            }
            'all'   { return $editor.Text -split "`r?`n" }
            'word' {}
            'section' {}
            'title' {}
            'posinfo' {
                if( 0 -eq $editor.SelectionLength ){
                    $lin = $editor.Document.GetLineByOffset( $editor.CaretOffset ).LineNumber
                    $col = $editor.CaretOffset - $editor.Document.GetLineByOffset( $editor.CaretOffset ).Offset 
                    return @( "$($lin):$col" )
                }else{
                    # 選択中の行が章の場合 #(文字) を返す
                    return $editor.SelectedText.split("`r?`n")
                }
            }
            default {}
        }
        return @("")
    }
    [bool] Replace( $regex, $replace ){
        $editor = $this.config.($this.target_tool).editor
        $curlin = $editor.document.GetLineByOffset( $editor.CaretOffset )
        $line = $editor.document.GetText( $curlin.Offset, $curlin.Length )

        if( $line -match $regex ){
            $line = $line -replace $regex, $replace
            $editor.Document.Replace( $curlin.Offset, $curlin.Length, $line )
            return $true
        }   

        return $false
    }
    [bool] Moved(){
        $editor = $this.config.($this.target_tool).editor

        return ( $this.offset -eq $editor.CaretOffset )
    }
    #endregion''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

}
#endregion###############################################################################################################









