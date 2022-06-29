﻿



using namespace System.Windows.Documents
using namespace System.Windows.Controls
using namespace System.Windows



class TTAppManager {
    #region variables
    [System.Windows.Window]$_window
    [Grid] $_grid_window_lr
    [Grid] $_grid_lpanel_ul
    [Grid] $_grid_rpanel_ul
    [Grid] $_grid_desk_lr
    [Grid] $_grid_desk_ul

    [TTCabinetManager] $Cabinet
    [TTPopupMenuManager] $PopupMenu
    [TTLibraryManager] $Library
    [TTIndexManager] $Index
    [TTShelfManager] $Shelf
    [TTDeskManager] $Desk
    [TTDocumentManager] $Document

    #endregion

    TTAppManager(){

        [xml]$xaml = Get-Content ( $global:TTScriptDirPath + "\thinktank.xaml" )
        $this._window = [System.Windows.Markup.XamlReader]::Load( (New-Object XmlNodeReader $xaml) )

        $this._window.Add_Loaded( $script:TTWindowLoaded )
        $this._window.Add_PreviewKeyDown( $global:TTPreviewKeyDown )
        $this._window.Add_PreviewKeyUp( $global:TTPreviewKeyUp )

        $this._grid_window_lr = $this.FindName('GridWindowLR')
        $this._grid_lpanel_ul = $this.FindName('GridLPanelUL')
        $this._grid_rpanel_ul = $this.FindName('GridRPanelUL')
        $this._grid_desk_lr =   $this.FindName('GridDeskLR')
        $this._grid_desk_ul =   $this.FindName('GridDeskUL')
    
        $this.PopupMenu =   [TTPopupMenuManager]::new( $this )
        $this.Library =     [TTLibraryManager]::new( $this )
        $this.Index =       [TTIndexManager]::new( $this )
        $this.Shelf =       [TTShelfManager]::new( $this )
        $this.Desk =        [TTDeskManager]::new( $this )
        $this.Cabinet =     [TTCabinetManager]::new( $this )
        $this.Document =    [TTDocumentManager]::new( $this )

    }
    [object] FindName( [string]$name ){
        return $this._window.FindName( $name )
    }
    [void] Show(){
        $this._window.ShowDialog()
    }
    [void] Window( [string]$state ){ 
        switch( $state ){
            'Max'    { $this._window.WindowState = [System.Windows.WindowState]::Maximized }
            'Min'    { $this._window.WindowState = [System.Windows.WindowState]::Minimized }
            'Normal' { $this._window.WindowState = [System.Windows.WindowState]::Normal }
            'Close'  { $this._window.Close() }
        }
    }
    [string] Window(){
        $ret = ""
        switch( $this._window.WindowState ){
            [System.Windows.WindowState]::Maximized { $ret = 'Max' }
            [System.Windows.WindowState]::Minimized { $ret = 'Min' }
            [System.Windows.WindowState]::Normal { $ret = 'Normal' }
        }
        return $ret
    }
    [void] Border( [string]$name, [int]$percent ){ 
        switch( $name ){
            'Layout.Library.Width' {
                $this._grid_window_lr.ColumnDefinitions[0].Width = "$percent*"
                $this._grid_window_lr.ColumnDefinitions[1].Width = "$(100-$percent)*"
            }
            'Layout.Library.Height' {
                $this._grid_lpanel_ul.RowDefinitions[0].Height = "$percent*"
                $this._grid_lpanel_ul.RowDefinitions[1].Height = "$(100-$percent)*"
            }
            'Layout.Shelf.Height' {
                $this._grid_rpanel_ul.RowDefinitions[0].Height = "$percent*"
                $this._grid_rpanel_ul.RowDefinitions[1].Height = "$(100-$percent)*"
            }
            'Layout.Work1.Width' {
                $this._grid_desk_lr.ColumnDefinitions[0].Width = "$percent*"
                $this._grid_desk_lr.ColumnDefinitions[1].Width = "$(100-$percent)*"
            }
            'Layout.Work1.Height' {
                $this._grid_desk_ul.RowDefinitions[0].Height = "$percent*"
                $this._grid_desk_ul.RowDefinitions[1].Height = "$(100-$percent)*"
            }
        }
    }
    [int] Border( [string]$name ){ 
        $a = -1
        $b = 100
        switch( $name ){
            'Layout.Library.Width' {
                $a = $this._grid_window_lr.ColumnDefinitions[0].ActualWidth
                $b = $this._grid_window_lr.ColumnDefinitions[1].ActualWidth
            }
            'Layout.Library.Height' {
                $a = $this._grid_lpanel_ul.RowDefinitions[0].ActualHeight
                $b = $this._grid_lpanel_ul.RowDefinitions[1].ActualHeight
            }
            'Layout.Shelf.Height' {
                $a = $this._grid_rpanel_ul.RowDefinitions[0].ActualHeight
                $b = $this._grid_rpanel_ul.RowDefinitions[1].ActualHeight
            }
            'Layout.Work1.Width' {
                $a = $this._grid_desk_lr.ColumnDefinitions[0].ActualWidth
                $b = $this._grid_desk_lr.ColumnDefinitions[1].ActualWidth
            }
            'Layout.Work1.Height' {
                $a = $this._grid_desk_ul.RowDefinitions[0].ActualHeight
                $b = $this._grid_desk_ul.RowDefinitions[1].ActualHeight
            }
        }
        return [int]( $a / ( $a + $b ) * 100 )
    }
    [string] Focus( [string] $target ){

        if( -not $this.Focusable( $target ) ){ return '' }

        switch -regex ( $target ){
            "(Library|Index|Shelf|Desk|Cabinet)" {
                return $this.$target.Focus()
            }
            "Work(?<num>[123])" {
                return $this.Document.Focus( $Matches.num )
            }
            "Workplace" {
                return $this.Document.Focus( $this.Document.FocusedNumber )
            }
            "(?<panel>Editor|Browser|Grid)Work(?<num>[123])" {
                return $this.Document.SelectTool( $Matches.num, $Matches.panel ).Focus($Matches.num)
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
    [void] Top( [int] $num ){ $this._window.Top = $num }
    [int]  Top(){ return $this._window.Top }
    [void] Left( [int] $num ){ $this._window.Left = $num }
    [int]  Left(){ return $this._window.Left }
    [void]   Title( $text ){ $this._window.Title = $text }
    [string] Title(){ return $this._window.Title }

    [void] Dialog( $id ){
        switch( $id ){
            'site'      { [TTTool]::message( "Githubへのリンク", "Thinktank" ) }
            'version'   { [TTTool]::message( "Thinktankのバージョン", "Thinktank" ) }
            'shortcut'  { [TTTool]::message( "ショートカットキーの一覧", "Thinktank" ) }
            'help'      { [TTTool]::message( "使い方を表示する", "Thinktank" ) }
            'about'     { [TTTool]::message( "このアプリは何なのかについて表示する", "Thinktank" ) }
        }
    }

}

#region TTPanelManager / TTLibraryManager / TTIndexManager / TTShellManager / TTDeskManager / TTCabinaetManager
class TTPanelManager {

    #region variables
    static [bool] $DisplayAlert = $true
    [string] $_name
    [TTAppManager] $_app
    [Label] $_label
    [DataGrid] $_datagrid
    [TextBox] $_textbox
    [Menu] $_menu
    [DockPanel] $_panel
    [string] $_resource

    [psobject[]] $_items
    [hashtable] $_dictionary
    [string[]] $_order
    [string] $_index
    [string] $_colname
    [string] $_sortdir
    [object] $_preserved
    [string] $_caption
    [string] $_header

    #endregion

    TTPanelManager( $name, [TTAppManager]$app, $ex ){ # Cabinet用
        $this._name =       $name
        $this._app =        $app

    }
    TTPanelManager( $name, [TTAppManager]$app ){
        $this._name =       $name
        $this._app =        $app
        $this._panel =      $app.FindName("$($this._name)Panel")
        $this._label =      $app.FindName("$($this._name)Caption")
        $this._datagrid =   $app.FindName("$($this._name)Items")
        $this._textbox =    $app.FindName("$($this._name)Keyword")
        $this._menu =       $app.FindName("$($this._name)Sorting")

        $this._panel.Add_GotFocus( $global:TTPanel_GotFocus )
        $this._panel.Add_LostFocus( $global:TTPanel_LostFocus )
        $this._panel.Add_SizeChanged( $global:TTPanel_SizeChanged )
        
    }

    [TTPanelManager] Resource( [string]$name ){
        $this._resource = $name
        return $this
    }
    [string] Resource(){
        return $this._resource
    }
    [TTPanelManager] Mark( [bool]$sw ){
        $this._header = if( $sw ){ '●' }else{ '' }
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
    [TTPanelManager] Keyword( [string]$keyword ){
        $this._textbox.Text = $keyword
        return $this
    }
    [string]Keyword(){
        return $this._textbox.Text
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
    [TTPanelManager] Refresh(){
        $this._datagrid.Items.refresh()
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
                if( $global:AppMan.($script:name)._label.Content -eq $script:text ){
                    $global:AppMan.($script:name)._label.Content = $script:tmp
                }
            }.GetNewClosure()
            $this._label.Content = $text
        }

        return $this
    }

}

class TTLibraryManager : TTPanelManager {

    TTLibraryManager( [TTAppManager]$app ) : base( "Library", $app ){
        $this._datagrid.Add_Sorting( $global:TTDataGrid_Sorting )
        $this._datagrid.Add_SelectionChanged( $global:TTDataGrid_SelectionChanged )
        $this._datagrid.Add_GotFocus( $global:TTDataGrid_GotFocus )
        $this._datagrid.Add_PreviewMouseDown( $global:TTDataGrid_PreviewMouseDown )
        $this._textbox.Add_TextChanged( $global:TTPanel_TextChanged_ToExtract )
    }
}

class TTIndexManager : TTPanelManager {
    
    TTIndexManager( [TTAppManager]$app ) : base( "Index", $app ){
        $this._datagrid.Add_Sorting( $global:TTDataGrid_Sorting )
        $this._datagrid.Add_SelectionChanged( $global:TTDataGrid_SelectionChanged )
        $this._datagrid.Add_GotFocus( $global:TTDataGrid_GotFocus )
        $this._datagrid.Add_PreviewMouseDown( $global:TTDataGrid_PreviewMouseDown )
        $this._textbox.Add_TextChanged( $global:TTPanel_TextChanged_ToExtract )


        $this._datagrid.Add_PreviewMouseDown( $script:IndexItems_PreviewMouseDown )
    }
}

class TTShelfManager : TTPanelManager {

    TTShelfManager( [TTAppManager]$app ) : base( "Shelf", $app ){
        $this._datagrid.Add_Sorting(            $global:TTDataGrid_Sorting )
        $this._datagrid.Add_SelectionChanged(   $script:TTDataGrid_SelectionChanged )
        $this._datagrid.Add_GotFocus(           $global:TTDataGrid_GotFocus )
        $this._datagrid.Add_PreviewMouseDown(   $global:TTDataGrid_PreviewMouseDown )
        $this._textbox.Add_TextChanged(         $global:TTPanel_TextChanged_ToExtract )


        $this._datagrid.Add_PreviewMouseDown( $script:ShelfItems_PreviewMouseDown )
    }

}

class TTDeskManager : TTPanelManager {

    TTDeskManager( [TTAppManager]$app ) : base ( "Desk", $app ){
        $this._textbox.Add_TextChanged( $global:TTPanel_TextChanged_ToHighlight )

        # $script:TextEditors_PreviewKeyDown
        # $script:TextEditors_TextChanged
        # $script:TextEditors_GotFocus
        # $script:TextEditors_PreviewMouseDown
        # $script:TextEditors_PreviewDrop
    }

}

class TTCabinetManager : TTPanelManager {

    #region variables
    [System.Windows.Window]$_window
    [object[]] $_selected

    $xml = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        Title="Cabinet" Name="Cabinet"  Top="10" Left="10" WindowStyle="None" AllowsTransparency="True" Topmost="True" >

        <Window.Resources>
            <ResourceDictionary Source="$global:PSScriptRoot\script\thinktank-style.xaml"/>
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
"@
    #endregion

    TTCabinetManager( [TTAppManager]$app ) : base ( "Cabinet", $app, $null ){

        $this._window = [Markup.XamlReader]::Load( (New-Object XmlNodeReader ([xml]$this.xml) ) )
        $this._name = $this._window.Name

        $this._panel =      $this._window.FindName("$($this._name)Panel")
        $this._label =      $this._window.FindName("$($this._name)Caption")
        $this._datagrid =   $this._window.FindName("$($this._name)Items")
        $this._textbox =    $this._window.FindName("$($this._name)Keyword")
        $this._menu =       $this._window.FindName("$($this._name)Sorting")

        $this._window.Add_GotFocus( $global:TTPanel_GotFocus )
        $this._window.Add_LostFocus( $global:TTPanel_LostFocus )
        # $this._window.Add_Loaded({ $global:AppMan.Cabinet.Focus() })
        $this._window.Add_Closing({ $args[1].Cancel = $True })
        $this._window.Add_MouseLeftButtonDown({ $global:AppMan.Cabinet._window.DragMove() })
        $this._window.Add_MouseDoubleClick({ $global:AppMan.Cabinet.Hide($true); $args[1].Handled=$True })
        $this._window.Add_PreviewKeyDown( $global:TTPreviewKeyDown )
        $this._window.Add_PreviewKeyUp( $global:TTPreviewKeyUp )

        $this._datagrid.Add_Sorting( $global:TTDataGrid_Sorting )
        $this._datagrid.Add_SelectionChanged( $global:TTDataGrid_SelectionChanged )
        $this._datagrid.Add_GotFocus( $global:TTDataGrid_GotFocus )
        $this._datagrid.Add_PreviewMouseDown( $global:TTDataGrid_PreviewMouseDown )
        $this._textbox.Add_TextChanged( $global:TTPanel_TextChanged_ToExtract )

    }
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
        $this._window.Dispatcher.Invoke({ $global:AppMan.Cabinet._window.Hide() })
        return $this
    }
    [string] Focus(){
        return $this.Show()
    }

}

#endregion###############################################################################################################


#region　TTDocumentManager
class TTDocumentManager{

    #region variants
    [TTAppManager] $app
    [TTEditorsManager] $Editor
    [TTBrowsersManager] $Browser
    [TTGridsManager] $Grid
    [string[]] $IDs = @('','','')
    [object[]] $Controls = @($null,$null,$null)

    [int] $FocusedNumber
    [string[]] $SelectedTools = @('','','') # Editor/Browser/Grid
    #endregion    

    TTDocumentManager( [TTAppManager]$app ){
        $this.app = $app
        $this.Editor = [TTEditorsManager]::New( $this ).Initialize()
        $this.Browser = [TTBrowsersManager]::New( $this ).Initialize()
        $this.Grid = [TTGridsManager]::New( $this ).Initialize()

        $this.IDs =         @( 'Work1', 'Work2', 'Work3' )
        $this.Controls =    @( $this.IDs.foreach{ $this.app.FindName($_) } )
        $this.Controls.foreach{ 
            $_.Add_GotFocus( $global:TTWork_GotFocus )
            $_.Add_LostFocus( $global:TTWork_LostFocus )
        }
        (1..3).foreach{ $this.SelectTool( $_, 'Editor' ) }

    }
    [string] Focus( [int]$num ){ # 1..3
        $this.FocusedNumber = $num
        $toolman = $this.( $this.SelectedTools[$num-1] )
        $toolman.Focus( $num )
        return $toolman.Name
    }
    [TTDocumentManager] SelectTool( [int]$num, [string]$tool ){
        $this.SelectedTools[$num-1] = $tool

        $this.Editor.Controls[$num-1].Visibility =  [Visibility]::Collapsed
        $this.Browser.Controls[$num-1].Visibility = [Visibility]::Collapsed
        $this.Grid.Controls[$num-1].Visibility =    [Visibility]::Collapsed
        $this.$tool.Controls[$num-1].Visibility =   [Visibility]::Visible

        return $this
    }


}

#　TTToolsManager / TTEditorsManager / TTBrowsersManager / TTGridsManager
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
class TTToolsManager { # abstract
    #region varinats
    [TTAppManager] $app
    [TTDocumentManager] $docman
    # [string[]] $IDs
    [object[]] $Controls
    #endregion

    TTToolsManager( $docman ){                  # should be override
        $this.docman = $docman
        $this.app = $docman.app
    }
    [TTToolsManager] Initialize(){              # if needed
        $this.Controls = @( $this.IDs.foreach{ $this.app.FindName($_) } )
        $this.Controls.foreach{ 
            $_.Add_GotFocus( $global:TTTool_GotFocus )
            $_.Add_LostFocus( $global:TTTool_LostFocus )
        }
        return $this
    }
    [string] Focus( [int]$num ){                # should be override
        $tool = $this.Controls[$num-1]
        $tool.Focus()
        return $tool.Name

    }
    [TTToolsManager] ScrollTo( $to ){           # should be override
        return $this
    }

}

class TTEditorsManager : TTToolsManager{

    #region variants
    # static [ScriptBlock] $OnSave
    # static [ScriptBlock] $OnLoad

    hidden [ICSharpCode.AvalonEdit.Document.TextDocument[]] $documents = @()
    [string[]] $Indices = @( "", "", "" )
    [object[]] $FoldManagers = @( $null, $null, $null )
    [object[]] $FoldStrategies = @( $null, $null, $null )
    [object[]] $HightlightRules = @( $null, $null, $null )
    [string[][]] $Histories= @( @(), @(), @() )
    [int[]] $HistoryPositions
    [string[]] $IDs = @( 'Editor1', 'Editor2', 'Editor3' )

    #endregion

    TTEditorsManager( $docman ) : base( $docman ) {
    }
    [TTEditorsManager] Initialize(){               # if needed
        ([TTToolsManager]$this).Initialize()
        $this.documents = @((1..3).foreach{ [ICSharpCode.AvalonEdit.Document.TextDocument]::new() })
        $this.documents.foreach{ $_.FileName = "" }
        (1..3).foreach{ [void]$this.Initialize($_) }
        return $this
    }
    [TTEditorsManager] Initialize( [int]$num ){
        if( $null -ne $this.FoldManagers[$num-1] ){
            [ICSharpCode.AvalonEdit.Folding.FoldingManager]::Uninstall( $this.FoldManagers[$num-1] )
        }
        $this.documents.where{ $_ -eq $this.Controls[$num-1].Document }.foreach{
            $_.Text = ""
            $_.FileName = ""
        }
        $this.Controls[$num-1].Document = $null
        $this.Indices[$num-1] = ""

        return $this
    }
    [TTEditorsManager] Load( [int]$num, [string]$index ){
        $editor =   $this.Controls[$num-1]
        $filepath = [TTTool]::index_to_filepath( $index )

        if( -not (Test-Path $filepath) ){ 
            [TTTool]::debug_message( $this, "error >> no such file: $filepath" )
            return $this
        }
        if( $filepath -eq $editor.Document.FileName ){
            [TTTool]::debug_message( $this, "caution >> read already: $filepath" )
            return $this
        } 

        $refdoc = $this.documents.where{ $_.FileName -eq $filepath }[0]
        if( $null -ne $refdoc ){ 
            # 他EditorのDocumentをシェア
            $editor.Document = $refdoc
        }else{
            # 本Editor用にDocument設定
            $refdoc = $this.documents.where{ $_.FileName -eq "" }[0]
            $editor.Document = $refdoc
            $editor.Document.FileName = $filepath
            $editor.Load( $filepath )
        }

        # 折畳み設定
        $this.Indices[$num-1] = $index
        $this.FoldManagers[$num-1] = [ICSharpCode.AvalonEdit.Folding.FoldingManager]::Install( $editor.TextArea )
        $this.FoldStrategies[$num-1] = [AvalonEdit.Sample.ThinktankFoldingStrategy]::new()
        $this.FoldStrategies[$num-1].UpdateFoldings( $this.FoldManagers[$num-1], $editor.Document )

        # &[TTEditorsManager]::OnLoad $this
#        [TTDocumentManager] ConfigureEditor( $offset, $wordwrap, $foldings ){
#            $conf  = $this.config.($this.target_tool)
#            $conf.editor.CaretOffset = $offset
#            $conf.editor.WordWrap    = $wordwrap
#            $folds = $foldings.split(",")
#            $conf.foldman.AllFoldings.foreach{ $_.IsFolded = ( $_.StartOffset -in $folds ) }
    
        Write-Host "State変更すること"
        # $script:app._set( "($editor.Name).Index", $index )

        return $this
    }
    [TTEditorsManager] Save( [int]$num ){
        $editor = $this.Editors[$num]
        $filepath = $editor.Document.FileName

        if( (0 -lt $filepath.length) -and ( $editor.IsModified ) ){
            if( $this.app._istrue( "Config.MemoSavedMessage" ) ){
                $title = $editor.Text.split( "`r`n" )[0]
                [TTTool]::debug_message( $editor.Name, "Save Memo $($this.Indices[$num]) : $title" )
            }

            $editor.Encoding = [System.Text.Encoding]::UTF8
            $editor.Save( $filepath )
            &[TTEditorsManager]::OnSave $this
        }
        return $this
    }
    [TTDocumentManager] Modified( [int]$num ){
        $this.Editor[$num].IsModified = $True
        return $this
    }
    [TTDocumentManager] SetWordWrap( [int]$num, $value ){
        $this.Controls.WordWrap = $value
        return $this
    }
    [void] UpdateFolding( [int]$num ){
        if( $null -ne $this.FoldStrategies[$num] ){
            $this.FoldStrategies[$num].UpdateFoldings( $this.FoldManager[$num], $this.Controls[$num].Document )
        }
    }
    [TTToolsManager] ScrollTo( [int]$num, [string]$to ){            # should be override
        $editor = $this.Controls[$num]
        switch( $to ){
            'nextline' { $editor.LineUp() }
            'prevline' { $editor.LineDown() }
        }
        return $this
    }
    [bool] MoveTo( [int]$num, [string]$to ){
        $editor = $this.Controls[$num]
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
    [TTDocumentManager] SelectTo( [int]$num, [string]$to, [string]$following_action ){
        $editor = $this.Controls[$num]
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
    [TTDocumentManager] NodeTo( [int]$num, [string]$state ){
        $editor = $this.Controls[$num]
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
    [TTDocumentManager] Insert( [int]$num, [string]$text ){
        $editor = $this.Controls[$num]
        $editor.Document.Insert( $editor.CaretOffset, $text )

        return $this
    }
    [TTDocumentManager] Edit( [int]$num, [string]$subject ){
        $editor = $this.Controls[$num]
        
        switch( $subject ){
            'delete'    { [EditingCommands]::Delete.Execute( $null, $editor.TextArea ) }
            'backspace' { [EditingCommands]::Backspace.Execute( $null, $editor.TextArea ) }
        }

        return $this
    }
    [TTDocumentManager] Cursor( [int]$num, [string]$action ){
        $editor = $this.Controls[$num]

        switch( $action ){
            'save'      { $this.offset = $editor.CaretOffset }
            'restore'   { $editor.CaretOffset = $this.offset }
        }

        return $this
    }
    [string[]] AtCursor( [int]$num, [string]$action ){
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

}

class TTBrowsersManager : TTToolsManager{
    #region variants
    [string[]] $Urls = @( "", "", "" )
    [string[]] $IDs   = @( 'Browser1', 'Browser2', 'Browser3' )
    #endregion

    TTBrowsersManager( $docman ) : base($docman) {
    }

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
    #region
    [string[]] $Indices = @( "", "", "" )
    [string[]] $IDs   = @( 'Grid1', 'Grid2', 'Grid3' )
    #endregion

    TTGridsManager( $docman )  : base($docman) {
    }

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
#endregion###############################################################################################################


#region TTPopupMenuManager
class TTPopupMenuManager {
    #region variables
    [string] $_name
    [TTAppManager] $_app
    [System.Windows.Window] $_window
    [ListView] $_list
    [psobject] $_selected
    $xml = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        Title="PopupMenu" Name="PopupMenu" WindowStyle="None" AllowsTransparency="True" Topmost="True">

        <Window.Resources>
            <ResourceDictionary Source="$global:PSScriptRoot\script\thinktank-style.xaml"/>
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
"@
    #endregion

    TTPopupMenuManager( [TTAppManager]$app ){
        $this._window = [Markup.XamlReader]::Load( (New-Object XmlNodeReader ([xml]$this.xml) ) )
        $this._name = $this._window.Name
        $this._list = $this._window.FindName("PopupMenuItems")

        $this._window.Add_Closing({ $args[1].Cancel = $True })
        $this._window.Add_MouseLeftButtonDown({ $global:AppMan.PopupMenu._window.DragMove() })
        $this._window.Add_MouseDoubleClick({ $global:AppMan.PopupMenu.Hide($true); $args[1].Handled=$True })
        $this._window.Add_PreviewKeyDown( $global:TTPreviewKeyDown )
        $this._window.Add_PreviewKeyUp( $global:TTPreviewKeyUp )
        
        $style = [Style]::new()
        $style.Setters.Add( [Setter]::new( [Controls.GridViewColumnHeader]::VisibilityProperty, [Visibility]::Collapsed ) )
        $this._list.view.ColumnHeaderContainerStyle = $style

    }
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
        return $this
    }
    [TTPopupMenuManager] Hide( [bool]$result ){
        if( $result ){
            $this._selected = $this._list.SelectedItem
        }else{
            $this._selected = $null
        }
        $this._window.Dispatcher.Invoke({ $global:AppMan.PopupMenu._window.Hide() })
        return $this
    }
    [psobject] Show(){
        $this._list.SelectedIndex = 0
        $this._window.ShowDialog()
        return $this._selected
    }
    [void] Top( [int] $num ){ $this._window.Top = $num }
    [int]  Top(){ return $this._window.Top }
    [void] Left( [int] $num ){ $this._window.Left = $num }
    [int]  Left(){ return $this._window.Left }

}

#endregion###############################################################################################################














