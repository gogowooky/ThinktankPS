



using namespace System.Windows.Controls
using namespace System.Windows 
using namespace System.Xml
using namespace System.Windows.Input
using namespace System.Windows.Documents




class TTStateController {
    #region variants/ new/ initialize
    static [bool] $DisplaySavedMessage = $true
    static [bool] $DisplayLoadedMessage = $true

    [TTCollection] $status
    [TTCollection] $configs

    TTStateController(){
        $this.status =  $global:Model.GetChild('Status')
        $this.configs = $global:Model.GetChild('Configs')

        # $this.event_before_window_loaded( $null )

    }

    [void] BindEvents( [TTAppManager]$view ){

        @( $view ).foreach{
            $_._window.Add_Loaded(              { $this.event_after_window_loaded( $args ) })
            $_._window.Add_StateChanged(        { $this.event_after_windowstate_changed( $args ) })
            $_._window.Add_SizeChanged(         { $this.event_after_windowsize_changed( $args ) })
        }
        @( $view.Library, $view.Index, $view.Shelf, $view.Desk, $view.Cabinet ).foreach{
            $_._panel.Add_SizeChanged(          { $this.event_after_bordersize_changed( $args ) })
        }
        @( $view.Library, $view.Index, $view.Shelf, $view.Cabinet ).foreach{
            $_._datagrid.Add_SelectionChanged(  { $this.event_after_selecteditem_changed( $args ) })
            $_._datagrid.Add_SourceUpdated(     {}) # 'Library.Resource'
            $_._datagrid.Add_Sorting(           {}) # 'Library.Sort.Dir', 'Library.Sort.Column'
            $_._datagrid.Add_TargetUpdated(     {}) # 'Library.Resource' ?
            $_._datagrid.Add_SelectionChanged(  {}) # 'Library.Selected'
            $_._textbox.Add_TextChanged(        { $this.event_after_textbox_changed_for_datagrid( $args ) })
            $_._textbox.Add_GotFocus(           { $this.event_after_focus_changed( $args ) })
            $_._textbox.Add_TextChanged(        {})          # 'Library.Keyword'
        }
        @( $view.Desk ).foreach{
            $_._textbox.Add_TextChanged(        { $this.event_after_textbox_changed_for_workplace( $args ) })
            $_._textbox.Add_GotFocus(           { $this.event_after_focus_changed( $args ) })
            $_._textbox.Add_TextChanged(        {})          # 'Library.Keyword'
        }

        [TTEditorsManager]::OnSaved =   { $this.event_after_editor_saved( $args ) }
        [TTEditorsManager]::OnLoaded =  { $this.event_after_editor_loaded( $args ) }
        $view.Document.Editor.Controls.foreach{
            $_.Add_GotFocus(            { $this.event_after_focus_changed( $args ) })
            $_.Add_PreviewKeyDown(      {})
            $_.Add_PreviewKeyUp(        {})
        }

        $view.Document.Browser.Controls.foreach{ 
            $_.Add_GotFocus(            { $this.event_after_focus_changed( $args ) })
            $_.Add_PreviewKeyDown(      {})
            $_.Add_PreviewKeyUp(        {})
        }

        $view.Document.Grid.Controls.foreach{ 
            $_.Add_GotFocus(            { $this.event_after_focus_changed( $args ) })
            $_.Add_PreviewKeyDown(      {})
            $_.Add_PreviewKeyUp(        {})
        }

    }

    [void] BindEvents( [TTResources]$model ){
        [TTCollection]::OnSaved =       { $this.event_after_editor_saved( $args ) }
        [TTCollection]::OnLoaded =      { $this.event_after_editor_loaded( $args ) }

        [TTMemo]::OnSaved =             {}
        [TTMemo]::OnLoaded =            {}
        
    }
 
    [void] LoadStoredState(){
        # 220811 保存statusを再現する
        $this.status.GetChildren().foreach{ $this._set( $_.Name, $_.Value ) }
        $this.window( 'Left',   $this._get('Window.Left') )
        $this.window( 'Top',    $this._get('Window.Top') )
        $this.window( 'State',  $this._get('Window.State') )
        $this.border( 'Layout.Library.Width',   $this._get('Layout.Library.Width') )
        $this.border( 'Layout.Library.Height',  $this._get('Layout.Library.Height') )
        $this.border( 'Layout.Shelf.Height',    $this._get('Layout.Shelf.Height') )
        $this.border( 'Layout.Work1.Width',     $this._get('Layout.Work1.Width') )
        $this.border( 'Layout.Work1.Height',    $this._get('Layout.Work1.Height') )

    }
    #endregion

    #region status
    [void] _set( $name, $value ){
        $this.status.Set( $name, $value )

        return 
        switch -regex ( $name ){
            'Config.MessageOnTaskRegistered' { $global:TTTimerResistMessage = ( $value -eq 'True' ) } 
            'Config.MessageOnTaskExpired' { $global:TTTimerExpiredMessage = ( $value -eq 'True' ) }
        }
    }
    [string] _get( $name ){ return $this.status.Get( $name ) }
    [bool] _like( $name, $value ){      return ( $this._get( $name ) -like      $value ) }
    [bool] _notlike( $name, $value ){   return ( $this._get( $name ) -notlike   $value ) }
    [bool] _match( $name, $value ){     return ( $this._get( $name ) -match     $value ) }
    [bool] _notmatch( $name, $value ){  return ( $this._get( $name ) -notmatch  $value ) }
    [bool] _eq( $name, $value ){        return ( $this._get( $name ) -eq        $value ) }
    [bool] _ne( $name, $value ){        return ( $this._get( $name ) -ne        $value ) }
    [bool] _in( $name, $value ){        return ( $this._get( $name ) -in        $value ) }
    [bool] _notin( $name, $value ){     return ( $this._get( $name ) -notin     $value ) }
    [bool] _istrue( $name ){            return ( $this._get( $name ) -eq $true ) }
    [bool] _isfalse( $name ){           return ( $this._get( $name ) -eq $false ) }
    [bool] _isnull( $name ){            return ( $this._get( $name ).length -eq 0 ) }

    [void] SetDefaultState(){
        $this._set( 'Application.Name',          "Thinktank" )
        $this._set( 'Application.Version',       "0.6.1" )
        $this._set( 'Application.LastModified',  "2022/06/01" )
        $this._set( 'Application.Author.Name',   "Shinichiro Egashira" )
        $this._set( 'Application.Author.Mail',   "gogowooky@gmail.com" )
        $this._set( 'Application.Author.Site',   "https://github.com/gogowooky" )

        $this.configs.GetChildren().foreach{ if( $this._isnull( $_.Name ) ){ $this._set( $_.Name, $_.Value ) } }
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    
    #region event
    [bool] event_after_window_loaded( $params ){
        $global:State.LoadStoredState()
        return $false
    }
    [bool] event_after_windowstate_changed( $params ){
        $this._set( 'Window.State', $global:View.Window('State') )
        return $false
    }
    [bool] event_after_windowsize_changed( $params ){
        $this._set( 'Window.Top',   $global:View.Window('Top') )
        $this._set( 'Window.Left',  $global:View.Window('Left') )
        return $false
    }
    [bool] event_after_bordersize_changed( $params ){
        $panel = $params[0].Name
        switch -wildcard ( $panel ){
            'Library*' {
                TTTimerResistEvent "event_after_bordersize_changed:$_" 2 0 {
                    $global:State._set( 'Layout.Library.Width', $global:View.Border('Layout.Library.Width') )
                    $global:State._set( 'Layout.Library.Height', $global:View.Border('Layout.Library.Height') )
                }    
            }
            'Shelf*' {
                TTTimerResistEvent "event_after_bordersize_changed:$_" 2 0 {
                    $global:State._set( 'Layout.Shelf.Height', $global:View.Border('Layout.Shelf.Height') )
                }    
            }
            'Work1*' {
                TTTimerResistEvent "event_after_bordersize_changed:$_" 2 0 {
                    $global:State._set( 'Layout.Work1.Width', $global:View.Border('Layout.Work1.Width') )
                    $global:State._set( 'Layout.Work1.Height', $global:View.Border('Layout.Work1.Height') )
                }    
            }
        }
        return $true

    }
    [bool] event_after_selecteditem_changed( $params ){ # Library/Index/Shelf/Cabinet
        $panel = ( $params[0].Name -replace "(Library|Index|Shelf|Cabinet).*", '$1' )
        $view = $global:View.$panel

        $view.FocusMark('') 
        $index = $view.SelectedIndex()
        $view.Caption( $index )
        $this._set( "$panel.Selected", $index )

        return $true
    }
    [bool] event_after_textbox_changed_for_datagrid( $params ){
        $panel = ( $params[0].Name -replace "(Library|Index|Shelf|Cabinet).*", '$1' )
        $this._set( "$panel.Keyword", $global:View.$panel.Keyword( $panel ) )
        $global:View.$panel.Extract( $panel )
    
        return $true
    }
    [bool] event_after_focus_changed( $params ){ 

        [TTTool]::debug_message( $params[0].Name, "event_after_focus_changed" )

        switch -regex ($this._get('Focus.Application')){    #### Unmark
            "(Library|Index|Shelf|Desk)" { $global:View.$_.FocusMark('') }
            "(Editor|Browser|Grid)[123]" { $global:View.Desk.FocusMark('') }
        }

        switch -regex ( $params[0].Name ){                  #### Mark
            "(?<name>Library|Index|Shelf|Desk).*" {
                $this._set( 'Focus.Application', $Matches.name )
                $global:View.($Matches.name).FocusMark('●')

            }
            "(?<name>Editor|Browser|Grid)(?<num>[123])" {
                $num = [int]($Matches.num)
                $name= $Matches.name
                $this._set( 'Current.Workplace', "Work$num" )
                $this._set( 'Current.Tool', $name )
                $this._set( 'Focus.Application', $Matches[0] )
                $global:View.Desk.FocusMark("●[$($_[0])$($_[-1])]") # Editor1 → E1

                switch($name){ # Desk caption
                    'Editor' {
                        $index = $global:View.Document.Editor.Indices[$num-1]
                        $title = $global:Model.GetChild('Memos').GetChild($index).Title
                        $global:View.Desk.Caption("[$index] $title")
                    }
                }
                $global:View.Document.CurrentNumber = $num
            }
        }
        return $false

    }
    [bool] event_after_textbox_changed_for_workplace( $params ){

        $text = $global:View.Desk._textbox.Text.Trim()
        $this._set( 'Desk.Keyword', $text )

        TTTimerResistEvent "Desk:event_after_textbox_changed_for_workplace" 1 0 {
            $text = $global:View.Desk._textbox.Text.Trim()
            for( $num = 0; $num -lt 3; $num++ ){
                $editor =   $global:View.Document.Editor.Controls[$num]
                $rules =    $global:View.Document.Editor.HightlightRules[$num]
                $editor_rules = $editor.SyntaxHighlighting.MainRuleSet.Rules.where{ $_.Color.Name -like "Select*" }
                $editor_rules.foreach{ $editor.SyntaxHighlighting.MainRuleSet.Rules.Remove($_) }
                $rules.clear()
                $rules = @()

                for( $color = 1; $color -lt 5; $color++ ){
                    $keyword = ([string]$text.split(",")[$color-1]).Trim()
                    if( 0 -eq $keyword.length ){ break }

                    $rule = [ICSharpCode.AvalonEdit.Highlighting.HighlightingRule]::new()
                    $rule.Color = $editor.SyntaxHighlighting.NamedHighlightingColors.where{ $_.Name -eq "Select$color" }[0]

                    if( $keyword -like "RE:*" ){
                        $keyword = $keyword.substring( 3 )
                        if( 0 -eq $keyword.length ){ break }

                    }else{
                        $keyword = $keyword -replace "[\.\^\$\|\\\[\]\(\)\{\}\+\*\?]", '\$0'
                        $keyword = "(" + ($keyword -replace "[ 　\t]+", "|" ) + ")"
    
                    }
                    $rule.Regex = [Regex]::new( $keyword )
                    $rules += $rule
                    $editor.SyntaxHighlighting.MainRuleSet.Rules.Add( $rule )
                }
                $editor.TextArea.TextView.Redraw()

            }

        }.GetNewClosure()

        $global:View.Document.Editor.Controls.foreach{ $_.TextArea.TextView.Redraw() }

        return $true

    }
    [void] event_after_editor_saved( $params ){
        $toolman, $num = $params
        $index = $toolman.Indices[$num-1]
        $editor = $toolman.Controls[$num-1]
        $filepath = $editor.Document.FileName

        if( [TTStateController]::DisplaySavedMessage ){
            $title = $editor.Text.split( "`r`n" )[0]
            [TTTool]::debug_message( $editor.Name, "Save Memo [$index] $title" )
        }

        #### Memos
        $memo = $global:Model.GetChild('Memos').GetChild($index)
        $memo.UpdateDate = (Get-Item $filepath).LastWriteTime.ToString("yyyy-MM-dd-HHmmss")
        $memo.Title = Get-Content $filepath -totalcount 1

        #### Editings
        $foldman = $toolman.FoldManagers[$num-1]
        $foldings = @( $foldman.AllFoldings.where{ $_.IsFolded }.foreach{ $_.StartOffset } ) -join ","
        $global:Model.GetChild('Editings').AddChild( $editor, $foldings )

    }
    [void] event_after_editor_loaded( $params ){
        $toolman, $num, $index = $params
        $editor = $toolman.Controls[$num-1]

        if( [TTStateController]::DisplayLoadedMessage ){
            $title = $editor.Text.split( "`r`n" )[0]
            [TTTool]::debug_message( $editor.Name, "Load Memo [$index] $title" )
        }

        #### status
        $this._set( "$($editor.Name).Index", $index )

        #### Editings
        $editing = $global:Model.GetChild('Editings').GetChild($index)
        if( $null -eq $editing ){ return }
        $editor.CaretOffset = $editing.Offset
        $editor.WordWrap    = $editing.Wordwrap
        $foldings = $editing.Foldings.split(",")
        $toolman.FoldManagers[$num-1].AllFoldings.foreach{ $_.IsFolded = ( $_.StartOffset -in $foldings ) }
        $caret = $editor.TextArea.Caret
        $editor.ScrollTo( $caret.Line, $caret.Column )

    }




    [bool] event_after_editor_focused( $params ){ # 未着手

        return $true
        # caption、変数類, 他panel状態の更新 

        $editor = $params[0]
        $name = $editor.Name
        $memo = $global:DocMan.config.$name.index
        $line = $editor.Document.GetLineByNumber(1)
        $title = $editor.Document.GetText( $line.Offset, $line.Length )

        $script:desk.caption( "[$name] $memo : $title" )
        $script:DocMan.current_editor = $editor
        if( $script:shelf._collection.Name -eq "Memo" ){ $script:shelf.refresh() }
        if( $script:index._collection.Name -eq "Memo" ){ $script:index.refresh() }

        $script:shelf.cursor( $script:DocMan.config.$name.index )
        $script:index.cursor( $script:DocMan.config.$name.index )

        $script:app._set( 'Desk.CurrentxEditor', $editor.Name )
        $script:app._set( 'Application.Focused', $editor.Name )

        return $true

    }
    #endregion ----------------------------------------------------------------------------------------------------------

    #region notification
    #endregion

}


