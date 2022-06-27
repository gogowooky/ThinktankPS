﻿


# .NET Action, Func, Delegate, Lambda expression in PowerShell
# https://www.reza-aghaei.com/net-action-func-delegate-lambda-expression-in-powershell/


#region TTModel
[ScriptBlock] $global:TTStatus_OnSave = {
    $collection = $args[0]
    @( 'Library', 'Index', 'Shelf' ).where{
        $global:appcon._get( "$_.Resource" ) -eq $collection.Name
    }.foreach{
        $global:appcon.group.refresh( $_ )   
    }
}

#endregion:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


#region key binding setup 
#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
#　oem1 = semicolon [;]
#　

$global:TTKeyEvents = @{}
$global:TTEventKeys = @{}
(@(
    # Application
@'
Application     None            Escape      ttcmd_application_window_quit
Application     Alt             L           ttcmd_focus_tentative_library
Application     Alt             I           ttcmd_focus_tentative_index
Application     Alt             S           ttcmd_focus_tentative_shelf
Application     Alt             C           ttcmd_focus_tentative_cabinet

!Application     Alt             Oem1        ttcmd_application_commands_execute
!Application     Alt, Shift      L           ttcmd_panel_focus_library_revtgl
!Application     Alt, Shift      I           ttcmd_panel_focus_index_revtgl
!Application     Alt, Shift      S           ttcmd_panel_focus_shelf_revtgl
!Application     Alt             D           ttcmd_panel_focus_desk_and_work
!Application     Alt, Shift      D           ttcmd_tool_focus_work_single_toggle
!Application     Alt             M           ttcmd_tool_focus_work_multi_toggle
!Application     Alt、Shift      M           ttcmd_tool_focus_work_multi_revtgl
!Application     Alt             W           ttcmd_tool_focus_app_multi_toggle
!Application     Alt、Shift      W           ttcmd_tool_focus_app_multi_revtgl
!Application     Control         Tab         ttcmd_desk_works_focus_current_norm
!Application     Control, Shift  Tab         ttcmd_desk_works_focus_current_rev
'@,
    #PopupMenu
@'
PopupMenu   Alt             P           ttcmd_menu_move_up
PopupMenu   Alt             N           ttcmd_menu_move_down
PopupMenu   None            Up          ttcmd_menu_move_up
PopupMenu   None            Down        ttcmd_menu_move_down
PopupMenu   Alt, Shift      P           ttcmd_menu_move_first
PopupMenu   Alt, Shift      N           ttcmd_menu_move_last
PopupMenu   Shift           Up          ttcmd_menu_move_first
PopupMenu   Shift           Down        ttcmd_menu_move_last
popupMenu   Alt             Escape      ttcmd_menu_cancel
PopupMenu   None            Escape      ttcmd_menu_cancel
PopupMenu   Alt             Return      ttcmd_menu_ok
PopupMenu   Alt             Space       ttcmd_menu_ok
PopupMenu   None            Return      ttcmd_menu_ok
'@,
    #$Cabinaet
@'
Cabinet         Alt             P           ttcmd_panel_move_up
Cabinet         Alt             N           ttcmd_panel_move_down
Cabinet         None            Up          ttcmd_panel_move_up
Cabinet         None            Down        ttcmd_panel_move_down
Cabinet         Alt, Shift      P           ttcmd_panel_move_first
Cabinet         Alt, Shift      N           ttcmd_panel_move_last
Cabinet         Shift           Up          ttcmd_panel_move_first
Cabinet         Shift           Down        ttcmd_panel_move_last
Cabinet         Alt             Escape      ttcmd_menu_cancel
Cabinet         None            Escape      ttcmd_menu_cancel
Cabinet         Alt             Return      ttcmd_menu_ok
Cabinet         Alt             Space       ttcmd_menu_ok
Cabinet         None            Return      ttcmd_menu_ok
Cabinet         Alt             C           ttcmd_panel_filter_clear
Cabinet         Alt             Oem1        ttcmd_panel_filter_clear
'@,
    #Library
@'
Library+    Alt         P           ttcmd_panel_move_up
Library+    Alt         N           ttcmd_panel_move_down
Library+    Alt, Shift  P           ttcmd_panel_move_first
Library+    Alt, Shift  N           ttcmd_panel_move_last
Library+    Alt         Up          ttcmd_application_border_inlpanel_up
Library+    Alt         Down        ttcmd_application_border_inlpanel_down
Library+    Alt         Left        ttcmd_application_border_inwindow_left
Library+    Alt         Right       ttcmd_application_border_inwindow_right
Library+    Alt         L           ttcmd_focus_tentative_library
Library+    Alt         Space       ttcmd_panel_action_invoke

Library     None        Up          ttcmd_panel_move_up
Library     None        Down        ttcmd_panel_move_down
Library     Shift       Up          ttcmd_panel_move_first
Library     Shift       Down        ttcmd_panel_move_last
Library     Ctrl        D           ttcmd_panel_discard_selected
Library     Ctrl        C           ttcmd_panel_filter_clear
Library     Ctrl        R           ttcmd_panel_reload
Library     None        F1          ttcmd_panel_sort_dsc_1stcolumn
Library     Shift       F1          ttcmd_panel_sort_asc_1stcolumn
Library     None        F2          ttcmd_panel_sort_dsc_2ndcolumn
Library     Shift       F2          ttcmd_panel_sort_asc_2ndcolumn
Library     None        F3          ttcmd_panel_sort_dsc_3rdcolumn
Library     Shift       F3          ttcmd_panel_sort_asc_3rdcolumn
Library     None        F4          ttcmd_panel_sort_dsc_4thcolumn
Library     Shift       F4          ttcmd_panel_sort_asc_4thcolumn
Library     None        F5          ttcmd_panel_sort_dsc_5thcolumn
Library     Shift       F5          ttcmd_panel_sort_asc_5thcolumn
Library     None        F6          ttcmd_panel_sort_dsc_6thcolumn
Library     Shift       F6          ttcmd_panel_sort_asc_6thcolumn
Library     Alt, Shift  Space       ttcmd_panel_action_select
Library     None        Return      ttcmd_panel_action_select
'@,
    #Index
@'
Index+      Alt         P           ttcmd_panel_move_up
Index+      Alt         N           ttcmd_panel_move_down
Index+      Alt, Shift  P           ttcmd_panel_move_first
Index+      Alt, Shift  N           ttcmd_panel_move_last
Index+      Alt         Up          ttcmd_application_border_inlpanel_up
Index+      Alt         Down        ttcmd_application_border_inlpanel_down
Index+      Alt         Left        ttcmd_application_border_inwindow_left
Index+      Alt         Right       ttcmd_application_border_inwindow_right
Index+      Alt         I           ttcmd_focus_tentative_index
Index+      Alt         Space       ttcmd_panel_action_invoke

Index       None        Up          ttcmd_panel_move_up
Index       None        Down        ttcmd_panel_move_down
Index       Shift       Up          ttcmd_panel_move_first
Index       Shift       Down        ttcmd_panel_move_last
Index       Ctrl        D           ttcmd_panel_discard_selected
Index       Ctrl        C           ttcmd_panel_filter_clear
Index       Ctrl        R           ttcmd_panel_reload
Index       None        F1          ttcmd_panel_sort_dsc_1stcolumn
Index       Shift       F1          ttcmd_panel_sort_asc_1stcolumn
Index       None        F2          ttcmd_panel_sort_dsc_2ndcolumn
Index       Shift       F2          ttcmd_panel_sort_asc_2ndcolumn
Index       None        F3          ttcmd_panel_sort_dsc_3rdcolumn
Index       Shift       F3          ttcmd_panel_sort_asc_3rdcolumn
Index       None        F4          ttcmd_panel_sort_dsc_4thcolumn
Index       Shift       F4          ttcmd_panel_sort_asc_4thcolumn
Index       None        F5          ttcmd_panel_sort_dsc_5thcolumn
Index       Shift       F5          ttcmd_panel_sort_asc_5thcolumn
Index       None        F6          ttcmd_panel_sort_dsc_6thcolumn
Index       Shift       F6          ttcmd_panel_sort_asc_6thcolumn
Index       Alt, Shift  Space       ttcmd_panel_action_select
Index       None        Return      ttcmd_panel_action_select
'@,
    #Shelf
@'
Shelf+      Alt         P           ttcmd_panel_move_up
Shelf+      Alt         N           ttcmd_panel_move_down
Shelf+      Alt, Shift  P           ttcmd_panel_move_first
Shelf+      Alt, Shift  N           ttcmd_panel_move_last
Shelf+      Alt         Up          ttcmd_application_border_inrpanel_up
Shelf+      Alt         Down        ttcmd_application_border_inrpanel_down
Shelf+      Alt         Left        ttcmd_application_border_inwpanel_left
Shelf+      Alt         Right       ttcmd_application_border_inwpanel_right
Shelf+      Alt         S           ttcmd_focus_tentative_shelf
Shelf+      Alt         Space       ttcmd_panel_action_invoke

Shelf       None        Up          ttcmd_panel_move_up
Shelf       None        Down        ttcmd_panel_move_down
Shelf       Shift       Up          ttcmd_panel_move_first
Shelf       Shift       Down        ttcmd_panel_move_last
Shelf       Ctrl        D           ttcmd_panel_discard_selected
Shelf       Ctrl        C           ttcmd_panel_filter_clear
Shelf       Ctrl        R           ttcmd_panel_reload
Shelf       None        F1          ttcmd_panel_sort_dsc_1stcolumn
Shelf       Shift       F1          ttcmd_panel_sort_asc_1stcolumn
Shelf       None        F2          ttcmd_panel_sort_dsc_2ndcolumn
Shelf       Shift       F2          ttcmd_panel_sort_asc_2ndcolumn
Shelf       None        F3          ttcmd_panel_sort_dsc_3rdcolumn
Shelf       Shift       F3          ttcmd_panel_sort_asc_3rdcolumn
Shelf       None        F4          ttcmd_panel_sort_dsc_4thcolumn
Shelf       Shift       F4          ttcmd_panel_sort_asc_4thcolumn
Shelf       None        F5          ttcmd_panel_sort_dsc_5thcolumn
Shelf       Shift       F5          ttcmd_panel_sort_asc_5thcolumn
Shelf       None        F6          ttcmd_panel_sort_dsc_6thcolumn
Shelf       Shift       F6          ttcmd_panel_sort_asc_6thcolumn
Shelf       Alt, Shift  Space       ttcmd_panel_action_select
Shelf       None        Return      ttcmd_panel_action_select
'@,
    #Misc
@'
xShelf       Shift       Return      ttcmd_shelf_activate_item
xShelf       Alt         Up          ttcmd_application_border_inworkplace_up
xShelf       Alt         Down        ttcmd_application_border_inworkplace_down
xShelf       Alt         Left        ttcmd_application_border_inwindow_left
xShelf       Alt         Right       ttcmd_application_border_inwindow_right
xShelf       Alt         D1          ttcmd_shelf_selected_toeditor1
xShelf       Alt         D2          ttcmd_shelf_selected_toeditor2
xShelf       Alt         D3          ttcmd_shelf_selected_toeditor3
xShelf       Alt         M           ttcmd_shelf_focus_menu
xShelf       Control     C           ttcmd_shelf_copy_item
xIndex       Alt         D1          ttcmd_shelf_selected_toeditor1
xIndex       Alt         D2          ttcmd_shelf_selected_toeditor2
xIndex       Alt         D3          ttcmd_shelf_selected_toeditor3
xIndex       Control     C           ttcmd_shelf_copy_item; break Handled
'@,
    #Desk
@'
Desk        None        Down        ttcmd_editor_focus_currenteditor
Desk        Alt         C           ttcmd_desk_clear
Desk        Alt         Up          ttcmd_application_border_indesk_up
Desk        Alt         Down        ttcmd_application_border_indesk_down
Desk        Alt         Left        ttcmd_application_border_indesk_left
Desk        Alt         Right       ttcmd_application_border_indesk_right
Desk        Alt         M           ttcmd_desk_focus_menu
Desk        Control     N           ttcmd_desk_works_focus_current_norm
Desk        Control     F           ttcmd_application_textsearch
'@,
    #Editor
@'
xEditor      None            PageUp          ttcmd_editor_scroll_toprevline
xEditor      None            Next            ttcmd_editor_scroll_tonextline
xEditor      None            BrowserBack     ttcmd_editor_scroll_toprevline
xEditor      None            BrowserForward  ttcmd_editor_scroll_tonextline
xEditor      None            Return          ttcmd_editor_scroll_tonewline
xEditor      Alt             T               ttcmd_editor_edit_insert_date $mod $skey
xEditor      Alt             V               ttcmd_editor_edit_insert_clipboard $mod $skey
xEditor      Alt             C               ttcmd_editor_copy_tag_atcursor
xEditor      Alt             D1              ttcmd_desk_works_focus_work1
xEditor      Alt             D2              ttcmd_desk_works_focus_work2
xEditor      Alt             D3              ttcmd_desk_works_focus_work3
xEditor      Alt             Right           ttcmd_editor_outline_collapse_section
xEditor      Alt             Left            ttcmd_editor_outline_fold_section
xEditor      Alt             Up              ttcmd_editor_outline_moveto_previous
xEditor      Alt             Down            ttcmd_editor_outline_moveto_next
xEditor      Alt             M               ttcmd_desk_focus_menu
xEditor      Alt             OemBackslash    ttcmd_application_config_editor_wordwrap_toggle
xEditor      Alt             PageUp          ttcmd_editor_scroll_tonextline
xEditor      Alt             Next            ttcmd_editor_scroll_roprevline
xEditor      Alt             P               ttcmd_editor_move_toprevkeyword
xEditor      Alt             N               ttcmd_editor_move_tonextkeyword
xEditor      Control         D1              ttcmd_desk_works_focus_work1
xEditor      Control         D2              ttcmd_desk_works_focus_work2
xEditor      Control         D3              ttcmd_desk_works_focus_work3
xEditor      Control         Space           ttcmd_editor_tag_invoke
xEditor      Control         OemPlus         ttcmd_editor_edit_turn_bullet_norm
xEditor      Control         Back            ttcmd_editor_history_previous_tocurrenteditor
xEditor      Control         I               ttcmd_editor_outline_insert_section
xEditor      Control         P               ttcmd_editor_move_toprevline
xEditor      Control         N               ttcmd_editor_move_tonextline
xEditor      Control         B               ttcmd_editor_move_leftchar
xEditor      Control         F               ttcmd_editor_move_rightchar
xEditor      Control         H               ttcmd_editor_edit_backspace
xEditor      Control         D               ttcmd_editor_edit_delete
xEditor      Control         K               ttcmd_editor_delete_tolineend
xEditor      Control         A               ttcmd_editor_move_tolinestart
xEditor      Control         E               ttcmd_editor_move_tolineend
xEditor      Control         S               ttcmd_editor_save
xEditor      Control         G               ttcmd_editor_new_tocurrenteditor
xEditor      Control         OemBackslash    ttcmd_application_config_editor_wordwrap_toggle
xEditor      Control         Oem3            ttcmd_application_config_editor_staycursor_toggle
xEditor      Control, Shift  OemPlus         ttcmd_editor_edit_turn_bullet_rev
xEditor      Control, Shift  Back            ttcmd_editor_history_next_tocurrenteditor
xEditor      Control, Shift  A               ttcmd_editor_select_tolinestart
xEditor      Control, Shift  E               ttcmd_editor_select_tolineend
xEditor      Control, Shift  P               ttcmd_editor_select_toprevline
xEditor      Control, Shift  N               ttcmd_editor_select_tonextline
xEditor      Control, Shift  B               ttcmd_editor_select_toleftchar
xEditor      Control, Shift  F               ttcmd_editor_select_torightchar
'@
) -join "`n" ).split("`n").foreach{
    if( $_ -match "(?<mode>[^ ]+)\s{2,}(?<mod>[^ ]+( [^ ]+)?)\s{2,}(?<keyname>[^ ]+)\s{2,}(?<command>[^\s]+)\s*" ){
        $global:TTKeyEvents[$Matches.mode] += @{}
        $global:TTKeyEvents[$Matches.mode][$Matches.mod] += @{}
        $global:TTKeyEvents[$Matches.mode][$Matches.mod][$Matches.keyname] = $Matches.command
        $global:TTEventKeys[$Matches.command] += @()
        $global:TTEventKeys[$Matches.command] += @( @{ Mode = $Matches.mode; Key = "[$($Matches.mod)]$($Matches.key)" } )
    }
}


[ScriptBlock] $global:TTPreviewKeyDown = { 
    $source =   [string]($args[0].Name) # ⇒ Application, Cabinet, PopupMenu
    $mod =      [string]($args[1].KeyboardDevice.Modifiers)
    $key =      if( $mod -in @('Alt','Alt, Shift') ){ [string]($args[1].SystemKey) }else{ [string]($args[1].Key) }
    $panel =    $global:appcon._get( 'Focus.Application' )
    $tttv  =    [TTTentativeKeyBindingMode]::Name

    if( $source -eq 'PopupMenu' ){
        $panel = $source
        $command = try{ $global:TTKeyEvents[$panel][$mod][$key] }catch{ $null }

    }elseif( $tttv -ne '' ){
        $panel = $tttv
        $command = try{ $global:TTKeyEvents["$panel+"][$mod][$key] }catch{ $null }
    }else{
        $command = @( 'Application', "$panel+", $panel ).foreach{
            try{ $global:TTKeyEvents[$_][$mod][$key] }catch{ $null }
        }.where{ $null -ne $_}[0]
    }

    Write-Host "PreviewKeyDown tentative:$tttv, panel:$panel, mod:$mod, key:$key, command:$command"

    if( 0 -ne $command.length ){
        if( $global:appcon._istrue( "Config.KeyDownMessage" ) ){
            Write-Host "PreviewKeyDown tentative:$tttv, panel:$panel, mod:$mod, key:$key, command:$command"
        }
        switch ( Invoke-Expression "$command '$panel' '$mod' '$key'" ){
            'cancel' { $args[1].Handled = $false }
            default { $args[1].Handled = $true }
        }
    }
 
}

[ScriptBlock] $global:TTPreviewKeyUp = {
    if( [TTTentativeKeyBindingMode]::Check( $args[1].Key ) ){
        $args[1].Handled = $True
    }
}


#endregion###############################################################################################################


#region 専用
[ScriptBlock] $global:TTWindowLoaded =      { $global:appcon.initialize_application() }
[ScriptBlock] $global:TTPanel_SizeChanged = { $global:appcon.set_border_status( $args ) }

[ScriptBlock] $global:TTPanel_GotFocus =    { $global:appcon.set_gotfocus_status( $args ) }
[ScriptBlock] $global:TTPanel_LostFocus =   { $global:appcon.set_lostfocus_status( $args ) }
[ScriptBlock] $global:TTTool_GotFocus =     { $global:appcon.set_gotfocus_status( $args ) }
[ScriptBlock] $global:TTTool_LostFocus =    { $global:appcon.set_lostfocus_status( $args ) }
[ScriptBlock] $global:TTWork_GotFocus =     { $global:appcon.set_gotfocus_status( $args ) }
[ScriptBlock] $global:TTWork_LostFocus =    { $global:appcon.set_lostfocus_status( $args ) }

[ScriptBlock] $global:TTDataGrid_Sorting =          { $global:appcon.group.datagrid_on_sorting( $args ) }
[ScriptBlock] $global:TTDataGrid_SelectionChanged = { $global:appcon.group.datagrid_on_selectionchanged( $args ) }
[ScriptBlock] $global:TTDataGrid_GotFocus =         { $global:appcon.group.datagrid_on_gotfocus( $args ) }
[ScriptBlock] $script:TTDataGrid_PreviewMouseDown = { $global:appcon.group.datagrid_on_previewmousedown( $args ) }
[ScriptBlock] $global:TTPanel_TextChanged_ToExtract = { $global:appcon.group.textbox_on_textchanged( $args ) }


#endregion :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

#region　

[ScriptBlock] $global:TTPanel_TextChanged_ToHighlight = {
    $panel = ( $args[0].Name -replace "(Desk).*", '$1' )

    $global:appcon._set( "$panel.Keyword", $global:appcon.keyword( $panel ) )
    # 

    # $script:app._set( 'Desk.Keyword', $script:desk._keyword.Text.Trim() )

    # $script:Editors.foreach{
    #     $editor = $_
    #     $name = $editor.Name
    #     $text = $script:desk._keyword.Text.Trim()
    #     if( 0 -lt $script:DocMan.config.$name.hlrules.count ){
    #         $script:DocMan.config.$name.hlrules.foreach{
    #             $editor.SyntaxHighlighting.MainRuleSet.Rules.Remove( $_ )
    #         }
    #         $script:DocMan.config.$name.hlrules.clear()
    #     }
    #     $keywords = $text.split(",")
    #     $keywords.foreach{
    #         $keyword = $_
    #         $select = "Select" + ($keywords.IndexOf($keyword)+1)
    #         $color1 = $editor.SyntaxHighlighting.NamedHighlightingColors.where{ $_.Name -eq $select }[0]
    
    #         if( $keyword -ne "" ){
    #             $rule = [ICSharpCode.AvalonEdit.Highlighting.HighlightingRule]::new()
    #             $rule.Color = $color1
    #             $keyword = $keyword -replace "[\.\^\$\|\\\[\]\(\)\{\}\+\*\?]", '\$0'
    #             $keyword = "(" + ($keyword -replace "[ 　\t]+", "|" ) + ")"
    #             $rule.Regex = [Regex]::new( $keyword )

    #             $script:DocMan.config.$name.hlrules += $rule
    #             $editor.SyntaxHighlighting.MainRuleSet.Rules.Insert( 0, $rule )
    #         }

    #         $editor.TextArea.TextView.Redraw()
    #     }
    # }

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

#endregion:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


#region　Document event
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ScriptBlock] $script:TextxEditors_TextChanged = {
    $editor = $args[0]
    $script:DocMan.Tool( $editor.Name ).UpdatexEditorFolding()
    switch( $editor.Name ){
        'xEditor1' { TTTimerResistEvent "TextxEditors1_TextChanged" 40 0 { $script:desk.tool('xEditor1').save() } }
        'xEditor2' { TTTimerResistEvent "TextxEditors2_TextChanged" 40 0 { $script:desk.tool('xEditor2').save() } }
        'xEditor3' { TTTimerResistEvent "TextxEditors3_TextChanged" 40 0 { $script:desk.tool('xEditor3').save() } }
    }
}
[ScriptBlock] $script:TextxEditors_GotFocus = {
    
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

    $script:app._set( 'Desk.CurrentxEditor', $editor.Name )
    $script:app._set( 'Application.Focused', $editor.Name )
}
[ScriptBlock] $script:TextxEditors_PreviewMouseDown = {
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
[ScriptBlock] $script:TextxEditors_PreviewDrop = {
    $editor = $args[0]
    $drag = $args[1]
    Write-Host $drag   
    # 要修正

    # ファイルのD&Dしか捕捉できない。→ $drag.Data.GetFileDropList()
    # browserのlinkはurlテキストが貼り付けられてしまい、PreviewDropが発火しない
}

#endregion:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::




