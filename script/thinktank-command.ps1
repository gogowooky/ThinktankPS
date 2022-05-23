




#region　Application
#########################################################################################################################
#region　Application Developping
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function ttcmd_application_developping_extract_keyword_containing_memo{
    #.SYNOPSIS
    # キーワードを含むメモのライブラリを作成する

    $script:desk.create_cache( "" )
}
function ttcmd_application_developping_debug{
    #.SYNOPSIS
    # デバッグ用

    Write-Host "DEBUG"
}


#endregion'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

#region　Application Border
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function ttcmd_application_borderstyle_all{
    #.SYNOPSIS
    # 全パネルを表示する
    $script:app.window( 'max' )
    $script:app.border( 'Layout.Guide.Width', "15" )
    $script:app.border( 'Layout.Library.Height', "25" )
    $script:app.border( 'Layout.Shelf.Height', "25" )
    $work = $script:app._get( 'Layout.Display' ).split(",").where{ $_ -like "Work*" } -join ","
    $script:app._set( 'Layout.Display', "Library,Status,Shelf,$work")
    $script:app._set( 'Layout.Style', "All")
}
function ttcmd_application_borderstyle_standard{
    #.SYNOPSIS
    # 標準敵な表示

    $script:app.window( 'max' )
    $script:app.border( 'Layout.Guide.Width', "15" )
    $script:app.border( 'Layout.Library.Height', "100" )
    $script:app.border( 'Layout.Shelf.Height', "25" )
    $work = ($script:app._get( 'Layout.Display' ).split(",")).where{ $_ -like "Work*" } -join ","
    $script:app._set( 'Layout.Display', "Library,Shelf,$work")
    $script:app._set( 'Layout.Style', "Standard")
}
function ttcmd_application_borderstyle_workplace{
    #.SYNOPSIS
    # WorkPlaceのみ表示する

    $script:app.window( 'max' )
    $script:app.border( 'Layout.Guide.Width', "0" )
    $script:app.border( 'Layout.Library.Height', "25" )
    $script:app.border( 'Layout.Shelf.Height', "25" )
    $work = ($script:app._get( 'Layout.Display' ).split(",")).where{ $_ -like "Work*" } -join ","
    $script:app._set( 'Layout.Display', "Shelf,$work")
    $script:app._set( 'Layout.Style', "Workplace")
}
function ttcmd_application_borderstyle_work{
    #.SYNOPSIS
    # Workのみ表示する

    $script:app.window( 'max' )
    $script:app.border( 'Layout.Guide.Width', "0" )
    $script:app.border( 'Layout.Library.Height', "100" )
    $script:app.border( 'Layout.Shelf.Height', "0" )
    $work = ($script:app._get( 'Layout.Display' ).split(",")).where{ $_ -like "Work*" } -join ","
    $script:app._set( 'Layout.Display', "$work")
    $script:app._set( 'Layout.Style', "Work" )
}
function ttcmd_application_borderstyle_turn_norm{
    #.SYNOPSIS
    # レイアウト表示を変更する

    switch( $script:app._get( 'Layout.Style') ){
        'All'       { ttcmd_application_borderstyle_standard; break }
        'Standard'  { ttcmd_application_borderstyle_workplace; break }
        'Workplace' { ttcmd_application_borderstyle_work; break }
        default     { ttcmd_application_borderstyle_all; break }
    }
}
function ttcmd_application_borderstyle_turn_rev{
    #.SYNOPSIS
    # レイアウト表示を変更する（逆方向）

    switch( $script:app._get( 'Layout.Style') ){
        'All'       { ttcmd_application_borderstyle_work; break }
        'Work'      { ttcmd_application_borderstyle_workplace; break }
        'Workplace' { ttcmd_application_borderstyle_standard; break }
        default     { ttcmd_application_borderstyle_all; break }
    }
}
function ttcmd_application_border_inwindow_left{
    #.SYNOPSIS
    # Window内境界を左へ移動

    $script:app.border( 'Layout.Guide.Width', "-1" )
}
function ttcmd_application_border_inwindow_right{
    #.SYNOPSIS
    # Window内境界を右へ移動

    $script:app.border( 'Layout.Guide.Width', "+1" )
}
function ttcmd_application_border_inguide_up{
    #.SYNOPSIS
    # Guide内境界を上へ移動

    $script:app.border( 'Layout.Library.Height', "-1" )
}
function ttcmd_application_border_inguide_down{
    #.SYNOPSIS
    # Guide内境界を下へ移動

    $script:app.border( 'Layout.Library.Height', "+1" )
}
function ttcmd_application_border_inworkplace_up{
    #.SYNOPSIS
    # Workplace内境界を上へ移動

    $script:app.border( 'Layout.Shelf.Height', "-1" )
}
function ttcmd_application_border_inworkplace_down{
    #.SYNOPSIS
    # Workplace内境界を下へ移動

    $script:app.border( 'Layout.Shelf.Height', "+1" )
}
function ttcmd_application_border_indesk_up{
    #.SYNOPSIS
    # Desk内境界を上へ移動

    $script:app.border( 'Layout.Work1.Height', "-1" )
}
function ttcmd_application_border_indesk_down{
    #.SYNOPSIS
    # Desk内境界を下へ移動

    $script:app.border( 'Layout.Work1.Height', "+1" )

}
function ttcmd_application_border_indesk_left{
    #.SYNOPSIS
    # Desk内境界を左へ移動

    $script:app.border( 'Layout.Work1.Width', "-1" )
}
function ttcmd_application_border_indesk_right{
    #.SYNOPSIS
    # Desk内境界を右へ移動

    $script:app.border( 'Layout.Work1.Width', "+1" )
}

#endregion'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

#region　Application Window
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function ttcmd_application_window_quit{
    #.SYNOPSIS
    # アプリケーションを終了する

    switch( [MessageBox]::Show( "終了しますか", "Quit",'YesNo','Question') ){
        'No' { return }
    }
    $script:app.window('close')
}
function ttcmd_application_window_full{
    #.SYNOPSIS
    # アプリケーションを最大化する
    
    $script:app.window('max')
}
function ttcmd_application_window_icon{
    #.SYNOPSIS
    # アプリケーションを最小化する

    $script:app.window('min')
}
function ttcmd_application_window_free{
    #.SYNOPSIS
    # アプリケーションを通常化する

    $script:app.window('normal')
}
function ttcmd_application_window_turn{
    #.SYNOPSIS
    # アプリケーション表示を変更する

    $script:app.window('toggle')
}

#endregion'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

#region　Application Help
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function ttcmd_application_help_site{
    #.SYNOPSIS
    # アプリケーションサイトを表示する

    $script:app.dialog( 'site' )
}
function ttcmd_application_help_version{
    #.SYNOPSIS
    # アプリケーションのバージョン表示

    $script:app.dialog( 'version' )
}
function ttcmd_application_help_shortcuts{
    #.SYNOPSIS
    # アプリケーションのショートカットキー一覧表示

    $script:app.dialog( 'shortcut' )
}
function ttcmd_application_help_instruction{
    #.SYNOPSIS
    # アプリケーションを使い方表示

    $script:app.dialog( 'help' )
}
function ttcmd_application_help_breifing{
    #.SYNOPSIS
    # アプリケーションの説明

    $script:app.dialog( 'about' )
}

#endregion'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

#region　Application Tool
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function ttcmd_application_textsearch{
    #.SYNOPSIS
    # 全文検索を実行する

    $keyword = $script:app.keyword()

}

#endregion'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

function ttcmd_application_commands_execute{
    #.SYNOPSIS
    # コマンドを選択して実行する

    $script:app.commands()
}

#endregion###############################################################################################################

#region　Library
#########################################################################################################################
function ttcmd_library_invoke_item{
    #.SYNOPSIS
    # 選択アイテムを実行する(library)

    $index = $script:library.selected_index()
    $script:library.item( $index ).DoAction()

}
function ttcmd_library_activate_item{
    #.SYNOPSIS
    # 選択アイテムを実行する(library)

    $index = $script:library.selected_index()
    $script:library.item( $index ).SelectActions()

}
function ttcmd_library_delete_selected{
    #.SYNOPSIS
    # 選択Libraryのキャッシュを削除する
    $index = $script:library.selected_index()
    switch( [MessageBox]::Show( "選択中の$indexを削除しますか", "Delete",'YesNo','Question') ){
        'No' { return }
    }
    $script:library.delete_selected()
}
function ttcmd_library_turn_norm{
    #.SYNOPSIS
    # Libraryにフォーカスして表示幅を変更する

    if( $script:app._eq( 'Application.Focused', 'Library' ) ){
        switch( $script:app._get( 'Layout.Guide.Width') ){
            '0' { 
                $script:app.border( 'Layout.Guide.Width', "15" ) 
                $script:library.focus()
            }
            '15' { 
                $script:app.border( 'Layout.Guide.Width', "24" )
                $script:library.focus()
            }
            default {
                $script:app.border( 'Layout.Guide.Width', "0" )
                $script:desk.focus()
            }
        }
    }else{
        $script:library.focus()
        if( -not $script:app.isvisible( 'Library' ) ){ ttcmd_library_turn_norm }
    }
}

function ttcmd_library_turn_rev{
    #.SYNOPSIS
    # Libraryにフォーカスして表示幅を変更する（逆順）

    if( $script:app._eq( 'Application.Focused', 'Library' ) ){
        switch( $script:app._get( 'Layout.Guide.Width') ){
            '0' { 
                $script:app.border( 'Layout.Guide.Width', "24" ) 
                $script:library.focus()
            }
            '24' { 
                $script:app.border( 'Layout.Guide.Width', "15" )
                $script:library.focus()
            }
            default {
                $script:app.border( 'Layout.Guide.Width', "0" )
                $script:desk.focus()
            }
        }
    }else{
        $script:library.focus()
        if( -not $script:app.isvisible( 'Library' ) ){ ttcmd_library_turn_rev }
    }
}
function ttcmd_library_move_up{
    #.SYNOPSIS
    # Libraryのカーソルを上に移動
    
    $script:library.cursor('up')
}
function ttcmd_library_move_down{
    #.SYNOPSIS
    # Libraryのカーソルを下に移動

    $script:library.cursor('down')
}
function ttcmd_library_move_first{
    #.SYNOPSIS
    # Libraryのカーソルを先頭に移動

    $script:library.cursor('first')
}
function ttcmd_library_move_last{
    #.SYNOPSIS
    # Libraryのカーソルを末尾に移動

    $script:library.cursor('last')
}
function ttcmd_library_filter_clear{
    #.SYNOPSIS
    # Libraryのフィルターをクリアする
    $script:library.nosearch()
}
function ttcmd_library_sort_dsc_1stcolumn{
    #.SYNOPSIS
    # Libraryの第１カラムでソートする

    $script:library.column('1').sort('Descending')
}
function ttcmd_library_sort_dsc_2ndcolumn{
    #.SYNOPSIS
    # Libraryの第２カラムでソートする

    $script:library.column('2').sort('Descending')
}
function ttcmd_library_sort_dsc_3rdcolumn{
    #.SYNOPSIS
    # Libraryの第３カラムでソートする

    $script:library.column('3').sort('Descending')
}
function ttcmd_library_sort_dsc_4thcolumn{
    #.SYNOPSIS
    # Libraryの第４カラムでソートする

    $script:library.column('4').sort('Descending')
}
function ttcmd_library_sort_dsc_5thcolumn{
    #.SYNOPSIS
    # Libraryの第５カラムでソートする

    $script:library.column('5').sort('Descending')
}
function ttcmd_library_sort_dsc_6thcolumn{
    #.SYNOPSIS
    # Libraryの第６カラムでソートする

    $script:library.column('6').sort('Descending')
}
function ttcmd_library_sort_asc_1stcolumn{
    #.SYNOPSIS
    # Libraryの第１カラムでソートする

    $script:library.column('1').sort('Ascending')
}
function ttcmd_library_sort_asc_2ndcolumn{
    #.SYNOPSIS
    # Libraryの第２カラムでソートする

    $script:library.column('2').sort('Ascending')
}
function ttcmd_library_sort_asc_3rdcolumn{
    #.SYNOPSIS
    # Libraryの第３カラムでソートする

    $script:library.column('3').sort('Ascending')
}
function ttcmd_library_sort_asc_4thcolumn{
    #.SYNOPSIS
    # Libraryの第４カラムでソートする

    $script:library.column('4').sort('Ascending')
}
function ttcmd_library_sort_asc_5thcolumn{
    #.SYNOPSIS
    # Libraryの第５カラムでソートする

    $script:library.column('5').sort('Ascending')
}
function ttcmd_library_sort_asc_6thcolumn{
    #.SYNOPSIS
    # Libraryの第６カラムでソートする

    $script:library.column('6').sort('Ascending')
}

function ttcmd_library_select_memo{
    #.SYNOPSIS
    # LibraryでMemoを選択する

    $script:library.cursor( 'Memo' )
}
function ttcmd_library_select_link{
    #.SYNOPSIS
    # LibraryでLinkを選択する

    $script:library.cursor( 'Link' )
}
function ttcmd_library_select_search{
    #.SYNOPSIS
    # LibraryでSearchを選択する

    $script:library.cursor( 'Search' )
}




#endregion###############################################################################################################

#region　Index
#########################################################################################################################
function ttcmd_index_copy_item{
    #.SYNOPSIS
    # 選択アイテムをコピーする(index）

    $lib, $index = $script:index.selected_index()
    [TTClipboard]::Copy( $script:shelf.item( $index ) )
}
function ttcmd_index_turn_rev{
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
function ttcmd_index_turn_norm{
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
function ttcmd_index_delete_selected{
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
function ttcmd_index_selected_tocurrenteditor{
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

function ttcmd_index_invoke_item{
    #.SYNOPSIS
    # 選択アイテムを実行する(index)

    $library, $index = $script:index.selected_index()
    $script:index.item( $index ).DoAction()
}
function ttcmd_index_activate_item{
    #.SYNOPSIS
    # 選択アイテムを実行する(index)

    $library, $index = $script:index.selected_index()
    $script:index.item( $index ).SelectActions()

}
function ttcmd_index_delete_selected{
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


function ttcmd_index_selected_toeditor1{
    #.SYNOPSIS
    # Indexの選択メモをエディタ１に読み込む

    ( $library, $index ) = $script:index.selected_index()
    switch( $library ){
        'Memo' { 
            $script:desk.tool( 'Editor1' ).load( $index )
        }
    }
}
function ttcmd_index_selected_toeditor2{
    #.SYNOPSIS
    # Indexの選択メモをエディタ２に読み込む

    ( $library, $index ) = $script:index.selected_index()
    switch( $library ){
        'Memo' { 
            $script:desk.tool( 'Editor2' ).load( $index )
        }
    }
}
function ttcmd_index_selected_toeditor3{
    #.SYNOPSIS
    # Indexの選択メモをエディタ３に読み込む

    ( $library, $index ) = $script:index.selected_index()
    switch( $library ){
        'Memo' { 
            $script:desk.tool( 'Editor3' ).load( $index )
        }
    }
}

function ttcmd_index_move_up{
    #.SYNOPSIS
    # Indexのカーソルを上に移動

    $script:index.cursor('up')
}
function ttcmd_index_move_down{
    #.SYNOPSIS
    # Indexのカーソルを下に移動

    $script:index.cursor('down')
}
function ttcmd_index_move_first{
    #.SYNOPSIS
    # Indexのカーソルを先頭に移動

    $script:index.cursor('first')
}
function ttcmd_index_move_last{
    #.SYNOPSIS
    # Indexのカーソルを末尾に移動

    $script:index.cursor('last')
}
function ttcmd_index_filter_clear{
    #.SYNOPSIS
    # Indexの検索キーワードを消去する

    $script:index.nosearch()
}
function ttcmd_index_sort_dsc_1stcolumn{
    #.SYNOPSIS
    # Indexの第１カラムでソートする

    $script:index.column('1').sort('Descending')
}
function ttcmd_index_sort_dsc_2ndcolumn{
    #.SYNOPSIS
    # Indexの第２カラムでソートする

    $script:index.column('2').sort('Descending')
}
function ttcmd_index_sort_dsc_3rdcolumn{
    #.SYNOPSIS
    # Indexの第３カラムでソートする

    $script:index.column('3').sort('Descending')
}
function ttcmd_index_sort_dsc_4thcolumn{
    #.SYNOPSIS
    # Indexの第３カラムでソートする

    $script:index.column('4').sort('Descending')
}
function ttcmd_index_sort_dsc_5thcolumn{
    #.SYNOPSIS
    # Indexの第５カラムでソートする

    $script:index.column('5').sort('Descending')
}
function ttcmd_index_sort_dsc_6thcolumn{
    #.SYNOPSIS
    # Indexの第６カラムでソートする

    $script:index.column('6').sort('Descending')
}
function ttcmd_index_sort_asc_1stcolumn{
    #.SYNOPSIS
    # Indexの第１カラムでソートする

    $script:index.column('1').sort('Ascending')
}
function ttcmd_index_sort_asc_2ndcolumn{
    #.SYNOPSIS
    # Indexの第２カラムでソートする

    $script:index.column('2').sort('Ascending')
}
function ttcmd_index_sort_asc_3rdcolumn{
    #.SYNOPSIS
    # Indexの第３カラムでソートする

    $script:index.column('3').sort('Ascending')
}
function ttcmd_index_sort_asc_4thcolumn{
    #.SYNOPSIS
    # Indexの第３カラムでソートする

    $script:index.column('4').sort('Ascending')
}
function ttcmd_index_sort_asc_5thcolumn{
    #.SYNOPSIS
    # Indexの第５カラムでソートする

    $script:index.column('5').sort('Ascending')
}
function ttcmd_index_sort_asc_6thcolumn{
    #.SYNOPSIS
    # Indexの第６カラムでソートする

    $script:index.column('6').sort('Ascending')
}


#endregion###############################################################################################################

#region　Shelf 未
#########################################################################################################################
function ttcmd_shelf_copy_item{
    #.SYNOPSIS
    # 選択アイテムをコピーする(shelf）

    $lib, $index = $script:shelf.selected_index()
    [TTClipboard]::Copy( $script:shelf.item( $index ) )
}

function ttcmd_shelf_invoke_item{
    #.SYNOPSIS
    # 選択アイテムを実行する（shelf）

    $library, $index = $script:shelf.selected_index()
    $script:shelf.item( $index ).DoAction()
}
function ttcmd_shelf_activate_item{
    #.SYNOPSIS
    # 選択アイテムを実行する（shelf）

    $library, $index = $script:shelf.selected_index()
    $script:shelf.item( $index ).SelectActions()
}
function ttcmd_shelf_delete_selected{
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

function ttcmd_shelf_selected_tocurrenteditor{
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



function ttcmd_shelf_selected_toeditor3{
    #.SYNOPSIS
    # 選択メモをエディタ３に読み込む

    ( $library, $index ) = $script:shelf.selected_index()
    switch( $library ){
        'Memo' {
            $script:desk.tool( 'Editor3' ).load( $index )
        }
    }
}
function ttcmd_shelf_selected_toeditor2{
    #.SYNOPSIS
    # 選択メモをエディタ２に読み込む

    ( $library, $index ) = $script:shelf.selected_index()
    switch( $library ){
        'Memo' {
            $script:desk.tool( 'Editor2' ).load( $index )
        }
    }
}
function ttcmd_shelf_selected_toeditor1{
    #.SYNOPSIS
    # 選択メモをエディタ１に読み込む

    ( $library, $index ) = $script:shelf.selected_index()
    switch( $library ){
        'Memo' { 
            $script:desk.tool( 'Editor1' ).load( $index )
        }
    }
}
function ttcmd_shelf_focus_menu{
    #.SYNOPSIS
    # shelfのメニューにフォーカスする

    $script:shelf._sorting.Items[0].focus()
}


function ttcmd_shelf_turn_norm{
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
function ttcmd_shelf_turn_rev{
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
function ttcmd_shelf_move_up{   
    #.SYNOPSIS
    # Shelfのカーソルを上に移動

    $script:shelf.cursor('up')
}
function ttcmd_shelf_move_down{   
    #.SYNOPSIS
    # Shelfのカーソルを下に移動

    $script:shelf.cursor('down')
}
function ttcmd_shelf_move_first{   
    #.SYNOPSIS
    # Shelfのカーソルを先頭に移動

    $script:shelf.cursor('first')
}
function ttcmd_shelf_move_last{   
    #.SYNOPSIS
    # Shelfのカーソルを最後に移動

    $script:shelf.cursor('last')
}
function ttcmd_shelf_clear{
    #.SYNOPSIS
    # Shelfのフィルターをクリアする

    $script:shelf.nosearch()
}
function ttcmd_shelf_sort_dsc_1stcolumn{
    #.SYNOPSIS
    # Shelfの第１カラムでソートする

    $script:shelf.column('1').sort('Descending')
}
function ttcmd_shelf_sort_dsc_2ndcolumn{
    #.SYNOPSIS
    # Shelfの第２カラムでソートする

    $script:shelf.column('2').sort('Descending')
}
function ttcmd_shelf_sort_dsc_3rdcolumn{
    #.SYNOPSIS
    # Shelfの第３カラムでソートする

    $script:shelf.column('3').sort('Descending')
}
function ttcmd_shelf_sort_dsc_4thcolumn{
    #.SYNOPSIS
    # Shelfの第４カラムでソートする

    $script:shelf.column('4').sort('Descending')
}
function ttcmd_shelf_sort_dsc_5thcolumn{
    #.SYNOPSIS
    # Shelfの第５カラムでソートする

    $script:shelf.column('5').sort('Descending')
}
function ttcmd_shelf_sort_dsc_6thcolumn{
    #.SYNOPSIS
    # Shelfの第６カラムでソートする

    $script:shelf.column('6').sort('Descending')
}
function ttcmd_shelf_sort_asc_1stcolumn{
    #.SYNOPSIS
    # Shelfの第１カラムでソートする

    $script:shelf.column('1').sort('Ascending')
}
function ttcmd_shelf_sort_asc_2ndcolumn{
    #.SYNOPSIS
    # Shelfの第２カラムでソートする

    $script:shelf.column('2').sort('Ascending')
}
function ttcmd_shelf_sort_asc_3rdcolumn{
    #.SYNOPSIS
    # Shelfの第３カラムでソートする

    $script:shelf.column('3').sort('Ascending')
}
function ttcmd_shelf_sort_asc_4thcolumn{
    #.SYNOPSIS
    # Shelfの第４カラムでソートする

    $script:shelf.column('4').sort('Ascending')
}
function ttcmd_shelf_sort_asc_5thcolumn{
    #.SYNOPSIS
    # Shelfの第５カラムでソートする

    $script:shelf.column('5').sort('Ascending')
}
function ttcmd_shelf_sort_asc_6thcolumn{
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
function ttcmd_desk_borderstyle_turn_norm{
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
function ttcmd_desk_borderstyle_turn_rev{
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
function ttcmd_desk_borderstyle_work123{
    #.SYNOPSIS
    # ３つのWorkplaceを表示

    $script:app.border( 'Layout.Work1.Width', "50" )
    $script:app.border( 'Layout.Work1.Height', "70" )
    $script:app._set( 'Layout.Desk', "Work1,Work2,Work3")
}
function ttcmd_desk_borderstyle_work12{
    #.SYNOPSIS
    # 横２つのWorkplaceを表示

    $script:app.border( 'Layout.Work1.Width', "50" )
    $script:app.border( 'Layout.Work1.Height', "100" )
    $script:app._set( 'Layout.Desk', "Work1,Work2")
}
function ttcmd_desk_borderstyle_work13{
    #.SYNOPSIS
    # 縦２つのWorkplaceを表示

    $script:app.border( 'Layout.Work1.Width', "100" )
    $script:app.border( 'Layout.Work1.Height', "50" )
    $script:app._set( 'Layout.Desk', "Work1,Work3")
}

function ttcmd_deskwork_turn_norm{
    #.SYNOPSIS
    # Work表示を切り替える

    switch( $script:app._get( 'Application.Focused' ) ){
        'Work1' { ttcmd_desk_borderstyle_work2 }
        'Work2' { ttcmd_desk_borderstyle_work3 }
        'Work3' { ttcmd_desk_borderstyle_work1 }
    }
}
function ttcmd_deskwork_turn_rev{
    #.SYNOPSIS
    # Work表示を切り替える（逆順）

    switch( $script:app._get( 'Application.Focused' ) ){
        'Work1' { ttcmd_desk_borderstyle_work3 }
        'Work2' { ttcmd_desk_borderstyle_work1 }
        'Work3' { ttcmd_desk_borderstyle_work2 }
    }
}
function ttcmd_desk_borderstyle_work1{
    #.SYNOPSIS
    # Work1を表示

    $script:app.border( 'Layout.Work1.Width', "100" )
    $script:app.border( 'Layout.Work1.Height', "100" )
    $script:desk.focus( 'Work1' )
    $script:app._set( 'Layout.Desk', "Work1")
}
function ttcmd_desk_borderstyle_work2{
    #.SYNOPSIS
    # Work2を表示

    $script:app.border( 'Layout.Work1.Width', "0" )
    $script:app.border( 'Layout.Work1.Height', "100" )
    $script:desk.focus( 'Work2' )
    $script:app._set( 'Layout.Desk', "Work2")
}
function ttcmd_desk_borderstyle_work3{
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
function ttcmd_desk_focus_menu{
    #.SYNOPSIS
    # deskのメニューにフォーカスする

    $script:desk._sorting.Items[0].focus()
}
function ttcmd_desk_works_focus_turn_norm{
    #.SYNOPSIS
    # Workのフォーカスを切り替える

    switch( $true ){
        $script:app._in( 'Application.Focused', $script:Work1IDs ) { $script:desk.focus( 'Work2' ); break }
        $script:app._in( 'Application.Focused', $script:Work2IDs ) { $script:desk.focus( 'Work3' ); break }
        default { $script:desk.focus( 'Work1' ) }
    }
}
function ttcmd_desk_works_focus_turn_rev{
    #.SYNOPSIS
    # Workのフォーカスを切り替える（逆方向）

    switch( $true ){
        $script:app._in( 'Application.Focused', $script:Work3IDs ) { $script:desk.focus( 'Work2' ); break }
        $script:app._in( 'Application.Focused', $script:Work1IDs ) { $script:desk.focus( 'Work3' ); break }
        default { $script:desk.focus( 'Work1' ) }
    }
}
function ttcmd_desk_works_focus_work1{
    #.SYNOPSIS
    # Work1にフォーカスする

    if( $script:app.isvisible( 'Work1' ) ){ 
        $script:desk.focus( 'Work1' )
    }else{
        ttcmd_desk_borderstyle_work1
    }
}
function ttcmd_desk_works_focus_work2{
    #.SYNOPSIS
    # Work2にフォーカスする

    if( $script:app.isvisible( 'Work2' ) ){ 
        $script:desk.focus( 'Work2' )
    }else{
        ttcmd_desk_borderstyle_work2
    }
}
function ttcmd_desk_works_focus_work3{
    #.SYNOPSIS
    # Work3にフォーカスする

    if( $script:app.isvisible( 'Work3' ) ){ 
        $script:desk.focus( 'Work3' )
    }else{
        ttcmd_desk_borderstyle_work3
    }
}
function ttcmd_desk_clear{
    #.SYNOPSIS
    # Shelfのフィルターをクリアする

    $script:desk.nosearch()
}

#endregion'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''


#endregion###############################################################################################################

#region　Config
#########################################################################################################################
function ttcmd_application_config_editor_wordwrap_on(){
    #.SYNOPSIS
    # カレントエディタのワードラップをON

    $tool = $script:app._get( "Desk.CurrentEditor" )
    $script:app._set( "$tool.WordWrap", 'true' )
}
function ttcmd_application_config_editor_wordwrap_off(){
    #.SYNOPSIS
    # カレントエディタのワードラップをOFF

    $tool = $script:app._get( "Desk.CurrentEditor" )
    $script:app._set( "$tool.WordWrap", 'false' )
}
function ttcmd_application_config_editor_wordwrap_toggle(){
    #.SYNOPSIS
    # カレントエディタのワードラップを切り替える

    $tool = $script:app._get( "Desk.CurrentEditor" )
    $script:app._set( "$tool.WordWrap", 'toggle' )
}
function ttcmd_application_config_editor_staycursor_on(){
    #.SYNOPSIS
    # カレントエディタのカーソル固定モードをON

    $tool = $script:app._get( "Desk.CurrentEditor" )
    $script:app._set( "$tool.StayCursor", 'true' )
}
function ttcmd_application_config_editor_staycursor_off(){
    #.SYNOPSIS
    # カレントエディタのカーソル固定モードをOFF

    $tool = $script:app._get( "Desk.CurrentEditor" )
    $script:app._set( "$tool.StayCursor", 'false' )
}
function ttcmd_application_config_editor_staycursor_toggle(){
    #.SYNOPSIS
    # カレントエディタのカーソル固定モードを切り替える

    $tool = $script:app._get( "Desk.CurrentEditor" )
    $script:app._set( "$tool.StayCursor", 'toggle' )
}
function ttcmd_application_config_app_keydown_message_on(){
    #.SYNOPSIS
    # アプリのキーダウンメッセージをON

    $script:app._set( "Config.KeyDownMessage", "True" )
}
function ttcmd_application_config_app_keydown_message_off(){
    #.SYNOPSIS
    # アプリのキーダウンメッセージをOFF

    $script:app._set( "Config.KeyDownMessage", "False" )
}
function ttcmd_application_config_app_taskexpired_message_on(){
    #.SYNOPSIS
    # アプリのタスク終了メッセージをON

    $script:app._set( "Config.TaskExpiredMessage", "True" )
}
function ttcmd_application_config_app_taskexpired_message_off(){
    #.SYNOPSIS
    # アプリのタスク終了メッセージをOFF

    $script:app._set( "Config.TaskExpiredMessage", "False" )
}
function ttcmd_application_config_app_memosaved_message_on(){
    #.SYNOPSIS
    # メモのセーブメッセージをON

    $script:app._set( "Config.MemoSavedMessage", "True" )
}
function ttcmd_application_config_app_memosaved_message_off(){
    #.SYNOPSIS
    # メモのセーブメッセージをOFF

    $script:app._set( "Config.MemoSavedMessage", "False" )
}
function ttcmd_application_config_app_cachesaved_message_on(){
    #.SYNOPSIS
    # キャッシュのセーブメッセージをON

    $script:app._set( "Config.CacheSavedMessage", "True" )
}
function ttcmd_application_config_app_cachesaved_message_off(){
    #.SYNOPSIS
    # キャッシュのセーブメッセージをOFF

    $script:app._set( "Config.CacheMemoSavedMessage", "False" )
}

#endregion###############################################################################################################

#region　Editor Edit
#########################################################################################################################
function ttcmd_editor_history_previous_tocurrenteditor{
    #.SYNOPSIS
    # 前のファイルを開く
    
    $current = $script:app._get( 'Desk.CurrentEditor' )
    $script:desk.tool( 'Editor' ).load( "previous" ).focus( $current )
}
function ttcmd_editor_history_next_tocurrenteditor{
    #.SYNOPSIS
    # 先のファイルを開く
    
    $current = $script:app._get( 'Desk.CurrentEditor' )
    $script:desk.tool( 'Editor' ).load( "next" ).focus( $current )
}
function ttcmd_desk_works_focus_current_norm{
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
function ttcmd_desk_works_focus_current_rev{
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
function ttcmd_editor_focus_currenteditor{
    #.SYNOPSIS
    # カレントエディタにフォーカスする

    $current = $script:app._get( 'Desk.CurrentEditor' )
    $script:desk.focus( $current )
}
function ttcmd_editor_save{
    #.SYNOPSIS
    # メモを強制保存する

    $tool = $script:app._get( "Desk.CurrentEditor" )
    $script:desk.tool( $tool ).modified( $true ).save()

}
function ttcmd_editor_new_tocurrenteditor{
    #.SYNOPSIS
    # 新規メモを作成し、カレントエディタに読み込む

    $index = $script:desk.create_memo()
    $tool = $script:app._get( "Desk.CurrentEditor" )
    $script:shelf.refresh()
    $script:desk.tool( $tool ).load( $index )
}
function ttcmd_editor_scroll_tonewline(){
    #.SYNOPSIS
    # 改行する

    $script:desk.tool('Editor').scroll_to( 'newline' )
}
function ttcmd_editor_scroll_toprevline{
    #.SYNOPSIS
    # 画面を上げる

    $script:desk.tool('Editor').scroll_to( 'prevline' )
}
function ttcmd_editor_scroll_tonextline{
    #.SYNOPSIS
    # 画面を下げる

    $script:desk.tool('Editor').scroll_to( 'nextline' )
}
function ttcmd_editor_select_all{
    #.SYNOPSIS
    # 全行選択する

    $script:desk.tool('Editor').select_to( 'all', '' )
}
function ttcmd_editor_select_tolineend{
    #.SYNOPSIS
    # カーソルから行末までを選択する

    $script:desk.tool('Editor').select_to( 'lineend+', '' )
}
function ttcmd_editor_select_tolinestart{
    #.SYNOPSIS
    # カーソルから行頭までを選択する

    $script:desk.tool('Editor').select_to( 'linestart', '' )
}
function ttcmd_editor_select_torightchar{
    #.SYNOPSIS
    # カーソルの右1文字を選択する

    $script:desk.tool('Editor').select_to( 'rightchar', '' )
}
function ttcmd_editor_select_toleftchar{
    #.SYNOPSIS
    # カーソルの左1文字を選択する

    $script:desk.tool('Editor').select_to( 'leftchar', '' )
}
function ttcmd_editor_select_tonextline{
    #.SYNOPSIS
    # カーソルの次行まで選択する

    $script:desk.tool('Editor').select_to( 'nextline', '' )
}
function ttcmd_editor_select_toprevline{
    #.SYNOPSIS
    # カーソルの前行まで選択する

    $script:desk.tool('Editor').select_to( 'prevline', '' )
}
function ttcmd_editor_delete_tolineend{
    #.SYNOPSIS
    # カーソルから行末までを削除する

    $script:desk.tool('Editor').select_to( 'lineend', 'cut' )
}
function ttcmd_editor_delete_tolinestart{
    #.SYNOPSIS
    # カーソルから行頭までを削除する

    $script:desk.tool('Editor').select_to( 'linestart', 'cut' )
}
function ttcmd_editor_move_tolineend{
    #.SYNOPSIS
    # カーソルを行末/文末へ移動する

    $script:desk.tool( 'Editor' ).move_to( 'lineend+' )
}
function ttcmd_editor_move_tolinestart{
    #.SYNOPSIS
    # カーソルを行頭/文頭へ移動する

    $script:desk.tool( 'Editor' ).move_to( 'linestart+' )
}
function ttcmd_editor_move_toprevline{
    #.SYNOPSIS
    # カーソルを前行へ移動する

    $script:desk.tool( 'Editor' ).move_to( 'prevline' )
}
function ttcmd_editor_move_tonextline{
    #.SYNOPSIS
    # カーソルを次行へ移動する

    $script:desk.tool( 'Editor' ).move_to( 'nextline' )
}
function ttcmd_editor_move_rightchar{
    #.SYNOPSIS
    # カーソルを右へ移動する

    $script:desk.tool( 'Editor' ).move_to( 'rightchar' )
}
function ttcmd_editor_move_leftchar{
    #.SYNOPSIS
    # カーソルを左へ移動する

    $script:desk.tool( 'Editor' ).move_to( 'leftchar' )
}
function ttcmd_editor_move_toprevkeyword{
    #.SYNOPSIS
    # カーソルを前のキーワードに移動する

    if( $false -eq $script:desk.tool( 'Editor' ).move_to( 'prevkeyword' ) ){
        ttcmd_editor_scroll_tonextline    
    }
}
function ttcmd_editor_move_tonextkeyword{
    #.SYNOPSIS
    # カーソルを次のキーワードに移動する

    if( $false -eq $script:desk.tool( 'Editor' ).move_to( 'nextkeyword' ) ){
        ttcmd_editor_scroll_roprevline
    }
}
function ttcmd_editor_edit_delete{
    #.SYNOPSIS
    # カーソルの右を削除する

    $script:desk.tool( 'Editor' ).edit( 'delete' )
}
function ttcmd_editor_edit_backspace{
    #.SYNOPSIS
    # カーソルの左を削除する

    $script:desk.tool( 'Editor' ).edit( 'backspace' )
}
function ttcmd_editor_edit_insert_clipboard( $modkey, $key ){
    #.SYNOPSIS
    # クリップボードの内容を貼り付ける

    [TTClipboard]::PasteTo( $script:DocMan.current_editor, $modkey, $key )
}
function ttcmd_editor_edit_insert_date( $mod, $key ){
    #.SYNOPSIS
    # 日付タグを挿入する

    # scan & select 
    $editor = $script:DocMan.current_editor
    $script:datetag.scan( $editor )
    $item = ShowPopupMenu -items $script:datetag.tags() -modkey $mod -key $key -title "Date" -editor $editor

    # insert tag 
    if( $null -ne $item ){
        if( $script:datetag.length -eq 0 ){
            $editor.Document.Insert( $editor.CaretOffset, $item )    
        }else{
            $editor.Document.Remove( $script:datetag.offset, $script:datetag.length )
            $editor.Document.Insert( $script:datetag.offset, $item )
        }
    }

    $script:datetag.reset()
}
function ttcmd_editor_edit_turn_bullet_norm{
    #.SYNOPSIS
    # カーソル位置にアイテムヘッダーを挿入する

    $script:desk.tool( 'Editor' ).edit('bullet_nor')
}
function ttcmd_editor_edit_turn_bullet_rev{
    #.SYNOPSIS
    # カーソル位置にアイテムヘッダーを挿入する

    $script:desk.tool( 'Editor' ).edit('bullet_rev')
}
function ttcmd_editor_outline_insert_section{
    #.SYNOPSIS
    # カーソル位置にセクションを挿入する

    $script:desk.tool( 'Editor' ).edit( 'section' )
}



#endregion###############################################################################################################

#region　Editor Outline
#########################################################################################################################
function ttcmd_editor_outline_moveto_next{
    #.SYNOPSIS
    # カーソルを次ののセクションに移動する

    $script:desk.tool( 'Editor' ).move_to( 'nextnode' )
}
function ttcmd_editor_outline_moveto_previous{
    #.SYNOPSIS
    # カーソルを前のセクションへ移動する

    $script:desk.tool( 'Editor' ).move_to( 'prevnode' )
}
function ttcmd_editor_outline_fold_section{

    #.SYNOPSIS
    # セクションを折り畳む
    
    $script:desk.tool( 'Editor' ).node_to( 'close' )
}
function ttcmd_editor_outline_collapse_section{
    #.SYNOPSIS
    # セクションを展開する

    $script:desk.tool( 'Editor' ).node_to( 'open' )
}
function ttcmd_editor_outline_fold_allsection{
    #.SYNOPSIS
    # 全セクションを折り畳む

    $script:desk.tool( 'Editor' ).node_to( 'close_all' )
}
function ttcmd_editor_outline_collapse_allsection{
    #.SYNOPSIS
    # 全セクションを展開する

    $script:desk.tool( 'Editor' ).node_to( 'open_all' )
}

#endregion###############################################################################################################

#region　Editor Tag
#########################################################################################################################
function ttcmd_editor_change_focus( $mod, $key ){
    #.SYNOPSIS
    # エディターのフォーカスを変更する

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
function ttcmd_editor_tag_invoke(){
    #.SYNOPSIS
    # タグを実行する

    [TTTagAction]::New( $script:DocMan.current_editor ).DoAction()
}

function ttcmd_editor_copy_tag_atcursor{
    #.SYNOPSIS
    # カレントエディタカーソル位置のタグをコピーする

    $editor  = $script:DocMan.current_editor
    $memo    = $script:TTMemos.GetChild( $script:DocMan.config.($editor.Name).index )
    $posinfo = $script:DocMan.Tool('Editor').AtCursor( 'posinfo' )[0]
    [TTClipboard]::Copy( $memo, $posinfo )
}

#endregion###############################################################################################################

#  ダブルクリックでメモを選んだ際は、他Editorに読込済みであれば、Editor.Focusで対応すること。








