


#region　Model Actions
#########################################################################################################################

#region　Functions
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function ttact_noop( $ttobj, $ttobjs ){
    #.SYNOPSIS
    # 何もしない

    [TTTool]::debug_message( $ttobj.GetDictionary().Index, "ttact_noop" )

}
function ttact_select_file( $ttobj, $ttobjs ){
    #.SYNOPSIS
    # 関連ファイルをエクスプローラーで選択する

    [TTTool]::debug_message( $ttobj.GetType(), "ttact_select_file" )

    if( ($ttobj -is [TTCollection]) -or
        ($ttobj -is [TTMemo]) -or
        ($ttobj -is [TTEditing]) -or 
        ($ttobj -is [TTConfig]) -or 
        ($ttobj -is [TTSearchMethod]) -or
        ($ttobj -is [TTExternalLink])){ 
            Start-Process "explorer.exe" "/select,`"$($ttobj.GetFilename())`"" 
    }
}
function ttact_discard_resources( $ttobj, $ttobjs ){
    #.SYNOPSIS
    # 関連リソースを開放する

    [TTTool]::debug_message( $ttobj.GetDictionary().Index, "ttact_discard_resources" )

    switch( $true ){
        { $ttobj -is [TTCollection] }{ $ttobj.DiscardResources() }
        { $ttobj -is [TTMemo] }{ $ttobj.DiscardResources() }
    }
    
}
function ttact_display_in_shelf( $ttobj, $ttobjs ){
    #.SYNOPSIS
    # Shelfパネルに表示する

    [TTTool]::debug_message( $ttobj.gettype(), "ttact_display_in_shelf" )
    $global:appcon.group.load( 'Shelf', $ttobj.name )
}
function ttact_display_in_index( $ttobj, $ttobjs ){
    #.SYNOPSIS
    # Indexパネルに表示する

    [TTTool]::debug_message( $ttobj.gettype(), "ttact_display_in_index" )
    $global:appcon.group.load( 'Index', $ttobj.name )
}
function ttact_display_in_cabinet( $ttobj, $ttobjs ){
    #.SYNOPSIS
    # Cabinetパネルに表示する

    [TTTool]::debug_message( $ttobj.gettype(), "ttact_display_in_cabinet" )
    $global:appcon.group.load( 'Cabinet', $ttobj.name ).focus('Cabinet')
}

function ttact_open_memo( $ttobj, $ttobjs ){
    #.SYNOPSIS
    # メモを開く
    
    [TTTool]::debug_message( $ttobj.GetDictionary().Index, "ttact_open_memo" )
    $global:appcon.tools.editor.load( $ttobj.MemoID )
}
function ttact_copy_url_toclipboard( $ttobj, $ttobjs ){
    #.SYNOPSIS
    # urlをクリップボードに保存する

    [TTTool]::debug_message( $ttobj.gettype().Index, "ttact_copy_url_toclipboard" )
    switch( $ttobj.GetType() ){
        'TTExternalLink' { [TTClipboard]::Copy( $ttobj.Uri ) }
        'TTSearchMethod' { [TTClipboard]::Copy( $ttobj.Url ) }
    }
}
function ttact_open_url_ex( $ttobj, $ttobjs ){
    #.SYNOPSIS
    # urlを外部ツールで開く

    [TTTool]::debug_message( $ttobj.gettype().Index, "ttact_open_url_ex" )
    switch( $ttobj.GetType() ){
        'TTExternalLink' { [TTTool]::open_url( $ttobj.Uri ) }
        'TTSearchMethod' { [TTTool]::open_url( $ttobj.Url ) }
    }
}
function ttact_open_url( $ttobj, $ttobjs ){
    #.SYNOPSIS
    # urlを開く（未実装）

    [TTTool]::debug_message( $ttobj.gettype().Index, "ttact_open_url" )
    switch( $ttobj.GetType() ){
        'TTExternalLink' { [TTTool]::open_url( $ttobj.Uri ) }
        'TTSearchMethod' { [TTTool]::open_url( $ttobj.Url ) }
    }

}
#endregion'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

#endregion###############################################################################################################




#region　Application Commands
#########################################################################################################################
# border                                                                                                                 

#endregion###############################################################################################################

#region　PopMenu Commands
#########################################################################################################################
function ttcmd_menu_cancel( $source, $mod, $key ){
    #.SYNOPSIS
    # メニューの選択をキャンセル

    $global:appcon.menu.close( $source, 'cancel' )
}
function ttcmd_menu_ok( $source, $mod, $key ){
    #.SYNOPSIS
    # メニューの選択を確定

    $global:appcon.menu.close( $source, 'ok' )
}
function ttcmd_menu_move_up( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルのカーソルを上に移動

    $global:appcon.menu.cursor( $source, 'up' )
}
function ttcmd_menu_move_down( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルのカーソルを下に移動

    $global:appcon.menu.cursor( $source, 'down' )
}
function ttcmd_menu_move_first( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルのカーソルを先頭に移動

    $global:appcon.menu.cursor( $source, 'first' )
}
function ttcmd_menu_move_last( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルのカーソルを末尾に移動

    $global:appcon.menu.cursor( $source, 'last' )
}

#endregion###############################################################################################################

#region　Panel系共通 ( Library, Index, Shelf, Desk, Cabinet ) Commands
#########################################################################################################################
#region focus

function ttcmd_tool_focus_app_multi_revtgl( $source, $mod, $key ){
    #.SYNOPSIS
    # 全体styleを変更（逆順）

    $global:appcon.view.style('Group','revtgl')
}
function ttcmd_tool_focus_app_multi_toggle( $source, $mod, $key ){
    #.SYNOPSIS
    # 全体styleを変更（正順）

    $global:appcon.view.style('Group','toggle')
}
function ttcmd_tool_focus_work_multi_revtgl( $source, $mod, $key ){
    #.SYNOPSIS
    # 複数Work形式に変更（逆順）

    if( $global:appcon._match( 'Focus.Application', '(Library|Index|Shelf|Cabinet)' ) ){
        $global:appcon.group.focus( $global:appcon._get('Current.Workspace'), $mod, $key )
    }else{
        $global:appcon.view.style('Desk','revtgl')
    }
}
function ttcmd_tool_focus_work_multi_toggle( $source, $mod, $key ){
    #.SYNOPSIS
    # 複数Work形式に変更（正順）

    if( $global:appcon._match( 'Focus.Application', '(Library|Index|Shelf|Cabinet)' ) ){
        $global:appcon.group.focus( $global:appcon._get('Current.Workspace'), $mod, $key )
    }else{
        $global:appcon.view.style('Desk','toggle')
    }
}
function ttcmd_tool_focus_work_single_revtgl( $source, $mod, $key ){
    #.SYNOPSIS
    # 単独Work形式で表示、その後、Workxを変更（逆順）

    if( $global:appcon._match( 'Focus.Application', '(Library|Index|Shelf|Cabinet)' ) ){
        $global:appcon.group.focus( $global:appcon._get('Current.Workspace'), $mod, $key )
        $global:appcon.view.style('Work',$global:appcon._get('Current.Workspace'))
    }else{
        $global:appcon.view.style('Work','revtgl')
    }
}
function ttcmd_tool_focus_work_single_toggle( $source, $mod, $key ){
    #.SYNOPSIS
    # 単独Work形式で表示、その後、Workxを変更（正順）

    if( $global:appcon._match( 'Focus.Application', '(Library|Index|Shelf|Cabinet)' ) ){
        $global:appcon.group.focus( $global:appcon._get('Current.Workspace'), $mod, $key )
        $global:appcon.view.style('Work',$global:appcon._get('Current.Workspace'))
    }else{
        $global:appcon.view.style('Work','toggle')
    }
}
function ttcmd_panel_focus_desk_and_work( $source, $mod, $key ){
    #.SYNOPSIS
    # Deskにフォーカス、その後、Workxにフォーカス

    if( $global:appcon._ne( 'Focus.Application', 'Desk' ) ){
        $global:appcon.group.focus( 'Desk', $mood, $key )
    }else{
        $global:appcon.group.focus( $global:appcon._get('Current.Workspace'), $mod, $key )
    }
}
function ttcmd_panel_focus_shelf_revtgl( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfにフォーカス、その後、表示スタイルを変更（逆順）

    if( $global:appcon._ne( 'Focus.Panel', 'Shelf' ) ){
        $global:appcon.group.focus( 'Shelf', $mood, $key )
    }else{
        $global:appcon.view.style( 'Shelf', 'revtgl' )
    }
}
function ttcmd_panel_focus_shelf_toggle( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfにフォーカス、その後、表示スタイルを変更（正順）

    if( $global:appcon._ne( 'Focus.Panel', 'Shelf' ) ){
        $global:appcon.group.focus( 'Shelf', $mood, $key )
    }else{
        $global:appcon.view.style( 'Shelf', 'toggle' )
    }
}
function ttcmd_panel_focus_index_revtgl( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexにフォーカス、その後、表示スタイルを変更（逆順）

    if( $global:appcon._ne( 'Focus.Panel', 'Index' ) ){
        $global:appcon.group.focus( 'Index', $mood, $key )
    }else{
        $global:appcon.view.style( 'Index', 'revtgl' )
    }
}
function ttcmd_panel_focus_index_toggle( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexにフォーカス、その後、表示スタイルを変更（正順）

    if( $global:appcon._ne( 'Focus.Panel', 'Index' ) ){
        $global:appcon.group.focus( 'Index', $mood, $key )
    }else{
        $global:appcon.view.style( 'Index', 'toggle' )
    }
}
function ttcmd_panel_focus_library_revtgl( $source, $mod, $key ){
    #.SYNOPSIS
    # Libraryにフォーカス、その後、表示スタイルを変更（逆順）

    if( $global:appcon._ne( 'Focus.Panel', 'Library' ) ){
        $global:appcon.group.focus( 'Library', $mood, $key )
    }else{
        $global:appcon.view.style( 'Library', 'revtgl' )
    }
}
function ttcmd_panel_focus_library_toggle( $source, $mod, $key ){
    #.SYNOPSIS
    # Libraryにフォーカス、その後、表示スタイルを変更（正順）

    if( $global:appcon._ne( 'Focus.Panel', 'Library' ) ){
        $global:appcon.group.focus( 'Library', $mood, $key )
    }else{
        $global:appcon.view.style( 'Library', 'toggle' )
    }
}
#endregion




#endregion###############################################################################################################









#region　旧Application
#########################################################################################################################

#region　Application Developping
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function ttcmd_application_developping_extract_keyword_containing_memo( $source, $mod, $key ){
    #.SYNOPSIS
    # キーワードを含むメモのライブラリを作成する

    $script:desk.create_cache( "" )
}
function ttcmd_application_developping_debug( $source, $mod, $key ){
    #.SYNOPSIS
    # デバッグ用

    Write-Host "DEBUG"
}


#endregion'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

#region　Application Border
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function ttcmd_application_borderstyle_all( $source, $mod, $key ){
    #.SYNOPSIS
    # 全パネルを表示する
    $script:app.window( 'max' )
    $script:app.border( 'Layout.Library.Width', "15" )
    $script:app.border( 'Layout.Library.Height', "25" )
    $script:app.border( 'Layout.Shelf.Height', "25" )
    $work = $script:app._get( 'Layout.Display' ).split(",").where{ $_ -like "Work*" } -join ","
    $script:app._set( 'Layout.Display', "Library,Status,Shelf,$work")
    $script:app._set( 'Layout.Style', "All")
}
function ttcmd_application_borderstyle_standard( $source, $mod, $key ){
    #.SYNOPSIS
    # 標準敵な表示

    $script:app.window( 'max' )
    $script:app.border( 'Layout.Library.Width', "15" )
    $script:app.border( 'Layout.Library.Height', "100" )
    $script:app.border( 'Layout.Shelf.Height', "25" )
    $work = ($script:app._get( 'Layout.Display' ).split(",")).where{ $_ -like "Work*" } -join ","
    $script:app._set( 'Layout.Display', "Library,Shelf,$work")
    $script:app._set( 'Layout.Style', "Standard")
}
function ttcmd_application_borderstyle_workplace( $source, $mod, $key ){
    #.SYNOPSIS
    # WorkPlaceのみ表示する

    $script:app.window( 'max' )
    $script:app.border( 'Layout.Library.Width', "0" )
    $script:app.border( 'Layout.Library.Height', "25" )
    $script:app.border( 'Layout.Shelf.Height', "25" )
    $work = ($script:app._get( 'Layout.Display' ).split(",")).where{ $_ -like "Work*" } -join ","
    $script:app._set( 'Layout.Display', "Shelf,$work")
    $script:app._set( 'Layout.Style', "Workplace")
}
function ttcmd_application_borderstyle_work( $source, $mod, $key ){
    #.SYNOPSIS
    # Workのみ表示する

    $script:app.window( 'max' )
    $script:app.border( 'Layout.Library.Width', "0" )
    $script:app.border( 'Layout.Library.Height', "100" )
    $script:app.border( 'Layout.Shelf.Height', "0" )
    $work = ($script:app._get( 'Layout.Display' ).split(",")).where{ $_ -like "Work*" } -join ","
    $script:app._set( 'Layout.Display', "$work")
    $script:app._set( 'Layout.Style', "Work" )
}
function ttcmd_application_borderstyle_turn_norm( $source, $mod, $key ){
    #.SYNOPSIS
    # レイアウト表示を変更する

    switch( $script:app._get( 'Layout.Style') ){
        'All'       { ttcmd_application_borderstyle_standard; break }
        'Standard'  { ttcmd_application_borderstyle_workplace; break }
        'Workplace' { ttcmd_application_borderstyle_work; break }
        default     { ttcmd_application_borderstyle_all; break }
    }
}
function ttcmd_application_borderstyle_turn_rev( $source, $mod, $key ){
    #.SYNOPSIS
    # レイアウト表示を変更する（逆方向）

    switch( $script:app._get( 'Layout.Style') ){
        'All'       { ttcmd_application_borderstyle_work; break }
        'Work'      { ttcmd_application_borderstyle_workplace; break }
        'Workplace' { ttcmd_application_borderstyle_standard; break }
        default     { ttcmd_application_borderstyle_all; break }
    }
}
function ttcmd_application_border_inworkplace_up( $source, $mod, $key ){
    #.SYNOPSIS
    # Workplace内境界を上へ移動

    $script:app.border( 'Layout.Shelf.Height', "-1" )
}
function ttcmd_application_border_inworkplace_down( $source, $mod, $key ){
    #.SYNOPSIS
    # Workplace内境界を下へ移動

    $script:app.border( 'Layout.Shelf.Height', "+1" )
}

#endregion'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

#region　Application Help
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function ttcmd_application_help_site( $source, $mod, $key ){
    #.SYNOPSIS
    # アプリケーションサイトを表示する

    $script:app.dialog( 'site' )
}
function ttcmd_application_help_version( $source, $mod, $key ){
    #.SYNOPSIS
    # アプリケーションのバージョン表示

    $script:app.dialog( 'version' )
}
function ttcmd_application_help_shortcuts( $source, $mod, $key ){
    #.SYNOPSIS
    # アプリケーションのショートカットキー一覧表示

    $script:app.dialog( 'shortcut' )
}
function ttcmd_application_help_instruction( $source, $mod, $key ){
    #.SYNOPSIS
    # アプリケーションを使い方表示

    $script:app.dialog( 'help' )
}
function ttcmd_application_help_breifing( $source, $mod, $key ){
    #.SYNOPSIS
    # アプリケーションの説明

    $script:app.dialog( 'about' )
}

#endregion'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

#region　Application Tool
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function ttcmd_application_textsearch( $source, $mod, $key ){
    #.SYNOPSIS
    # 全文検索を実行する

    $keyword = $script:app.keyword()

}

#endregion'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''


#endregion###############################################################################################################


#region　Library
#########################################################################################################################


function ttcmd_panel_style_toggle( $source, $mod, $key ){
    #.SYNOPSIS
    # 各パネルにフォーカスして表示幅を変更する

    $global:appcon.view.style( $source, 'toggle' )
}
function ttcmd_panel_style_revtgl( $source, $mod, $key ){
    #.SYNOPSIS
    # 各パネルにフォーカスして表示幅を変更する（逆順）

    $global:appcon.view.style( $source, 'revtgl' )
}



#endregion###############################################################################################################

#region　Index
#########################################################################################################################
function ttcmd_index_copy_item( $source, $mod, $key ){
    #.SYNOPSIS
    # 選択アイテムをコピーする(index）

    $lib, $index = $script:index.selected_index()
    [TTClipboard]::Copy( $script:shelf.item( $index ) )
}
function ttcmd_index_turn_rev( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexにフォーカスして表示高を変更する（逆順）

    if( $script:app._eq( 'Application.Focused', 'Index' ) ){
        switch( $script:app._get( 'Layout.Library.Height') ){
            '0' {
                $script:app.border( 'Layout.Library.Height', "25" )
                $script:index.focus()
            }
            '25' {
                $script:app.border( 'Layout.Library.Height', "50" )
                $script:index.focus()
            }
            default { 
                $script:app.border( 'Layout.Library.Height', "0" ) 
                $script:index.focus()
            }
        }
    }else{
        $script:index.focus()
        if( -not $script:app.isvisible( 'Index' ) ){ ttcmd_index_turn_rev }
    }

}
function ttcmd_index_turn_norm( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexにフォーカスして表示高を変更する

    if( $script:app._eq( 'Application.Focused', 'Index' ) ){
        switch( $script:app._get( 'Layout.Library.Height') ){
            '0' {
                $script:app.border( 'Layout.Library.Height', "50" )
                $script:index.focus()
            }
            '50' {
                $script:app.border( 'Layout.Library.Height', "25" )
                $script:index.focus()
            }
            default { 
                $script:app.border( 'Layout.Library.Height', "0" ) 
                $script:index.focus()
            }
        }
    }else{
        $script:index.focus()
        if( -not $script:app.isvisible( 'Index' ) ){ ttcmd_index_turn_norm }
    }

}
function ttcmd_index_delete_selected( $source, $mod, $key ){
    #.SYNOPSIS
    # 選択Indexを削除する
    $index = $script:index.selected_index()
    switch( [MessageBox]::Show( "選択中の$indexを削除しますか", "Delete",'YesNo','Question') ){
        'No' { return }
    }
    $script:index.delete_selected()
    $script:index.reload()
    if( $script:shelf._library_name -eq $script:index._library_name ){ $script:shelf.reload() }

}
function ttcmd_index_selected_tocurrenteditor( $source, $mod, $key ){
    #.SYNOPSIS
    # 選択メモをカレントエディタに読み込む

    ( $library, $index ) = $script:index.selected_index()
    switch( $library ){
        'Memo' {
            $script:desk.tool( 'Editor' ).load( $index )
            ttcmd_editor_focus_currenteditor
        }
    }
}

function ttcmd_index_invoke_item( $source, $mod, $key ){
    #.SYNOPSIS
    # 選択アイテムを実行する(index)

    $library, $index = $script:index.selected_index()
    $script:index.item( $index ).DoAction()
}
function ttcmd_index_activate_item( $source, $mod, $key ){
    #.SYNOPSIS
    # 選択アイテムを実行する(index)

    $library, $index = $script:index.selected_index()
    $script:index.item( $index ).SelectActions()

}
function ttcmd_index_delete_selected( $source, $mod, $key ){
    #.SYNOPSIS
    # 選択メモを削除する

    $index = $script:app._get( 'Memo.Index' )

    switch( [MessageBox]::Show( "$indexを削除しますか", "Quit",'YesNo','Question') ){
        'No' { return }
    }

    $index = $script:app._get( 'Memo.Index' )
    $script:DocMan.Tool( $index ).Reset()
    $script:desk.delete_memo( $index )
    $script:shelf.reload()
    $script:index.reload()
}


function ttcmd_index_selected_toeditor1( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexの選択メモをエディタ１に読み込む

    ( $library, $index ) = $script:index.selected_index()
    switch( $library ){
        'Memo' { 
            $script:desk.tool( 'Editor1' ).load( $index )
        }
    }
}
function ttcmd_index_selected_toeditor2( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexの選択メモをエディタ２に読み込む

    ( $library, $index ) = $script:index.selected_index()
    switch( $library ){
        'Memo' { 
            $script:desk.tool( 'Editor2' ).load( $index )
        }
    }
}
function ttcmd_index_selected_toeditor3( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexの選択メモをエディタ３に読み込む

    ( $library, $index ) = $script:index.selected_index()
    switch( $library ){
        'Memo' { 
            $script:desk.tool( 'Editor3' ).load( $index )
        }
    }
}

function ttcmd_index_move_up( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexのカーソルを上に移動

    $script:index.cursor('up')
}
function ttcmd_index_move_down( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexのカーソルを下に移動

    $script:index.cursor('down')
}
function ttcmd_index_move_first( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexのカーソルを先頭に移動

    $script:index.cursor('first')
}
function ttcmd_index_move_last( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexのカーソルを末尾に移動

    $script:index.cursor('last')
}
function ttcmd_index_filter_clear( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexの検索キーワードを消去する

    $script:index.nosearch()
}
function ttcmd_index_sort_dsc_1stcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexの第１カラムでソートする

    $script:index.column('1').sort('Descending')
}
function ttcmd_index_sort_dsc_2ndcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexの第２カラムでソートする

    $script:index.column('2').sort('Descending')
}
function ttcmd_index_sort_dsc_3rdcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexの第３カラムでソートする

    $script:index.column('3').sort('Descending')
}
function ttcmd_index_sort_dsc_4thcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexの第３カラムでソートする

    $script:index.column('4').sort('Descending')
}
function ttcmd_index_sort_dsc_5thcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexの第５カラムでソートする

    $script:index.column('5').sort('Descending')
}
function ttcmd_index_sort_dsc_6thcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexの第６カラムでソートする

    $script:index.column('6').sort('Descending')
}
function ttcmd_index_sort_asc_1stcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexの第１カラムでソートする

    $script:index.column('1').sort('Ascending')
}
function ttcmd_index_sort_asc_2ndcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexの第２カラムでソートする

    $script:index.column('2').sort('Ascending')
}
function ttcmd_index_sort_asc_3rdcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexの第３カラムでソートする

    $script:index.column('3').sort('Ascending')
}
function ttcmd_index_sort_asc_4thcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexの第３カラムでソートする

    $script:index.column('4').sort('Ascending')
}
function ttcmd_index_sort_asc_5thcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexの第５カラムでソートする

    $script:index.column('5').sort('Ascending')
}
function ttcmd_index_sort_asc_6thcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexの第６カラムでソートする

    $script:index.column('6').sort('Ascending')
}


#endregion###############################################################################################################

#region　Shelf 未
#########################################################################################################################
function ttcmd_shelf_copy_item( $source, $mod, $key ){
    #.SYNOPSIS
    # 選択アイテムをコピーする(shelf）

    $lib, $index = $script:shelf.selected_index()
    [TTClipboard]::Copy( $script:shelf.item( $index ) )
}

function ttcmd_shelf_invoke_item( $source, $mod, $key ){
    #.SYNOPSIS
    # 選択アイテムを実行する（shelf）

    $library, $index = $script:shelf.selected_index()
    $script:shelf.item( $index ).DoAction()
}
function ttcmd_shelf_activate_item( $source, $mod, $key ){
    #.SYNOPSIS
    # 選択アイテムを実行する（shelf）

    $library, $index = $script:shelf.selected_index()
    $script:shelf.item( $index ).SelectActions()
}
function ttcmd_shelf_delete_selected( $source, $mod, $key ){
    #.SYNOPSIS
    # 選択Indexを削除する
    $index = $script:shelf.selected_index()
    switch( [MessageBox]::Show( "選択中の$indexを削除しますか", "Delete",'YesNo','Question') ){
        'No' { return }
    }
    $script:shelf.delete_selected()
    $script:shelf.reload()
    if( $script:shelf._library_name -eq $script:index._library_name ){ $script:index.reload() }
}

function ttcmd_shelf_selected_tocurrenteditor( $source, $mod, $key ){
    #.SYNOPSIS
    # 選択メモをカレントエディタに読み込む

    ( $library, $index ) = $script:shelf.selected_index()
    switch( $library ){
        'Memo' {
            $script:desk.tool( 'Editor' ).load( $index )
        }
    }
}



# [2022-04-12]
# ShelfとIndexのキーそろえる
# Indexも最初からMemo表示
# 行頭文字、Section文字、タブについて統一敵な入力方法
# フォーカスのあるパネルに * マーク
# DeskでのAlt+Space→currenteditor focus

# 行頭
# Section文字
# Bullet
# 日付
# thinktank記号



function ttcmd_shelf_selected_toeditor3( $source, $mod, $key ){
    #.SYNOPSIS
    # 選択メモをエディタ３に読み込む

    ( $library, $index ) = $script:shelf.selected_index()
    switch( $library ){
        'Memo' {
            $script:desk.tool( 'Editor3' ).load( $index )
        }
    }
}
function ttcmd_shelf_selected_toeditor2( $source, $mod, $key ){
    #.SYNOPSIS
    # 選択メモをエディタ２に読み込む

    ( $library, $index ) = $script:shelf.selected_index()
    switch( $library ){
        'Memo' {
            $script:desk.tool( 'Editor2' ).load( $index )
        }
    }
}
function ttcmd_shelf_selected_toeditor1( $source, $mod, $key ){
    #.SYNOPSIS
    # 選択メモをエディタ１に読み込む

    ( $library, $index ) = $script:shelf.selected_index()
    switch( $library ){
        'Memo' { 
            $script:desk.tool( 'Editor1' ).load( $index )
        }
    }
}
function ttcmd_shelf_focus_menu( $source, $mod, $key ){
    #.SYNOPSIS
    # shelfのメニューにフォーカスする

    $script:shelf._sorting.Items[0].focus()
}


function ttcmd_shelf_turn_norm( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfにフォーカスして表示高を変更する

    if( $script:app._eq( 'Application.Focused', 'Shelf' ) ){
        switch( $script:app._get( 'Layout.Shelf.Height') ){
            '0' { 
                $script:app.border( 'Layout.Shelf.Height', "80" )
                $script:shelf.focus()
            }
            '80' {
                $script:app.border( 'Layout.Shelf.Height', "25" )
                $script:shelf.focus()
            }
            default {
                $script:app.border( 'Layout.Shelf.Height', "0" )
                $script:desk.focus()
            }
        }
    }else{
        $script:shelf.focus()
        if( -not $script:app.isvisible( 'Shelf' ) ){ ttcmd_shelf_turn_norm }
    }
}
function ttcmd_shelf_turn_rev( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfにフォーカスして表示高を変更する（逆順）

    if( $script:app._eq( 'Application.Focused', 'Shelf' ) ){
        switch( $script:app._get( 'Layout.Shelf.Height') ){
            '0' { 
                $script:app.border( 'Layout.Shelf.Height', "25" )
                $script:shelf.focus()
            }
            '25' {
                $script:app.border( 'Layout.Shelf.Height', "80" )
                $script:shelf.focus()
            }
            default {
                $script:app.border( 'Layout.Shelf.Height', "0" )
                $script:desk.focus()
            }
        }
    }else{
        $script:shelf.focus()
        if( -not $script:app.isvisible( 'Shelf' ) ){ ttcmd_shelf_turn_rev }
    }

}
function ttcmd_shelf_move_up( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfのカーソルを上に移動

    $script:shelf.cursor('up')
}
function ttcmd_shelf_move_down( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfのカーソルを下に移動

    $script:shelf.cursor('down')
}
function ttcmd_shelf_move_first( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfのカーソルを先頭に移動

    $script:shelf.cursor('first')
}
function ttcmd_shelf_move_last( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfのカーソルを最後に移動

    $script:shelf.cursor('last')
}
function ttcmd_shelf_clear( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfのフィルターをクリアする

    $script:shelf.nosearch()
}
function ttcmd_shelf_sort_dsc_1stcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfの第１カラムでソートする

    $script:shelf.column('1').sort('Descending')
}
function ttcmd_shelf_sort_dsc_2ndcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfの第２カラムでソートする

    $script:shelf.column('2').sort('Descending')
}
function ttcmd_shelf_sort_dsc_3rdcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfの第３カラムでソートする

    $script:shelf.column('3').sort('Descending')
}
function ttcmd_shelf_sort_dsc_4thcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfの第４カラムでソートする

    $script:shelf.column('4').sort('Descending')
}
function ttcmd_shelf_sort_dsc_5thcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfの第５カラムでソートする

    $script:shelf.column('5').sort('Descending')
}
function ttcmd_shelf_sort_dsc_6thcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfの第６カラムでソートする

    $script:shelf.column('6').sort('Descending')
}
function ttcmd_shelf_sort_asc_1stcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfの第１カラムでソートする

    $script:shelf.column('1').sort('Ascending')
}
function ttcmd_shelf_sort_asc_2ndcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfの第２カラムでソートする

    $script:shelf.column('2').sort('Ascending')
}
function ttcmd_shelf_sort_asc_3rdcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfの第３カラムでソートする

    $script:shelf.column('3').sort('Ascending')
}
function ttcmd_shelf_sort_asc_4thcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfの第４カラムでソートする

    $script:shelf.column('4').sort('Ascending')
}
function ttcmd_shelf_sort_asc_5thcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfの第５カラムでソートする

    $script:shelf.column('5').sort('Ascending')
}
function ttcmd_shelf_sort_asc_6thcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfの第６カラムでソートする

    $script:shelf.column('6').sort('Ascending')
}


# 保存されない
# 強制保存コマンドあってよいかもな




#endregion###############################################################################################################

#region　Desk
#########################################################################################################################
#region　Desk Border
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function ttcmd_desk_borderstyle_turn_norm( $source, $mod, $key ){
    #.SYNOPSIS
    # Deskにフォーカスする

    if( $script:app._eq( 'Application.Focused', 'Desk' ) ){
        switch( $script:app._get( 'Layout.Desk' ) ){
            'Work1,Work2,Work3' { ttcmd_desk_borderstyle_work13 }
            'Work1,Work2'       { ttcmd_desk_borderstyle_work123 }
            'Work1,Work3'       { ttcmd_desk_borderstyle_work1 }
            default             { ttcmd_desk_borderstyle_work12 }
        }
    }
    $script:desk.focus()
}
function ttcmd_desk_borderstyle_turn_rev( $source, $mod, $key ){
    #.SYNOPSIS
    # Deskにフォーカスする

    if( $script:app._eq( 'Application.Focused', 'Desk' ) ){
        switch( $script:app._get( 'Layout.Desk' ) ){
            'Work1,Work2,Work3' { ttcmd_desk_borderstyle_work12 }
            'Work1,Work3'       { ttcmd_desk_borderstyle_work123 }
            'Work1'             { ttcmd_desk_borderstyle_work13 }
            default             { ttcmd_desk_borderstyle_work1 }
        }
    }
    $script:desk.focus()
}
function ttcmd_desk_borderstyle_work123( $source, $mod, $key ){
    #.SYNOPSIS
    # ３つのWorkplaceを表示

    $script:app.border( 'Layout.Work1.Width', "50" )
    $script:app.border( 'Layout.Work1.Height', "70" )
    $script:app._set( 'Layout.Desk', "Work1,Work2,Work3")
}
function ttcmd_desk_borderstyle_work12( $source, $mod, $key ){
    #.SYNOPSIS
    # 横２つのWorkplaceを表示

    $script:app.border( 'Layout.Work1.Width', "50" )
    $script:app.border( 'Layout.Work1.Height', "100" )
    $script:app._set( 'Layout.Desk', "Work1,Work2")
}
function ttcmd_desk_borderstyle_work13( $source, $mod, $key ){
    #.SYNOPSIS
    # 縦２つのWorkplaceを表示

    $script:app.border( 'Layout.Work1.Width', "100" )
    $script:app.border( 'Layout.Work1.Height', "50" )
    $script:app._set( 'Layout.Desk', "Work1,Work3")
}

function ttcmd_deskwork_turn_norm( $source, $mod, $key ){
    #.SYNOPSIS
    # Work表示を切り替える

    switch( $script:app._get( 'Application.Focused' ) ){
        'Work1' { ttcmd_desk_borderstyle_work2 }
        'Work2' { ttcmd_desk_borderstyle_work3 }
        'Work3' { ttcmd_desk_borderstyle_work1 }
    }
}
function ttcmd_deskwork_turn_rev( $source, $mod, $key ){
    #.SYNOPSIS
    # Work表示を切り替える（逆順）

    switch( $script:app._get( 'Application.Focused' ) ){
        'Work1' { ttcmd_desk_borderstyle_work3 }
        'Work2' { ttcmd_desk_borderstyle_work1 }
        'Work3' { ttcmd_desk_borderstyle_work2 }
    }
}
function ttcmd_desk_borderstyle_work1( $source, $mod, $key ){
    #.SYNOPSIS
    # Work1を表示

    $script:app.border( 'Layout.Work1.Width', "100" )
    $script:app.border( 'Layout.Work1.Height', "100" )
    $script:desk.focus( 'Work1' )
    $script:app._set( 'Layout.Desk', "Work1")
}
function ttcmd_desk_borderstyle_work2( $source, $mod, $key ){
    #.SYNOPSIS
    # Work2を表示

    $script:app.border( 'Layout.Work1.Width', "0" )
    $script:app.border( 'Layout.Work1.Height', "100" )
    $script:desk.focus( 'Work2' )
    $script:app._set( 'Layout.Desk', "Work2")
}
function ttcmd_desk_borderstyle_work3( $source, $mod, $key ){
    #.SYNOPSIS
    # Work3を表示

    $script:app.border( 'Layout.Work1.Width', "0" )
    $script:app.border( 'Layout.Work1.Height', "0" )
    $script:desk.focus( 'Work3' )
    $script:app._set( 'Layout.Desk', "Work3")
}

#endregion'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

#region　Desk Works
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function ttcmd_desk_focus_menu( $source, $mod, $key ){
    #.SYNOPSIS
    # deskのメニューにフォーカスする

    $script:desk._sorting.Items[0].focus()
}
function ttcmd_desk_works_focus_turn_norm( $source, $mod, $key ){
    #.SYNOPSIS
    # Workのフォーカスを切り替える

    switch( $true ){
        $script:app._in( 'Application.Focused', $script:Work1IDs ) { $script:desk.focus( 'Work2' ); break }
        $script:app._in( 'Application.Focused', $script:Work2IDs ) { $script:desk.focus( 'Work3' ); break }
        default { $script:desk.focus( 'Work1' ) }
    }
}
function ttcmd_desk_works_focus_turn_rev( $source, $mod, $key ){
    #.SYNOPSIS
    # Workのフォーカスを切り替える（逆方向）

    switch( $true ){
        $script:app._in( 'Application.Focused', $script:Work3IDs ) { $script:desk.focus( 'Work2' ); break }
        $script:app._in( 'Application.Focused', $script:Work1IDs ) { $script:desk.focus( 'Work3' ); break }
        default { $script:desk.focus( 'Work1' ) }
    }
}
function ttcmd_desk_works_focus_work1( $source, $mod, $key ){
    #.SYNOPSIS
    # Work1にフォーカスする

    if( $script:app.isvisible( 'Work1' ) ){ 
        $script:desk.focus( 'Work1' )
    }else{
        ttcmd_desk_borderstyle_work1
    }
}
function ttcmd_desk_works_focus_work2( $source, $mod, $key ){
    #.SYNOPSIS
    # Work2にフォーカスする

    if( $script:app.isvisible( 'Work2' ) ){ 
        $script:desk.focus( 'Work2' )
    }else{
        ttcmd_desk_borderstyle_work2
    }
}
function ttcmd_desk_works_focus_work3( $source, $mod, $key ){
    #.SYNOPSIS
    # Work3にフォーカスする

    if( $script:app.isvisible( 'Work3' ) ){ 
        $script:desk.focus( 'Work3' )
    }else{
        ttcmd_desk_borderstyle_work3
    }
}
function ttcmd_desk_clear( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfのフィルターをクリアする

    $script:desk.nosearch()
}

#endregion'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''


#endregion###############################################################################################################

#region　Config
#########################################################################################################################
function ttcmd_application_config_editor_wordwrap_on( $source, $mod, $key ){
    #.SYNOPSIS
    # カレントエディタのワードラップをON

    $tool = $script:app._get( "Desk.CurrentEditor" )
    $script:app._set( "$tool.WordWrap", 'true' )
}
function ttcmd_application_config_editor_wordwrap_off( $source, $mod, $key ){
    #.SYNOPSIS
    # カレントエディタのワードラップをOFF

    $tool = $script:app._get( "Desk.CurrentEditor" )
    $script:app._set( "$tool.WordWrap", 'false' )
}
function ttcmd_application_config_editor_wordwrap_toggle( $source, $mod, $key ){
    #.SYNOPSIS
    # カレントエディタのワードラップを切り替える

    $tool = $script:app._get( "Desk.CurrentEditor" )
    $script:app._set( "$tool.WordWrap", 'toggle' )
}
function ttcmd_application_config_editor_staycursor_on( $source, $mod, $key ){
    #.SYNOPSIS
    # カレントエディタのカーソル固定モードをON

    $tool = $script:app._get( "Desk.CurrentEditor" )
    $script:app._set( "$tool.StayCursor", 'true' )
}
function ttcmd_application_config_editor_staycursor_off( $source, $mod, $key ){
    #.SYNOPSIS
    # カレントエディタのカーソル固定モードをOFF

    $tool = $script:app._get( "Desk.CurrentEditor" )
    $script:app._set( "$tool.StayCursor", 'false' )
}
function ttcmd_application_config_editor_staycursor_toggle( $source, $mod, $key ){
    #.SYNOPSIS
    # カレントエディタのカーソル固定モードを切り替える

    $tool = $script:app._get( "Desk.CurrentEditor" )
    $script:app._set( "$tool.StayCursor", 'toggle' )
}
function ttcmd_application_config_app_keydown_message_on( $source, $mod, $key ){
    #.SYNOPSIS
    # アプリのキーダウンメッセージをON

    $script:app._set( "Config.KeyDownMessage", "True" )
}
function ttcmd_application_config_app_keydown_message_off( $source, $mod, $key ){
    #.SYNOPSIS
    # アプリのキーダウンメッセージをOFF

    $script:app._set( "Config.KeyDownMessage", "False" )
}
function ttcmd_application_config_app_taskexpired_message_on( $source, $mod, $key ){
    #.SYNOPSIS
    # アプリのタスク終了メッセージをON

    $script:app._set( "Config.TaskExpiredMessage", "True" )
}
function ttcmd_application_config_app_taskexpired_message_off( $source, $mod, $key ){
    #.SYNOPSIS
    # アプリのタスク終了メッセージをOFF

    $script:app._set( "Config.TaskExpiredMessage", "False" )
}
function ttcmd_application_config_app_memosaved_message_on( $source, $mod, $key ){
    #.SYNOPSIS
    # メモのセーブメッセージをON

    $script:app._set( "Config.MemoSavedMessage", "True" )
}
function ttcmd_application_config_app_memosaved_message_off( $source, $mod, $key ){
    #.SYNOPSIS
    # メモのセーブメッセージをOFF

    $script:app._set( "Config.MemoSavedMessage", "False" )
}
function ttcmd_application_config_app_cachesaved_message_on( $source, $mod, $key ){
    #.SYNOPSIS
    # キャッシュのセーブメッセージをON

    $script:app._set( "Config.CacheSavedMessage", "True" )
}
function ttcmd_application_config_app_cachesaved_message_off( $source, $mod, $key ){
    #.SYNOPSIS
    # キャッシュのセーブメッセージをOFF

    $script:app._set( "Config.CacheMemoSavedMessage", "False" )
}

#endregion###############################################################################################################

#region　Editor Edit
#########################################################################################################################
function ttcmd_editor_history_previous_tocurrenteditor( $source, $mod, $key ){
    #.SYNOPSIS
    # 前のファイルを開く
    
    $current = $script:app._get( 'Desk.CurrentEditor' )
    $script:desk.tool( 'Editor' ).load( "previous" ).focus( $current )
}
function ttcmd_editor_history_next_tocurrenteditor( $source, $mod, $key ){
    #.SYNOPSIS
    # 先のファイルを開く
    
    $current = $script:app._get( 'Desk.CurrentEditor' )
    $script:desk.tool( 'Editor' ).load( "next" ).focus( $current )
}
function ttcmd_desk_works_focus_current_norm( $source, $mod, $key ){
    #.SYNOPSIS
    # カレントエディタにフォーカスする

    switch( $script:app._get( 'Application.Focused'　) ){
        'Editor1' { $script:desk.focus( 'Editor2' ) }
        'Editor2' { $script:desk.focus( 'Editor3' ) }
        'Editor3' { $script:desk.focus( 'Editor1' ) }
        default {
            $current = $script:app._get( 'Desk.CurrentEditor' )
            $script:desk.focus( $current )    
        }
    }
}
function ttcmd_desk_works_focus_current_rev( $source, $mod, $key ){
    #.SYNOPSIS
    # カレントエディタにフォーカスする（逆順）

    switch( $script:app._get( 'Application.Focused'　) ){
        'Editor1' { $script:desk.focus( 'Editor3' ) }
        'Editor2' { $script:desk.focus( 'Editor1' ) }
        'Editor3' { $script:desk.focus( 'Editor2' ) }
        default {
            $current = $script:app._get( 'Desk.CurrentEditor' )
            $script:desk.focus( $current )    
        }
    }
}
function ttcmd_editor_focus_currenteditor( $source, $mod, $key ){
    #.SYNOPSIS
    # カレントエディタにフォーカスする

    $current = $script:app._get( 'Desk.CurrentEditor' )
    $script:desk.focus( $current )
}
function ttcmd_editor_new_tocurrenteditor( $source, $mod, $key ){
    #.SYNOPSIS
    # 新規メモを作成し、カレントエディタに読み込む

    $index = $script:desk.create_memo()
    $tool = $script:app._get( "Desk.CurrentEditor" )
    $script:shelf.refresh()
    $script:desk.tool( $tool ).load( $index )
}
function ttcmd_editor_scroll_tonewline( $source, $mod, $key ){
    #.SYNOPSIS
    # 改行する

    $script:desk.tool('Editor').scroll_to( 'newline' )
}
function ttcmd_editor_scroll_toprevline( $source, $mod, $key ){
    #.SYNOPSIS
    # 画面を上げる

    $script:desk.tool('Editor').scroll_to( 'prevline' )
}
function ttcmd_editor_scroll_tonextline( $source, $mod, $key ){
    #.SYNOPSIS
    # 画面を下げる

    $script:desk.tool('Editor').scroll_to( 'nextline' )
}
function ttcmd_editor_select_all( $source, $mod, $key ){
    #.SYNOPSIS
    # 全行選択する

    $script:desk.tool('Editor').select_to( 'all', '' )
}
function ttcmd_editor_select_tolineend( $source, $mod, $key ){
    #.SYNOPSIS
    # カーソルから行末までを選択する

    $script:desk.tool('Editor').select_to( 'lineend+', '' )
}
function ttcmd_editor_select_tolinestart( $source, $mod, $key ){
    #.SYNOPSIS
    # カーソルから行頭までを選択する

    $script:desk.tool('Editor').select_to( 'linestart', '' )
}
function ttcmd_editor_select_torightchar( $source, $mod, $key ){
    #.SYNOPSIS
    # カーソルの右1文字を選択する

    $script:desk.tool('Editor').select_to( 'rightchar', '' )
}
function ttcmd_editor_select_toleftchar( $source, $mod, $key ){
    #.SYNOPSIS
    # カーソルの左1文字を選択する

    $script:desk.tool('Editor').select_to( 'leftchar', '' )
}
function ttcmd_editor_select_tonextline( $source, $mod, $key ){
    #.SYNOPSIS
    # カーソルの次行まで選択する

    $script:desk.tool('Editor').select_to( 'nextline', '' )
}
function ttcmd_editor_select_toprevline( $source, $mod, $key ){
    #.SYNOPSIS
    # カーソルの前行まで選択する

    $script:desk.tool('Editor').select_to( 'prevline', '' )
}
function ttcmd_editor_edit_delete( $source, $mod, $key ){
    #.SYNOPSIS
    # カーソルの右を削除する

    $script:desk.tool( 'Editor' ).edit( 'delete' )
}
function ttcmd_editor_edit_backspace( $source, $mod, $key ){
    #.SYNOPSIS
    # カーソルの左を削除する

    $script:desk.tool( 'Editor' ).edit( 'backspace' )
}
function ttcmd_editor_edit_insert_clipboard( $source, $mod, $key ){
    #.SYNOPSIS
    # クリップボードの内容を貼り付ける

    params( $modkey, $key )
    [TTClipboard]::PasteTo( $script:DocMan.current_editor, $modkey, $key )
}
function ttcmd_editor_edit_turn_bullet_norm( $source, $mod, $key ){
    #.SYNOPSIS
    # カーソル位置にアイテムヘッダーを挿入する

    $script:desk.tool( 'Editor' ).edit('bullet_nor')
}
function ttcmd_editor_edit_turn_bullet_rev( $source, $mod, $key ){
    #.SYNOPSIS
    # カーソル位置にアイテムヘッダーを挿入する

    $script:desk.tool( 'Editor' ).edit('bullet_rev')
}
function ttcmd_editor_outline_insert_section( $source, $mod, $key ){
    #.SYNOPSIS
    # カーソル位置にセクションを挿入する

    $script:desk.tool( 'Editor' ).edit( 'section' )
}



#endregion###############################################################################################################

#region　Editor Outline
#########################################################################################################################
function ttcmd_editor_outline_fold_allsection( $source, $mod, $key ){
    #.SYNOPSIS
    # 全セクションを折り畳む

    $script:desk.tool( 'Editor' ).node_to( 'close_all' )
}
function ttcmd_editor_outline_collapse_allsection( $source, $mod, $key ){
    #.SYNOPSIS
    # 全セクションを展開する

    $script:desk.tool( 'Editor' ).node_to( 'open_all' )
}

#endregion###############################################################################################################

#region　Editor Tag
#########################################################################################################################
function ttcmd_editor_change_focus( $source, $mod, $key ){
    #.SYNOPSIS
    # エディターのフォーカスを変更する

    params( $mod, $key )
    $editor = $script:DocMan.current_editor

    # read datetag at cursor ( id, format, offset, length, date, init ) 
    $items = @($script:EditorIDs.foreach{
        $select = if( $editor.Name -eq $_ ){ "@" }else{ "" }
        $memoid = $script:DocMan.config.$_.index
        $title = $script:DocMan.config.$_.editor.Text.split("`r`n")[0]
        "$select$_ | $memoid | $title"
    })

    # show menu
    $item = ShowPopupMenu -items $items -modkey $mod -key $key -title "SelectEditor" -editor $editor

    # focus editor 
    if( $null -ne $item ){
        switch -regex ($item){
            '.?Editor1.*' { ttcmd_desk_works_focus_work1 }
            '.?Editor2.*' { ttcmd_desk_works_focus_work2 }
            '.?Editor3.*' { ttcmd_desk_works_focus_work3 }
        }
    }
}

function ttcmd_editor_copy_tag_atcursor( $source, $mod, $key ){
    #.SYNOPSIS
    # カレントエディタカーソル位置のタグをコピーする

    $editor  = $script:DocMan.current_editor
    $memo    = $global:TTMemos.GetChild( $script:DocMan.config.($editor.Name).index )
    $posinfo = $script:DocMan.Tool('Editor').AtCursor( 'posinfo' )[0]
    [TTClipboard]::Copy( $memo, $posinfo )
}

#endregion###############################################################################################################

#  ダブルクリックでメモを選んだ際は、他Editorに読込済みであれば、Editor.Focusで対応すること。








