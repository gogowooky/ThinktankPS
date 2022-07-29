


using namespace System.Windows.Controls
using namespace System.Windows 
using namespace System.Xml
using namespace System.Windows.Input
using namespace System.Windows.Documents


class TTApplicationController {
    #region variants/ new/ default/ initialize_application
    [TTMenuController] $menu
    [TTViewController] $view
    [TTGroupController] $group
    [TTToolsController] $tools
    [TTStatus] $status
    [TTConfigs] $configs

    TTApplicationController(){
        $this.menu = [TTMenuController]::New( $this )
        $this.view = [TTViewController]::New( $this )
        $this.group = [TTGroupController]::New( $this )
        $this.tools = [TTToolsController]::New( $this )

        $this.status = $global:TTResources.GetChild( "Status" )
        $this.configs = $global:TTResources.GetChild( "Configs" )

        $this.status.OnSave = $global:TTStatus_OnSave
    }
    [TTApplicationController] default(){

        $this._set( 'Application.Name',          "Thinktank" )
        $this._set( 'Application.Version',       "0.6.1" )
        $this._set( 'Application.LastModified',  "2022/06/01" )
        $this._set( 'Application.Author.Name',   "Shinichiro Egashira" )
        $this._set( 'Application.Author.Mail',   "gogowooky@gmail.com" )
        $this._set( 'Application.Author.Site',   "https://github.com/gogowooky" )

        $this._set( 'Config.CacheSavedMessage',   'False' )
        $this._set( 'Config.MemoSavedMessage',    'True' )
        $this._set( 'Config.TaskExpiredMessage',  'False' )
        $this._set( 'Config.KeyDownMessage',      'False' )
        $this._set( "Config.TaskResisterMessage", 'False' )

        [void] $this.menu.default()
        [void] $this.view.default()
        [void] $this.group.default()
        [void] $this.tools.default()

        return $this
    }
    [TTApplicationController] initialize_application(){

        $this.default()

        $this.configs.GetChildren().foreach{ if( $this._isnull( $_.Name ) ){ $this._set( $_.Name, $_.Value ) } }
        $this.status.GetChildren().foreach{ $this._set( $_.Name, $_.Value ) }

        [void] $this.menu.initialize()
        [void] $this.view.initialize()
        [void] $this.group.initialize()
        [void] $this.tools.initialize()

        return $this
    }

    #endregion

    #region status
    [string] _get( $name ){
        return $this.status.Get( $name )
    }
    [void] _set( $name, $value ){
        $this.status.Set( $name, $value )

        return 
        switch -regex ( $name ){
            'Config.TaskResisterMessage' {
                $global:TTTimerResistMessage = ( $value -eq 'True' )
            } 
            'Config.TaskExpiredMessage' {
                $global:TTTimerExpiredMessage = ( $value -eq 'True' )
            }
            # '(?<tool>Editor.)\.WordWrap' {
            #     if( $value -eq 'toggle' ){ $value = [string]$this._isfalse( $name ) }
            #     # $script:DocMan.Tool( $Matches.tool ).SetConfiguration( "WordWrap", $value)
            #     $this.status.Set( $name, $value )
            # }
            # 'Application.Focused' {
            #     return
            #     $script:library.caption('-')
            #     $script:index.caption('-')
            #     $script:shelf.caption('-')
            #     $script:desk.caption('-')
            #     switch( $value ){
            #         'Library'   { $script:library.caption('*') }
            #         'Index'     { $script:index.caption('*') }
            #         'Shelf'     { $script:shelf.caption('*') }
            #         'Desk'      { $script:desk.caption('*') }
            #         default     { $script:desk.caption('+') }
            #     }
            # }
        }
    }
    [bool] _like( $name, $value ){
        return ( $this._get( $name ) -like $value )
    }
    [bool] _notlike( $name, $value ){
        return ( $this._get( $name ) -notlike $value )
    }
    [bool] _match( $name, $value ){
        return ( $this._get( $name ) -match $value )
    }
    [bool] _notmatch( $name, $value ){
        return ( $this._get( $name ) -notmatch $value )
    }
    [bool] _eq( $name, $value ){
        return ( $this._get( $name ) -eq $value )
    }
    [bool] _ne( $name, $value ){
        return ( $this._get( $name ) -ne $value )
    }
    [bool] _in( $name, $value ){
        return ( $this._get( $name ) -in $value )
    }
    [bool] _notin( $name, $value ){
        return ( $this._get( $name ) -notin $value )
    }
    [bool] _istrue( $name ){
        return ( $this._get( $name ) -eq $true )
    }
    [bool] _isfalse( $name ){
        return ( $this._get( $name ) -eq $false )
    }
    [bool] _isnull( $name ){
        return ( $this._get( $name ).length -eq 0 )
    }
    #endregion

    #region dialog
    [bool] dialog( $id ){ 
        switch( $id ){
            'site'      { [TTTool]::message( "Githubへのリンク", "Thinktank" ) }
            'version'   { [TTTool]::message( "Thinktankのバージョン", "Thinktank" ) }
            'shortcut'  { [TTTool]::message( "ショートカットキーの一覧", "Thinktank" ) }
            'help'      { [TTTool]::message( "使い方を表示する", "Thinktank" ) }
            'about'     { [TTTool]::message( "このアプリは何なのかについて表示する", "Thinktank" ) }
        }
        return $true
   
    }
    #endregion

    #region event
    [bool] event_set_focus_panel( $params ){ 

        [TTTool]::debug_message( $params[0].Name, "event_set_focus_panel" )

        switch -regex ( $params[0].Name ){
            "(?<name>Library|Index|Shelf|Desk)" {
                $this._set( 'Focus.Panel', $Matches.name )
            }
        }
        return $true
    }
    [bool] event_set_focus_application( $params ){ 

        [TTTool]::debug_message( $params[0].Name, "event_set_focus_application" )

        switch -regex ($this._get('Focus.Application')){    #### Unmark
            "(Library|Index|Shelf|Desk)" {
                $global:AppMan.$_.FocusMark('')
            }
            "(Editor|Browser|Grid)[123]" {
                $global:AppMan.Desk.FocusMark('')
            }
        }

        switch -regex ( $params[0].Name ){                  #### Mark
            "(?<name>Library|Index|Shelf|Desk)" {
                $this._set( 'Focus.Application', $Matches.name )
                $global:AppMan.($this._get('Focus.Application')).FocusMark('●')

            }
            "(?<name>Editor|Browser|Grid)(?<num>[123])" {
                $num = [int]($Matches.num)
                $name= $Matches.name
                $this._set( 'Current.Workplace', "Work$num" )
                $this._set( 'Current.Tool', $name )
                $this._set( 'Focus.Application', $Matches[0] )
                $global:AppMan.Desk.FocusMark("●[$($_[0])$($_[-1])]") # Editor1 → E1
                switch($name){ # Desk caption
                    'Editor' {
                        $index = $global:AppMan.Document.Editor.Indices[$num-1]
                        $title = $global:TTResources.GetChild('Memos').GetChild($index).Title
                        $this.group.caption( 'Desk', "[$index] $title")
                    }
                }
                $global:AppMan.Document.CurrentNumber = $num
            }
        }
        return $true
    }
    [bool] event_refocus( $params ){ # Library/Index/Shelf/Desk/Cabinet
        if( $params[0].Name -match "(?<panel>Library|Index|Shelf|Cabinet).*" ){
            $this.group.focus( $Matches.panel, '', '' )
            return $true
        }
        return $false
    }

    [bool] event_set_border( $params ){
        return $true
        $panel = $params[0].Name
        switch -wildcard ( $panel ){
            'Library*' {
                TTTimerResistEvent "event_set_border:$_" 2 0 {
                    $global:appcon._set( 'Layout.Library.Width', [string]$global:AppMan.Border('Layout.Library.Width') )
                    $global:appcon._set( 'Layout.Library.Height', [string]$global:AppMan.Border('Layout.Library.Height') )
                }    
            }
            'Shelf*' {
                TTTimerResistEvent "event_set_border:$_" 2 0 {
                    $global:appcon._set( 'Layout.Shelf.Height', [string]$global:AppMan.Border('Layout.Shelf.Height') )
                }    
            }
            'Work1*' {
                TTTimerResistEvent "event_set_border:$_" 2 0 {
                    $global:appcon._set( 'Layout.Work1.Width', [string]$global:AppMan.Border('Layout.Work1.Width') )
                    $global:appcon._set( 'Layout.Work1.Height', [string]$global:AppMan.Border('Layout.Work1.Height') )
                }    
            }
        }
        return $true

    }
    [bool] event_save_status( $params ){ 
        $collection = $params[0]
        @( 'Library', 'Index', 'Shelf' ).where{
            $global:appcon._get("$_.Resource") -eq $collection.Name
        }.foreach{
            # $global:appcon.group.refresh($_)
        }
        return $true
    }
    #endregion

}
class TTViewController {
    #region variants/ new/ default/ initialize
    [TTApplicationController] $app

    TTViewController( [TTApplicationController] $_app ){
        $this.app = $_app
    }
    [TTViewController] default(){

        $this.app._set( 'Window.Left',   '0' )
        $this.app._set( 'Window.Top',    '0' )
        $this.app._set( 'Window.State',  'Max' )
        $this.app._set( 'ListMenu.Left',   '0' )
        $this.app._set( 'ListMenu.Top',    '0' )
        $this.app._set( 'Layout.Library.Width',     '15' )
        $this.app._set( 'Layout.Library.Height',    '25' )
        $this.app._set( 'Layout.Shelf.Height',      '25' )
        $this.app._set( 'Layout.Work1.Width',       '70' )
        $this.app._set( 'Layout.Work1.Height',      '70' )
        $this.app._set( 'Layout.Library.ExWidth',   '50' )
        $this.app._set( 'Layout.Shelf.ExHeight',    '75' )
        $this.app._set( 'Layout.Work1.ExHeight',    '80' )
        $this.app._set( 'Layout.Work1.ExWidth',     '20' )
    
        return $this
    }
    [TTViewController] initialize(){

        $this.window( 'Left',   $this.app._get('Window.Left') )
        $this.window( 'Top',    $this.app._get('Window.Top') )
        $this.window( 'State',  $this.app._get('Window.State') )
        $this.border( 'Layout.Library.Width',   $this.app._get('Layout.Library.Width') )
        $this.border( 'Layout.Library.Height',  $this.app._get('Layout.Library.Height') )
        $this.border( 'Layout.Shelf.Height',    $this.app._get('Layout.Shelf.Height') )
        $this.border( 'Layout.Work1.Width',     $this.app._get('Layout.Work1.Width') )
        $this.border( 'Layout.Work1.Height',    $this.app._get('Layout.Work1.Height') )


        return $this
    }
    #endregion

    #region style/ focusable/ window/ border    
    [TTViewController] style( [string] $name, [string] $value ){
        switch( $name ){
            'Group' { # Standard, Zen, toggle/revtgl
                $order = @( 'Standard', 'Zen' )
                switch( $value ){
                    'Standard' {
                        $global:AppMan.Border( 'Layout.Library.Width', $this.app._get('Layout.Library.Width') )
                        $global:AppMan.Border( 'Layout.Library.Height', $this.app._get('Layout.Library.Height') )
                        $global:AppMan.Border( 'Layout.Shelf.Height', $this.app._get('Layout.Shelf.Height') )
                        $this.app._set( 'Layout.Style.Group', $value )
                    }
                    'Zen' {
                        $this.app._set( 'Layout.Library.Width', $global:AppMan.Border('Layout.Library.Width') )
                        $this.app._set( 'Layout.Library.Height', $global:AppMan.Border('Layout.Library.Height') )
                        $this.app._set( 'Layout.Shelf.Height', $global:AppMan.Border('Layout.Shelf.Height') )
                        $global:AppMan.Border( 'Layout.Library.Width', 0 )
                        $global:AppMan.Border( 'Layout.Shelf.Height', 0 )
                        $this.app._set( 'Layout.Style.Group', $value )
                        $this.app.group.focus( $this.app._get('Current.Workplace'), '', '' )
                    }
                    'toggle' {
                        $this.style( $name, [TTTool]::toggle( $this.app._get('Layout.Style.Group'), $order ) )
                    }
                    'revtgl' {
                        $this.style( $name, [TTTool]::revtgl( $this.app._get('Layout.Style.Group'), $order ) )
                    }
                }

            }
            'Work' { # Work1, Work2, Work3, toggle/revtgl
                $order = @( 'Work1', 'Work2', 'Work3' )
                $work1 = @{}
                switch( $value ){
                    'Work1' { $work1 = @{ width = 100;  height = 100 } }
                    'Work2' { $work1 = @{ width = 0;    height = 100 } }
                    'Work3' { $work1 = @{ width = 0;    height = 0 } }
                    'toggle' { return $this.style( 'Work', [TTTool]::toggle( $this.app._get('Layout.Style.Work'), $order ) ) }
                    'revtgl' { return $this.style( 'Work', [TTTool]::revtgl( $this.app._get('Layout.Style.Work'), $order ) ) }
                }
                $global:AppMan.Border( 'Layout.Work1.Width', $work1.width )
                $global:AppMan.Border( 'Layout.Work1.Height', $work1.height )
                $this.app._set( 'Layout.Style.Work', $value )
                $this.app.group.focus( $value, '', '' )

            }
            'Focus+Work' { # Workplace≧2 → focusWork, Workplace=1 → Work+Focus
                $focusable_tools = @( 'Work1', 'Work2', 'Work3' ).where{ $global:AppMan.Focusable($_) }
                if( 1 -lt $focusable_tools.count ){
                    $work = $this.app._get('Current.Workplace')
                    switch( $value ){
                        'toggle' { $work = [TTTool]::toggle( $work, $focusable_tools ) }
                        'revtgl' { $work = [TTTool]::revtgl( $work, $focusable_tools ) }
                    }
                    $this.app.group.focus( $work, '', '' )

                }else{
                    $this.style( 'Work', $value )

                }

            }
            'Desk' { # Work12, Work123, Work13, toggle/revtgl
                $order = @( 'Work12', 'Work123', 'Work13' )
                switch( $value ){
                    'Alone' {
                        $this.app._set( 'Layout.Work1.Width', $global:AppMan.Border('Layout.Work1.Width') )
                        $this.app._set( 'Layout.Work1.Height', $global:AppMan.Border('Layout.Work1.Height') )
                        $global:AppMan.Border( 'Layout.Work1.Width', 100 )
                        $global:AppMan.Border( 'Layout.Work1.Height', 100 )
                        $work = $this.app._get('Current.Workplace')
                        $this.style( 'Work', $work )
                        $this.app.group.focus( $work, '', '' )
                    }
                    'Work12' {
                        $this.app._set( 'Layout.Work1.Height', $global:AppMan.Border('Layout.Work1.Height') )
                        $global:AppMan.Border( 'Layout.Work1.Width', $this.app._get('Layout.Work1.Width') )
                        $global:AppMan.Border( 'Layout.Work1.Height', 100 )
                        $this.app._set( 'Layout.Style.Desk', $value )                
                    }
                    'Work123' {
                        $global:AppMan.Border( 'Layout.Work1.Width', $this.app._get('Layout.Work1.Width') )
                        $global:AppMan.Border( 'Layout.Work1.Height', $this.app._get('Layout.Work1.Height') )
                        $this.app._set( 'Layout.Style.Desk', $value )                
                    }
                    'Work13' {
                        $this.app._set( 'Layout.Work1.Width', $global:AppMan.Border('Layout.Work1.Width') )
                        $global:AppMan.Border( 'Layout.Work1.Width', 100 )
                        $global:AppMan.Border( 'Layout.Work1.Height', $this.app._get('Layout.Work1.Height') )
                        $this.app._set( 'Layout.Style.Desk', $value )                
                    }
                    'toggle' {
                        $this.style( $name, [TTTool]::toggle( $this.app._get('Layout.Style.Desk'), $order ) )
                    }
                    'revtgl' {
                        $this.style( $name, [TTTool]::revtgl( $this.app._get('Layout.Style.Desk'), $order ) )
                    }
                }

            }
            'Library' { # None, Default, Extent , toggle/revtgl
                $order = @( 'None', 'Default', 'Extent' )
                switch( $value ){
                    'None' {
                        $global:AppMan.Border( 'Layout.Library.Width', 0 )
                        $this.app._set( 'Layout.Style.Library', $value )
                    }
                    'Default' {
                        $global:AppMan.Border( 'Layout.Library.Width', $this.app._get('Layout.Library.Width') )
                        $this.app._set( 'Layout.Style.Library', $value )
                    }
                    'Extent' {
                        $width = $this.app._get('Layout.Library.Width') + 10
                        $this.border( 'Layout.Library.Width', $width )
                        $this.app._set( 'Layout.Style.Library', $value )
                    }
                    'toggle' {
                        $this.style( $name, [TTTool]::toggle( $this.app._get('Layout.Style.Library'), $order ) )
                    }
                    'revtgl' {
                        $this.style( $name, [TTTool]::revtgl( $this.app._get('Layout.Style.Library'), $order ) )
                    }
                }
            }
            'Index' { # None, Default, Extent , toggle/revtgl
                $order = @( 'None', 'Default', 'Extent' )
                switch( $value ){
                    'None' {
                        $global:AppMan.Border( 'Layout.Library.Height', 100 )
                        $this.app._set( 'Layout.Style.Index', $value )
                    }
                    'Default' {
                        $global:AppMan.Border( 'Layout.Library.Height', $this.app._get('Layout.Library.Height') )
                        $this.app._set( 'Layout.Style.Index', $value )
                    }
                    'Extent' {
                        $global:AppMan.Border( 'Layout.Library.Height', 0 )
                        $this.app._set( 'Layout.Style.Index', $value )
                    }
                    'toggle' {
                        $this.style( $name, [TTTool]::toggle( $this.app._get('Layout.Style.Index'), $order ) )
                    }
                    'revtgl' {
                        $this.style( $name, [TTTool]::revtgl( $this.app._get('Layout.Style.Index'), $order ) )
                    }
                }
            }
            'Shelf' { # None, Default, Extent, Full, toggle/revtrgl
                $order = @( 'None', 'Default', 'Extent', 'Full' )
                switch( $value ){
                    'None' {
                        $global:AppMan.Border( 'Layout.Shelf.Height', 0 )
                        $this.app._set( 'Layout.Style.Shelf', $value )
                    }
                    'Default' {
                        $global:AppMan.Border( 'Layout.Shelf.Height', $this.app._get('Layout.Shelf.Height') )
                        $this.app._set( 'Layout.Style.Shelf', $value )
                    }
                    'Extent' {
                        $width = $this.app._get('Layout.Shelf.Height') + 20
                        $global:AppMan.Border( 'Layout.Shelf.Height', $width )
                        $this.app._set( 'Layout.Style.Shelf', $value )
                    }
                    'Full' {
                        $global:AppMan.Border( 'Layout.Shelf.Height', 100 )
                        $this.app._set( 'Layout.Style.Shelf', $value )
                    }
                    'toggle' {
                        $this.style( $name, [TTTool]::toggle( $this.app._get('Layout.Style.Shelf'), $order ) )
                    }
                    'revtgl' {
                        $this.style( $name, [TTTool]::revtgl( $this.app._get('Layout.Style.Shelf'), $order ) )
                    }
                }
            }
        }

        return $this
    }
    [bool] focusable( $id ){
        return $global:AppMan.Focusable( $id )
    }
    [TTViewController] window( [string] $name, [string] $value ){
        switch( $name ){
            'State' { 
                switch( $value ){
                    'toggle' { $value = [TTTool]::toggle( $this.app._get('Window.State'), @('Max', 'Normal') ) }
                    'revtgl' { $value = [TTTool]::revtgl( $this.app._get('Window.State'), @('Max', 'Normal') ) }
                }
                $global:AppMan.Window( $value )
                $this.app._set( 'Window.State',  $value )
            }
            'Top' {
                $global:AppMan.Top( $value )
                $this.app._set( 'Window.Top',  $value )
            }
            'Left' {
                $global:AppMan.Left( $value )
                $this.app._set( 'Window.Left',  $value )
            }
        }
        return $this
    }
    [TTViewController] border( [string] $name, [string] $value ){

        $percent = [int]$value
        if( $value -match "^[+-]\d+$" ){ $percent += [int]$this.app._get( $name ) }

        if( $percent -lt 0 ){ $percent = 0 }
        if( 100 -lt $percent ){ $percent = 100 }

        $global:AppMan.Border( $name, $percent )
        $this.app._set( $name, [string]$percent )

        return $this

    }
    #endregion
}
class TTGroupController {
    #region variants/ new/ default/ initialize
    [TTApplicationController] $app

    TTGroupController( [TTApplicationController] $_app){
        $this.app = $_app
    }
    [TTGroupController] default(){

        $this.app._set( 'Library.Resource',     'Thinktank' )
        $this.app._set( 'Library.Keyword',      '' )
        $this.app._set( 'Library.Sort.Dir',     'Descending' )
        $this.app._set( 'Library.Sort.Column',  'UpdateDate' )
        $this.app._set( 'Library.Selected',     'Memos' )

        $this.app._set( 'Index.Resource',       'Status' )
        $this.app._set( 'Index.Keyword',        '' )
        $this.app._set( 'Index.Sort.Dir',       'Descending' )
        $this.app._set( 'Index.Sort.Column',    'Name' )
        $this.app._set( 'Index.Selected',       'Application.Author.Name' )

        $this.app._set( 'Shelf.Resource',       'Memos' )
        $this.app._set( 'Shelf.Keyword',        '' )
        $this.app._set( 'Shelf.Sort.Dir',       'Descending' )
        $this.app._set( 'Shelf.Sort.Column',    'UpdateDate' )
        $this.app._set( 'Shelf.Selected',       'thinktank' )

        $this.app._set( 'Cabinet.Resource',       'Commands' )
        $this.app._set( 'Cabinet.Keyword',        '' )
        $this.app._set( 'Cabinet.Sort.Dir',       'Descending' )
        $this.app._set( 'Cabinet.Sort.Column',    'UpdateDate' )
        $this.app._set( 'Cabinet.Selected',       'ttcmd_application_window_quit' )

        $this.app._set( 'Desk.Keyword', '' )

        $this.app._set( 'Focus.Application',  'Library' )

        return $this
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

    #region invoke_action/ select_actions_then_invoke
    [bool] invoke_action( [string]$panel ){
        $items = $global:AppMan.$panel.SelectedItems()
        return $items[0].InvokeAction( 'Action', $items )
    }

    [bool] select_actions_then_invoke( [string]$panel ){
        $items = $global:AppMan.$panel.SelectedItems()

        $title = "{0}:{1}:アクション選択" -f $global:AppMan.$panel.Caption(), $panel
        $actions = $items[0].GetActions()
        $selected = $global:AppMan.PopupMenu.Caption( $title ).Items( $actions.Keys ).Show()

        $selected.foreach{
            $action = $actions[$_]
            $items[0].InvokeAction( $action, $items )
        }
        return $true
    }
    #endregion

    #region caption/ keyword(io)/ focus
    # Library/Index/Shelf/Desk/Cabinet
    [TTGroupController] caption( [string]$panel, [string]$text ){
        $global:AppMan.$panel.Caption( $text )
        return $this
    }
    [TTGroupController] keyword( [string]$panel, [string]$text ){
        $global:AppMan.$panel.Keyword( $text )
        $this.app._set( "$panel.Keyword", $text )
        return $this
}
    [string] keyword( [string]$panel ){
        return $global:AppMan.$panel.Keyword()
    }
    [TTGroupController] focus( $panel, $mod, $key ){

        if( $panel -match "(?<panel>Library|Index|Shelf)\+" ){                      #### tentative focus

            $tentative_panel = $Matches.panel

            if( $this.app._ne( 'Focus.Application', $tentative_panel ) ){

                if( [TTTentativeKeyBindingMode]::IsNotActive() ){                   #:::: to go tentative mode
                    $nopanel = ( $this.app.view.focusable( $tentative_panel ) -eq $false )
                    if( $nopanel ){ $this.app.view.style( $tentative_panel, 'Default' ) }
            
                    [TTTentativeKeyBindingMode]::Start( $tentative_panel, $mod, $key )
                    [TTTentativeKeyBindingMode]::Add_OnExit({
                        if( $script:nopanel ){ $global:appcon.view.style( $script:ttp, 'None' ) }
                    }.GetNewClosure() )

                }elseif( [TTTentativeKeyBindingMode]::Name -eq $tentative_panel ){  #:::: to cancel tentative mode
                    $global:AppMan.Focus( $tentative_panel )

                }
            }

        }else{                                                                      #### normal focus
            $global:AppMan.Focus( $panel )

        }

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
        $res = $global:TTResources.GetChild( $name )
        $global:AppMan.$panel.Items( $res.GetChildren(), $res.Child().GetDictionary(), $res.Child().GetDisplay().$panel.split(',') )
        $sortc = $this.app._get("$panel.$name.Sort.Column")
        $sortd = $this.app._get("$panel.$name.Sort.Dir")
        $this.sort( $panel, $sortc, $sortd )

        $selected = $this.app._get("$panel.$name.Selected")
        $this.cursor( $panel, $selected )

        [TTPanelManager]::DisplayAlert = $displayalert

        $this.refresh('Library')

        return $this
    }
    [TTGroupController] cursor( [string]$panel, [string]$to ){
        $global:AppMan.$panel.Column('index').Cursor( $to )
        $this.app._set( "$panel.Selected", $this.selected( $panel ) )
        return $this
    }
    [TTGroupController] sort( [string]$panel, [string]$colname, [string]$dir ){
        $sortc, $sortd = $global:AppMan.$panel.Column( $colname ).Sort( $dir ).Sort()
        $global:AppMan.$panel.Alert( "'$sortc'を$($sortd)でソート", 2 )
        $this.app._set( "$panel.Sort.Dir", $sortd )
        $this.app._set( "$panel.Sort.Column", $sortc )

        return $this
    }
    [TTGroupController] extract( [string]$panel ){
        $pn = $panel
        TTTimerResistEvent "$panel:extract" 2 0 {
            $global:AppMan.$script:pn.Extract()
        }.GetNewClosure()
        return $this
    }
    [string] selected( [string]$panel ){
        return $global:AppMan.$panel.SelectedIndex()
    }
    [TTGroupController] refresh( [string]$panel ){
        $res = $this.app._get("$panel.Resource")
        switch( $res ){
            'Memos' { 
                $idx = $global:AppMan.Document.Editor.Indices
                $global:AppMan.$panel._datagrid.Items.foreach{
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
                    $global:AppMan.Library._datagrid.Items.foreach{
                        if( $_.Name -in $panel_res ){
                            $_.flag = [string]($pan[0])
                        }else{
                            $_.flag = ''
                        }
                    }
                }
            }
        }

        $global:AppMan.$panel.Refresh()
        return $this
    }

    #endregion

    #region events
    [bool] event_sort_datagrid( $params ){ # Library/Index/Shelf/Desk/Cabinet
        $panel = ( $params[0].Name -replace "(Library|Index|Shelf|Cabinet).*", '$1' )
        $e = $params[1]
        $e.Handled = $false
        $colname = $e.Column.Header
        $this.sort( $panel, $colname, 'toggle' )

        return $true
    }
    [bool] event_selection_change_datagrid( $params ){ # Library/Index/Shelf/Desk/Cabinet
        $panel = ( $params[0].Name -replace "(Library|Index|Shelf|Cabinet).*", '$1' )
        $index = $this.selected( $panel )
        $this.app._set( "$panel.Selected", $index )
        $this.caption( $panel, $index )

        return $true
    }
    [bool] event_select_datagrid_item_by_mouse( $params ){
        $panel =    ($params[0].Name -replace "(Library|Index|Shelf).*",'$1')
        $mouse =    $params[1]
        switch( $mouse.ChangedButton ){
            ([Input.MouseButton]::Left) {
                if( $mouse.ClickCount -eq 2 ){
                    $this.invoke_action( $panel )
                    $mouse.Handled = $true
                }
            }
            ([Input.MouseButton]::Right) {
                if( $mouse.ClickCount -eq 1 ){
                    $this.select_actions_then_invoke( $panel )
                    $mouse.Handled = $true
                }
            }
        }
        return $true
    }
    [bool] event_extract_datagrid_items( $params ){
        $panel = ( $params[0].Name -replace "(Library|Index|Shelf|Cabinet).*", '$1' )
        $this.app._set( "$panel.Keyword", $this.keyword( $panel ) )
        $this.extract( $panel )
    
        return $true
    }
    [bool] event_highlight_text_on_editor( $params ){

        $text = $global:AppMan.Desk._textbox.Text.Trim()
        $this.app._set( 'Desk.Keyword', $text )

        TTTimerResistEvent "Desk:event_highlight_text_on_editor" 1 0 {

            $text = $global:AppMan.Desk._textbox.Text.Trim()

            for( $num = 0; $num -lt 3; $num++ ){
                $editor =   $global:AppMan.Document.Editor.Controls[$num]
                $rules =    $global:AppMan.Document.Editor.HightlightRules[$num]
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

        $global:AppMan.Document.Editor.Controls.foreach{ $_.TextArea.TextView.Redraw() }

        return $true
    }
    #endregion 

}
class TTToolsController {
    #region variants/ new/ default/ initialize
    [TTApplicationController] $app
    [TTEditorController] $editor
    [TTBrowserController] $browser
    [TTGridController] $grid

    TTToolsController( [TTApplicationController] $_app){
        $this.app = $_app
        $this.editor = [TTEditorController]::new( $this )
        $this.browser = [TTBrowserController]::new( $this )
        $this.grid = [TTGridController]::new( $this )
    }
    [TTToolsController] default(){

        $this.app._set( 'Work1.Tool', 'Editor' )
        $this.app._set( 'Work2.Tool', 'Editor' )
        $this.app._set( 'Work3.Tool', 'Editor' )
        $this.app._set( 'Current.Workspace', 'Work1' )
        $this.app._set( 'Current.Tool', 'Editor1' )

        [void] $this.editor.default()
        [void] $this.browser.default()
        [void] $this.grid.default()
        
        return $this
    }
    [TTToolsController] initialize(){

        $this.tool( 'Work1', $this.app._get('Work1.Tool') )
        $this.tool( 'Work2', $this.app._get('Work2.Tool') )
        $this.tool( 'Work3', $this.app._get('Work3.Tool') )

        $this.current( [int][string]($this.app._get('Current.Workspace')[-1]) )

        [void] $this.editor.initialize()
        [void] $this.browser.initialize()
        [void] $this.grid.initialize()

        return $this
    }
    #endregion

    #region tool/ current/ focus
    [TTToolsController] tool( [string]$work, [string]$tool ){
        $this.app._set( "$work.Tool", $tool )
        $global:AppMan.Document.SelectTool( [int][string]$work[-1], $tool )
        return $this
    }
    [TTToolsController] current( [int]$num ){
        $this.app._set( "Current.Workspace", "Work$num" )
        $global:AppMan.Document.SetCurrent( $num )
        return $this
    }
    [TTToolsController] focus( [int]$num ){
        switch($num){
            0 { 
                $num = $global:AppMan.Document.CurrentNumber
                break
            }
            default {
                $this.app._set( "Current.Tool", "$($global:AppMan.Document.CurrentTools[$num-1])$num" )
                $this.current( $num )
            }
        }
        $global:AppMan.Document.Focus( $num )
        return $this
    }
    #endregion

}
class TTEditorController {
    #region variants/ new/ default/ initialize

    static [bool] $DisplaySavedMessage = $true
    static [bool] $DisplayLoadedMessage = $true

    [TTToolsController] $tools

    TTEditorController( [TTToolsController] $_tools ){
        $this.tools = $_tools
    }
    [TTEditorController] default(){

        $this.tools.app._set( 'Editor1.Index', 'thinktank' )
        $this.tools.app._set( 'Editor2.Index', 'thinktank' )
        $this.tools.app._set( 'Editor3.Index', 'thinktank' )

        return $this
    }   
    [TTEditorController] initialize(){
        $this.load( 1, $this.tools.app._get('Editor1.Index') )
        $this.load( 2, $this.tools.app._get('Editor2.Index') )
        $this.load( 3, $this.tools.app._get('Editor3.Index') )
        return $this
    }

    #endregion

    #region load/ focus/ save
    [TTEditorController] load( [int]$no, [string]$index ){
        if( $index -in @( 'forward', 'backward' ) ){
            $index = $global:AppMan.Document.Editor.History( $no, $index )
        }

        $global:AppMan.Document.Editor.Initialize( $no ).Load( $no, $index )

        ### Panel
        @('Index','Shelf','Cabinet').foreach{ $this.tools.app.group.refresh($_) }

        return $this
    }
    [TTEditorController] load( [string]$index ){
        $no = $global:AppMan.Document.CurrentNumber
        return $this.load( $no, $index )
    }
    [TTEditorController] focus( [int]$no ){
        $global:AppMan.Document.SelectTool( $no, 'Editor' ).Focus( $no )
        return $this
    }
    [TTEditorController] save( [int]$no ){
        $global:AppMan.Document.Editor.Save( $no )
        return $this

    }

    #endregion

    #region modified
    [TTEditorController] modified( [int]$no, [bool]$modified ){
        $global:AppMan.Document.Editor.Controls[$no-1].IsModified = $modified
        return $this
    }
    #endregion

    #region paste
    [bool] paste(){
        $no = $global:AppMan.Document.CurrentNumber
        return $this.paste( $no )
    }
    [bool] paste( [int]$no ){
        $editor = $global:AppMan.Document.Editor.Controls[$no-1]
        $text = [TTClipboard]::GetText()

        switch( [TTClipboard]::DataType() ){
            "Text,"                  { $this._paste_url_text( $_, $editor, $text ) }
            "FileDropList,Text,CSV," { $this._paste_outlookmails( $_, $editor, $text ) }
            "Text,CSV,"              { $this._paste_outlookmails( $_, $editor, $text ) } 
            "TTObject,"              { $this._paste_ttobject( $_, $editor, $text ) } 
            "Text,TTObject,"         { $this._paste_ttobject_text( $_, $editor, $text ) } 
            "TTObjects,"             { $this._paste_ttobjects( $_, $editor, $text ) } 
            "FileDropList,Text,"     { $this._paste_outlookschedule( $_, $editor, $text ) }
            "Image,"                 { $this._paste_image( $_, $editor, $text ) } 
            "Image,Html,"            { $this._paste_image( $_, $editor, $text ) } 
            "Text,Rtf,Html,"         { $this._paste_url_text( $_, $editor, $text ) } # word
            "FileDropList,"          { $this._paste_files_folders( $_, $editor, $text ) }
            "Text,Html,"             { $this._paste_url_text( $_, $editor, $text ) } # favorite
            "Text,Image,CSV,Rtf,Html,DataInterchangeFormat," { $this._paste_excelrange( $_, $editor, $text ) } 
            default                  { 
                Write-Host "non supported data"
                return $false
            }
        }
        return $true

    }
    [void] _paste_url_text( $type, $editor, $text ){
        $doc = $editor.Document
        $cur = $editor.CaretOffset

        if( $text -match "^https?://[^　 \[\],;`&lt;&gt;&quot;&apos;]+"){   #### url
            $items = @{
                "@そのまま" =           'raw'
                "URLデコード" =         'decode'
                "# ⇒ [タイトル](URL)" = 'title'
            }
            $selected = $global:AppMan.PopupMenu.Caption( 'URLをペースト' ).Items( $items.Keys ).Show()
            switch( $items[$selected] ){
                'decode' { 
                    $text = [System.Web.HttpUtility]::UrlDecode($text)
                }
                'title'  {
                    if( ( Invoke-WebRequest $text ).Content -match "\<title\>(?<title>.+)\<\/title\>" ){
                        $text = "[$($Matches.title)]($text)"
                    }
                    $text = [System.Web.HttpUtility]::UrlDecode( $text )
                }
            }
            $doc.Insert( $cur, $text )

        }else{                                                              #### text
            $items = @{
                "@そのまま"     = 'raw'
                "コメント化"    = 'commentize'
                "URLデコード"   = 'decode'
                "URLエンコード%"   = 'decode'
            }
            $selected = $global:AppMan.PopupMenu.Caption( 'テキストをペースト' ).Items( $items.Keys ).Show()
            switch( $items[$selected] ){
                'decode' {
                    $text = [System.Web.HttpUtility]::UrlDecode($text)
                }
                'commentize' {
                    $text =  @(
                        $text.split("`r`n").where{$_ -ne ""}.foreach{ "; $_" }
                    ) -join "`r`n"
                }
            }
            $doc.Insert( $cur, $text )

        }
        
    }
    [void] _paste_outlookmails( $type, $editor, $text ){
        $doc = $editor.Document
        $cur = $editor.CaretOffset
        $titles = (ConvertFrom-Csv ([Clipboard]::GetText() -replace "`t", ",")).件名
        $outlook = New-Object -ComObject Outlook.Application
    
        try {
            $fmt = ""
            $mails = $outlook.ActiveExplorer().Selection
    
            for( $i = 1; $i -le $mails.count; $i++ ){
                $mail = $mails.Item($i)
                if( $mail.Subject -notin $titles ){ continue }
    
                $id =           (Get-Date $mail.ReceivedTime).tostring("yyyy-MM-dd-HHmmss")
                $title =        $mail.Subject
                $sendername =   $mail.Sender.Name
                $body = @(($mail.body.split("From")[0]).split("`r`n").where{ $_ -ne "" }.foreach{ "; "+$_ }) -join "`r`n"
    
                if( $fmt -eq "" ){
                    $items = @{
                        "[mail:$($id)]" =                   '"[mail:$($id)]`r`n"'
                        "$($sendername):[mail:$($id)]" =    '"`r`n$($sendername):[mail:$($id)]"'
                        "⇒ $title`\[mail:$($id)]" =          '"⇒ $title`r`n[mail:$($id)]"'
                        "⇒ $title`\[mail:$($id)]`\本体" =     '"⇒ $title`r`n[mail:$($id)]`r`n$body"'
                    }
                    $selected = $global:AppMan.PopupMenu.Caption( 'Outlookメールをペースト' ).Items( $items.Keys ).Show()
                    $fmt = $items[$selected]
                    if( 0 -eq $fmt.length ){ return }
                }
                $doc.Insert( $cur, (Invoke-Expression $fmt) )
                $backupFolderName = $global:TTResources.GetChild('Configs').GetChild("OutlookBackupFolder").Value
                $mailFolderName = $mail.parent.FolderPath.substring(2)
                foreach( $folder in $outlook.GetNamespace("MAPI").Folders ){
                    if( ($folder.Name -eq $backupFolderName) -and
                        ($folder.Name -ne $mailFolderName) ){ $mail.Move( $folder ) } 
                }
            }
        
        } finally {
            [void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($outlook)
        }

    }
    [void] _paste_ttobjects( $type, $editor, $text ){
        $doc =  $editor.Document
        $cur =  $editor.CaretOffset
        $objs = [TTClipboard]::_ttobjs

        switch( $objs[0].GetType().Name ){
            'TTMemo' { 
                $items = @{
                    "@[memo:$($objs[0].MemoID)]" =                   'memoid'
                    "[memo:$($objs[0].MemoID)] $($objs[0].Title)"=    'title'
                }
                $selected = $global:AppMan.PopupMenu.Caption( 'TTMemoをペースト' ).Items( $items.Keys ).Show()
                switch( $items[$selected] ){
                    'memoid' { 
                        $objs.foreach{ $doc.Insert( $cur, "[memo:$($_.MemoID)]`r`n" ) }
                    } 
                    'title' {
                        $objs.foreach{ $doc.Insert( $cur, "[memo:$($_.MemoID)] $($_.Title)`r`n" ) }
                    }
                }    
            }
        }
    }
    [void] _paste_ttobject( $type, $editor, $text ){
        # $doc    = [TTClipboard]::_target.Document
        # $offset = [TTClipboard]::_target.CaretOffset
        # $target = [TTClipboard]::_target 
        # $copied = [TTClipboard]::_copied

        # switch( $copied.GetType().Name ){
        #     'TTMemo' { 
        #         $items = @{
        #             "@[memo:$($copied.MemoID)]"     = 'memoid'
        #             "[memo:$($copied.MemoID)] $($copied.Title)"  = 'title'
        #         }
        #         switch( $items[ [string](ShowPopupMenu $items.keys "" "" "Memo" $target) ] ){
        #             'memoid' { $doc.Insert( $offset, "[memo:$($copied.MemoID)]" ) }
        #             'title'  { $doc.Insert( $offset, "[memo:$($copied.MemoID)] $($copied.Title)" ) }
        #         }    
        #     }
        # }
    
    }
    [void] _paste_ttobject_text( $type, $editor, $text ){ # メモと引用テキスト
        # $text   = [Clipboard]::GetText()
        # $doc    = [TTClipboard]::_target.Document
        # $offset = [TTClipboard]::_target.CaretOffset
        # $target = [TTClipboard]::_target 
        # $copied = [TTClipboard]::_copied

        # switch( $copied.GetType().Name ){
        #     'TTMemo' { 
        #         $items = @{
        #             "@[memo:$($copied.MemoID):$text]"     = 'memoid'
        #             "[memo:$($copied.MemoID):$text] $($copied.Title)"  = 'title'
        #         }
        #         switch( $items[ [string](ShowPopupMenu $items.keys "" "" "Memo" $target) ] ){
        #             'memoid' { $doc.Insert( $offset, "[memo:$($copied.MemoID):$text]" ) }
        #             'title'  { $doc.Insert( $offset, "[memo:$($copied.MemoID):$text] $($copied.Title)" ) }
        #         }    
        #     }
        # }

    }
    [void] _paste_outlookschedule( $type, $editor, $text ){ # 未実装
        $text = [Clipboard]::GetText()                   # 件名（場所）
        $filedroplist = [Clipboard]::GetFileDropList()   # error
    }
    [void] _paste_image( $type, $editor, $text ){ # photoタグとの運用を考える
    
        # $image = [Clipboard]::GetImage()  # image:System.Windows.Interop.InteropBitmap
    
        $folder = $global:TTResources.GetChild('Configs').GetChild("CaptureFolder").value
        if( (Test-Path $folder) -eq $false ){ $folder = [Environment]::GetFolderPath('MyPictures') }
        $folder = $folder + "\thinktank\" + (Get-Date).ToString("yyyy-MM-dd")
        if( (Test-Path $folder) -eq $false ){ New-Item $folder -ItemType Directory }
        $filename = $folder + "\" + (Get-Date).ToString("yyyy-MM-dd-HHmmss") + ".png"
    
        (Get-Clipboard -Format Image).Save( $filename )
    
        $editor.Document.Insert( $editor.CaretOffset, "$filename`r`n" )
    }
    [void] _paste_files_folders( $type, $editor, $text ){ # 未実装
        
        $filedroplist = [Clipboard]::GetFileDropList()
        $filedroplist.foreach{
            $editor.Document.Insert( $editor.CaretOffset, "$_`r`n" )
        }
        # Write-Host "filedroplist:$filedroplist" # [stringcollection]fullpath
    }
    [void] _paste_excelrange( $type, $editor, $text ){ # 未実装
        # $text = [Clipboard]::GetText()
        # $image = [Clipboard]::GetImage()            # string
        # $csv = [Clipboard]::GetDataObject("CSV")    # image:System.Windows.Interop.InteropBitmap
        # $rtf = [Clipboard]::GetDataObject("Rich Text Format")      # no datd
        # $html = [Clipboard]::GetDataObject("Html")                 # no datd
        # $dif = [Clipboard]::GetDataObject("DataInterchangeFormat") # no datd
    }

    #endregion

    #region insert/ edit
    [bool] edit( [string]$target ){
        $no = $global:AppMan.Document.CurrentNumber
        return $this.edit( $no, $target )
    }
    [bool] edit( [int]$no, [string]$target ){
        $editor = $global:AppMan.Document.Editor.Controls[$no-1]

        switch( $target ){
            'delete'    { [EditingCommands]::Delete.Execute( $null, $editor.TextArea ) }
            'backspace' { [EditingCommands]::Backspace.Execute( $null, $editor.TextArea ) }
        }
        return $true
    }
    [bool] insert( [string]$target ){
        $no = $global:AppMan.Document.CurrentNumber
        return $this.insert( $no, $target )
    }
    [bool] insert( [int]$no, [string]$target ){
        $editor = $global:AppMan.Document.Editor.Controls[$no-1]
        $doc = $editor.Document
        $cur = $editor.CaretOffset

        switch( $target ){
            'clipboard' { return $this.paste( $no ) }
            'newline' { $doc.Insert( $cur, "`r`n" ) }
            'newline+' { $editor.LineDown(); $doc.Insert( $cur, "`r`n" ) }
        }

        return $true

    }

    #endregion

    #region move_to, select_to, node_to
    [bool] move_to( [string]$to ){
        $no = $global:AppMan.Document.CurrentNumber
        return $this.move_to( $no, $to )
    }
    [bool] move_to( [int]$no, [string]$to ){
        return $global:AppMan.Document.Editor.MoveTo( $no, $to )
    }
    [bool] select_to( [string]$to ){
        $no = $global:AppMan.Document.CurrentNumber
        return $this.select_to( $no, $to, '' )
    }
    [bool] select_to( [string]$to, [string]$following_action ){
        $no = $global:AppMan.Document.CurrentNumber
        return $this.select_to( $no, $to, $following_action )
    }
    [bool] select_to( [int]$no, [string]$to, [string]$following_action ){
        return $global:AppMan.Document.Editor.SelectTo( $no, $to, $following_action )
    }
    [bool] node_to( [string]$state ){
        $no = $global:AppMan.Document.CurrentNumber
        return $this.node_to( $no, $state )
    }
    [bool] node_to( [int]$no, [string]$state ){
        # ファイルのD&Dしか捕捉できない。→ $drag.Data.GetFileDropList()
        # browserのlinkはurlテキストが貼り付けられてしまい、PreviewDropが発火しない
        return $global:AppMan.Document.Editor.NodeTo( $no, $state )
    }

    #endregion

    #region event
    [bool] on_textchanged( $params ){

        $editor = $params[0]
        $num = [int][string]($editor.Name[-1])

        if( $global:AppMan.Document.Editor.UpdateFolding($num) ){
            TTTimerResistEvent "on_textchanged(Editor$num)" 10 0 { 
                $global:appcon.tools.editor.save($num)
            }.GetNewClosure()
        }

        return $true
    }
    [bool] on_focus( $params ){

        return $true

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
    [bool] on_previewmousedown( $params ){
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

        return $true
    }
    [bool] on_previewdrop( $params ){

        return $true

        $editor = $params[0]
        $drag = $params[1]
        Write-Host $drag   
        # 要修正
    
    }

    [void] on_save( $params ){
        $toolman, $num = $params
        $index = $toolman.Indices[$num-1]
        $editor = $toolman.Controls[$num-1]
        $filepath = $editor.Document.FileName

        if( [TTEditorController]::DisplaySavedMessage ){
            $title = $editor.Text.split( "`r`n" )[0]
            [TTTool]::debug_message( $editor.Name, "Save Memo [$index] $title" )
        }

        #### Memos
        $memo = $global:TTResources.GetChild('Memos').GetChild($index)
        $memo.UpdateDate = (Get-Item $filepath).LastWriteTime.ToString("yyyy-MM-dd-HHmmss")
        $memo.Title = Get-Content $filepath -totalcount 1

        #### Editings
        $foldman = $toolman.FoldManagers[$num-1]
        $foldings = @( $foldman.AllFoldings.where{ $_.IsFolded }.foreach{ $_.StartOffset } ) -join ","
        $global:TTResources.GetChild('Editings').AddChild( $editor, $foldings )

    }
    [void] on_load( $params ){
        $toolman, $num, $index = $params
        $editor = $toolman.Controls[$num-1]

        if( [TTEditorController]::DisplayLoadedMessage ){
            $title = $editor.Text.split( "`r`n" )[0]
            [TTTool]::debug_message( $editor.Name, "Load Memo [$index] $title" )
        }

        #### status
        $this.tools.app._set( "$($editor.Name).Index", $index )

        #### Editings
        $editing = $global:TTResources.GetChild('Editings').GetChild($index)
        if( $null -eq $editing ){ return }
        $editor.CaretOffset = $editing.Offset
        $editor.WordWrap    = $editing.Wordwrap
        $foldings = $editing.Foldings.split(",")
        $toolman.FoldManagers[$num-1].AllFoldings.foreach{ $_.IsFolded = ( $_.StartOffset -in $foldings ) }
        $caret = $editor.TextArea.Caret
        $editor.ScrollTo( $caret.Line, $caret.Column )

    }


    #endregion
}
class TTBrowserController {
    #region variants/ new/ default/ initialize
    [TTToolsController] $tools
    TTBrowserController( [TTToolsController] $_tools ){
        $this.tools = $_tools
    }
    [TTBrowserController] default(){
        $this.tools.app._set( 'Browser1.Url', 'http://google.com' )
        $this.tools.app._set( 'Browser2.Url', 'http://google.com' )
        $this.tools.app._set( 'Browser3.Url', 'http://google.com' )
        return $this
    }
    [TTBrowserController] initialize(){

        return $this
    }
    #endregion
}
class TTGridController {
    #region variants/ new/ default/ initialize
    [TTToolsController] $tools
    TTGridController( [TTToolsController] $_tools ){
        $this.tools = $_tools
    }
    [TTGridController] default(){
        $this.tools.app._set( 'Grid1.Index',  'thinktank' )
        $this.tools.app._set( 'Grid2.Index',  'thinktank' )
        $this.tools.app._set( 'Grid3.Index',  'thinktank' )
        return $this
    }
    [TTGridController] initialize(){

        return $this
    }
    #endregion
}
class TTMenuController {
    #region variants/ new/ default/ initialize
    [TTApplicationController] $app

    TTMenuController( [TTApplicationController] $_app ){
        $this.app = $_app
    }
    [TTMenuController] default(){
        $this.app._set( 'PopupMenu.Left',   '0' )
        $this.app._set( 'PopupMenu.Top',    '0' )

        return $this
    }
    [TTMenuController] initialize(){
        $global:AppMan.PopupMenu.Left( $this.app._get('PopupMenu.Left') )
        $global:AppMan.PopupMenu.Top( $this.app._get('PopupMenu.Top') )

        return $this
    }
    #endregion

    #region close/cursor
    [TTMenuController] close( [string]$name, [string]$action ){
        switch( $action ){
            'cancel' { $global:AppMan.$name.Hide( $false ) }
            'ok' { $global:AppMan.$name.Hide( $true ) }
        }
        return $this
    }
    [TTMenuController] cursor( [string]$name, [string]$to ){
        $global:AppMan.$name.Cursor( $to )
        return $this
    }
    #endregion

}

<# region 旧　index, library, shelf, ListMenu 
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
class TTLibrary : TTListPanel {
    TTLibrary(){
        $this._name = "Library"
    }
    [TTLibrary] initialize(){
        [void] ([TTListPanel]$this).initialize( $global:TTResources ) 

        $this._items.Add_SelectionChanged( $script:LibraryItems_SelectionChanged )
        $this._items.Add_PreviewKeyDown( $script:LibraryItems_PreviewKeyDown )
        $this._keyword.Add_TextChanged( $script:LibraryKeyword_TextChanged )
        $this._keyword.Add_PreviewKeyDown( $script:LibraryKeyword_PreviewKeyDown )

        return $this
    }
    [TTLibrary] unmark_column(){
        @( $script:shelf, $script:index ).foreach{
            $index = $_._library_name
            if( 0 -eq $index.length ){ break }
            $this._group.GetChild( $index ).flag = ""
        }
        return $this
    }
    [TTLibrary] mark_column(){
        $i = 1
        @( $script:shelf, $script:index ).foreach{
            $index = $_._library_name
            if( 0 -eq $index.length ){ break }
            $this._group.GetChild( $index ).flag = $i
            $i += 1
        }
        return $this
    }

}
class TTShelf : TTListPanel {
    [string] $_library_name

    TTShelf(){ 
        $this._name = "Shelf"
    }
    [TTShelf] initialize( $library_name ){
        $this._library_name = $library_name

        [void] ([TTListPanel]$this).initialize( $global:TTResources.GetChild( $this._library_name ) )

        $this._items.Add_SelectionChanged( $script:ShelfItems_SelectionChanged )
        $this._items.Add_PreviewKeyDown( $script:ShelfItems_PreviewKeyDown )
        $this._items.Add_PreviewMouseDown( $script:ShelfItems_PreviewMouseDown )
        $this._items.Add_GotFocus( $script:ShelfItems_GotFocus )
        $this._keyword.Add_PreviewKeyDown( $script:ShelfKeyword_PreviewKeyDown )
        $this._keyword.Add_TextChanged( $script:ShelfKeyword_TextChanged )  
        
        return $this 
    }
    [void] status_set( $id, $text ){
        switch( $id ){
            'Sort' {
                $dir, $col = $this.sort_params()
                $script:app._set( "$($this._name).SortColumn", $col )
                $script:app._set( "$($this._name).SortDir", $dir )
                $script:app._set( "$($this._library_name).SortColumn", $col )
                $script:app._set( "$($this._library_name).SortDir", $dir )
            }
            'Index' {
                $selected = ([TTListPanel]$this).selected_index()
                $script:app._set( "$($this._name).Index", $selected )
                $script:app._set( "$($this._library_name).Index", $selected )
            }
            'Keyword' {
                $script:app._set( "$($this._name).Keyword", $text )
                $script:app._set( "$($this._library_name).Keyword", $text )
            }
        }
    }
    [string[]] selected_index(){
        return @( $this._library_name, ([TTListPanel]$this).selected_index() )
    }
    [TTShelf] unmark_column(){
        $this._group.GetChildren().foreach{ $_.flag = "" }


        # $script:EditorIDs.foreach{
        #     $index = $script:DocMan.config.$_.index
        #     if( 0 -ne $index.length ){
        #         if( $null -ne $this._group.GetChild( $index ) ){
        #             $this._group.GetChild( $index ).flag = ""
        #         }
        #     }
        # }
        return $this
    }
    [TTShelf] mark_column(){
        $script:EditorIDs.foreach{
            $index = $script:DocMan.config.$_.index
            if( 0 -ne $index.length ){
                if( $null -ne $this._group.GetChild( $index ) ){
                    $this._group.GetChild( $index ).flag = $_[-1]
                }
            }
        }
        return $this
    }
    [TTShelf] delete_selected(){
        $lib, $index = $this.selected_index()
        switch( $lib ){
            "Memo" { 
                $script:EditorIDs.where{ 
                    $index -eq $script:DocMan.config.$_.index 
                }.foreach{ 
                    $script:desk.tool($_).load( 'thinktank' )
                }
            }
        }
        $this._group.DeleteChild( $index )
        $this.reload()
        return $this
    }

}
class TTIndex : TTShelf {
    TTIndex(){ 
        $this._name = "Index"
    }
    [TTIndex] initialize( $library_name ){
        $this._library_name = $library_name

        [void] ([TTListPanel]$this).initialize( $global:TTResources.GetChild( $this._library_name ) )

        $this._items.Add_SelectionChanged( $script:IndexItems_SelectionChanged )
        $this._items.Add_PreviewKeyDown( $script:IndexItems_PreviewKeyDown )
        $this._items.Add_PreviewMouseDown( $script:IndexItems_PreviewMouseDown )
        $this._items.Add_GotFocus( $script:IndexItems_GotFocus )
        $this._keyword.Add_TextChanged( $script:IndexKeyword_TextChanged )
        $this._keyword.Add_PreviewKeyDown( $script:IndexKeyword_PreviewKeyDown )
         
        return $this
    }
    [TTIndex] items( $items ){
        $this._items.Items.SortDescriptions.Clear()
        $this._items.ItemsSource = $null
        $this._items.ItemsSource = $items

        $dictionary = $this._dictionary
        $bindings = $dictionary.Index.split(",")
              
        $this._items.Columns.Clear()
        $bindings.foreach{
            $col = [DataGridTextColumn]::New()
            $col.Header = $dictionary[$_]
            $col.Binding = [Data.Binding]::New($_)
            if( $bindings.IndexOf($_) -eq $bindings.count - 1 ){ $col.Width = "*" }
            $this._items.Columns.Add( $col )
        }

        $this._items.Items.Refresh()
        return $this
    }
    [TTIndex] column( $column ){
        try{ $num = [int]$column }catch{ $num = 0 }
        if( 0 -lt $num ){
            $this._column = ($this._dictionary.Shelf.split(","))[$num-1]
        }else{
            $this._column = $column
        }
        return $this
    }
    [TTIndex] delete_selected(){
        $lib, $index = $this.selected_index()
        switch( $lib ){
            "Memo" { 
                $script:EditorIDs.where{ 
                    $index -eq $script:DocMan.config.$_.index 
                }.foreach{ 
                    $script:desk.tool($_).load( 'thinktank' )
                }
            }
        }
        $this._group.DeleteChild( $index )
        $this.reload()
        return $this
    }


}
class TTListMenu : TTListPanel {

    TTListMenu(){
        $this._name = "ListMenu"
    }

    [TTListMenu] initialize( $group ){ # $this._name を設定してから呼び出すこと
        $this._items    = $script:ListMenuWindow.FindName("$($this._name)Items")
        $this._keyword  = $script:ListMenuWindow.FindName("$($this._name)Keyword")
        $this._caption  = $script:ListMenuWindow.FindName("$($this._name)Caption")
        $this._sorting  = $script:ListMenuWindow.FindName("$($this._name)Sorting")

        $this._group = $group
        $dictionary = ((New-Object $group.ChildType).GetDictionary())
        $this._dictionary = $dictionary
        $this._column = $dictionary.Index
        
        $this.items( $this._group.GetChildren() )
        $this.nosearch()

        $this.menu()
        return $this
    }

}
#endregion:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#>
#region desk / TTDesk
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
class TTDesk{
    TTDesk(){
        $this.bullets = @( '・ ', ' - ', '= ', '■ ', '● ', '⇒ ', '→ ', '↓ ', '> ', '; ' )
        $this._name = "Desk"
        $this._keyword = $null
        $this._caption = $null
        $this._sorting = $null
    }
    [void] initialize(){
        $script:DocMan.Initialize()
        $script:DocMan.Equip( 'Work1', 'Editor' )
        $script:DocMan.Equip( 'Work2', 'Editor' )
        $script:DocMan.Equip( 'Work3', 'Editor' )

        $this._keyword  = $script:AppMan.FindName("$($this._name)Keyword")
        $this._caption  = $script:AppMan.FindName("$($this._name)Caption")
        $this._sorting  = $script:AppMan.FindName("$($this._name)Sorting")

        $this._keyword.Add_PreviewKeyDown( $script:DeskKeyword_PreviewKeyDown )
        $this._keyword.Add_TextChanged( $script:DeskKeyword_TextChanged )  

        [xml]$xshd = Get-Content "$global:TTScriptDirPath\thinktank.xshd"
        $script:Editors.foreach{
            $_.Options.ShowTabs = $True
            $_.Options.IndentationSize = 6
            $_.Options.HighlightCurrentLine = $True
            $_.Options.EnableHyperlinks = $False
            $_.Options.EnableEmailHyperlinks = $False

            $_.SyntaxHighlighting = [ICSharpCode.AvalonEdit.Highlighting.Xshd.HighlightingLoader]::Load( 
                [XmlReader](New-Object XmlNodeReader $xshd), 
                [ICSharpCode.AvalonEdit.Highlighting.HighlightingManager].Instance
            )
            $_.AllowDrop = $true
            $_.Add_Drop( $script:TextEditors_PreviewDrop )
            $_.Add_TextChanged( $script:TextEditors_TextChanged )
            $_.Add_PreviewKeyDown( $script:TextEditors_PreviewKeyDown )
            $_.Add_PreviewMouseDown( $script:TextEditors_PreviewMouseDown )
            $_.Add_GotFocus( $script:TextEditors_GotFocus )

        }

        $this.menu()

        return 

    }
    [TTDesk] tool( $tool ){
        $this._tool = $tool
        return $this
    }
    [TTDesk] menu(){
        if( $null -eq $this._sorting ){ return $this }

        $menus = @()
        $lines = @(
            Get-ChildItem -Path @( "$global:TTRootDirPath\thinktank.md" ) | `
                Select-String "^Thinktank@?(?<pcname>.*)?:Keywords:" | `
                Select-Object -Property Filename, LineNumber, Matches, Line
        )

        if ( 0 -Lt $lines.Count ) {
            ForEach ( $line in $lines ) {
                $line.Line -match "^Thinktank@?(?<pcname>.*)?:Keywords:(?<menus>[^,]+),\s*(?<keywords>.*)"
                $ma = $Matches
                if ( 0 -lt $ma.pcname.length ) {
                    if ( $ma.pcname.Trim() -ne $Env:COMPUTERNAME ) { continue }
                } else {
                    if ( ($this.menus.count -ne 0) -and
                         ($this.menus.keys.contains($ma.menus.Trim().Replace(":",","))) ) { continue }
                }
                $keys = $ma.menus.Trim().Replace(":",",")
                $value = [ScriptBlock]::Create( "[TTTool]::desk_keyword(`"$($ma.keywords.Trim())`")" )
                $menus += [psobject]@{ keys = $keys; value = $value }    
            }
        }

        $this._sorting.Items.Clear()

        foreach( $menu in $menus ){
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

        return $this
    }
    [TTDesk] load( $index ){

        $script:shelf.unmark_column()
        $script:DocMan.Tool( $this._tool ).Load( $index )
        $script:shelf.mark_column()

        $script:shelf.refresh()

        $editing = $global:TTEditings.GetChild( $index )
        if( $null -ne $editing ){
            $script:DocMan.Tool( $this._tool ).ConfigureEditor( $editing.Offset, $editing.WordWrap, $editing.Foldings )
        }
        return $this

    }
    [TTDesk] save(){
        $editor = $script:DocMan.Tool( $this._tool ).Save()
        if( $null -eq $editor ){ return $this }

        $filepath = $editor.Document.FileName
        $memoid = ( $filepath -replace '.+[\\/](?<memoid>[\w\-]+)\..{2,5}','${memoid}' )       

        # update TTMemos(Model)
        $memo = $global:TTMemos.GetChild( $memoid )
        $memo.Title = Get-Content $filepath -totalcount 1
        $memo.UpdateDate = (Get-Item $filepath).LastWriteTime.ToString("yyyy-MM-dd-HHmmss")

        # update TTEditings(Model)
        $global:TTEditings.AddChild( $editor )

        return $this

    }
    [TTDesk] caption( $text ){
        if( 0 -lt $text.length ){
            $caption = ($this._caption.Content) -replace "^[●◎]?(.*)", "`$1"
            $this._caption.Content = switch( $text ){
                '*' { "●$caption"; break }
                '+' { "◎$caption"; break }
                '-' { $caption; break }
                default { "Desk : $text" }
            }
        }
        return $this
    }
    [TTDesk] focus(){
        $this._keyword.Focus()
        $script:app._set( 'Application.Focused', 'Desk' )
        return $this
    }
    [TTDesk] focus( $id ){
        switch( $true ){
            { $id -in $script:WorkIDs } {
                $toolid = ( $id.replace( 'Work', $script:app._get( "$id.Tool" )) )
                $script:app._set( 'Application.Focused', $toolid )
                $this.focus( $toolid )
            }
            { $id -in $script:EditorIDs }   { 
                $script:app._set( 'Application.Focused', $id )
                $script:DocMan.config.($id).editor.Focus()
                $this.tool( $id )
            }
            { $id -in $script:BrowserIDs }  {
                $this.tool( $id )
            }
            { $id -in $script:GridIDs }     {
                $this.tool( $id )
            }
        }
        return $this
    }
    [TTDesk] scroll_to( $to ){
        $script:DocMan.Tool( $this._tool ).ScrollTo( $to )
        return $this
    }
    [TTDesk] select_to( $to, $following_action ){
        $script:DocMan.Tool( $this._tool ).SelectTo( $to, $following_action )
        return $this
    }
    [TTDesk] move_to( $to ){
        $script:DocMan.Tool( $this._tool ).MoveTo( $to )
        return $this
    }
    [TTDesk] node_to( $to ){
        $script:DocMan.Tool( $this._tool ).NodeTo( $to )
        return $this
    }
    [TTDesk] edit( $action ){
        switch( $action ){
            'section' {
                if( $script:desk.tool( 'Editor' ).replace( "^#{1,10} $", '$0' ) ){
                    $script:desk.tool( 'Editor' ).move_to('linestart').insert('#').move_to('lineend')
                }else{
                    $script:desk.tool( 'Editor' ).move_to('linestart').insert("# `r`n").move_to('prevline').move_to('lineend')
                }
            }
            # 'bullet_nor1' {
            #     $bullets = "・ | - |= |■ |● |⇒ |→ |↓ |> |; "
            #     $cur = $bullets.split("|")
            #     $nxt = @{}; $cur.foreach{ $nxt[$_] = $cur[ ($cur.IndexOf($_)+1) % $cur.count ] }

            #     if( $this.replace( "^($bullets)(.*)$", '$0' ) ){
            #         $cur.foreach{ if( $this.replace( "^($_)(.*)$", "$($nxt[$_])`$2" ) ){ break } }
            #     }else{
            #         $this.replace( "^.*$", "$($cur[0])`$0" )
            #     }
            # }

            # $this.bullets = @( '・ ', ' - ', '= ', '■ ', '● ', '⇒ ', '→ ', '↓ ', '> ', '; ' )

            'bullet_nor' {
                $next_bullets = @($this.bullets[(1..($this.bullets.count-1))+(0)])
                Foreach( $bullet in $this.bullets ){
                    if( $script:desk.tool( 'Editor' ).replace( "^($bullet)", $next_bullets[$this.bullets.IndexOf($bullet)] ) ){ return $this }
                }
                $script:desk.tool( 'Editor' ).move_to('linestart').insert($this.bullets[0]).move_to('lineend')                            
            }
            'bullet_rev' {
                $next_bullets = @($this.bullets[(-1..($this.bullets.count-2))])
                Foreach( $bullet in $this.bullets ){
                    if( $script:desk.tool( 'Editor' ).replace( "^($bullet)", $next_bullets[$this.bullets.IndexOf($bullet)] ) ){ return $this }
                }
                $script:desk.tool( 'Editor' ).move_to('linestart').insert($this.bullets[0]).move_to('lineend')                            
            }
            default { $script:DocMan.Tool( $this._tool ).Edit( $action ) }
        }
        return $this

        # 行
        # 空section行: 　       section変更
        # 空行：　              bullet挿入
        # 空文字+bullet行：     bullet変更
        # 空文字+文字：         
        #
    }
    [TTDesk] insert( $text ){
        $script:DocMan.Tool( $this._tool ).Insert( $text )
        return $this
    }
    [bool] replace( $regex, $text ){
        return $script:DocMan.Tool( $this._tool ).Replace( $regex, $text )
    }
    [string] create_memo(){
        return $global:TTMemos.CreateChild()
    }
    [TTDesk] delete_memo( $index ){
        $global:TTMemos.DeleteChild( $index )
        return $this
    }
    [void] create_cache( $keyword ){
        if( 0 -eq $keyword.length ){ $keyword = $script:app._get( 'Desk.Keyword' ) }
        if( 0 -eq $keyword.length ){ return }
        # $exmemo = [TTExMemos]::New().Keyword( $keyword )
        # $global:TTResources.AddChild( $exmemo )

        $script:library.initialize()    
    }
    [TTDesk] search( $text ){
        $this._keyword.Text = $text
        return $this
    }
    [TTDesk] nosearch(){
        $this._keyword.Text = ''
        return $this
    }
    [bool] moved(){
        return $script:DocMan.Moved()
    }


}

#endregion:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#>
<# region　ListMenu / TTListMenu
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

[xml]$script:ListMenuXaml = [xml]@"
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
    Title="Menu" Name="ListMenu"  Top="10" Left="10" WindowStyle="None" AllowsTransparency="True">

    <Window.Resources>
        <ResourceDictionary Source="$PSScriptRoot\thinktank-style.xaml"/>
    </Window.Resources>

    <Border BorderBrush="Black" BorderThickness="1">
        <Grid Margin="0" FocusManager.FocusedElement="{Binding ElementName=SelectTextBox}" 
            Background="White" >
            <DockPanel>
                <Label Name="ListMenuCaption"
                    DockPanel.Dock="Top" Margin="0" HorizontalAlignment="Stretch" Content="Select" />

                <Grid DockPanel.Dock="Top" HorizontalAlignment="Stretch" >
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="7*"/>
                        <ColumnDefinition Width="3*"/>
                    </Grid.ColumnDefinitions>

                    <Menu Name="ListMenuSorting" FontFamily="Meiryo" FontSize="12">
                        <MenuItem Header="thinktank" />
                        <MenuItem Header="すると" />
                        <MenuItem Header="キャンプ" />
                        <MenuItem Header="車旅行" />
                    </Menu>

                    <GridSplitter Grid.Column="0" Width="4" IsTabStop="False" />

                    <TextBox Name="ListMenuKeyword" Text="" FontFamily="Meiryo" FontSize="12" Grid.Column="1" />
                </Grid>

                <DataGrid Name="ListMenuItems"
                    AutoGenerateColumns="False"
                    ColumnHeaderHeight="22" RowHeight="22" FontFamily="Meiryo" FontSize="11" 
                    BorderThickness="0" HorizontalAlignment="stretch" />

            </DockPanel>
        </Grid>
    </Border>
</Window>
"@
$script:ListMenuWindow = $null
$script:ListMenu = $null
$script:ListMenuLeft   = 0
$script:ListMenuTop    = 0

#region　actions and events
#------------------------------------------------------------------------------------------------------------------------
function Show_ListMenu( $group ){

    # initialize variables
    #'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    $script:ListMenuWindow = $null
    $script:ListMenu = $null
    $script:ListMenuWindow = [Markup.XamlReader]::Load( (New-Object XmlNodeReader [TTPopupMenu]$script:ListMenuXaml) )
    $script:ListMenu = [TTListMenu]::New().Initialize( $group )

    # event
    #'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    $script:ListMenuWindow.Add_Loaded( $script:ListMenu_Loaded )
    $script:ListMenuWindow.Add_Unloaded( $script:ListMenu_Unloaded )
    $script:ListMenuWindow.Add_MouseLeftButtonDown({ $script:ListMenuWindow.DragMove() })
    $script:ListMenu._keyword.Add_TextChanged( $script:ListMenuKeyword_TextChanged )
    $script:ListMenu._keyword.Add_PreviewKeyDown( $script:ListMenuKeyword_PreviewKeyDown ) 
    $script:ListMenu._items.Add_PreviewKeyDown( $script:ListMenuItems_PreviewKeyDown )

    # show window and return result
    #'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    if( $script:ListMenuWindow.ShowDialog() ){
        return $script:ListMenu._items.SelectedItems
    }else{
        return @()
    }
}
[ScriptBlock] $script:ListMenu_Loaded = {

    # if( 0 -eq $script:ListMenuLeft ){
        [System.Windows.Point] $pt = $this.grid_rpanel_ul.PointToScreen([System.Windows.Point]::New(0, 0))
        $script:ListMenuLeft = $pt.X
        $script:ListMenuTop = $pt.Y
    # }
    $script:ListMenuWindow.Width  = $script:ListMenu._items.ActualWidth * 2 / 3
    $script:ListMenuWindow.Height = ( @( $script:ListMenu._items.ItemsSource.count, 10 ) | Measure-Object -Minimum ).Minimum * 22.5 + 130

    $script:ListMenuWindow.Left   = $script:ListMenuLeft
    $script:ListMenuWindow.Top    = $script:ListMenuTop 

    $script:ListMenu._keyword.Focus()

}
[ScriptBlock] $script:ListMenu_Unloaded = {

    $script:ListMenuLeft   = $script:ListMenuWindow.Left
    $script:ListMenuTop    = $script:ListMenuWindow.Top
}
[ScriptBlock] $script:ListMenuKeyword_TextChanged = {
    $script:app._set( 'ListMenu.Keyword', $script:ListMenu._keyword.Text )

    TTTimerResistEvent( 
        "ListMenuKeyword_TextChanged", 2, 0, 
        {
            $script:ListMenu.search()
        }
    )
}
[ScriptBlock] $script:ListMenuKeyword_PreviewKeyDown = {
    $key  = $args[1].Key
    $mod  = $args[1].KeyboardDevice.Modifiers
    # $skey = $args[1].SystemKey

    :Handled switch( $mod ){
        'None' {
            switch( $key ){
                'Down' { $script:ListMenu.cursor('down'); break Handled }
                'Up'   { $script:ListMenu.cursor('up'); break Handled }
                'Return' { 
                    $script:ListMenuWindow.DialogResult = $True
                    if( $null -eq $script:ListMenu._items.SelectedItem ){
                        $script:ListMenu._items.SelectedIndex = 0
                    }
                    $script:ListMenuWindow.Close()
                    break Handled
                }
                'Escape' { 
                    $script:ListMenuWindow.DialogResult = $False
                    $script:ListMenuWindow.Close()
                    break Handled
                }
                default { return }
            }
        }
        'Shift' {
            switch( $key ){
                'Down'  { $script:ListMenu.cursor('last'); break Handled }
                'Up'    { $script:ListMenu.cursor('first'); break Handled }
                'C'     { $script:ListMenu.nosearch(); break Handled }
            }
        }
        'Control' { 
            switch( $key ){
                'N'    { $script:ListMenu.cursor('down'); break Handled }
                'P'    { $script:ListMenu.cursor('up'); break Handled }
                'Oem1' { # [*:] 
                    $script:ListMenuWindow.DialogResult = $False
                    $script:ListMenuWindow.Close()
                    break Handled
                }
                default{ return }
            }
        }
        'Control, Shift' {
            switch( $key ){
                'N'    { $script:ListMenu.cursor('last'); break Handled }
                'P'    { $script:ListMenu.cursor('first'); break Handled }
            }
        }
            default { return }
    }  
    $args[1].Handled = $True  
}
[ScriptBlock] $script:ListMenuItems_PreviewKeyDown = {
    $script:ListMenu._keyword.Focus()
}
#endregion---------------------------------------------------------------------------------------------------------------


#>

