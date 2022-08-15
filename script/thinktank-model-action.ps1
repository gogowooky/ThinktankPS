

#region Memo
#########################################################################################################################
[TTMemo]::Action =                  'ttact_open_memo'
[TTMemo]::ActionDiscardResources =  'ttact_discard_resources'
[TTMemo]::ActionOpen =              'ttact_open_memo'
[TTMemo]::ActionDataLocation =      'ttact_select_file'
[TTMemo]::ActionToClipboard =       'ttact_copy_object'

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

#endregion###############################################################################################################

#region Collection
#########################################################################################################################
[TTCollection]::Action =                    'ttact_display_in_shelf'
[TTCollection]::ActionDiscardResources =    'ttact_discard_resources'
[TTCollection]::ActionToShelf =             'ttact_display_in_shelf'
[TTCollection]::ActionToIndex =             'ttact_display_in_index'
[TTCollection]::ActionToCabinet =           'ttact_display_in_cabinet'
[TTCollection]::ActionDataLocaiton =        'ttact_select_file'

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

#endregion###############################################################################################################

#region Config
#########################################################################################################################
[TTConfig]::Action =                    'ttact_noop'
[TTConfig]::ActionDiscardResources =    'ttact_noop'
[TTConfig]::ActionDataLocaiton =        'ttact_noop'

function ttact_noop( $ttobj, $ttobjs ){
    #.SYNOPSIS
    # 何もしない

    [TTTool]::debug_message( $ttobj.GetDictionary().Index, "ttact_noop" )

}

#endregion###############################################################################################################

#region State
#########################################################################################################################
[TTState]::Action =                     'ttact_noop'
[TTState]::ActionDiscardResources =     'ttact_noop'
[TTState]::ActionFilter =               'ttact_noop'
#endregion###############################################################################################################

#region Command
#########################################################################################################################
[TTCommand]::Action =                   'ttact_noop'
[TTCommand]::ActionDiscardResources =   'ttact_noop'
[TTCommand]::ActionInvokeCommand =      'ttact_noop'
#endregion###############################################################################################################

#region SearchMethod
#########################################################################################################################
[TTSearchMethod]::Action =                  'ttact_noop'
[TTSearchMethod]::ActionDiscardResources =  'ttact_noop'
[TTSearchMethod]::ActionDataLocation =      'ttact_noop'
[TTSearchMethod]::ActionToEditor =          'ttact_noop'
[TTSearchMethod]::ActionOpenUrl =           'ttact_open_url'
[TTSearchMethod]::ActionOpenUrlEx =         'ttact_open_url_ex'
[TTSearchMethod]::ActionToClipboard =       'ttact_copy_url_toclipboard'

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

#region ExternalLink
#########################################################################################################################
[TTExternalLink]::Action =                  'ttact_noop'
[TTExternalLink]::ActionDiscardResources =  'ttact_noop'
[TTExternalLink]::ActionDataLocation =      'ttact_noop'
[TTExternalLink]::ActionOpenUrl =           'ttact_open_url'
[TTExternalLink]::ActionOpenUrlEx =         'ttact_open_url_ex'
[TTExternalLink]::ActionToClipboard =       'ttact_copy_url_toclipboard'
#endregion###############################################################################################################

#region Editing
#########################################################################################################################
[TTEditing]::Action =                  'ttact_open_memo'
[TTEditing]::ActionDiscardResources =  'ttact_discard_resources'
[TTEditing]::ActionDataLocation =      'ttact_select_file'
#endregion###############################################################################################################


