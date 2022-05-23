


using namespace System.Windows.Controls
using namespace System.Windows 
using namespace System.Xml




#region app / TTApplication 
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
class TTApplication {   

    [void] initialize(){
        $this.window( 'max' )
        $this.border( 'Layout.Guide.Width',    "12" )
        $this.border( 'Layout.Library.Height', "25" )
        $this.border( 'Layout.Shelf.Height',   "25" )

        $this._set( 'Application.Name',          "Thinktank" )
        $this._set( 'Application.Version',       "0.51" )
        $this._set( 'Application.LastModified',  "2022/03/16" )
        $this._set( 'Application.Author.Name',   "Shinichiro Egashira" )
        $this._set( 'Application.Author.Mail',   "gogowooky@gmail.com" )
        $this._set( 'Application.Author.Site',   "https://github.com/gogowooky" )

        $this._set( 'Config.CacheSavedMessage',   'False' )
        $this._set( 'Config.MemoSavedMessage',    'True' )
        $this._set( 'Config.TaskExpiredMessage',  'False' )
        $this._set( 'Config.KeyDownMessage',      'False' )
        $this._set( "Config.TaskResisterMessage", 'False' )

    }
    [bool] isvisible( $id ){
        switch -regex ( $id ){
            'Library'   { return ( $this._ne( 'Layout.Guide.Width', '0' ) -and $this._ne( 'Layout.Library.Height', '0' ) ) }
            'Index'     { return ( $this._ne( 'Layout.Guide.Width', "0" ) -and $this._ne( 'Layout.Library.Height', "100" ) ) }
            'Shelf'     { return ( $this._ne( 'Layout.Guide.Width', "100" ) -and $this._ne( 'Layout.Shelf.Height', "0" ) ) }
            'Desk'      { return ( $this._ne( 'Layout.Guide.Width', "100" ) -and $this._ne( 'Layout.Shelf.Height', "100" ) ) }
            'Work1'     { return ( $this.IsVisible( 'Desk' ) -and $this._ne( 'Layout.Work1.Height', "0" ) -and $this._ne( 'Layout.Work1.Width', "0" ) ) }
            'Work2'     { return ( $this.IsVisible( 'Desk' ) -and $this._ne( 'Layout.Work1.Height', "0" ) -and $this._ne( 'Layout.Work1.Width', "100" ) ) }
            'Work3'     { return ( $this.IsVisible( 'Desk' ) -and $this._ne( 'Layout.Work1.Height', "100" ) ) }
            'Editor[123]'   { $work = $id.replace( 'Editor', 'Work' ); return ( $this.IsVisible( $work ) -and $this._ne( "$work.Tool", "Editor" ) ) }
            'Browser[123]'  { $work = $id.replace( 'Browser', 'Work' ); return ( $this.IsVisible( $work ) -and $this._ne( "$work.Tool", "Browser" ) ) }
            'Grid[123]'     { $work = $id.replace( 'Grid', 'Work' ); return ( $this.IsVisible( $work ) -and $this._ne( "$work.Tool", "Grid" ) ) }
            default     { return $false }
        }
        return $true
    }
    [void] dialog( $id ){
        switch( $id ){
            'site'      { [TTTool]::message( "Githubへのリンク", "Thinktank" ) }
            'version'   { [TTTool]::message( "Thinktankのバージョン", "Thinktank" ) }
            'shortcut'  { [TTTool]::message( "ショートカットキーの一覧", "Thinktank" ) }
            'help'      { [TTTool]::message( "使い方を表示する", "Thinktank" ) }
            'about'     { [TTTool]::message( "このアプリは何なのかについて表示する", "Thinktank" ) }
        }
    }
    [void] commands(){
        ( Show_ListMenu $script:TTCommands ).foreach{ $_.DoAction() }
    }
    [void] window( $value ){
        if( $value -eq "toggle" ){
            $value = switch( $script:app._get( 'Window.Display' ) ){
                'max'   { 'normal' }
                default { 'max' }
            }
        }
        $value = if( $value -match "^(min|max|normal|close)$" ){ $value }else{ 'max' }
        $script:app._set( 'Window.Display', $value )
        $script:AppMan.Window( $value )
    }
    [void] caption( $text ){
        $script:AppMan.Title( $text )
    }
    [void] border( $name, $value ){

        $percent = [int]$value
        if( $value -match "^[+-]\d+$" ){ $percent += [int]$script:app._get( $name ) }

        if( $percent -lt 0 ){ $percent = 0 }
        if( 100 -lt $percent ){ $percent = 100 }        

        $script:AppMan.Border( $name, $percent )

    }
    [string] keyword(){ # 今後検討
        return (Get-Clipboard -Format Text)
    }
    [string] _get( $name ){
        return $script:TTStatus.Get( $name )
    }
    [void] _set( $name, $value ){
        $script:TTStatus.Set( $name, $value )
        switch -regex ( $name ){
            'Config.TaskResisterMessage' {
                [TTTask]::task_resist_message = ( $value -eq 'True' )
            } 
            'Config.TaskExpiredMessage' {
                [TTTask]::task_expire_message = ( $value -eq 'True' )
            }
            '(?<tool>Editor.)\.WordWrap' {
                if( $value -eq 'toggle' ){ $value = [string]$this._isfalse( $name ) }
                $script:DocMan.Tool( $Matches.tool ).SetConfiguration( "WordWrap", $value)
                $script:TTStatus.Set( $name, $value )
            }
            'Application.Focused' {
                $script:library.caption('-')
                $script:index.caption('-')
                $script:shelf.caption('-')
                $script:desk.caption('-')
                switch( $value ){
                    'Library'   { $script:library.caption('*') }
                    'Index'     { $script:index.caption('*') }
                    'Shelf'     { $script:shelf.caption('*') }
                    'Desk'      { $script:desk.caption('*') }
                    default     { $script:desk.caption('+') }
                }
            }
        }
    }
    [bool] _eq( $name, $value ){    return ( $this._get( $name ) -eq $value ) }
    [bool] _ne( $name, $value ){    return ( $this._get( $name ) -ne $value ) }
    [bool] _in( $name, $value ){    return ( $this._get( $name ) -in $value ) }
    [bool] _notin( $name, $value ){ return ( $this._get( $name ) -notin $value ) }
    [bool] _istrue( $name ){        return ( $this._get( $name ) -eq $true ) }
    [bool] _isfalse( $name ){       return ( $this._get( $name ) -eq $false ) }

    [void] _config( $name, $default, $script ){
        $value = $script:TTConfigs.GetChild( $name ).Value
        if( $null -eq $value ){ $value = $default }
        $this._set( $name, $value )
        if( $null -ne $script ){ &$script $name $value }
    }
    [string] _config( $name ){
        return $script:TTConfigs.GetChild( $name ).Value
    }
} 
#endregion:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

#region index, library, shelf, ListMenu / TTListPanel
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
class TTListPanel {
    #region instance variable
    [string] $_name
    [object] $_items
    [object] $_keyword
    [object] $_caption
    [object] $_sorting
    [TTCollection] $_collection
    [hashtable] $_dictionary
    [string] $_column
    [TTObject] $_item

    TTListPanel(){
        $this._items = $null
        $this._keyword = $null
        $this._caption = $null
        $this._sorting = $null
    }

    # itemsが登録数0であってもカラムはちゃんと表示されるようにする
    # https://marunaka-blog.com/wpf-datagrid/3169/
    #endregion
    [TTListPanel] initialize( $collection ){ # $this._name を設定してから呼び出すこと
        $this._items    = $script:AppMan.FindName("$($this._name)Items")
        $this._items.AutoGenerateColumns = $false
        $this._keyword  = $script:AppMan.FindName("$($this._name)Keyword")
        $this._caption  = $script:AppMan.FindName("$($this._name)Caption")
        $this._sorting  = $script:AppMan.FindName("$($this._name)Sorting")
        
        $this._collection = $collection
        $this._dictionary = ((New-Object $collection.ChildType).GetDictionary())
        $this._column = $this._dictionary.Index
        
        $this.items( $this._collection.GetChildren() )
        $this.nosearch()

        $this.menu()
        return $this
    }
    [TTListPanel] menu(){
        if( $null -eq $this._sorting ){ return $this }

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
    [TTListPanel] focus(){ 
        $this._keyword.Focus()
        $script:app._set( 'Application.Focused', $this._name )
        return $this
    }
    [TTListPanel] caption( $text ){
        if( 0 -lt $text.length ){
            $caption = ($this._caption.Content) -replace "^[●]?(.*)", "`$1"
            $this._caption.Content = switch( $text ){
                '*' { "●$caption"; break }
                '-' { $caption; break }
                default { "$($this._name) : $text" }
            }
        }
        return $this
    }
    [TTListPanel] items( $items ){
        $this._items.Items.SortDescriptions.Clear()
        $this._items.ItemsSource = $null
        $this._items.ItemsSource = $items

        $dictionary = $this._dictionary
        $bindings = $dictionary.ShelfFormat.split(",")
              
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
    [TTListPanel] replace( $items ){
        return $this.cursor('preserve').items($items).cursor('restore')
    }
    [TTListPanel] reload(){
        $this.search()
        return $this
    }
    [TTListPanel] refresh(){
        if( $null -ne $this._items ){
            $this._items.Items.Refresh()
        }
        return $this
    }
    [TTListPanel] column( $column ){
        try{ $num = [int]$column }catch{ $num = 0 }
        if( 0 -lt $num ){
            $this._column = $this._dictionary.Keys.where{ $this._dictionary[$_] -eq $this._items.columns[$num-1].Header }[0]
        }else{
            $this._column = $column
        }
        return $this
    }
    [TTListPanel] cursor( $action ){
        $lv = $this._items
        switch( $action ){
            'up'    { $lv.SelectedIndex -= if( 0 -lt $lv.SelectedIndex ){ 1 }else{ 0 } }
            'down'  { $lv.SelectedIndex += if( $lv.SelectedIndex -lt $lv.Items.Count - 1 ){ 1 }else{ 0 } }
            'first' { $lv.SelectedIndex = 0 }
            'last'  { $lv.SelectedIndex = $lv.Items.Count - 1 }
            'up+'   { $lv.SelectedIndex -= if( 0 -le $lv.SelectedIndex ){ 1 }else{ -$lv.Items.Count } }
            'down+' { $lv.SelectedIndex += if( $lv.SelectedIndex -lt $lv.Items.Count - 1 ){ 1 }else{ -$lv.Items.Count } }
            'preserve'  {
                if( $null -eq $lv.SelectedItem ){ break }
                $this._item = $lv.SelectedItem }
            'restore'   { 
                if( $null -eq $this._item ){ break }
                if( 0 -lt $lv.Items.where{ $_ -eq $this._item }.count ){
                    $lv.SelectedItem = $this._item
                }
            }
            default { $lv.SelectedItem = $this._collection.GetChild( $action ) }
        }
        if( 0 -le $lv.SelectedIndex ){ $lv.ScrollIntoView( $lv.SelectedItem ) }
        $this.status_reset( 'Index' )
        return $this
    }
    [TTListPanel] sort( $direction ){
        $this.cursor('preserve')

        $lv = $this._items
        $view = [System.Windows.Data.CollectionViewSource]::GetDefaultView( $lv.ItemsSource )
        $direction  = switch( $direction ){
            'toggle'    { if('Descending' -eq $view.SortDescriptions[0].Direction){ 'Ascending' }else{ 'Descending' }  }
            'Ascending' { 'Ascending' }
            default     { 'Descending' }
        }
        $view.SortDescriptions.Clear()
        $sortDescription = New-Object System.ComponentModel.SortDescription( $this._column, $direction )
        $view.SortDescriptions.Add( $sortDescription )

        $this.cursor('restore')
        $this.status_reset( 'Sort' )
        return $this
    }
    [TTObject] item( $index ){
        return $this._collection.GetChild( $index )
    }
    [array]sort_params(){
        $lv = $this._items
        $view = [System.Windows.Data.CollectionViewSource]::GetDefaultView( $lv.ItemsSource )
        return @( $view.SortDescriptions[0].Direction, $view.SortDescriptions[0].PropertyName )
    }
    [string]selected_index(){
        return $this._items.SelectedItem.($this._dictionary.Index)
    }
    [TTListPanel] search(){
        $text = $this._keyword.Text
        $dir, $col = $this.sort_params()
        $this.cursor('preserve').items( $this._collection.GetChildren( $text ) ).sort( $dir ).cursor('restore')
        $this.status_set( 'Sort', $text )
        return $this
    }
    [TTListPanel] search( $text ){
        $this._keyword.Text = $text
        return $this
    }
    [TTListPanel] nosearch(){
        $this._keyword.Text = ''
        return $this
    }
    [TTListPanel] status_set( $id, $text ){
        switch( $id ){
            'Sort' {
                $dir, $col = $this.sort_params()
                $script:app._set( "$($this._name).SortColumn", $col )
                $script:app._set( "$($this._name).SortDir", $dir )
            }
            'Index' {
                $script:app._set( "$($this._name).Index", $this.selected_index() )
            }
            'Keyword' {
                $script:app._set( "$($this._name).Keyword", $text )
            }
        }
        return $this
    }
    [TTListPanel] status_reset( $id ){ return $this.status_set( $id, "") }

    [TTListPanel] delete_selected(){
        $index = $this.selected_index()
        $this._collection.DeleteChild( $index )
        return $this
    }

}
class TTLibrary : TTListPanel {
    TTLibrary(){
        $this._name = "Library"
    }
    [TTLibrary] initialize(){
        [void] ([TTListPanel]$this).initialize( $script:TTResources ) 

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
            $this._collection.GetChild( $index ).flag = ""
        }
        return $this
    }
    [TTLibrary] mark_column(){
        $i = 1
        @( $script:shelf, $script:index ).foreach{
            $index = $_._library_name
            if( 0 -eq $index.length ){ break }
            $this._collection.GetChild( $index ).flag = $i
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

        [void] ([TTListPanel]$this).initialize( $script:TTResources.GetChild( $this._library_name ) )

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
        $this._collection.GetChildren().foreach{ $_.flag = "" }


        # $script:EditorIDs.foreach{
        #     $index = $script:DocMan.config.$_.index
        #     if( 0 -ne $index.length ){
        #         if( $null -ne $this._collection.GetChild( $index ) ){
        #             $this._collection.GetChild( $index ).flag = ""
        #         }
        #     }
        # }
        return $this
    }
    [TTShelf] mark_column(){
        $script:EditorIDs.foreach{
            $index = $script:DocMan.config.$_.index
            if( 0 -ne $index.length ){
                if( $null -ne $this._collection.GetChild( $index ) ){
                    $this._collection.GetChild( $index ).flag = $_[-1]
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
        $this._collection.DeleteChild( $index )
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

        [void] ([TTListPanel]$this).initialize( $script:TTResources.GetChild( $this._library_name ) )

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
        $bindings = $dictionary.IndexFormat.split(",")
              
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
            $this._column = ($this._dictionary.ShelfFormat.split(","))[$num-1]
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
        $this._collection.DeleteChild( $index )
        $this.reload()
        return $this
    }


}
class TTListMenu : TTListPanel {

    TTListMenu(){
        $this._name = "ListMenu"
    }

    [TTListMenu] initialize( $collection ){ # $this._name を設定してから呼び出すこと
        $this._items    = $script:ListMenuWindow.FindName("$($this._name)Items")
        $this._keyword  = $script:ListMenuWindow.FindName("$($this._name)Keyword")
        $this._caption  = $script:ListMenuWindow.FindName("$($this._name)Caption")
        $this._sorting  = $script:ListMenuWindow.FindName("$($this._name)Sorting")

        $this._collection = $collection
        $dictionary = ((New-Object $collection.ChildType).GetDictionary())
        $this._dictionary = $dictionary
        $this._column = $dictionary.Index
        
        $this.items( $this._collection.GetChildren() )
        $this.nosearch()

        $this.menu()
        return $this
    }

}

#endregion:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

#region desk / TTDesk
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
class TTDesk{
    [string] $_name
    [object] $_keyword
    [object] $_caption
    [object] $_sorting
    hidden [string[]]$bullets
    [string] $_tool

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

        [xml]$xshd = Get-Content "$script:TTScriptDirPath\thinktank.xshd"
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
            Get-ChildItem -Path @( "$script:TTRootDirPath\thinktank.md" ) | `
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

        $editing = $script:TTEditings.GetChild( $index )
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
        $memo = $script:TTMemos.GetChild( $memoid )
        $memo.Title = Get-Content $filepath -totalcount 1
        $memo.UpdateDate = (Get-Item $filepath).LastWriteTime.ToString("yyyy-MM-dd-HHmmss")

        # update TTEditings(Model)
        $script:TTEditings.AddChild( $editor )

        return $this

    }
    [TTDesk] modified( $modified ){
        $script:DocMan.Tool( $this._tool ).Modified( $modified )
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
    [TTDesk] cursor( $action ){
        $script:DocMan.Tool( $this._tool ).Cursor( $action )
        return $this
    }
    [bool] replace( $regex, $text ){
        return $script:DocMan.Tool( $this._tool ).Replace( $regex, $text )
    }
    [string] create_memo(){
        return $script:TTMemos.CreateChild()
    }
    [TTDesk] delete_memo( $index ){
        $script:TTMemos.DeleteChild( $index )
        return $this
    }
    [void] create_cache( $keyword ){
        if( 0 -eq $keyword.length ){ $keyword = $script:app._get( 'Desk.Keyword' ) }
        if( 0 -eq $keyword.length ){ return }
        $exmemo = [TTExMemos]::New().Keyword( $keyword )
        $script:TTResources.AddChild( $exmemo )

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

#region　ListMenu / TTListMenu
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
function Show_ListMenu( $collection ){

    # initialize variables
    #'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    $script:ListMenuWindow = $null
    $script:ListMenu = $null
    $script:ListMenuWindow = [Markup.XamlReader]::Load( (New-Object XmlNodeReader [TTPopupMenu]$script:ListMenuXaml) )
    $script:ListMenu = [TTListMenu]::New().Initialize( $collection )

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

    [TTTask]::Register( 
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

#endregion:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::




