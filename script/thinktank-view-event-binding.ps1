




#region Key Event
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ScriptBlock] $global:TTPreviewKeyDown = { # Bind to AppMan, PopupMenu, Cabinet

    $source =   [string]($args[0].Name) # ⇒ Application, Cabinet, PopupMenu
    $mod =      [string]($args[1].KeyboardDevice.Modifiers)
    $key =      if( $mod -in @('Alt','Alt, Shift') ){ [string]($args[1].SystemKey) }else{ [string]($args[1].Key) }
    $tttv  =    [TTTentativeKeyBindingMode]::Name
    $panel =    $global:appcon._get('Focus.Application')
    $global:TTKeyEventMod = $mod
    $global:TTKeyEventKey = $key
    
    if( $key.Contains('Alt') -or $key.Contains('Control') ){ return }

    if( $source -eq 'Application' ){        #### Application
        if( $tttv -ne '' ){                 #### tentative Index/Library/Shelf
            $panel = $tttv
            $command = try{ $global:TTKeyEvents["$panel+"][$mod][$key] }catch{ $null }

        }else{                              #### non tentative

            $command = try{ $global:TTKeyEvents['Application'][$mod][$key] }catch{ $null }

            if( 0 -ne $command.length ){    #### Application
                $panel = $source

            }else{
                if( $panel -match "(?<panel>Editor|Browser|Grid)[123]" ){
                    $command = try{ $global:TTKeyEvents[$Matches.panel][$mod][$key] }catch{ $null }

                }elseif( $panel -eq 'Desk' ){
                    $command = try{ $global:TTKeyEvents['Desk'][$mod][$key] }catch{ $null }

                }else{                      #### normal Index/Library/Shelf
                    $command = @( "$panel+", $panel ).foreach{
                        try{ $global:TTKeyEvents[$_][$mod][$key] }catch{ $null }
                    }.where{ $null -ne $_ }[0]
                }
            }
        }
        
    }else{                                  #### PopupMenu / Cabinet 
        $panel = $source
        $command = try{ $global:TTKeyEvents[$panel][$mod][$key] }catch{ $null }    

    }

    if( 0 -ne $command.length ){
        if( $global:TTKeyEventMessage ){
            Write-Host "PreviewKeyDown source:$source, tentative:$tttv, panel:$panel, mod:$mod, key:$key, command:$command"
        }
        Invoke-Expression "$command '$panel' '$mod' '$key'"
        $args[1].Handled = $true 
        
    }else{
        $args[1].Handled = $false
    }
 
}
[ScriptBlock] $global:TTPreviewKeyUp = { # Bind to AppMan, PopupMenu, Cabinet
    if( [TTTentativeKeyBindingMode]::Check( $args[1].Key ) ){
        $args[1].Handled = $True
    }
}
$global:TTKeyEventMod = ''
$global:TTKeyEventKey = ''

$global:TTKeyEventMessage = $false
$global:TTKeyEvents = @{}
$global:TTEventKeys = @{}

function KeyBindingSetup(){

    $keybinds = ( @(  
        $global:KeyBind_Application,    $global:KeyBind_Cabinet,    $global:KeyBind_Library, 
        $global:KeyBind_Index,          $global:KeyBind_Shelf,      $global:KeyBind_Misc, 
        $global:KeyBind_Desk,           $global:KeyBind_Editor,     $global:KeyBind_PopupMenu  ) -join "`n" )

    $keybinds.split("`n").foreach{
        $kb_fmt = "(?<mode>[^ ]+)\s{2,}(?<mod>[^ ]+( [^ ]+)?)\s{2,}(?<key>[^ ]+)\s{2,}(?<command>[^\s]+)\s*"
        if( $_ -match $kb_fmt ){
            $global:TTKeyEvents[$Matches.mode] += @{}
            $global:TTKeyEvents[$Matches.mode][$Matches.mod] += @{}
            $global:TTKeyEvents[$Matches.mode][$Matches.mod][$Matches.key] = $Matches.command
            $global:TTEventKeys[$Matches.command] += @()
            $global:TTEventKeys[$Matches.command] += @( @{ Mode = $Matches.mode; Key = "[$($Matches.mod)]$($Matches.key)" } )
        }
    }
}


[ScriptBlock] $global:TTAppMan_PreviewKeyDown = $global:TTPreviewKeyDown
[ScriptBlock] $global:TTCabin_PreviewKeyDown =  $global:TTPreviewKeyDown
[ScriptBlock] $global:TTPopup_PreviewKeyDown =  $global:TTPreviewKeyDown
[ScriptBlock] $global:TTPanel_PreviewKeyDown =  {}
[ScriptBlock] $global:TTTool_PreviewKeyDown =   {}

[ScriptBlock] $global:TTWindow_PreviewKeyUp =   $global:TTPreviewKeyUp
[ScriptBlock] $global:TTCabin_PreviewKeyUp =    $global:TTPreviewKeyUp
[ScriptBlock] $global:TTPopup_PreviewKeyUp =    $global:TTPreviewKeyUp
[ScriptBlock] $global:TTPanel_PreviewKeyUp =    {}
[ScriptBlock] $global:TTTool_PreviewKeyUp =     {}

#endregion:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

#region PopupMenu Event
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ScriptBlock] $global:TTPopup_MouseLeftButtonDown = { $global:AppMan.PopupMenu._window.DragMove() }
[ScriptBlock] $global:TTPopup_MouseDoubleClick =    { $global:AppMan.PopupMenu.Hide($true) }
[ScriptBlock] $global:TTPopup_LostKeyboardFocus =   { $global:AppMan.PopupMenu.Hide($false) }
# ; $args[1].Handled = $true

#endregion:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

#region Application Event
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ScriptBlock] $global:TTWindowLoaded =  { $args[1].Handled = $global:appcon.initialize_application() }

#endregion:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

#region Focus Event
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ScriptBlock] $global:TTPanel_GotFocus =    { $args[1].Handled = $global:appcon.event_set_focus_panel( $args ) }
[ScriptBlock] $global:TTTool_GotFocus =     { $args[1].Handled = $global:appcon.event_set_focus_application( $args ) }
[ScriptBlock] $global:TTDataGrid_GotFocus = { $args[1].Handled = $global:appcon.event_refocus( $args ) }


[ScriptBlock] $global:TextEditors_GotFocus =    { $global:appcon.tools.editor.event_setup_after_focus_changes( $args ) }
[ScriptBlock] $global:TTMenu_GotFocus =         {}     # menu制御
[ScriptBlock] $global:TTMenu_LostFocus =        {}
[ScriptBlock] $global:TTWindow_GotFocus =       {}   # application制御
[ScriptBlock] $global:TTWindow_LostFocus =      {}


#endregion:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

#region Mouse Click Events
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ScriptBlock] $global:TTDataGrid_PreviewMouseDown =     { $global:appcon.group.event_select_datagrid_item_by_mouse( $args ) }
[ScriptBlock] $global:TextEditors_PreviewMouseDown =    { $global:appcon.tools.editor.event_invoke_actions_by_mouse( $args ) }
[ScriptBlock] $global:Browsers_PreviewMouseDown =       {}
[ScriptBlock] $global:Grids_PreviewMouseDown =          {}

#endregion:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

#region Panel related Events
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ScriptBlock] $global:TTPanel_SizeChanged = { $global:appcon.event_set_border( $args ) }

[ScriptBlock] $global:TTPanel_TextChanged_ToExtract =   { $global:appcon.group.event_extract_datagrid_items( $args ) }
[ScriptBlock] $global:TTDesk_TextChanged_ToHighlight =  { $global:appcon.group.event_highlight_text_on_editor( $args ) }

[ScriptBlock] $global:TTDataGrid_Sorting =          { $global:appcon.group.event_sort_datagrid( $args ) }
[ScriptBlock] $global:TTDataGrid_SelectionChanged = { $global:appcon.group.event_selection_change_datagrid( $args ) }

# [ScriptBlock] $global:TTPanelTool_GotFocus =    { $args[1].Handled = $global:appcon.set_gotfocus_status( $args ) }
# [ScriptBlock] $global:TTPanelTool_LostFocus =   { $args[1].Handled = $global:appcon.set_lostfocus_status( $args ) }

#endregion:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

#region TextEditor related Events
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ScriptBlock] $global:TextEditors_TextChanged =        { $global:appcon.tools.editor.event_auto_save_after_text_change( $args ) }
[ScriptBlock] $global:TextEditors_PreviewDrop =        { $global:appcon.tools.editor.on_previewdrop( $args ) }

[ScriptBlock] [TTEditorsManager]::OnSave = { $global:appcon.tools.editor.on_save( $args ) }
[ScriptBlock] [TTEditorsManager]::OnLoad = { $global:appcon.tools.editor.on_load( $args ) }


#endregion:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::




#region　View Key-Command Binding 
#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
#　oem1 = semicolon [;]
#　
$global:KeyBind_Misc = @'
xShelf       Shift       Return      ttcmd_shelf_activate_item
xShelf       Alt         Up          ttcmd_application_border_inworkplace_up
xShelf       Alt         Down        ttcmd_application_border_inworkplace_down
xShelf       Alt         Left        ttcmd_application_border_inwpanel_left
xShelf       Alt         Right       ttcmd_application_border_inwpanel_right
xShelf       Alt         D1          ttcmd_shelf_selected_toeditor1
xShelf       Alt         D2          ttcmd_shelf_selected_toeditor2
xShelf       Alt         D3          ttcmd_shelf_selected_toeditor3
xShelf       Alt         M           ttcmd_shelf_focus_menu
xShelf       Control     C           ttcmd_shelf_copy_item
xIndex       Alt         D1          ttcmd_shelf_selected_toeditor1
xIndex       Alt         D2          ttcmd_shelf_selected_toeditor2
xIndex       Alt         D3          ttcmd_shelf_selected_toeditor3
xIndex       Control     C           ttcmd_shelf_copy_item; break Handled
'@

#endregion






