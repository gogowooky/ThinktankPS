


using namespace System.Windows.Input
using namespace System.Windows.Documents
using namespace System.Windows.Controls
using namespace System.Windows
using namespace System.Xml




class TTAppManager {
    #region variables/ new/ GetWPFObject
    [System.Windows.Window]$_window

    [TTCabinetManager] $Cabinet
    [TTPopupMenuManager] $PopupMenu
    [TTLibraryManager] $Library
    [TTIndexManager] $Index
    [TTShelfManager] $Shelf
    [TTDeskManager] $Desk
    [TTDocumentManager] $Document

    [Grid] $GridWindowLR
    [Grid] $GridLPanelUL
    [Grid] $GridRPanelUL
    [Grid] $GridDeskLR
    [Grid] $GridDeskUL

    TTAppManager(){

        [xml]$xaml = (Get-Content ( $global:TTScriptDirPath + "\thinktank.xaml" ) ).replace( "C:\Users\shin\Documents\ThinktankPS2\script", $global:TTScriptDirPath )
        $this._window = [System.Windows.Markup.XamlReader]::Load( (New-Object XmlNodeReader $xaml) )

        $this.GridWindowLR = $this.GetWPFObject('GridWindowLR')
        $this.GridLPanelUL = $this.GetWPFObject('GridLPanelUL')
        $this.GridRPanelUL = $this.GetWPFObject('GridRPanelUL')
        $this.GridDeskLR =   $this.GetWPFObject('GridDeskLR')
        $this.GridDeskUL =   $this.GetWPFObject('GridDeskUL')
    
        $this.Library =     [TTLibraryManager]::new( $this )
        $this.Index =       [TTIndexManager]::new( $this )
        $this.Shelf =       [TTShelfManager]::new( $this )
        $this.Desk =        [TTDeskManager]::new( $this )
        $this.Cabinet =     [TTCabinetManager]::new( $this )
        $this.Document =    [TTDocumentManager]::new( $this )
        $this.PopupMenu =   [TTPopupMenuManager]::new( $this )

    }
    [object] GetWPFObject( [string]$name ){
        return $this._window.FindName( $name )
    }
    #endregion

    #region SetDefaultState/ ShowApplication
    [void] SetDefaultStates(){
        $this.Window( 'State', 'Max' )
        $this.Window( 'Top', '0' )
        $this.Window( 'Left', '0' )
        $this.Border( 'Layout.Library.Width',   '15' )
        $this.Border( 'Layout.Library.Height',  '25' )
        $this.Border( 'Layout.Shelf.Height',    '25' )
        $this.Border( 'Layout.Work1.Width',     '70' )
        $this.Border( 'Layout.Work1.Height',    '70' )
        $this.Border( 'Layout.Library.ExWidth', '50' )
        $this.Border( 'Layout.Shelf.ExHeight',  '75' )
        $this.Border( 'Layout.Work1.ExHeight',  '80' )
        $this.Border( 'Layout.Work1.ExWidth',   '20' )


        # $this._set( 'Config.MessageOnCacheSaved',   'False' ) # Modelでsetして、eventで設定すべし
        # $this._set( 'Config.MessageOnMemoSaved',    'True' )  # Viewでsetして、eventで設定すべし
        # $this._set( 'Config.MessageOnTaskExpired',  'False' ) # Viewでsetして、eventで設定すべし
        # $this._set( 'Config.MessageOnKeyDown',      'False' ) # Viewでsetして、eventで設定すべし
        # $this._set( "Config.MessageOnTaskRegistered", 'False' ) # Viewでsetして、eventで設定すべし

        # $this._set( 'Focus.Application',  'Library' )

        $this.Library.SetDefaultStates()
        $this.Index.SetDefaultStates()
        $this.Shelf.SetDefaultStates()
        $this.Desk.SetDefaultStates()
        $this.Cabinet.SetDefaultStates()
        $this.Document.SetDefaultStates()
        $this.PopupMenu.SetDefaultStates()
    
    }
    [void] ShowApplication(){


        # set default
        $this.SetDefaultStates()
        $this.Library.SetDefaultStates()
        $this.Index.SetDefaultStates()
        $this.Shelf.SetDefaultStates()
        $this.Desk.SetDefaultStates()
        $this.Cabinet.SetDefaultStates()
        $this.Document.SetDefaultStates()
        $this.PopupMenu.SetDefaultStates()

        # 220813: ここまでNo Errorでくるが要見直し。　
        # View/Modelは自分のことだけ考えて、ActionやStateがEvent Bindの面倒を見るのが良いのではないか

        # reset stored config


        $this._window.ShowDialog()
    }
    #endregion

    #region Window(io)/ Border(io)/ Title(io)
    [void] Window( [string]$name, [string]$value ){ 
        switch( $name ){
            'State' {
                switch( $value ){
                    'Max'    { $this._window.WindowState = [System.Windows.WindowState]::Maximized }
                    'Min'    { $this._window.WindowState = [System.Windows.WindowState]::Minimized }
                    'Normal' { $this._window.WindowState = [System.Windows.WindowState]::Normal }
                    'Close'  { $this._window.Close() }
                }
            }
            'Top' { $this._window.Top = [int]$value }
            'Left' { $this._window.Left = [int]$value }
        }
    }
    [string] Window( $name ){
        switch( $name ){
            'State' {
                switch( $this._window.WindowState ){
                    [System.Windows.WindowState]::Maximized { return 'Max' }
                    [System.Windows.WindowState]::Minimized { return 'Min' }
                    [System.Windows.WindowState]::Normal { return 'Normal' }
                }        
            }
            'Top' { return [string]$this._window.Top }
            'Left' { return [string]$this._window.Left }
        }
        return ""
    }
    [void] Border( [string]$name, [string]$value ){ # percent 
        $percent = [int]$value
        if( $value -match "^[+-]\d+$" ){ $percent += [int]$this._get( $name ) }
        if( $percent -lt 0 ){ $percent = 0 }
        if( 100 -lt $percent ){ $percent = 100 }

        switch( $name ){
            'Layout.Library.Width' {
                $this.GridWindowLR.ColumnDefinitions[0].Width = "$percent*"
                $this.GridWindowLR.ColumnDefinitions[1].Width = "$(100-$percent)*"
            }
            'Layout.Library.Height' {
                $this.GridLPanelUL.RowDefinitions[0].Height = "$percent*"
                $this.GridLPanelUL.RowDefinitions[1].Height = "$(100-$percent)*"
            }
            'Layout.Shelf.Height' {
                $this.GridRPanelUL.RowDefinitions[0].Height = "$percent*"
                $this.GridRPanelUL.RowDefinitions[1].Height = "$(100-$percent)*"
            }
            'Layout.Work1.Width' {
                $this.GridDeskLR.ColumnDefinitions[0].Width = "$percent*"
                $this.GridDeskLR.ColumnDefinitions[1].Width = "$(100-$percent)*"
            }
            'Layout.Work1.Height' {
                $this.GridDeskUL.RowDefinitions[0].Height = "$percent*"
                $this.GridDeskUL.RowDefinitions[1].Height = "$(100-$percent)*"
            }
        }

    }
    [string] Border( [string]$name ){ # 220812 eventで更新するなら必要ないか？
        $a = -1
        $b = 100

        switch( $name ){
            'Layout.Library.Width' {
                $a = $this.GridWindowLR.ColumnDefinitions[0].ActualWidth
                $b = $this.GridWindowLR.ColumnDefinitions[1].ActualWidth
            }
            'Layout.Library.Height' {
                $a = $this.GridLPanelUL.RowDefinitions[0].ActualHeight
                $b = $this.GridLPanelUL.RowDefinitions[1].ActualHeight
            }
            'Layout.Shelf.Height' {
                $a = $this.GridRPanelUL.RowDefinitions[0].ActualHeight
                $b = $this.GridRPanelUL.RowDefinitions[1].ActualHeight
            }
            'Layout.Work1.Width' {
                $a = $this.GridDeskLR.ColumnDefinitions[0].ActualWidth
                $b = $this.GridDeskLR.ColumnDefinitions[1].ActualWidth
            }
            'Layout.Work1.Height' {
                $a = $this.GridDeskUL.RowDefinitions[0].ActualHeight
                $b = $this.GridDeskUL.RowDefinitions[1].ActualHeight
            }
        }
        return [string][int]( $a / ( $a + $b ) * 100 )
    }
    [void] Title( $text ){ $this._window.Title = $text }
    [string] Title(){ return $this._window.Title }
    [void] Style( [string]$name, [string]$value ){
        switch( $name ){
            'Group' { # Standard, Zen, next+/prev+
                $order = @( 'Standard', 'Zen' )
                switch( $value ){
                    'Standard' {
                        $global:View.Border( 'Layout.Library.Width',    $this._get('Stored.Layout.Library.Width') )
                        $global:View.Border( 'Layout.Library.Height',   $this._get('Stored.Layout.Library.Height') )
                        $global:View.Border( 'Layout.Shelf.Height',     $this._get('Stored.Layout.Shelf.Height') )
                    }
                    'Zen' {
                        $this._set( 'Stored.Layout.Library.Width',  $global:View.Border('Layout.Library.Width') )
                        $this._set( 'Stored.Layout.Library.Height', $global:View.Border('Layout.Library.Height') )
                        $this._set( 'Stored.Layout.Shelf.Height',   $global:View.Border('Layout.Shelf.Height') )
                        $global:View.Border( 'Layout.Library.Width', 0 )
                        $global:View.Border( 'Layout.Shelf.Height', 0 )
                    }
                    default {
                        $style= [TTTool]::siblig( $_, $this._get('Layout.Style.Group'), $order )
                        if( $style -ne '' ){ $this.Style( $name, $style ) }
                        return
                    }
                    # $this._set( 'Layout.Style.Group', $value )
                    # $this.app.group.focus( $this.app._get('Current.Workplace'), '', '' )
                }
            }
            'Work' { # Work1, Work2, Work3, next+/prev+
                $order = @( 'Work1', 'Work2', 'Work3' )
                $layout = @{}
                switch( $value ){
                    'Work1' { $layout = @{ width = 100;  height = 100 } }
                    'Work2' { $layout = @{ width = 0;    height = 100 } }
                    'Work3' { $layout = @{ width = 0;    height = 0 } }
                    default{
                        $style= [TTTool]::siblig( $_, $this._get('Layout.Style.Work'), $order )
                        if( $style -ne '' ){ $this.Style( $name, $style ) }
                        return
                    }
                }
                $global:View.Border( 'Layout.Work1.Width', $layout.width )
                $global:View.Border( 'Layout.Work1.Height', $layout.height )
                $this._set( 'Layout.Style.Work', $value )
                # $this.group.focus( $value, '', '' )

            }
            'Focus+Work' { # Workplace≧2 → focusWork, Workplace=1 → Work+Focus
                $focusable_tools = @( 'Work1', 'Work2', 'Work3' ).where{ $global:View.Focusable($_) }
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
                        $this.app._set( 'Layout.Work1.Width', $global:View.Border('Layout.Work1.Width') )
                        $this.app._set( 'Layout.Work1.Height', $global:View.Border('Layout.Work1.Height') )
                        $global:View.Border( 'Layout.Work1.Width', 100 )
                        $global:View.Border( 'Layout.Work1.Height', 100 )
                        $work = $this.app._get('Current.Workplace')
                        $this.style( 'Work', $work )
                        $this.app.group.focus( $work, '', '' )
                    }
                    'Work12' {
                        $this.app._set( 'Layout.Work1.Height', $global:View.Border('Layout.Work1.Height') )
                        $global:View.Border( 'Layout.Work1.Width', $this.app._get('Layout.Work1.Width') )
                        $global:View.Border( 'Layout.Work1.Height', 100 )
                        $this.app._set( 'Layout.Style.Desk', $value )                
                    }
                    'Work123' {
                        $global:View.Border( 'Layout.Work1.Width', $this.app._get('Layout.Work1.Width') )
                        $global:View.Border( 'Layout.Work1.Height', $this.app._get('Layout.Work1.Height') )
                        $this.app._set( 'Layout.Style.Desk', $value )                
                    }
                    'Work13' {
                        $this.app._set( 'Layout.Work1.Width', $global:View.Border('Layout.Work1.Width') )
                        $global:View.Border( 'Layout.Work1.Width', 100 )
                        $global:View.Border( 'Layout.Work1.Height', $this.app._get('Layout.Work1.Height') )
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
                        $global:View.Border( 'Layout.Library.Width', 0 )
                        $this.app._set( 'Layout.Style.Library', $value )
                    }
                    'Default' {
                        $global:View.Border( 'Layout.Library.Width', $this.app._get('Layout.Library.Width') )
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
                        $global:View.Border( 'Layout.Library.Height', 100 )
                        $this.app._set( 'Layout.Style.Index', $value )
                    }
                    'Default' {
                        $global:View.Border( 'Layout.Library.Height', $this.app._get('Layout.Library.Height') )
                        $this.app._set( 'Layout.Style.Index', $value )
                    }
                    'Extent' {
                        $global:View.Border( 'Layout.Library.Height', 0 )
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
                        $global:View.Border( 'Layout.Shelf.Height', 0 )
                        $this.app._set( 'Layout.Style.Shelf', $value )
                    }
                    'Default' {
                        $global:View.Border( 'Layout.Shelf.Height', $this.app._get('Layout.Shelf.Height') )
                        $this.app._set( 'Layout.Style.Shelf', $value )
                    }
                    'Extent' {
                        $width = $this.app._get('Layout.Shelf.Height') + 20
                        $global:View.Border( 'Layout.Shelf.Height', $width )
                        $this.app._set( 'Layout.Style.Shelf', $value )
                    }
                    'Full' {
                        $global:View.Border( 'Layout.Shelf.Height', 100 )
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

    }


    #endregion

    #region Focus/ Focasable/ Dialog  
    [string] Focus( [string] $target ){

        switch -regex ( $target ){      
            "(Library|Index|Shelf|Desk|Cabinet)" {                          # Library|Index|Sheld|Desk|Cabninet
                return $this.$target.Focus()
            }
            "Workplace" {                                                   # Workplace
                return $this.Document.Focus( $this.Document.CurrentNumber )
            }
            "Work(?<num>[123])" {                                           # Work[123]
                return $this.Document.Focus( [int]($Matches.num) )
            }
            "(?<panel>Editor|Browser|Grid)(?<num>[123])" {                  # Editor[123]/Browser[123]/Grid[123]
                return $this.Document.SelectTool( $Matches.num, $Matches.panel ).Focus($Matches.num)
            }
            default{
                Write-Host "ERROR!!: AppMan.Focus"
            }
        }

        <#
        if( $target -match "(?<panel>[^\d]+)(?<num>\d)?" ){
            $panel = $Matches.panel
            $num = [int]($Matches.num)

            if( 0 -eq $num ){               # Library/Index/Shelf/Desk
                return $this.$panel.Focus() 

            }else{                          # xxxx1/xxxx2/xxxx3
                $this.Desk.Focus() 
                if( $panel -eq 'Work' ){    # Work*
                    return $this.Document.Focus($num)
                }else{                      #Editor*/Browser*/Grid*
                    return $this.Document.SelectTool($num,$panel).Focus($num)
                }
            }
        }
        #>

        return ''
    }
    [bool] Focusable( [string]$id ){
        switch -wildcard ( $id ){
            'Workplace' { return $true }
            'Cabinet'   { return $true }
            'Library'   { return ( $this.Border('Layout.Library.Width') -ne 0 -and   $this.Border('Layout.Library.Height') -ne 0 ) }
            'Index'     { return ( $this.Border('Layout.Library.Width') -ne 0 -and   $this.Border('Layout.Library.Height') -ne 100 ) }
            'Shelf'     { return ( $this.Border('Layout.Library.Width') -ne 100 -and $this.Border('Layout.Shelf.Height') -ne '0' ) }
            'Desk'      { return ( $this.Border('Layout.Library.Width') -ne 100 -and $this.Border('Layout.Shelf.Height') -ne 100 ) }
            '*1'    { return ( $this.Focusable('Desk') -and $this.Border('Layout.Work1.Height') -ne 0 -and $this.Border('Layout.Work1.Width') -ne 0 ) }
            '*2'    { return ( $this.Focusable('Desk') -and $this.Border('Layout.Work1.Height') -ne 0 -and $this.Border('Layout.Work1.Width') -ne 100 ) }
            '*3'    { return ( $this.Focusable('Desk') -and $this.Border('Layout.Work1.Height') -ne 100 ) }
        }
        return $false
    }
    #endregion
}


class TTPanelManager { # abstract

    #region variables/ new
    static [bool] $DisplayAlert = $true
    [string] $_name
    [TTAppManager] $_app
    [Label] $_label
    [DataGrid] $_datagrid
    [TextBox] $_textbox
    [Menu] $_menu
    [DockPanel] $_panel
    # [string] $_resource

    [psobject[]] $_items
    [hashtable] $_dictionary
    [string[]] $_order
    [string] $_index
    [string] $_colname
    [string] $_sortdir
    [object] $_preserved
    [string] $_caption
    [string] $_header

    TTPanelManager( $name, [TTAppManager]$app ){
        $this._name =   $name
        $this._app =    $app

    }
    #endregion

    #region Items/ SelecteItems/ SelectedItem/ GetItems/ SelectedIndex/ Refresh
    [TTPanelManager] Items( [psobject[]]$items, [hashtable]$dictionary, [string[]]$order ){
        # 【引数】 
        # items : @( @{ Name = ""; Value = "" } )
        # dictionary : @{ Name = "名前"; Value = "値"; Index = "Name" }
        # order : @( "flag" , "Name", "Value" )
        $this._items = $items
        $this._dictionary = $dictionary
        $this._order = $order
        $this._index = $dictionary.Index
        $this._colname = $dictionary.Index
        $this._sortdir = 'Descending'

        $this._datagrid.ItemsSource = $items
        $this._datagrid.AutoGenerateColumns = $false
        $this._datagrid.Columns.Clear()
        $order.foreach{
            $col = [DataGridTextColumn]::New()
            $col.Header = $dictionary[$_]
            $col.Binding = [Data.Binding]::New($_)
            if( $order.IndexOf($_) -eq $order.count - 1 ){ $col.Width = "*" }
            $this._datagrid.Columns.Add( $col )
        }

        return $this

    }
    [object[]] SelectedItems(){
        return $this._datagrid.SelectedItems
    }
    [object] SelectedItem(){
        return $this._datagrid.SelectedItem
    }
    [object[]] GetItems( [string]$keyword ){
        $items = @()
        switch( $keyword ){
            'SelectedItems' {
                $items = $this._datagrid.SelectedItems
            }
            'AllItems' {
                $items = [System.Windows.Data.CollectionViewSource]::GetDefaultView( $this._datagrid.ItemsSource )
            }  
            default {
                $items = $this._datagrid.Items.where{ $_.($this._colname) -like $keyword }
            }
        }
        return $items

    }
    [string] SelectedIndex(){
        return $this._datagrid.SelectedItem.($this._index) 
    }
    [TTPanelManager] Refresh(){

        $this._datagrid.Items.refresh()
        return $this
    }

    #endregion

    #region FocusMark/ Caption(io)/ Keyword(io)/ Keywords/ Sorting
    [TTPanelManager] FocusMark( [string]$header ){
        $this._header = $header
        $this._label.Content = "$($this._header)$($this._name): $($this._caption)"
        return $this
    }
    [TTPanelManager] Caption( [string]$caption ){
        $this._caption = $caption
        $this._label.Content = "$($this._header)$($this._name): $($this._caption)"
        return $this
    }
    [string] Caption(){
        return $this._caption
    }
    [TTPanelManager] Keyword( [string]$keyword ){
        $this._textbox.Text = $keyword
        return $this
    }
    [string]Keyword(){
        return $this._textbox.Text
    }
    [string[]]Keywords(){
        $tb = $this._textbox
        if( $tb.Text -ne '' ){
            $pos = $tb.Text.SubString( 0, $tb.CaretIndex ).split(',').count - 1
            $text = $tb.Text.Split(',')[$pos].Trim()
            if( $text -ne '' ){
                $text = $text -replace "[\.\^\$\|\\\[\]\(\)\{\}\+\*\?]", '\$0'
                $text = $text -replace "[　\t]+", ' '
                return $text.Split(' ')
            }
        }
        return $null

    }
    [TTPanelManager] Sorting( [psobject[]]$menus ){
        # 【引数】 
        # sorting : @( @{ Titles = (CSV); Value = (ScriptBlock) },,, )

        $this._menu.Items.Clear()

        if( $null -ne $menus ){
            foreach( $menu in $menus ){
                $items = $this._menu.Items
                $titles = $menu.Titles.split(",")
                foreach( $title in $titles ){
                    if( 0 -eq $items.where{ $_.Header -eq $title }.count ){
                        $item = [MenuItem]::New()
                        $item.Header = $title
                        if( $titles[-1] -eq $title ){ $item.Add_Click( $menu.Script ) }
                        $items.Add($item)
                        $items = $item.Items

                    }else{
                        $items = $items.where{ $_.Header -eq $title }[0].Items
                    }
                }
            }
        }

        return $this

    }
    
    #endregion

    #region Cursor/ Column(io)/ Sort(io)/ Select/ Focus/ Extract/ Add/ Delete/ Alert
    [TTPanelManager] Cursor( [string]$action ){
        $dg = $this._datagrid

        switch( $action ){
            'up'    { $dg.SelectedIndex -= if( 0 -lt $dg.SelectedIndex ){ 1 }else{ 0 } }
            'down'  { $dg.SelectedIndex += if( $dg.SelectedIndex -lt $dg.Items.Count - 1 ){ 1 }else{ 0 } }
            'first' { $dg.SelectedIndex = 0 }
            'last'  { $dg.SelectedIndex = $dg.Items.Count - 1 }
            'up+'   { $dg.SelectedIndex -= if( 0 -le $dg.SelectedIndex ){ 1 }else{ -$dg.Items.Count } }
            'down+' { $dg.SelectedIndex += if( $dg.SelectedIndex -lt $dg.Items.Count - 1 ){ 1 }else{ -$dg.Items.Count } }
            'preserve'  {
                if( $null -eq $dg.SelectedItem ){ break }
                $this._preserved = $dg.SelectedItem
            }
            'restore'   { 
                if( $null -eq $this._preserved ){ break }
                if( 0 -lt $dg.Items.where{ $_ -eq $this._preserved }.count ){
                    $dg.SelectedItem = $this._item
                }
            }
            default {
                ForEach( $item in $dg.Items ){
                    if( $item.($this._colname) -like $action ){
                        $dg.ScrollIntoView($item)
                        $dg.SelectedItem = $item
                        break 
                    }
                }
            }
        }
        if( 0 -le $dg.SelectedIndex ){ $dg.ScrollIntoView( $dg.SelectedItem ) }
        return $this
    }
    [TTPanelManager] Column( [string]$name ){
        switch( $name ){
            'index'     { $this._colname = $this._index }
            ''          { $this._colname = $this._index }
            default     { 
                try{ 
                    $num = [int]$name
                    if( ( 0 -lt $num ) -and ( $num -le $this._datagrid.columns.count ) ){
                        $this._colname = $this._dictionary.Keys.where{
                            $this._dictionary[$_] -eq $this._datagrid.columns[$num-1].Header 
                        }[0]
                    }else{
                        $this._colname = $null
                    }
                }catch{
                    $this._colname = $this._dictionary.Keys.where{ $_ -eq $name }[0]
                    if( 0 -eq $this._colname.length ){
                        $this._colname = $this._dictionary.Keys.where{ $this._dictionary[$_] -eq $name }[0]
                    }
                }
                if( 0 -eq $this._colname.length ){
                    $this._colname = @($this._dictionary.Keys)[0]
                }

            }
        }
        return $this

    }
    [string] Column(){
        return $this._colname
    }
    [TTPanelManager] Sort( [string]$direction ){

        $view = [System.Windows.Data.CollectionViewSource]::GetDefaultView( $this._datagrid.ItemsSource )
        $direction  = switch( $direction ){
            'toggle'    { if( 'Descending' -eq $view.SortDescriptions[0].Direction ){ 'Ascending' }else{ 'Descending' }  }
            'Ascending' { 'Ascending' }
            default     { 'Descending' }
        }
        $view.SortDescriptions.Clear()
        $sortDescription = New-Object System.ComponentModel.SortDescription( $this._colname, $direction )
        $this.Alert( "'$($this._colname)'を$($direction)でソート", 2 )
        $view.SortDescriptions.Add( $sortDescription )

        $this._sortdir = $direction
        $this._datagrid.Items.refresh()

        return $this
    }
    [string[]] Sort(){
        $dic = @{ 'Ascending' = '正順'; 'Descending' = '逆順' }
        return @( $this._dictionary[$this._colname], $dic[$this._sortdir] )
    }
    [TTPanelManager] Select( [string]$index ){
        $this._datagrid.SelectedItem = $this._datagrid.Items.where{ $_.($this._index) -eq $index }[0]
        return $this
    }
    [string] Focus(){
        $this._textbox.Focus()
        return $this._name
    }
    [TTPanelManager] Extract(){
        return $this.Extract( $this._textbox.Text )
    }
    [TTPanelManager] Extract( [string]$keyword ){
        $view = [System.Windows.Data.CollectionViewSource]::GetDefaultView( $this._datagrid.ItemsSource )
        if( $keyword -eq '' ){
            $view.Filter = $null

        }else{
            $view.Filter = {
                $key = $script:keyword
                $item = $args[0]
                $item_content = ( @($item.GetDictionary().Keys.foreach{ $item.$_ }) -join "," )
                @($key.split(",").foreach{
                    @($_.Trim().split(" ").foreach{
                        if ( $_ -like "-*" ) { # 除外 
                            $item_content -notlike "*$($_.substring(1))*" 
                        } else { # 選択
                            $item_content -like "*$_*"
                        }
                    }) -notcontains $false
                }) -contains $true
            }.GetNewClosure()
        }
        return $this
    }
    [TTPanelManager] Add( [object]$item ){ # none
        return $this
    }
    [TTPanelManager] Delete( [object]$item ){ # none
        return $this
        
    }
    [TTPanelManager] Alert( [string]$text, [int]$sec ){
        if( [TTPanelManager]::DisplayAlert ){
            $tmp = $this._label.Content
            $name = $this._name
            TTTimerResistEvent "$name::Message" $sec 0 {
                if( $global:View.($script:name)._label.Content -eq $script:text ){
                    $global:View.($script:name)._label.Content = $script:tmp
                }
            }.GetNewClosure()
            $this._label.Content = $text
        }

        return $this
    }

    #endregion

}
#region TTLibraryManager, TTIndexManager, TTShellManager, TTDeskManager, TTCabinaetManager
class TTLibraryManager : TTPanelManager {
    TTLibraryManager( [TTAppManager]$app ) : base ( 'Library', $app ){
        $this._panel =      $app.GetWPFObject('LibraryPanel')
        $this._label =      $app.GetWPFObject('LibararyCaption')
        $this._datagrid =   $app.GetWPFObject('LibararyItems')
        $this._textbox =    $app.GetWPFObject('LibararyKeyword')

    }
    [void] SetDefaultStates(){
        $this.Items( 'Thinktank' )

        # $this._set( 'Library.Resource',     'Thinktank' )
        # $this._set( 'Library.Keyword',      '' )
        # $this._set( 'Library.Sort.Dir',     'Descending' )
        # $this._set( 'Library.Sort.Column',  'UpdateDate' )
        # $this._set( 'Library.Selected',     'Memos' )
    }
}
class TTIndexManager : TTPanelManager {
    TTIndexManager( [TTAppManager]$app ) : base ( 'Index', $app ){
        $this._panel =      $app.GetWPFObject('IndexPanel')
        $this._label =      $app.GetWPFObject('IndexCaption')
        $this._datagrid =   $app.GetWPFObject('IndexItems')
        $this._textbox =    $app.GetWPFObject('IndexKeyword')

    }
    [void] SetDefaultStates(){
        # $this._set( 'Index.Resource',       'Status' )
        # $this._set( 'Index.Keyword',        '' )
        # $this._set( 'Index.Sort.Dir',       'Descending' )
        # $this._set( 'Index.Sort.Column',    'Name' )
        # $this._set( 'Index.Selected',       'Application.Author.Name' )
    }
}
class TTShelfManager : TTPanelManager {
    TTShelfManager( [TTAppManager]$app ) : base ( 'Shelf', $app ){
        $this._panel =      $app.GetWPFObject('ShelfPanel')
        $this._label =      $app.GetWPFObject('ShelfCaption')
        $this._datagrid =   $app.GetWPFObject('ShelfItems')
        $this._textbox =    $app.GetWPFObject('ShelfKeyword')
        $this._menu =       $app.GetWPFObject('ShelfSorting')

    }
    [void] SetDefaultStates(){
        # $this._set( 'Shelf.Resource',       'Memos' )
        # $this._set( 'Shelf.Keyword',        '' )
        # $this._set( 'Shelf.Sort.Dir',       'Descending' )
        # $this._set( 'Shelf.Sort.Column',    'UpdateDate' )
        # $this._set( 'Shelf.Selected',       'thinktank' )
    }

}
class TTDeskManager : TTPanelManager {
    TTDeskManager( [TTAppManager]$app ) : base ( 'Desk', $app ){
        $this._panel =      $app.GetWPFObject('DeskPanel')
        $this._label =      $app.GetWPFObject('DeskCaption')
        $this._textbox =    $app.GetWPFObject('DeskKeyword')
        $this._menu =       $app.GetWPFObject('DeskSorting')

    }
    [void] SetDefaultStates(){
        # $this._set( 'Desk.Keyword', '' )
    }

}
class TTCabinetManager : TTPanelManager {

    #region variables/ new
    [System.Windows.Window]$_window
    [object[]] $_selected

    $xml = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        Title="Cabinet" Name="Cabinet"  Top="10" Left="10" WindowStyle="None" AllowsTransparency="True" Topmost="True" >

        <Window.Resources>
            <ResourceDictionary Source="C:\Users\shin\Documents\ThinktankPS2\script\thinktank-style.xaml"/>
        </Window.Resources>

        <Border BorderBrush="Black" BorderThickness="1">
            <Grid Margin="0" FocusManager.FocusedElement="{Binding ElementName=SelectTextBox}"
                Background="White" >
                <DockPanel Name="CabinetPanel">
                    <Label Name="CabinetCaption"
                        DockPanel.Dock="Top" Margin="0" HorizontalAlignment="Stretch" Content="" />
                    <Grid DockPanel.Dock="Top" HorizontalAlignment="Stretch" >
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="3*"/>
                            <ColumnDefinition Width="7*"/>
                        </Grid.ColumnDefinitions>

                        <Menu Name="CabinetSorting" FontFamily="Meiryo" FontSize="12">
                            <MenuItem Header="thinktank" />
                            <MenuItem Header="すると" />
                            <MenuItem Header="キャンプ" />
                            <MenuItem Header="車旅行" />
                        </Menu>

                        <GridSplitter Grid.Column="0" Width="4" IsTabStop="False" />

                        <TextBox Name="CabinetKeyword" Text="" FontFamily="Meiryo" FontSize="12" Grid.Column="1" />
                    </Grid>

                    <DataGrid Name="CabinetItems"
                        AutoGenerateColumns="False"
                        ColumnHeaderHeight="22" RowHeight="22" FontFamily="Meiryo" FontSize="11"
                        BorderThickness="0" HorizontalAlignment="stretch" />

                </DockPanel>
            </Grid>
        </Border>
    </Window>
"@.replace( "C:\Users\shin\Documents\ThinktankPS2\script", $global:TTScriptDirPath )

    TTCabinetManager( [TTAppManager]$app ) : base ( 'Cabinet', $app ){
        $this._window = [Markup.XamlReader]::Load( (New-Object XmlNodeReader ([xml]$this.xml) ) )
        $this._name = $this._window.Name

        $this._panel =      $this._window.FindName('CabinetPanel')
        $this._label =      $this._window.FindName('CabinetCaption')
        $this._datagrid =   $this._window.FindName('CabinetItems')
        $this._textbox =    $this._window.FindName('CabinetKeyword')
        $this._menu =       $this._window.FindName('CabinetSorting')

    }

    #endregion

    #region SetDefaultStates 
    [void] SetDefaultStates(){
        # $this._set( 'Cabinet.Resource',       'Commands' )
        # $this._set( 'Cabinet.Keyword',        '' )
        # $this._set( 'Cabinet.Sort.Dir',       'Descending' )
        # $this._set( 'Cabinet.Sort.Column',    'UpdateDate' )
        # $this._set( 'Cabinet.Selected',       'ttcmd_application_window_quit' )
        # $this._set( 'Cabinet.Left',   '0' ) # Viewでsetして、eventで設定すべし
        # $this._set( 'Cabinet.Top',    '0' ) # Viewでsetして、eventで設定すべし
    }

    #endregion

    #region Title/ Show/ Hide/ Focus
    [TTCabinetManager] Title( $text ){
        $this.Caption( $text )
        return $this
    }
    [object[]] Show(){
        $this._textbox.Focus()
        $this._window.ShowDialog()
        return $this._selected
    }
    [TTCabinetManager] Hide( [bool]$result ){
        if( $result ){
            $this._selected = $this._datagrid.SelectedItems
        }else{
            $this._selected = $null
        }
        $this._window.Dispatcher.Invoke({$global:View.Cabinet._window.Hide() })
        return $this
    }
    [string] Focus(){
        return $this.Show()
    }

    #endregion
}

#endregion


class TTDocumentManager{
    #region variants/ new
    [TTAppManager] $app
    [TTEditorsManager] $Editor
    [TTBrowsersManager] $Browser
    [TTGridsManager] $Grid
    [string[]] $IDs = @('','','')
    [object[]] $Controls = @($null,$null,$null)

    [int] $CurrentNumber = 1
    [string[]] $CurrentTools = @('','','') # Editor/Browser/Grid

    TTDocumentManager( [TTAppManager]$app ){
        $this.app = $app
        $this.IDs =         @( 'Work1', 'Work2', 'Work3' )
        $this.Controls =    @( $this.IDs.foreach{ $this.app.GetWPFObject($_) } )

        $this.Editor =  [TTEditorsManager]::New( $this )
        $this.Browser = [TTBrowsersManager]::New( $this )
        $this.Grid =    [TTGridsManager]::New( $this )

    }
    #endregion    

    #region SetDefaultStates

    [void] SetDefaultStates(){
        (1..3).foreach{ $this.SelectTool( $_, 'Editor' ) }

        # $this._set( 'Work1.Tool', 'Editor' )
        # $this._set( 'Work2.Tool', 'Editor' )
        # $this._set( 'Work3.Tool', 'Editor' )
        # $this._set( 'Current.Workspace', 'Work1' )
        # $this._set( 'Current.Tool', 'Editor1' )

        $this.Editor.SetDefaultStates()
        $this.Browser.SetDefaultStates()
        $this.Grid.SetDefaultStates()
    }

    #endregion

    #region Focus/ SetCurrent/ SelectTool
    [TTDocumentManager] Focus( [int]$num ){ # 1..3
        $this.SetCurrent( $num )
        $this.( $this.CurrentTools[$num-1] ).Focus( $num )
        return $this
    }
    [TTDocumentManager] SetCurrent( [int]$num ){ # 1..3
        $this.CurrentNumber = $num
        return $this
    }
    [TTDocumentManager] SelectTool( [int]$num, [string]$tool ){
        $this.CurrentTools[$num-1] = $tool  # Editor/Browser/Grid

        $this.Editor.Controls[$num-1].Visibility =  [Visibility]::Collapsed
        $this.Browser.Controls[$num-1].Visibility = [Visibility]::Collapsed
        $this.Grid.Controls[$num-1].Visibility =    [Visibility]::Collapsed
        $this.$tool.Controls[$num-1].Visibility =   [Visibility]::Visible

        return $this
    }

    #endregion
}


class TTToolsManager { # abstract
    #region varinats/ new
    [TTAppManager] $app
    [TTDocumentManager] $docman
    # [string[]] $IDs
    [object[]] $Controls

    TTToolsManager( $docman ){                  # should be override
        $this.docman = $docman
        $this.app = $docman.app
        
        $this.Controls = @( $this.IDs.foreach{ $this.app.GetWPFObject($_) } )
    }

    #endregion

    [string] Focus( [int]$num ){                # should be override
        $tool = $this.Controls[$num-1]
        $tool.Focus()
        return $tool.Name

    }
    [TTToolsManager] ScrollTo( $to ){           # should be override
        return $this
    }

}
#region　TTEditorsManager / TTBrowsersManager / TTGridsManager

class TTEditorsManager : TTToolsManager{

    #region variants/ new
    static [bool] $StayCursor = $false
    static [bool] $DisplaySavingMessage = $false

    hidden [ICSharpCode.AvalonEdit.Document.TextDocument[]] $documents = @()
    [string[]] $Indices =           @( "", "", "" )
    [object[]] $FoldManagers =      @( $null, $null, $null )
    [object[]] $FoldStrategies =    @( $null, $null, $null )
    [object[]] $HightlightRules =   @( @(), @(), @() )
    [string[][]] $Histories=        @( @(@('') * 100), @(@('') * 100), @(@('') * 100) )
    [int[]] $HistoryPositions =     @( -1, -1, -1 )
    [string[]] $IDs =               @( 'Editor1', 'Editor2', 'Editor3' )
    [xml] $xshd

    TTEditorsManager( $docman ) : base( $docman ) {
        $this.xshd = Get-Content "$global:TTScriptDirPath\thinktank.xshd"
    }
    #endregion

    #region SetDefaultStates
    [void] SetDefaultStates(){

        # $this._set( 'Editor1.Index', 'thinktank' )
        # $this._set( 'Editor2.Index', 'thinktank' )
        # $this._set( 'Editor3.Index', 'thinktank' )

    }


    #endregion

    [TTEditorsManager] Initialize(){               # if needed

        ([TTToolsManager]$this).Initialize()
        $this.documents = @((1..3).foreach{ [ICSharpCode.AvalonEdit.Document.TextDocument]::new() })
        $this.documents.foreach{ $_.FileName = "" }
        (1..3).foreach{
            [void]$this.Initialize($_)
        }
        return $this

    }
    [TTEditorsManager] Initialize( [int]$num ){
        $editor = $this.Controls[$num-1]
        if( $null -ne $this.FoldManagers[$num-1] ){
            [ICSharpCode.AvalonEdit.Folding.FoldingManager]::Uninstall( $this.FoldManagers[$num-1] )
        }

        if( 0 -eq $this.documents.where{ 0 -eq $_.FileName.length }.count ){
            $this.documents.where{
                $_ -eq $editor.Document
            }.foreach{
                $_.Text = ''
                $_.FileName = ''
            }
            $this.Indices[$num-1] = ''
        }

        $this.FoldStrategies[$num-1] = $null
        $editor.Document = $null
        $editor.Options.ShowTabs = $True
        $editor.Options.IndentationSize = 6
        $editor.Options.HighlightCurrentLine = $True
        $editor.Options.EnableHyperlinks = $False
        $editor.Options.EnableEmailHyperlinks = $False

        $editor.SyntaxHighlighting = [ICSharpCode.AvalonEdit.Highlighting.Xshd.HighlightingLoader]::Load( 
            [XmlReader](New-Object XmlNodeReader ([xml]$this.xshd)),
            [ICSharpCode.AvalonEdit.Highlighting.HighlightingManager]::Instance
        )
        $editor.AllowDrop = $true

        $editor.Add_TextChanged(        { $global:Action.event_to_save_after_text_change_on_editor( $args ) })
        $editor.Add_PreviewMouseDown(   { $global:Action.event_to_invoke_action_after_click_on_editor( $args ) })
        $editor.Add_Drop(               { $global:Action.event_to_open_file_after_file_dropped( $args ) })
        $editor.Add_GotFocus(           { $global:State.event_after_editor_focused( $args ) })
        
        return $this
    }
    #region Add_Events
    static [ScriptBlock] $OnSaved = {}
    static [ScriptBlock] $OnLoaded = {}
    #endregion

    #region Load/ Save/ History
    [TTEditorsManager] Load( [string]$index ){
        return $this.Load( $this.docman.CurrentNumbe, $index )
    }
    [TTEditorsManager] Load( [int]$num, [string]$index ){
        if( $num -eq -1 ){ $num = $global:View.Document.CurrentNumber }

        $editor =   $this.Controls[$num-1]
        $index = $this.GetHistory( $index )
        $filepath = [TTTool]::index_to_filepath( $index )

        #### noneed to load
        if( -not (Test-Path $filepath) ){ 
            [TTTool]::debug_message( $this, "error >> no such file: $filepath" )
            return $this
        }
        if( $filepath -eq $editor.Document.FileName ){
            [TTTool]::debug_message( $this, "caution >> read already: $filepath" )
            return $this
        }

        #### load
        $this.Initialize( $num )

        $refdoc = $this.documents.where{ $_.FileName -eq $filepath }[0]
        if( $null -ne $refdoc ){    #::: share file loaded on other editor
            $editor.Document = $refdoc

        }else{                      #::: setup document object & load file
            $refdoc = $this.documents.where{ $_.FileName -eq "" }[0]
            $editor.Document = $refdoc
            $editor.Document.FileName = $filepath
            $editor.Load( $filepath )

        }

        $this.documents.where{
            $doc = $_
            0 -eq $this.Controls.where{ $_.Document -eq $doc }.count
        }.foreach{
            $_.Text = ''
            $_.FileName = ''
        }

        #### setup folding object
        $this.Indices[$num-1] = $index
        $this.FoldManagers[$num-1] = [ICSharpCode.AvalonEdit.Folding.FoldingManager]::Install( $editor.TextArea )
        $this.FoldStrategies[$num-1] = [AvalonEdit.Sample.ThinktankFoldingStrategy]::new()
        $this.FoldStrategies[$num-1].UpdateFoldings( $this.FoldManagers[$num-1], $editor.Document )

        #### invoke OnLoad event
        &([TTEditorsManager]::OnLoad) $this $num $index
        #    $this.SetHistory( $num, $index ) # →eventで処理する
        #    @('Index','Shelf','Cabinet').foreach{ $this.tools.app.group.refresh($_) }


        return $this
    }
    [TTEditorsManager] Save(){
        return $this.Save( $this.docman.CurrentNumbe )
    }
    [TTEditorsManager] Save( [int]$num ){
        if( $num -eq -1 ){ $num = $global:View.Document.CurrentNumber }

        $editor = $this.Controls[$num-1]
        $filepath = $editor.Document.FileName

        if( (0 -eq $filepath.length) -or ( -not $editor.IsModified ) ){ return $this }

        #### Save
        $editor.Encoding = [System.Text.Encoding]::UTF8
        $editor.Save( $filepath )

        #### invoke OnSave event
        &([TTEditorsManager]::OnSave) $this $num

        return $this
    }
    [string] GetHistory( [string]$action ){
        return $this.GetHistory( $this.docman.CurrentNumber, $action )
    }
    [string] GetHistory( [int]$num, [string]$action ){
        if( $num -eq -1 ){ $num = $global:View.Document.CurrentNumber }

        $curpos = $this.HistoryPositions[$num-1]
        $curidx = $this.Histories[$num-1][$curpos]

        switch( $action ){
            'backward' {    #### Previous index of history
                if( $curpos -le 0 ){ return $curidx }
                $curpos -= 1
                $this.HistoryPositions[$num-1] = $curpos
                return $this.Histories[$num-1][$curpos]
            }
            'forward' {     #### Forward index of history
                if( $curpos -eq 100 ){ return $curidx }
                $curpos += 1
                if( 0 -eq $this.Histories[$num-1][$curpos].length ){ return $curidx }
                $this.HistoryPositions[$num-1] = $curpos
                return $this.Histories[$num-1][$curpos]

            }
        }

        return $action
    }
    [void] SetHistory( [string]$index ){
        $this.SetHistory( $this.docman.CurrentNumber, $index )
    }
    [void] SetHistory( [int]$num, [string]$index ){
        if( $num -eq -1 ){ $num = $global:View.Document.CurrentNumber }

        $curpos = $this.HistoryPositions[$num-1]
        $curidx = $this.Histories[$num-1][$curpos]

        if( $curidx -eq $index ){ return }
        if( $curpos -eq 100 ){ return }
        $curpos += 1
        $this.HistoryPositions[$num-1] = $curpos
        if( $this.Histories[$num-1][$curpos] -ne $index ){
            $this.Histories[$num-1][$curpos] = $index
            @(($curpos+1)..99).foreach{ $this.Histories[$num-1][$_] = '' }
        }        
    }
    [string] Create(){
        #### invoke OnCreate event
        $index = $global:Model.GetChild('Memos').CreateChild()

        &([TTEditorsManager]::OnCreate) $this $index
        # @('Index','Shelf','Cabinet').where{ 
        #     $this.tools.app._get("$_.Resource") -eq 'Memos'
        # }.foreach{
        #     $this.tools.app.group.reload($_)
        # } 

        return $index
    }
    [string] Create( [int]$num ){
        if( $num -eq -1 ){ $num = $this.docman.CurrentNumber }
        $index = $this.Create()

        return $this.load( $index ) 
    }

    #endregion

    #region MoveTo/ NodeTo/ SelectTo
    [bool] MoveTo( [string]$to ){
        return $this.MoveTo( $this.docman.CurrentNumber, $to )
    }
    [bool] MoveTo( [int]$num, [string]$to ){
        if( $num -eq -1 ){ $num = $global:View.Document.CurrentNumber }

        $editor = $this.Controls[$num-1]
        $curpos = $editor.CaretOffset
        $curlin = $editor.document.GetLineByOffset( $curpos )
        $area = $editor.TextArea
        $doc  = $editor.Document

        :Handled switch( $to ){
            'documentstart' { [EditingCommands]::MoveToDocumentStart.Execute( $null, $area ) }
            'documentend'   { [EditingCommands]::MoveToDocumentEnd.Execute( $null, $area ) }
            'linestart' { [EditingCommands]::MoveToLineStart.Execute( $null, $area ) }
            'lineend'   { [EditingCommands]::MoveToLineEnd.Execute( $null, $area ) }
            'leftchar'  { [EditingCommands]::MoveLeftByCharacter.Execute( $null, $area ) }
            'rightchar' { [EditingCommands]::MoveRightByCharacter.Execute( $null, $area ) }
            'linestart+' {
                $to = if ( $curpos -eq $doc.GetLineByOffset( $curpos ).Offset ){ 'documentstart' }else{ 'linestart' }
                return $this.MoveTo( $num, $to )
            }
            'lineend+'  {
                $to = if ( $curpos -eq $doc.GetLineByOffset( $curpos ).EndOffset ){ 'documentend' }else{ 'lineend' }
                return $this.MoveTo( $num, $to )
            }
            'prevline+' {
                $editor.LineUp()
                [EditingCommands]::MoveUpByLine.Execute( $null, $area )
            }
            'prevline' {
                [EditingCommands]::MoveUpByLine.Execute( $null, $area )
            }
            'nextline+' {
                $editor.LineDown()
                [EditingCommands]::MoveDownByLine.Execute( $null, $area )
            }
            'nextline' {
                [EditingCommands]::MoveDownByLine.Execute( $null, $area )
            }
            'prevnode-' {
                $curlin = $curlin.PreviousLine
                while( $null -ne $curlin ){
                    # scan document
                    if( $doc.GetText( $curlin.Offset, $curlin.Length ) -match "^(?<tag>#+) .*" ){
                        $editor.CaretOffset = $curlin.Offset
                        $editor.ScrollToLine( $curlin.LineNumber )
                        break
                    }
                    $curlin = $curlin.PreviousLine
                }
            }
            'nextnode-' {
                $curlin = $curlin.NextLine
                while( $null -ne $curlin ){
                    # scan document
                    if( $doc.GetText( $curlin.Offset, $curlin.Length ) -match "^(?<tag>#+) .*" ){
                        $editor.CaretOffset = $curlin.Offset
                        $editor.ScrollToLine( $curlin.LineNumber )
                        break
                    }
                    $curlin = $curlin.NextLine
                }
            }
            'prevnode' {
                $level = if( $doc.GetText( $curlin.Offset, $curlin.Length  ) -match "(?<tag>^#+) .*"  ){ $Matches.tag.length }else{ 10 }
                $curlin = $curlin.PreviousLine
                while( $null -ne $curlin ){
                    # scan document
                    if( $doc.GetText( $curlin.Offset, $curlin.Length ) -match "^(?<tag>#{1,$level}) .*" ){
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
            'nextnode' {
                $level = if( $doc.GetText( $curlin.Offset, $curlin.Length ) -match "(?<tag>^#+) .*"  ){ $Matches.tag.length }else{ 10 }
                $curlin = $curlin.NextLine
                while( $null -ne $curlin ){
                    # scan document
                    if( $doc.GetText( $curlin.Offset, $curlin.Length ) -match "^(?<tag>#{1,$level}) .*" ){
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
            'prevkeyword' {
                $keywords = $this.app.Desk.Keywords()
                if( $null -eq $keywords ){
                    $this.MoveTo( $num, 'prevnode-' )

                }else{
                    $poskey = @( $keywords.foreach{ [pscustomobject]@{
                            pos = $editor.Document.LastIndexOf( $_, 0, $editor.CaretOffset - 1, [System.StringComparison]::CurrentCultureIgnoreCase )
                            key = $_ 
                        }
                    } | Sort-Object -Property pos -Descending )[0]

                    if( $poskey.pos -ne -1 ){
                        $editor.SelectionStart = $poskey.pos
                        $editor.SelectionLength = $poskey.key.length
                        $editor.ScrollTo( $area.Caret.Line, $area.Caret.Column )

                    }else{
                        return $false
                    }
                }
            }
            'nextkeyword' {
                $keywords = $this.app.Desk.Keywords()
                if( $null -eq $keywords ){
                    $this.MoveTo( $num, 'nextnode-' )

                }else{
                    $poskey = @( $keywords.foreach{ [pscustomobject]@{
                        pos = $editor.Document.IndexOf( $_, $editor.CaretOffset + 1, $editor.Text.Length - $editor.CaretOffset - 1, [System.StringComparison]::CurrentCultureIgnoreCase )
                        key = $_ 
                    }
                } | Sort-Object -Property pos -Descending )[-1]

                    if( $poskey.pos -ne -1 ){
                        $editor.SelectionStart = $poskey.pos
                        $editor.SelectionLength = $poskey.key.length
                        $editor.ScrollTo( $area.Caret.Line, $area.Caret.Column )
                        
                    }else{
                        return $false
                    }
                }
            }
            'prevkeywordnode' {
                $text = $global:View.Desk._textbox.Text.Trim().Split(",")[0]  # テキストボックスの最初の , までをキーワード認識
                $text = $text -replace "[\.\^\$\|\\\[\]\(\)\{\}\+\*\?]", '\$0'  # 正規表現記号をエスケープ 
                $text = $text -replace "[ 　\t]+", " "                          # 空白文字を半角に統一

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
            'nextkeywordnode' {
                $text = $global:View.Desk._textbox.Text.Trim().Split(",")[0]         # テキストボックスの最初の , までをキーワード認識
                $text = $text -replace "[\.\^\$\|\\\[\]\(\)\{\}\+\*\?]", '\$0'  # 正規表現記号をエスケープ 
                $text = $text -replace "[ 　\t]+", " "                          # 空白文字を半角に統一

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
            default{
                switch -regex( $to ){
                    "^(?<line>\d+)$" {
                        $editor.CaretOffset = $editor.Document.GetLineByNumber( [int]($Matches.line) ).EndOffset
                    }

                    "^(?<line>\d+):(?<column>\d+)$" {
                        $editor.CaretOffset = $editor.Document.GetLineByNumber( [int]($Matches.line) ).Offset + [int]($Matches.column)
                    }
                    "^#(?<keyword>.+)$" {
                        
                    }
                    "^(?<keyword>.+)$" {}
                }
            }
        }

        return $true

    }
    [bool] NodeTo( [string]$state ){
        return $this.NodeTo( $this.docman.CurrentNumber, $state )
    }
    [bool] NodeTo( [int]$num, [string]$state ){
        if( $num -eq -1 ){ $num = $global:View.Document.CurrentNumber }

        $editor =   $this.Controls[$num-1]
        $curpos =   $editor.CaretOffset
        $curlin =   $editor.document.GetLineByOffset( $curpos )
        $foldman =  $this.FoldManagers[$num-1]

        switch( $state ){
            'open_all'  { $foldman.AllFoldings.foreach{ $_.IsFolded = $false }; return $true }
            'close_all' { $foldman.AllFoldings.foreach{ $_.IsFolded = $true }; return $true }
        }

        # check not node
        if( -not ( $editor.document.GetText( $curlin.Offset, 10 ) -match "(?<tag>^#+) .*" ) ){ return $false }

        $level = $Matches.tag.length       
        $folding = $foldman.GetFoldingsAt( $curlin.EndOffset )[0]
        # check not folding
        if( $null -eq $folding ){ return $false }

        switch( $state ){
            'open' {
                if( $folding.IsFolded -ne $False ){
                    $folding.IsFolded = $False                  # open node
                }else{
                    $this.NodeTo( $num, 'open_children' )     # open all child nodes
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
                    $this.NodeTo( $num, 'open_sibling' )      # open all sibling nodes
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
                    $this.NodeTo( $num, 'close_sibling' )     # close all sibling nodes
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

        return $true
    }
    [bool] SelectTo( [string]$to, [string]$following_action ){
        return $this.SelectTo( $this.docman.CurrentNumber, $to, $following_action )
    }
    [bool] SelectTo( [int]$num, [string]$to, [string]$following_action ){
        if( $num -eq -1 ){ $num = $global:View.Document.CurrentNumber }

        $editor = $this.Controls[$num-1]
        $curpos  = $editor.CaretOffset

        switch( $to ){
            'all' {
                $editor.SelectAllItems
            }
            'line' {
                $line = $editor.Document.GetLineByOffset( $curpos )
                $editor.SelectionStart =    $line.Offset
                $editor.SelectionLength =   $line.Length
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
            default {
                $line = $editor.Document.GetLineByOffset( $curpos )
                $editor.SelectionStart = $editor.Document.GetText( $line.Offset, $line.Length ).IndexOf($_) + $line.Offset
                $editor.SelectionLength = $_.length
            }
        }

        switch( $following_action ){
            'cut' { $editor.Cut() }
            'copy' { $editor.Copy() }
            default {}
        }

        return $true

    }

    #endregion

    #region Text/ Edit
    [string] Text( [string]$attr ){
        return $this.Text( $this.docman.CurrentNumber, $attr )
    }
    [string] Text( [int]$num, [string]$attr ){
        $editor = $this.Controls[$num-1]

        switch( $attr ){
            'Title' { return ($editor.Text -split "`r?`n")[0] }
            'CurLine' {}
            'CurSection' {}
            'CurWord' {}
            'CurCharacter' {}
            'CurTag' {}
            'RootSection' {}
            'ParentSection' {}
        }
        return ""
    }
    [void] Edit( [string]$action ){
        $this.Edit( $this.docman.CurrentNumber, $action )
    }
    [void] Edit( [int]$num, [string]$action ){
        $editor = $this.Controls[$num-1]
        $doc = $editor.Document
        $cur = $editor.CaretOffset

        switch( $action ) {
            'delete'    { [EditingCommands]::Delete.Execute( $null, $editor.TextArea ) }
            'backspace' { [EditingCommands]::Backspace.Execute( $null, $editor.TextArea ) }
            'section+'  { return }
            'section-'  { return }
            'clipboard' { $this.Paste( $num ) }
            'newline'   { $doc.Insert( $cur, "`r`n" ) }
            'newline+'  { $editor.LineDown(); $doc.Insert( $cur, "`r`n" ) }
            'touch'     { $editor.IsModified = $true }
        }
    }
    #endregion

    #region Paste
    [void] Paste(){
        $this.Paste( $this.docman.CurrentNumber )
    }
    [bool] Paste( [int]$no ){
        $editor = $this.Controls[$no-1]
        $text = [TTClipboard]::GetText()

        switch( [TTClipboard]::DataType() ){
            "Text,"                     { $this._paste_url_text( $_, $editor, $text ) }
            "FileDropList,Text,CSV,"    { $this._paste_outlookmails( $_, $editor, $text ) }
            "Text,CSV,"                 { $this._paste_outlookmails( $_, $editor, $text ) } 
            "TTObject,"                 { $this._paste_ttobject( $_, $editor, $text ) } 
            "Text,TTObject,"            { $this._paste_ttobject_text( $_, $editor, $text ) } 
            "TTObjects,"                { $this._paste_ttobjects( $_, $editor, $text ) } 
            "FileDropList,Text,"        { $this._paste_outlookschedule( $_, $editor, $text ) }
            "Image,"                    { $this._paste_image( $_, $editor, $text ) } 
            "Image,Html,"               { $this._paste_image( $_, $editor, $text ) } 
            "Text,Rtf,Html,"            { $this._paste_url_text( $_, $editor, $text ) } # word
            "FileDropList,"             { $this._paste_files_folders( $_, $editor, $text ) }
            "Text,Html,"                { $this._paste_url_text( $_, $editor, $text ) } # favorite
            "Text,Image,CSV,Rtf,Html,DataInterchangeFormat," 
                                        { $this._paste_excelrange( $_, $editor, $text ) } 
            default                     { 
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
            $selected = $global:View.PopupMenu.Caption( 'URLをペースト' ).Items( $items.Keys ).Show()
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
            $selected = $global:View.PopupMenu.Caption( 'テキストをペースト' ).Items( $items.Keys ).Show()
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
                    $selected = $global:View.PopupMenu.Caption( 'Outlookメールをペースト' ).Items( $items.Keys ).Show()
                    $fmt = $items[$selected]
                    if( 0 -eq $fmt.length ){ return }
                }
                $doc.Insert( $cur, (Invoke-Expression $fmt) )
                $backupFolderName = $global:Model.GetChild('Configs').GetChild("OutlookBackupFolder").Value
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
                $selected = $global:View.PopupMenu.Caption( 'TTMemoをペースト' ).Items( $items.Keys ).Show()
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
    
        $folder = $global:Model.GetChild('Configs').GetChild("CaptureFolder").value
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
    
    #region UpdateFolding
    [bool] UpdateFolding( [int]$num ){
        if( ($null -ne $this.FoldStrategies[$num-1]) -and ($null -ne $this.FoldManagers[$num-1]) ){
            $this.FoldStrategies[$num-1].UpdateFoldings(
                $this.FoldManagers[$num-1], $this.Controls[$num-1].Document
            )
            return $true
        }
        return $false
    }
    #endregion
    
    #region no mod
    [TTDocumentManager] SetWordWrap( [int]$num, $value ){
        $this.Controls.WordWrap = $value
        return $this
    }
    # [TTToolsManager] ScrollTo( [int]$num, [string]$to ){            # should be override
    #     $editor = $this.Controls[$num]
    #     switch( $to ){
    #         'nextline' { $editor.LineUp() }
    #         'prevline' { $editor.LineDown() }
    #     }
    #     return $this
    # }
    [TTDocumentManager] Insert( [int]$num, [string]$text ){
        $editor = $this.Controls[$num]
        $editor.Document.Insert( $editor.CaretOffset, $text )

        return $this
    }
    # [TTDocumentManager] Edit( [int]$num, [string]$subject ){
    #     $editor = $this.Controls[$num]
        
    #     switch( $subject ){
    #         'delete'    { [EditingCommands]::Delete.Execute( $null, $editor.TextArea ) }
    #         'backspace' { [EditingCommands]::Backspace.Execute( $null, $editor.TextArea ) }
    #     }

    #     return $this
    # }
    [TTDocumentManager] Cursor( [int]$num, [string]$action ){
        $editor = $this.Controls[$num]

        switch( $action ){
            'save'      { $this.offset = $editor.CaretOffset }
            'restore'   { $editor.CaretOffset = $this.offset }
        }

        return $this
    }
    [string[]] AtCursor( [int]$num, [string]$action ){ # Textと機能被り
        $editor = $this.Controls[$num]
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
    [bool] Replace( [int]$num, [string]$regex, [string]$replace ){
        $editor = $this.Controls[$num]
        $curlin = $editor.document.GetLineByOffset( $editor.CaretOffset )
        $line = $editor.document.GetText( $curlin.Offset, $curlin.Length )

        if( $line -match $regex ){
            $line = $line -replace $regex, $replace
            $editor.Document.Replace( $curlin.Offset, $curlin.Length, $line )
            return $true
        }   

        return $false
    }
    [bool] Moved( [int]$num ){
        $editor = $this.Controls[$num]

        return ( $this.offset -eq $editor.CaretOffset )
    }

    #endregion
}

class TTBrowsersManager : TTToolsManager{
    #region variants/ new
    [string[]] $Urls = @( "", "", "" )
    [string[]] $IDs   = @( 'Browser1', 'Browser2', 'Browser3' )
    #endregion

    TTBrowsersManager( $docman ) : base($docman) {
    }

    #region SetDefaultStates
    [void] SetDefaultStates(){

        # $this.tools.app._set( 'Browser1.Url', 'http://google.com' )
        # $this.tools.app._set( 'Browser2.Url', 'http://google.com' )
        # $this.tools.app._set( 'Browser3.Url', 'http://google.com' )

    }
    #endregion

    [TTBrowsersManager] Initialize(){
        ([TTToolsManager]$this).Initialize()

        return $this
    }
    [TTBrowsersManager] Initialize( [int]$num ){
        $This.Controls[$num].Source = $null
        $this.Urls[$num] = ""
        Write-Host "State変更すること"

        # $this.app._set( "$($this.IDs[$num]).Url", "" )

        return $this
    }
}

class TTGridsManager : TTToolsManager{
    #region variants/ new
    [string[]] $Indices = @( "", "", "" )
    [string[]] $IDs   = @( 'Grid1', 'Grid2', 'Grid3' )

    TTGridsManager( $docman )  : base($docman) {
    }

    #endregion

    #region SetDefaultStates 
    [void] SetDefaultStates(){

        # $this.tools.app._set( 'Grid1.Index',  'thinktank' )
        # $this.tools.app._set( 'Grid2.Index',  'thinktank' )
        # $this.tools.app._set( 'Grid3.Index',  'thinktank' )

    }
    #endregion
    
    [TTGridsManager] Initialize(){
        ([TTToolsManager]$this).Initialize()

        return $this
    }
    [TTGridsManager] Initialize( [int]$num ){
        $This.Controls[$num].ItemsSource = $null
        $this.Indices[$num] = ""
        Write-Host "State変更すること"

        # $this.app._set( "$($this.IDs[$num]).Index", "" )

        return $this
    }
    
}
#endregion



class TTPopupMenuManager {
    #region variables/ new
    [string] $_name
    [TTAppManager] $_app
    [System.Windows.Window] $_window
    [ListView] $_list
    [string] $_selected
    $xml = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        Title="PopupMenu" Name="PopupMenu" WindowStyle="None" AllowsTransparency="True" Topmost="True">

        <Window.Resources>
            <ResourceDictionary Source="C:\Users\shin\Documents\ThinktankPS2\script\thinktank-style.xaml"/>
        </Window.Resources>
    
        <Border BorderBrush="Black" BorderThickness="1">
            <DockPanel>
                <Label Name="PopupMenuCaption"
                    DockPanel.Dock="Top" HorizontalAlignment="Stretch" Margin="0" Content="" />
                <ListView Name="PopupMenuItems"
                    SelectionMode="Single"
                    ScrollViewer.HorizontalScrollBarVisibility="Hidden"
                    ScrollViewer.VerticalScrollBarVisibility="Hidden"
                    FontFamily="Meiryo" FontSize="11">
                    <ListView.View>
                        <GridView>
                            <GridViewColumn/>
                        </GridView>
                    </ListView.View>
                </ListView>
            </DockPanel>
        </Border>
    </Window>
"@.replace( "C:\Users\shin\Documents\ThinktankPS2\script", $global:TTScriptDirPath )

    TTPopupMenuManager( [TTAppManager]$app ){
        $this._window = [Markup.XamlReader]::Load((New-Object XmlNodeReader ([xml]$this.xml)))
        $this._name = $this._window.Name
        $this._list = $this._window.FindName("PopupMenuItems")

        $style = [Style]::new()
        $style.Setters.Add( [Setter]::new( [Controls.GridViewColumnHeader]::VisibilityProperty, [Visibility]::Collapsed ) )
        $this._list.view.ColumnHeaderContainerStyle = $style

        # $this._set( 'PopupMenu.Left',   '0' ) # Viewでsetして、eventで設定すべし
        # $this._set( 'PopupMenu.Top',    '0' ) # Viewでsetして、eventで設定すべし
    }

    
    #endregion
    
    [void] SetDefaultStates(){
    }

    #region  Caption/ Cursor/ Items/ Hide/ Show/ Tio(io)/ Left(io)
    [TTPopupMenuManager] Caption( $text ){
        $this._window.FindName("$($this._name)Caption").Content = $text
        return $this
    }
    [TTPopupMenuManager] Cursor( [string]$action ){
        $list = $this._list
        switch( $action ){
            'up'    { $list.SelectedIndex -= if( 0 -lt $list.SelectedIndex ){ 1 }else{ 0 } }
            'down'  { $list.SelectedIndex += if( $list.SelectedIndex -lt $list.Items.Count - 1 ){ 1 }else{ 0 } }
            'first' { $list.SelectedIndex = 0 }
            'last'  { $list.SelectedIndex = $list.Items.Count - 1 }
            'up+'   { $list.SelectedIndex -= if( 0 -le $list.SelectedIndex ){ 1 }else{ -$list.Items.Count } }
            'down+' { $list.SelectedIndex += if( $list.SelectedIndex -lt $list.Items.Count - 1 ){ 1 }else{ -$list.Items.Count } }
            default { $list.SelectedItem = $list.Items.where{ $_ -like $action }[0]; break }
        }
        if( 0 -le $list.SelectedIndex ){ $list.ScrollIntoView( $list.SelectedItem ) }
        return $this
    }
    [TTPopupMenuManager] Items( $items ){
        $this._list.ItemsSource = $items

        $view = [System.Windows.Data.CollectionViewSource]::GetDefaultView( $this._list.ItemsSource )
        $view.SortDescriptions.Clear()
        $sortDescription = New-Object System.ComponentModel.SortDescription( "", 'Ascending' )
        $view.SortDescriptions.Add($sortDescription)

        return $this
    }
    [TTPopupMenuManager] Hide( [bool]$result ){
        if( $result ){ 
            $this._selected = $this._list.SelectedItem 
        }
        $this._window.Hide()
        # $this._window.Dispatcher.Invoke({ $global:View.PopupMenu._window.Hide() })
        return $this
    }
    [psobject] Show(){
        $width = (
            $this._list.ItemsSource.foreach{
                [System.Text.Encoding]::GetEncoding("shift_jis").GetByteCount( $_ )
            } | Measure-Object -Max
        ).Maximum
        $this._list.view.Columns[0].Width = $width * 10 + 15
        $this._list.SelectedItem = $this._list.ItemsSource.where{ $_ -like "@*" }[0]
        $this._window.Width = $width * 10 + 15
        $this._window.Width = $width * 10 + 15
        $this._window.Height = ($this._list.Items.Count + 1) * 22.5 + 15  
        
        # $this._list.SelectedIndex = -1

        # if( $global:TTKeyEventMod -ne 'None' ){
        #     [TTTentativeKeyBindingMode]::Start( 'PopupMenu', $global:TTKeyEventMod, '' )
        #     $this.Hide($true)
        #     # [TTTentativeKeyBindingMode]::Add_OnExit({ $global:View.PopupMenu.Hide($true) })
        # }

        $this._selected = ""                

        $this._window.ShowDialog()
        
        return $this._selected
    }
    [void] Top( [int] $num ){ $this._window.Top = $num }
    [int]  Top(){ return $this._window.Top }
    [void] Left( [int] $num ){ $this._window.Left = $num }
    [int]  Left(){ return $this._window.Left }

    #endregion
}















