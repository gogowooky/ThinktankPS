




using namespace System.Windows.Controls
using namespace System.Windows 
using namespace System.Xml
using namespace System.Windows.Input
using namespace System.Windows.Documents



#region Key Event
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
$global:TTKeyEventMod = ''
$global:TTKeyEventKey = ''

$global:TTKeyEventMessage = $false
$global:TTKeyEvents = @{}
$global:TTEventKeys = @{}

[ScriptBlock] $global:Action_event_to_trigger_key_bound_command = { # Bind to AppMan, PopupMenu, Cabinet

    $source =   [string]($args[0].Name) # ⇒ Application, Cabinet, PopupMenu
    $mod =      [string]($args[1].KeyboardDevice.Modifiers)
    $key =      if( $mod -in @('Alt','Alt, Shift') ){ [string]($args[1].SystemKey) }else{ [string]($args[1].Key) }
    $tttv  =    [TTTentativeKeyBindingMode]::Name
    $panel =    $global:State._get('Focus.Application')
    $global:TTKeyEventMod = $mod
    $global:TTKeyEventKey = $key
    
    if( $key.Contains('Alt') -or $key.Contains('Control') ){ return }

    if( $source -eq 'Application' ){        #### Application
        if( $tttv -ne '' ){                 #### tentative Index/Library/Shelf
            $panel = $tttv
            $command = try{ $global:TTKeyEvents["$panel+"][$mod][$key] }catch{ $null }

        }else{                              #### non tentative

            $command = try{ $global:TTKeyEvents['Application'][$mod][$key] }catch{ $null }

            if( 0 -ne $command.length ){    #### Application
                $panel = $source

            }else{
                if( $panel -match "(?<panel>Editor|Browser|Grid)[123]" ){
                    $command = try{ $global:TTKeyEvents[$Matches.panel][$mod][$key] }catch{ $null }

                }elseif( $panel -eq 'Desk' ){
                    $command = try{ $global:TTKeyEvents['Desk'][$mod][$key] }catch{ $null }

                }else{                      #### normal Index/Library/Shelf
                    $command = @( "$panel+", $panel ).foreach{
                        try{ $global:TTKeyEvents[$_][$mod][$key] }catch{ $null }
                    }.where{ $null -ne $_ }[0]
                }
            }
        }
        
    }else{                                  #### PopupMenu / Cabinet 
        $panel = $source
        $command = try{ $global:TTKeyEvents[$panel][$mod][$key] }catch{ $null }    

    }

    if( 0 -ne $command.length ){
        if( $global:TTKeyEventMessage ){
            Write-Host "PreviewKeyDown source:$source, tentative:$tttv, panel:$panel, mod:$mod, key:$key, command:$command"
        }
        Invoke-Expression "$command '$panel' '$mod' '$key'"
        $args[1].Handled = $true 
        
    }else{
        $args[1].Handled = $false
    }
 
}
[ScriptBlock] $global:Action_event_to_terminate_key_event = { # Bind to AppMan, PopupMenu, Cabinet
    if( [TTTentativeKeyBindingMode]::Check( $args[1].Key ) ){
        $args[1].Handled = $True
    }
}

function KeyBindingSetup(){

    $keybinds = ( @(  
        $global:KeyBind_Application,    $global:KeyBind_Cabinet,    $global:KeyBind_Library, 
        $global:KeyBind_Index,          $global:KeyBind_Shelf,      $global:KeyBind_Misc, 
        $global:KeyBind_Desk,           $global:KeyBind_Editor,     $global:KeyBind_PopupMenu  ) -join "`n" )

    $keybinds.split("`n").foreach{
        $kb_fmt = "(?<mode>[^ ]+)\s{2,}(?<mod>[^ ]+( [^ ]+)?)\s{2,}(?<key>[^ ]+)\s{2,}(?<command>[^\s]+)\s*"
        if( $_ -match $kb_fmt ){
            $global:TTKeyEvents[$Matches.mode] += @{}
            $global:TTKeyEvents[$Matches.mode][$Matches.mod] += @{}
            $global:TTKeyEvents[$Matches.mode][$Matches.mod][$Matches.key] = $Matches.command
            $global:TTEventKeys[$Matches.command] += @()
            $global:TTEventKeys[$Matches.command] += @( @{ Mode = $Matches.mode; Key = "[$($Matches.mod)]$($Matches.key)" } )
        }
    }
}


#endregion::::::::::::::::::::::::::::::::: ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::




class TTActionController {
    #region variants/ new/ BindEvents(view, model)
    [TTTagFormat] $datetag

    TTActionController(){
        $this.datetag = [TTTagFormat]::new()

        $keybinds = ( @(  
            $global:KeyBind_Application,    $global:KeyBind_Cabinet,    $global:KeyBind_Library, 
            $global:KeyBind_Index,          $global:KeyBind_Shelf,      $global:KeyBind_Misc, 
            $global:KeyBind_Desk,           $global:KeyBind_Editor,     $global:KeyBind_PopupMenu  ) -join "`n" 
        )
    
        $keybinds.split("`n").foreach{
            $kb_fmt = "(?<mode>[^ ]+)\s{2,}(?<mod>[^ ]+( [^ ]+)?)\s{2,}(?<key>[^ ]+)\s{2,}(?<command>[^\s]+)\s*"
            if( $_ -match $kb_fmt ){
                $global:TTKeyEvents[$Matches.mode] += @{}
                $global:TTKeyEvents[$Matches.mode][$Matches.mod] += @{}
                $global:TTKeyEvents[$Matches.mode][$Matches.mod][$Matches.key] = $Matches.command
                $global:TTEventKeys[$Matches.command] += @()
                $global:TTEventKeys[$Matches.command] += @( @{ Mode = $Matches.mode; Key = "[$($Matches.mod)]$($Matches.key)" } )
            }
        }
    }
    [void] BindEvents( [TTAppManager]$view ){

        @( $view, $view.Cabinet, $view.PopupMenu ).foreach{
            $_._window.Add_PreviewKeyDown(      { $this.event_to_trigger_key_bound_command( $args ) })
            $_._window.Add_PreviewKeyUp(        { $this.event_to_terminate_key_event( $args ) })
        }
        @( $view.Library, $view.Index, $view.Shelf ).foreach{
            $_._datagrid.Add_GotFocus(          { $this.event_to_move_focus_to_main( $args ) })
            $_._datagrid.Add_Sorting(           { $this.event_to_sort_datagrid_after_onsort( $args ) })
            $_._datagrid.Add_PreviewMouseDown(  { $this.event_to_invoke_action_after_click_on_datagrid( $args ) })
            $_._datagrid.Add_SourceUpdated(     {})    # 'Library.Resource'
            $_._datagrid.Add_TargetUpdated(     {})    # 'Library.Resource' ?
            $_._datagrid.Add_SelectionChanged(  {})    # 'Library.Selected'
            $_._textbox.Add_TextChanged(        {})    # 'Library.Keyword'
        }
        @( $view.Desk ).foreach{
            $_._textbox.Add_TextChanged(        {})    # 'Library.Keyword'
        }
        @( $view.Cabinet ).foreach{
            # $this._window.Add_Loaded({ $global:View.Cabinet.Focus() })
            $_._window.Add_Closing(             { $args[1].Cancel = $True })
            $_._window.Add_MouseLeftButtonDown( { $_._window.DragMove() })
            $_._window.Add_MouseDoubleClick(    { $_.Hide($true); $args[1].Handled=$True })
            $_._datagrid.Add_GotFocus(          { $this.event_to_move_focus_to_main( $args ) })
            $_._datagrid.Add_Sorting(           {}) # 'Library.Sort.Dir', 'Library.Sort.Column'
            $_._datagrid.Add_PreviewMouseDown(  { $this.event_to_invoke_action_after_click_on_datagrid( $args ) })
            $_._datagrid.Add_SourceUpdated(     {}) # 'Library.Resource'
            $_._datagrid.Add_TargetUpdated(     {}) # 'Library.Resource' ?
            $_._datagrid.Add_SelectionChanged(  {}) # 'Library.Selected'
            $_._textbox.Add_TextChanged(        {})     # 'Library.Keyword'
        }
        @( $view.PopupMenu ).foreach{
            $_._window.Add_Closing(             { $args[1].Cancel = $True })
            $_._window.Add_MouseLeftButtonDown( { $_._window.DragMove() })
            $_._window.Add_MouseDoubleClick(    { $_.Hide( $true ) })
            $_._window.Add_LostKeyboardFocus(   { $_.Hide( $false ) })
        }
        @( $view.Document.Editor ).foreach{
            $_.OnSave =                 { $global:State.event_after_editor_saved( $args ) }
            $_.OnLoad =                 { $global:State.event_after_editor_loaded( $args ) }
            $_.Controls.foreach{
                $_.Add_GotFocus(        { $global:State.event_after_focus_changed( $args ) })
                $_.Add_TextChanged(     { $this.event_to_save_after_text_change_on_editor( $args ) })
                $_.Add_PreviewMouseDown({ $this.event_to_invoke_action_after_click_on_editor( $args ) })
                $_.Add_PreviewDrop(     { $this.event_to_open_file_after_file_dropped( $args ) })
                $_.Add_PreviewKeyDown(  {})
                $_.Add_PreviewKeyUp(    {})
            }
        }
        @( $view.Document.Browser ).foreach{
            $this.Controls.foreach{ 
                $_.Add_GotFocus(        { $global:State.event_after_focus_changed( $args ) })
                $_.Add_PreviewKeyDown(  {})
                $_.Add_PreviewKeyUp(    {})
            }
        }
        @( $view.Document.Grid ).foreach{
            $this.Controls.foreach{ 
                $_.Add_GotFocus(        { $global:State.event_after_focus_changed( $args ) })
                $_.Add_PreviewKeyDown(  {})
                $_.Add_PreviewKeyUp(    {})
            }
        }
    }
    [void] BindEvents( [TTResources]$model ){
    }

    #endregion

    #region invoke/ select_and_invoke
    [bool] invoke( [string]$panel ){
        $items = $global:View.$panel.SelectedItems()
        return $items[0].InvokeAction( 'Action', $items )
    }
    [bool] select_and_invoke( [string]$panel ){
        $items = $global:View.$panel.SelectedItems()

        $title = "{0}:{1}:アクション選択" -f $global:View.$panel.Caption(), $panel
        $actions = $items[0].GetActions()
        $selected = $global:View.PopupMenu.Caption( $title ).Items( $actions.Keys ).Show()

        $selected.foreach{
            $action = $actions[$_]
            $items[0].InvokeAction( $action, $items )
        }
        return $true
    }

    #endregion

    #region focus
    [void] focus( $panel, $mod, $key ){

        if( $panel -notmatch "(?<panel>Library|Index|Shelf)\+" ){       #### go normal focus
                $global:View.Focus( $panel )
                return
        }

        $tentative_panel = $Matches.panel

        if( $this._eq( 'Focus.Application', $tentative_panel ) ){       #### no need to focus
            return
        }

        if( [TTTentativeKeyBindingMode]::Name -eq $tentative_panel ){   #### move to normal focus
            [TTTentativeKeyBindingMode]::Initialize()
            $global:View.Focus( $tentative_panel )
            return
        }
        
        if( [TTTentativeKeyBindingMode]::Name -ne '' ){                 #### cancel tentative mode
            [TTTentativeKeyBindingMode]::Initialize()
            return

        }else{                                                          #### go tentative mode
            $notvisible = ( $global:View.Focusable( $tentative_panel ) -eq $false )
            if( $notvisible ){ $global:View.Style( $tentative_panel, 'Default' ) }
    
            # tentative mode, Library | Index | Shelf
            [TTTentativeKeyBindingMode]::Start( $tentative_panel, $mod, $key )
            [TTTentativeKeyBindingMode]::Add_OnExit({
                if( $script:notvisible ){ $global:View.Style( $script:tentative_panel, 'None' ) }
            }.GetNewClosure() )
        }

    }

    #endregion ----------------------------------------------------------------------------------------------------------
    
    #region event
    [bool] event_to_trigger_key_bound_command( $params ){   # View/PopupMenu/Cabinet

        $source =   [string]($args[0].Name) # ⇒ Application, Cabinet, PopupMenu
        $mod =      [string]($args[1].KeyboardDevice.Modifiers)
        $key =      if( $mod -in @('Alt','Alt, Shift') ){ [string]($args[1].SystemKey) }else{ [string]($args[1].Key) }
        $tttv  =    [TTTentativeKeyBindingMode]::Name
        $panel =    $global:State._get('Focus.Application')
        $global:TTKeyEventMod = $mod
        $global:TTKeyEventKey = $key
        
        if( $key.Contains('Alt') -or $key.Contains('Control') ){ return $false }
    
        $command = 
            if( $source -eq 'Application' ){        #### Application
                $cmd = ''
                if( $tttv -ne '' ){                 #### tentative Index/Library/Shelf
                    $panel = $tttv
                    $cmd = try{ $global:TTKeyEvents["$panel+"][$mod][$key] }catch{ $null }
        
                }else{                              #### non tentative
                    $cmd = try{ $global:TTKeyEvents['Application'][$mod][$key] }catch{ $null }
        
                    if( 0 -ne $cmd.length ){    #### Application
                        $panel = $source
        
                    }else{
                        if( $panel -match "(?<panel>Editor|Browser|Grid)[123]" ){
                            $cmd = try{ $global:TTKeyEvents[$Matches.panel][$mod][$key] }catch{ $null }
        
                        }elseif( $panel -eq 'Desk' ){
                            $cmd = try{ $global:TTKeyEvents['Desk'][$mod][$key] }catch{ $null }
        
                        }else{                      #### normal Index/Library/Shelf
                            $cmd = @( "$panel+", $panel ).foreach{
                                try{ $global:TTKeyEvents[$_][$mod][$key] }catch{ $null }
                            }.where{ $null -ne $_ }[0]
                        }
                    }
                }
                $cmd
                
            }else{                                  #### PopupMenu / Cabinet 
                $panel = $source
                try{ $global:TTKeyEvents[$panel][$mod][$key] }catch{ $null }    
        
            }
        
        if( 0 -ne $command.length ){            #### Invoke Command
            if( $global:TTKeyEventMessage ){
                Write-Host "PreviewKeyDown source:$source, tentative:$tttv, panel:$panel, mod:$mod, key:$key, command:$command"
            }
            Invoke-Expression "$command '$panel' '$mod' '$key'"
            return $true 
            
        }else{                                  #### no such key binding
            return $false
        }
        
    }
    [bool] event_to_terminate_tentative_mode( $params ){    # View/PopupMenu/Cabinet
        if( [TTTentativeKeyBindingMode]::Check( $params[1].Key ) ){
            return $False
        }
        return $False
    }
    [bool] event_to_move_focus_to_main( $params ){          # Library/Index/Shelf/Cabinet
        if( $params[0].Name -match "(?<panel>Library|Index|Shelf|Cabinet).*" ){
            $panel = $Matches.panel
            $global:View.$panel.focus( $Matches.panel, '', '' ) # tentative処理を誰がするか
        }
        return $false
    }
    [bool] event_to_sort_datagrid_after_onsort( $params ){  # Library/Index/Shelf/Cabinet
        $panel = ( $params[0].Name -replace "(Library|Index|Shelf|Cabinet).*", '$1' )
        $e = $params[1]
        $e.Handled = $false
        $colname = $e.Column.Header
        $global:View.$panel.sort( $panel, $colname, 'toggle' )

        return $false
    }
    [bool] event_to_invoke_action_after_click_on_datagrid( $params ){ # Library/Index/Shelf/Cabinet
        $panel =    ($params[0].Name -replace "(Library|Index|Shelf).*",'$1')
        $mouse =    $params[1]
        switch( $mouse.ChangedButton ){
            ([Input.MouseButton]::Left) {
                if( $mouse.ClickCount -eq 2 ){
                    $this.invoke( $panel )
                    $mouse.Handled = $true
                }
            }
            ([Input.MouseButton]::Right) {
                if( $mouse.ClickCount -eq 1 ){
                    $this.select_and_invoke( $panel )
                    $mouse.Handled = $true
                }
            }
        }
        return $false
    }
    [bool] event_to_save_after_text_change_on_editor( $params ){    # Editor
        $editor = $params[0]
        $num = [int][string]($editor.Name[-1])

        if( $global:View.Document.Editor.UpdateFolding($num) ){ 
            TTTimerResistEvent "event_to_save_after_text_change_on_editor(Editor$num)" 10 0 { 
                $global:View.Document.Editor.Save($num)
            }.GetNewClosure()
        }

        return $false
    }
    [bool] event_to_invoke_action_after_click_on_editor( $params ){ # Editor
        $editor =   $params[0]
        $mouse =    $params[1]
    
        switch( $mouse.ChangedButton ){
            ([Input.MouseButton]::Left) {
                if( $mouse.ClickCount -eq 2 ){
                    $pos = $editor.GetPositionFromPoint( $mouse.GetPosition($editor) )
                    [TTTagAction]::New( $editor ).invoke( $pos.Line, $pos.Column )
                    $mouse.Handled = $true
                }
            }
        }

        return $false
    }
    [bool] event_to_open_file_after_file_dropped( $params ){        # 未実装

        return $false

        $editor = $params[0]
        $drag = $params[1]
        Write-Host $drag   
        # 要修正
    
    }

    [bool] event_to_sort_datagrid_after_onsort( $params ){}
    
    #endregion ----------------------------------------------------------------------------------------------------------
}





<#
class TTGroupController {
    #region variants/ new/ initialize
    [TTApplicationController] $app

    TTGroupController( [TTApplicationController] $_app){
        $this.app = $_app
    }
    [TTGroupController] initialize(){

        $this.load( 'Library', 'Thinktank' )
        $this.load( 'Shelf',    $this.app._get('Shelf.Resource') )
        $this.load( 'Index',    $this.app._get('Index.Resource') )
        $this.load( 'Cabinet',  $this.app._get('Cabinet.Resource') )

        $this.caption( 'Desk', '' )
        $this.keyword( 'Desk', $this.app._get('Desk.Keyword') )

        $this.focus( $this.app._get('Focus.Application'), '', '' )

        return $this
    }
    #endregion



    #region reload/ load/ cursor/ sort/ extract/ selected/ refresh 
    #Library/Index/Shelf/Cabinet
    [TTGroupController] reload( $panel ){
        return $this.load( $panel, $this.app._get( "$panel.Resource" ) )
    }
    [TTGroupController] load( [string]$panel, [string]$name ){

        $curname = $this.app._get( "$panel.Resource" )
        $this.app._set( "$panel.$curname.Keyword",  $this.app._get( "$panel.Keyword" ) )
        $this.app._set( "$panel.$curname.Sort.Column",  $this.app._get( "$panel.Sort.Column" ) )
        $this.app._set( "$panel.$curname.Sort.Dir",  $this.app._get( "$panel.Sort.Dir" ) )
        $this.app._set( "$panel.$curname.Selected", $this.app._get( "$panel.Selected" ) )

        $displayalert = [TTPanelManager]::DisplayAlert
        [TTPanelManager]::DisplayAlert = $false

        $this.app._set( "$panel.Resource", $name )
        $this.caption( $panel, '' )
        $this.keyword( $panel, $this.app._get("$panel.$name.Keyword") )
        $res = $global:Model.GetChild( $name )
        $global:View.$panel.Items( $res.GetChildren(), $res.Child().GetDictionary(), $res.Child().GetDisplay().$panel.split(',') )
        $sortc = $this.app._get("$panel.$name.Sort.Column")
        $sortd = $this.app._get("$panel.$name.Sort.Dir")
        $this.sort( $panel, $sortc, $sortd )

        $selected = $this.app._get("$panel.$name.Selected")
        $this.cursor( $panel, $selected )

        [TTPanelManager]::DisplayAlert = $displayalert

        $this.refresh('Library')

        return $this
    }
    [TTGroupController] extract( [string]$panel ){
        $pn = $panel
        TTTimerResistEvent "$panel:extract" 2 0 {
            $global:View.$script:pn.Extract()
        }.GetNewClosure()
        return $this
    }
    [TTGroupController] refresh( [string]$panel ){
        $res = $this.app._get("$panel.Resource")
        switch( $res ){
            'Memos' { 
                $idx = $global:View.Document.Editor.Indices
                $global:View.$panel._datagrid.Items.foreach{
                    if( $_.MemoID -in $idx ){
                        $_.flag = $idx.IndexOf($_.MemoID) + 1
                    }else{
                        $_.flag = ''
                    }
                }
            }
            'Thinktank' {
                @('Index','Shelf','Cabinet').foreach{
                    $pan = $_
                    $panel_res = $this.app._get("$_.Resource")
                    $global:View.Library._datagrid.Items.foreach{
                        if( $_.Name -in $panel_res ){
                            $_.flag = [string]($pan[0])
                        }else{
                            $_.flag = ''
                        }
                    }
                }
            }
        }

        $global:View.$panel.Refresh()
        return $this
    }

    #endregion


}


#>
