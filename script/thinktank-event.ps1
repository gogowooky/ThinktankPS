





#region Window event
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ScriptBlock] $script:Window_PreviewKeyDown = {
    $skey = $args[1].SystemKey
    $key  = $args[1].Key
    $mod  = $args[1].KeyboardDevice.Modifiers

    if( $script:app._istrue( "Config.KeyDownMessage" ) ){
        Write-Host "Window_PreviewKeyDown [$mod], key:$key, sykey:$skey, susmodmode:$([TTSusModMode]::Name)"
    }

    switch( $mod ){
        'None' { 
            switch( $key ){
                'Escape' { ttcmd_application_window_quit; return }
            }
        }
    }

    :Handled switch( [TTSusModMode]::Name ){
        "normal mode" {
            switch( $mod ){
                'Alt' { 
                    switch( $skey ){
                        'L' { ttcmd_library_turn_norm; break Handled }
                        'I' { ttcmd_index_turn_norm; break Handled }
                        'S' { ttcmd_shelf_turn_norm; break Handled }
                        'D' { ttcmd_desk_borderstyle_turn_norm; break Handled }
                        'W' { ttcmd_application_borderstyle_turn_norm; break Handled }
                        default { return }
                    }
                }
                'Alt, Shift' { 
                    switch( $skey ){ 
                        'L' { ttcmd_library_turn_rev; break Handled }
                        'I' { ttcmd_index_turn_rev; break Handled }
                        'S' { ttcmd_shelf_turn_rev; break Handled }
                        'D' { ttcmd_desk_borderstyle_turn_rev; break Handled }
                        'W' { ttcmd_application_borderstyle_turn_rev; break Handled }
                        default { return }
                    }
                }
                'Control' { 
                    switch( $key ){
                        'Oem1'  { ttcmd_application_commands_execute; break Handled } # [*:]
                        'D1'    { ttcmd_desk_works_focus_work1; break Handled }
                        'D2'    { ttcmd_desk_works_focus_work2; break Handled }
                        'D3'    { ttcmd_desk_works_focus_work3; break Handled }
                        'Tab'   { ttcmd_desk_works_focus_current_norm; break Handled }
                        default { return }
                    }
                }
                'Control, Shift' {
                    switch( $key ){
                        'Tab'   { ttcmd_desk_works_focus_current_rev; break Handled }
                        default { return }
                    }
                }
            }
            return
        }

        "style mode" {
            switch( $mod ){
                'Alt' {
                    return
                }
                'Alt, Shift' {
                    return
                }
            }
            $args[1].Handled = $True; break
        }

        default { return } 
    }

    $args[1].Handled = $True; return

}
[ScriptBlock] $script:Window_Loaded = {

    $script:app.initialize()
    $script:index.initialize( "Memo" )
    $script:library.initialize()
    $script:shelf.initialize( "Memo" )
    $script:library.mark_column()

    $script:desk.initialize()

    $script:library.cursor( "Memo" )

    $script:desk.tool( 'Editor1' ).load( 'thinktank' )
    $script:desk.tool( 'Editor2' ).load( 'thinktank' )
    $script:desk.tool( 'Editor3' ).load( 'thinktank' )
    $script:shelf.column('UpdateDate').sort('Descending').cursor( "thinktank" )

    ttcmd_application_borderstyle_all
    ttcmd_desk_borderstyle_work1

    $script:desk.focus( 'Work1' )
    $script:shelf.refresh()
    $script:index.refresh()

    $script:app.caption( "Thinktank ver." + $script:app._config( "Application.Version" ) )
    
}
[ScriptBlock] $script:Window_PreviewKeyUp = {
    if( [TTSusModMode]::Check( $args[1].Key ) ){ $args[1].Handled = $True }
}

#endregion:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

#region　Library event
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ScriptBlock] $script:LibraryKeyword_PreviewKeyDown = {
    $skey = $args[1].SystemKey
    $key  = $args[1].Key
    $mod  = $args[1].KeyboardDevice.Modifiers

    :Handled switch( $mod ){
        'None' { 
            switch( $key ){
                'Return'{ ttcmd_library_invoke_item; break Handled }
                'Up'    { ttcmd_library_move_up; break Handled }
                'Down'  { ttcmd_library_move_down; break Handled }
                'F1'    { ttcmd_library_sort_dsc_1stcolumn; break Handled }
                'F2'    { ttcmd_library_sort_dsc_2ndcolumn; break Handled }
                'F3'    { ttcmd_library_sort_dsc_3rdcolumn; break Handled }
                'F4'    { ttcmd_library_sort_dsc_4thcolumn; break Handled }
                'F5'    { ttcmd_library_sort_dsc_5thcolumn; break Handled }
                'F6'    { ttcmd_library_sort_dsc_6thcolumn; break Handled }
                default { return }
            }
        }
        'Shift' { 
            switch( $key ){
                'Return'{ ttcmd_library_activate_item; break Handled }
                'Up'    { ttcmd_library_move_first; break Handled }
                'Down'  { ttcmd_library_move_last; break Handled }
                'F1'    { ttcmd_library_sort_asc_1stcolumn; break Handled }
                'F2'    { ttcmd_library_sort_asc_2ndcolumn; break Handled }
                'F3'    { ttcmd_library_sort_asc_3rdcolumn; break Handled }
                'F4'    { ttcmd_library_sort_asc_4thcolumn; break Handled }
                'F5'    { ttcmd_library_sort_asc_5thcolumn; break Handled }
                'F6'    { ttcmd_library_sort_asc_6thcolumn; break Handled }
                default { return }
            }
        }
        'Alt' {
            switch( $skey ){
                'Space' { ttcmd_library_invoke_item; break Handled }
                'P'     { ttcmd_library_move_up; break Handled }
                'N'     { ttcmd_library_move_down; break Handled }
                'C'     { ttcmd_library_filter_clear; break Handled }
                'Up'    { ttcmd_application_border_inguide_up; break Handled }
                'Down'  { ttcmd_application_border_inguide_down; break Handled }
                'Left'  { ttcmd_application_border_inwindow_left; break Handled }
                'Right' { ttcmd_application_border_inwindow_right; break Handled }
                default { return }
            }
        }
        'Alt, Shift' {
            switch( $skey ){
                'Space' { ttcmd_library_activate_item; break Handled }
                'P'     { ttcmd_library_move_first; break Handled }
                'N'     { ttcmd_library_move_last; break Handled }
                default { return }
            }
        }
        'Control' { 
            switch( $key ){
                'D'     { ttcmd_library_delete_selected; break Handled } 
                'M' { 
                    ttcmd_library_select_memo
                    ttcmd_library_invoke_item
                    break Handled
                } 
                'L' {
                    ttcmd_library_select_link
                    ttcmd_library_invoke_item
                    break Handled
                } 
                'S' { 
                    ttcmd_library_select_search
                    ttcmd_library_invoke_item
                    break Handled
                }
                default { return }
            }
        }
        'Control, Shift' {
            switch( $key ){
                'M' { 
                    ttcmd_library_select_memo
                    ttcmd_library_activate_item
                    break Handled
                } 
                'L' {
                    ttcmd_library_select_link
                    ttcmd_library_activate_item
                    break Handled
                } 
                'S' { 
                    ttcmd_library_select_search
                    ttcmd_library_activate_item
                    break Handled
                } 
                default { return }
            }

        }
        default { return } 
    }
    $args[1].Handled = $True

}
[ScriptBlock] $script:LibraryKeyword_TextChanged = {
    $script:app._set( 'Library.Keyword', $scrip:LibraryKeyword.Text )

    [TTTask]::Register( 
        "LibraryKeyword_TextChanged", 3, 0, { $script:library.search() }
    )
}
[ScriptBlock] $script:LibraryItems_SelectionChanged = {
    $name = $script:library._items.SelectedItem.Name
    $script:app._set( 'Library.Index', $name )
    $script:library.caption( $name )
}
[ScriptBlock] $script:LibraryItems_PreviewKeyDown = {
    $script:library.focus()
}

#endregion:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

#region　Index event
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ScriptBlock] $script:IndexKeyword_PreviewKeyDown = {
    $skey = $args[1].SystemKey
    $key  = $args[1].Key
    $mod  = $args[1].KeyboardDevice.Modifiers

    :Handled switch( $mod ){
        'None' {
            switch( $key ){
                'Return'{ ttcmd_index_invoke_item; break Handled }
                'Up'    { ttcmd_index_move_up; break Handled }
                'Down'  { ttcmd_index_move_down; break Handled }
                'F1'    { ttcmd_index_sort_dsc_1stcolumn; break Handled }
                'F2'    { ttcmd_index_sort_dsc_2ndcolumn; break Handled }
                'F3'    { ttcmd_index_sort_dsc_3rdcolumn; break Handled }
                'F4'    { ttcmd_index_sort_dsc_4thcoumn; break Handled }
                'F5'    { ttcmd_index_sort_dsc_5thcolumn; break Handled }
                'F6'    { ttcmd_index_sort_dsc_6thcolumn; break Handled }
                default { return }
            }
        }
        'Shift' { 
            switch( $key ){
                'Return'{ ttcmd_index_activate_item; break Handled }
                'Up'    { ttcmd_index_move_first; break Handled }
                'Down'  { ttcmd_index_move_last; break Handled }
                'F1'    { ttcmd_index_sort_asc_1stcolumn; break Handled }
                'F2'    { ttcmd_index_sort_asc_2ndcolumn; break Handled }
                'F3'    { ttcmd_index_sort_asc_3rdcolumn; break Handled }
                'F4'    { ttcmd_index_sort_asc_4thcoumn; break Handled }
                'F5'    { ttcmd_index_sort_asc_5thcolumn; break Handled }
                'F6'    { ttcmd_index_sort_asc_6thcolumn; break Handled }
                default { return }
            }
        }
        'Alt' {
            switch( $skey ){
                'Space' { ttcmd_index_invoke_item; break Handled }
                'P'     { ttcmd_index_move_up; break Handled }
                'N'     { ttcmd_index_move_down; break Handled }
                'C'     { ttcmd_index_filter_clear; break Handled }
                'Up'    { ttcmd_application_border_inguide_up; break Handled }
                'Down'  { ttcmd_application_border_inguide_down; break Handled }
                'Left'  { ttcmd_application_border_inwindow_left; break Handled }
                'Right' { ttcmd_application_border_inwindow_right; break Handled }
                'D1'    { ttcmd_shelf_selected_toeditor1; break Handled }
                'D2'    { ttcmd_shelf_selected_toeditor2; break Handled }
                'D3'    { ttcmd_shelf_selected_toeditor3; break Handled }
                default { return }
            }
        }
        'Alt, Shift' {
            switch( $skey ){
                'Space' { ttcmd_index_activate_item; break Handled }
                'P'     { ttcmd_index_move_first; break Handled }
                'N'     { ttcmd_index_move_last; break Handled }
                default { return }
            }
        }
        'Control' { 
            switch( $key ){
                'D'  { ttcmd_library_delete_selected; break Handled } 
                'C'  { ttcmd_shelf_copy_item; break Handled } 
                default { return }
            }
        }
        default { return } 
    }
    $args[1].Handled = $True
}
[ScriptBlock] $script:IndexKeyword_TextChanged = {
    $script:app._set( 'Index.Keyword', $script:index._keyword.Text )
    [TTTask]::Register( 
        "IndexKeyword_TextChanged", 3, 0, { $script:index.search() }
    )
}
[ScriptBlock] $script:IndexItems_SelectionChanged = {
    $index_index = $script:index._items.SelectedItem.($script:index._dictionary.Index)
    $script:app._set( 'Index.Index', $index_index )
    $script:index.caption( "[$($script:index._library_name)] $index_index" )
}
[ScriptBlock] $script:IndexItems_PreviewMouseDown = {

    $mouse = $args[1]

    switch( $mouse.ChangedButton ){
        ([Input.MouseButton]::Left) {
            if( $mouse.ClickCount -eq 2 ){
                ttcmd_index_selected_tocurrenteditor
                $mouse.Handled = $true
            }
        }
    }

}
[ScriptBlock] $script:IndexItems_GotFocus = {
    $script:index.focus()
}
[ScriptBlock] $script:IndexItems_PreviewKeyDown = {
    $script:index.focus()
}

#endregion:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

#region　Shelf event
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ScriptBlock] $script:ShelfKeyword_PreviewKeyDown = {
    $skey = $args[1].SystemKey
    $key  = $args[1].Key
    $mod  = $args[1].KeyboardDevice.Modifiers

    :Handled switch( $mod ){
        'None' { 
            switch( $key ){
                'Return' { ttcmd_shelf_invoke_item; break Handled }
                'Up'     { ttcmd_shelf_move_up; break Handled }
                'Down'   { ttcmd_shelf_move_down; break Handled }
                'F1'     { ttcmd_shelf_sort_dsc_1stcolumn; break Handled }
                'F2'     { ttcmd_shelf_sort_dsc_2ndcolumn; break Handled }
                'F3'     { ttcmd_shelf_sort_dsc_3rdcolumn; break Handled }
                'F4'     { ttcmd_shelf_sort_dsc_4thcolumn; break Handled }
                'F5'     { ttcmd_shelf_sort_dsc_5thcolumn; break Handled }
                'F6'     { ttcmd_shelf_sort_dsc_6thcolumn; break Handled }
                default  { return }
            }
        }
        'Shift' {
            switch( $key ){
                'Return' { ttcmd_shelf_activate_item; break Handled }
                'Up'     { ttcmd_shelf_move_first; break Handled }
                'Down'   { ttcmd_shelf_move_last; break Handled }
                'F1'     { ttcmd_shelf_sort_asc_1stcolumn; break Handled }
                'F2'     { ttcmd_shelf_sort_asc_2ndcolumn; break Handled }
                'F3'     { ttcmd_shelf_sort_asc_3rdcolumn; break Handled }
                'F4'     { ttcmd_shelf_sort_asc_4thcolumn; break Handled }
                'F5'     { ttcmd_shelf_sort_asc_5thcolumn; break Handled }
                'F6'     { ttcmd_shelf_sort_asc_6thcolumn; break Handled }
                default { return }
            }
        }
        'Alt' {
            switch( $skey ){
                'Space' { ttcmd_shelf_invoke_item; break Handled }
                'P'     { ttcmd_shelf_move_up; break Handled }
                'N'     { ttcmd_shelf_move_down; break Handled }
                'C'     { ttcmd_shelf_clear; break Handled }
                'Up'    { ttcmd_application_border_inworkplace_up; break Handled }
                'Down'  { ttcmd_application_border_inworkplace_down; break Handled }
                'Left'  { ttcmd_application_border_inwindow_left; break Handled }
                'Right' { ttcmd_application_border_inwindow_right; break Handled }
                'D1'    { ttcmd_shelf_selected_toeditor1; break Handled }
                'D2'    { ttcmd_shelf_selected_toeditor2; break Handled }
                'D3'    { ttcmd_shelf_selected_toeditor3; break Handled }
                'M'     { ttcmd_shelf_focus_menu; break Handled }
                default { return }
            }
        }
        'Alt, Shift' {
            switch( $skey ){
                'Space' { ttcmd_shelf_activate_item; break Handled }
                'P'     { ttcmd_shelf_move_first; break Handled }
                'N'     { ttcmd_shelf_move_last; break Handled }

                default { return }
            }
        }
        'Control' { 
            switch( $key ){
                'D'  { ttcmd_shelf_delete_selected; break Handled }
                'C'  { ttcmd_shelf_copy_item; break Handled } 

                default { return }
            }
        }
        'Control, Shift' { 
            switch( $key ){
                default { return }
            }
        }
        default { return } 
    }
    $args[1].Handled = $True

}
[ScriptBlock] $script:ShelfKeyword_TextChanged = {

    $script:app._set( 'Shelf.Keyword', $script:shelf._keyword.Text )
    $library_index = $script:app._get( 'Library.Index' ) # ここちがう
    $script:app._set( "$library_index.Keyword", $script:shelf._keyword.Text ) # ここちがう

    # trigger background filter
    #'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    [TTTask]::Register( 
        "ShelfKeyword_TextChanged", 3, 0, { $script:shelf.search() }
    )

}
[ScriptBlock] $script:ShelfItems_SelectionChanged = {

    if( $null -eq $script:shelf._items.SelectedItem ){ return }

    $lib_index = $script:app._get( 'Library.Index' )
    $shelf_index = $script:shelf._items.SelectedItem.($script:shelf._dictionary.Index)
    $script:app._set( 'Shelf.Index', $shelf_index )
    $script:app._set( "$lib_index.Index", $shelf_index )

    $script:shelf.caption( "[$($script:shelf._library_name)] $shelf_index" )


    switch -Wildcard ( $shelf_index ){
        "ExMemo*" { $script:app._set( "Memo.Index", $script:shelf._items.SelectedItem.index ) }
    }

}
[ScriptBlock] $script:ShelfItems_PreviewMouseDown = {

    $mouse = $args[1]

    switch( $mouse.ChangedButton ){
        ([Input.MouseButton]::Left) {
            if( $mouse.ClickCount -eq 2 ){
                ttcmd_shelf_selected_tocurrenteditor
                $mouse.Handled = $true
            }
        }
    }

}
[ScriptBlock] $script:ShelfItems_GotFocus = {
    $script:shelf.focus()
}
[ScriptBlock] $script:ShelfItems_PreviewKeyDown = {
    $script:shelf.focus()
}

#endregion:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

#region　Desk event
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ScriptBlock] $script:DeskKeyword_PreviewKeyDown = {

    $skey = $args[1].SystemKey
    $key  = $args[1].Key
    $mod  = $args[1].KeyboardDevice.Modifiers

    :Handled switch( $mod ){
        'None'{
            switch( $skey ){
                'Down' { ttcmd_editor_focus_currenteditor; break Handled }
                default { return }
            }
        }
        'Alt' { 
            switch( $skey ){
                'C'     { ttcmd_desk_clear; break Handled }
                'Up'    { ttcmd_application_border_indesk_up; break Handled }
                'Down'  { ttcmd_application_border_indesk_down; break Handled }
                'Left'  { ttcmd_application_border_indesk_left; break Handled }
                'Right' { ttcmd_application_border_indesk_right; break Handled }
                'M'     { ttcmd_desk_focus_menu; break Handled }
                default { return }
            }
        }
        'Alt, Shift' { 
            switch( $skey ){
                default { return }
            }
        }
        'Control' { 
            switch( $key ){
                'N' { ttcmd_desk_works_focus_current_norm; break Handled }
                'F' { ttcmd_application_textsearch; break Handled }
                default { return }
            }
        }
        default { return } 
    }
    $args[1].Handled = $True

}
[ScriptBlock] $script:DeskKeyword_TextChanged = {

    $script:app._set( 'Desk.Keyword', $script:desk._keyword.Text.Trim() )

    $script:Editors.foreach{
        $editor = $_
        $name = $editor.Name
        $text = $script:desk._keyword.Text.Trim()
        if( 0 -lt $script:DocMan.config.$name.hlrules.count ){
            $script:DocMan.config.$name.hlrules.foreach{
                $editor.SyntaxHighlighting.MainRuleSet.Rules.Remove( $_ )
            }
            $script:DocMan.config.$name.hlrules.clear()
        }
        $keywords = $text.split(",")
        $keywords.foreach{
            $keyword = $_
            $select = "Select" + ($keywords.IndexOf($keyword)+1)
            $color1 = $editor.SyntaxHighlighting.NamedHighlightingColors.where{ $_.Name -eq $select }[0]
    
            if( $keyword -ne "" ){
                $rule = [ICSharpCode.AvalonEdit.Highlighting.HighlightingRule]::new()
                $rule.Color = $color1
                $keyword = $keyword -replace "[\.\^\$\|\\\[\]\(\)\{\}\+\*\?]", '\$0'
                $keyword = "(" + ($keyword -replace "[ 　\t]+", "|" ) + ")"
                $rule.Regex = [Regex]::new( $keyword )

                $script:DocMan.config.$name.hlrules += $rule
                $editor.SyntaxHighlighting.MainRuleSet.Rules.Insert( 0, $rule )
            }

            $editor.TextArea.TextView.Redraw()
        }
    }
}
[ScriptBlock] $script:TextEditors_PreviewKeyDown = {
    $editor = $args[0]
    $key = $args[1].Key
    $mod = $args[1].KeyboardDevice.Modifiers
    $skey = $args[1].SystemKey

    :Handled switch( $mod ){
        'None' { 
            switch( $key ){
                # 以下見直し
                'PageUp'        { ttcmd_editor_scroll_toprevline; break Handled }
                'Next'          { ttcmd_editor_scroll_tonextline; break Handled }
                'BrowserBack'   { ttcmd_editor_scroll_toprevline; break Handled }
                'BrowserForward'{ ttcmd_editor_scroll_tonextline; break Handled }
                'Return' { ttcmd_editor_scroll_tonewline; return }
                default { return }
            }
        }
        'Shift' {
            return
        }
        'Alt' {
            switch( $skey ){
                'T'     { ttcmd_editor_edit_insert_date $mod $skey; break Handled }
                'V'     { ttcmd_editor_edit_insert_clipboard $mod $skey; break Handled }
                'C'     { ttcmd_editor_copy_tag_atcursor; break Handled }

                'D1'    { ttcmd_desk_works_focus_work1; break Handled }
                'D2'    { ttcmd_desk_works_focus_work2; break Handled }
                'D3'    { ttcmd_desk_works_focus_work3; break Handled }

                'Right' { ttcmd_editor_outline_collapse_section; break Handled }
                'Left'  { ttcmd_editor_outline_fold_section; break Handled }
                'Up'    { ttcmd_editor_outline_moveto_previous; break Handled }
                'Down'  { ttcmd_editor_outline_moveto_next; break Handled }
                'M'     { ttcmd_desk_focus_menu; break Handled }

                # 以下見直し
                'OemBackslash' { ttcmd_application_config_editor_wordwrap_toggle break Handled } # [\_]
                'PageUp' { ttcmd_editor_scroll_tonextline; break Handled }
                'Next'   { ttcmd_editor_scroll_roprevline; break Handled }
                'P' { ttcmd_editor_move_toprevkeyword; break Handled }
                'N' { ttcmd_editor_move_tonextkeyword; break Handled }

                default { return }
            }
            break
        }
        'Alt, Shift' {
            return
        }
        'Control' { 
            switch( $key ){
                'D1' { ttcmd_desk_works_focus_work1; break Handled }
                'D2' { ttcmd_desk_works_focus_work2; break Handled }
                'D3' { ttcmd_desk_works_focus_work3; break Handled }


                'Space'     { ttcmd_editor_tag_invoke; break Handled }
                # 'Tab'       { ttcmd_editor_change_focus $mod $key; break Handled }
                'OemPlus'   { ttcmd_editor_edit_turn_bullet_norm; break Handled }
                'Back'      { ttcmd_editor_history_previous_tocurrenteditor; break Handled }
                'I' { ttcmd_editor_outline_insert_section; break Handled }
                'P' { ttcmd_editor_move_toprevline; break Handled }
                'N' { ttcmd_editor_move_tonextline; break Handled  }
                'B' { ttcmd_editor_move_leftchar; break Handled }
                'F' { ttcmd_editor_move_rightchar; break Handled }
                'H' { ttcmd_editor_edit_backspace; break Handled }
                'D' { ttcmd_editor_edit_delete; break Handled }
                'K' { ttcmd_editor_delete_tolineend; break Handled }
                # 'X' { (intrinsic editor command)::Cut }
                # 'C' { (intrinsic editor command)::Copy }
                # 'V' { (intrinsic editor command)::Paste }
                # 'Z' { (intrinsic editor command)::Undo }
                # 'Y' { (intrinsic editor command)::Redo }
                'A' { ttcmd_editor_move_tolinestart; break Handled }
                'E' { ttcmd_editor_move_tolineend; break Handled }
                'S' { ttcmd_editor_save; break Handled }
                'G' { ttcmd_editor_new_tocurrenteditor; break Handled }

                # 以下見直し
                'OemBackslash' { ttcmd_application_config_editor_wordwrap_toggle; break Handled } # [\_]
                'Oem3' { ttcmd_application_config_editor_staycursor_toggle; break Handled } # [@`]
                # 'Tab' { ttcmd_desk_works_focus_turn_norm; break Handled }



                default { return }
            }
            break
        }
        'Control, Shift' { 
            switch( $key ){
                # 'Tab' { ttcmd_desk_works_focus_turn_rev; break Handled }
                'OemPlus'   { ttcmd_editor_edit_turn_bullet_rev; break Handled }
                'Back'      { ttcmd_editor_history_next_tocurrenteditor; break Handled }

                # 以下見直し
                'A' { ttcmd_editor_select_tolinestart; break Handled }
                'E' { ttcmd_editor_select_tolineend; break Handled }
                'P' { ttcmd_editor_select_toprevline; break Handled }
                'N' { ttcmd_editor_select_tonextline; break Handled }
                'B' { ttcmd_editor_select_toleftchar; break Handled }
                'F' { ttcmd_editor_select_torightchar; break Handled }


                default { return }
            }        
            break
        }
        default { return } 
    }
    $args[1].Handled = $True
}
[ScriptBlock] $script:TextEditors_TextChanged = {
    $editor = $args[0]
    $script:DocMan.Tool( $editor.Name ).UpdateEditorFolding()
    switch( $editor.Name ){
        'Editor1' { [TTTask]::Register( "TextEditors1_TextChanged", 40, 0, { $script:desk.tool('Editor1').save() } ) }
        'Editor2' { [TTTask]::Register( "TextEditors2_TextChanged", 40, 0, { $script:desk.tool('Editor2').save() } ) }
        'Editor3' { [TTTask]::Register( "TextEditors3_TextChanged", 40, 0, { $script:desk.tool('Editor3').save() } ) }
    }
}
[ScriptBlock] $script:TextEditors_GotFocus = {
    $editor = $args[0]
    $name = $editor.Name
    $memo = $script:DocMan.config.$name.index
    $line = $editor.Document.GetLineByNumber(1)
    $title = $editor.Document.GetText( $line.Offset, $line.Length )

    $script:desk.caption( "[$name] $memo : $title" )
    $script:DocMan.current_editor = $editor
    if( $script:shelf._collection.Name -eq "Memo" ){ $script:shelf.refresh() }
    if( $script:index._collection.Name -eq "Memo" ){ $script:index.refresh() }

    $script:shelf.cursor( $script:DocMan.config.$name.index )
    $script:index.cursor( $script:DocMan.config.$name.index )

    $script:app._set( 'Desk.CurrentEditor', $editor.Name )
    $script:app._set( 'Application.Focused', $editor.Name )
}
[ScriptBlock] $script:TextEditors_PreviewMouseDown = {
    $editor   = $args[0]
    $memoitem = $args[1]

    switch( $memoitem.ChangedButton ){
        ([Input.MouseButton]::Left) {
            if( $memoitem.ClickCount -eq 2 ){
                $pos = $editor.GetPositionFromPoint( $memoitem.GetPosition($editor) )
                [TTTagAction]::New( $editor ).invoke( $pos.Line, $pos.Column )
                $memoitem.Handled = $true
            }
        }
    }
}
[ScriptBlock] $script:TextEditors_PreviewDrop = {
    $editor = $args[0]
    $drag = $args[1]
    Write-Host $drag   
    # 要修正

    # ファイルのD&Dしか捕捉できない。→ $drag.Data.GetFileDropList()
    # browserのlinkはurlテキストが貼り付けられてしまい、PreviewDropが発火しない
}

#endregion:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::




