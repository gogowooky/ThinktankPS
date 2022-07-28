


#region　Model Actions
#########################################################################################################################
function ttact_open_memo( $ttobj, $ttobjs ){
    #.SYNOPSIS
    # メモを開く
    
    $global:appcon.tools.editor.load( $ttobj.MemoID )
}
function ttact_discard_resources( $ttobj, $ttobjs ){
    #.SYNOPSIS
    # 関連リソースを開放する

    $ttobjs.foreach{ $_.$ttobj.DiscardResources() }
    
}
function ttact_select_file( $ttobj, $ttobjs ){
    #.SYNOPSIS
    # 関連ファイルをエクスプローラーで選択する

    $ttobjs.foreach{ Start-Process "explorer.exe" "/select,`"$($_.GetFilename())`"" }
}
function ttact_copy_object( $ttobj, $ttobjs ){
    #.SYNOPSIS
    # TTObjectをコピーする

    [TTClipboard]::Copy( [object[]]$ttobjs )

}


function ttact_noop( $ttobj, $ttobjs ){
    #.SYNOPSIS
    # 何もしない

    [TTTool]::debug_message( $ttobj.GetDictionary().Index, "ttact_noop" )

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

#endregion###############################################################################################################








#region　旧Application
#########################################################################################################################

function ttcmd_application_developping_extract_keyword_containing_memo( $source, $mod, $key ){
    #.SYNOPSIS
    # キーワードを含むメモのライブラリを作成する

    $script:desk.create_cache( "" )
}

function ttcmd_application_textsearch( $source, $mod, $key ){
    #.SYNOPSIS
    # 全文検索を実行する

    $keyword = $script:app.keyword()

}

function ttcmd_index_copy_item( $source, $mod, $key ){
    #.SYNOPSIS
    # 選択アイテムをコピーする(index）

    $lib, $index = $script:index.selected_index()
    [TTClipboard]::Copy( $script:shelf.item( $index ) )
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
function ttcmd_shelf_copy_item( $source, $mod, $key ){
    #.SYNOPSIS
    # 選択アイテムをコピーする(shelf）

    $lib, $index = $script:shelf.selected_index()
    [TTClipboard]::Copy( $script:shelf.item( $index ) )
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


function ttcmd_shelf_focus_menu( $source, $mod, $key ){
    #.SYNOPSIS
    # shelfのメニューにフォーカスする

    $script:shelf._sorting.Items[0].focus()
}




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


function ttcmd_editor_copy_tag_atcursor( $source, $mod, $key ){
    #.SYNOPSIS
    # カレントエディタカーソル位置のタグをコピーする

    $editor  = $script:DocMan.current_editor
    $memo    = $global:TTMemos.GetChild( $script:DocMan.config.($editor.Name).index )
    $posinfo = $script:DocMan.Tool('Editor').AtCursor( 'posinfo' )[0]
    [TTClipboard]::Copy( $memo, $posinfo )
}


#  ダブルクリックでメモを選んだ際は、他Editorに読込済みであれば、Editor.Focusで対応すること。








