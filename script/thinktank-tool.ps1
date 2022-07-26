


using namespace System.Windows 
using namespace System.Windows.Controls
using namespace System.Windows.Documents
using namespace System.IO
using namespace System.Xml
using namespace System.Data
using namespace System.Dynamic
using namespace System.Drawing
using namespace ICSharpCode.avalonEdit
using namespace System.Text.RegularExpressions





#region　static TTTool
#########################################################################################################################
class TTTool{

    static [string] toggle( [string]$item, [string[]]$items ){
        $n = $items.IndexOf( $item )
        return $items[ ( $items.length + $n + 1 ) % $items.length ]
    }
    static [string] revtgl( [string]$item, [string[]]$items ){
        $n = $items.IndexOf( $item )
        if( $n -eq -1 ){ $n = 1 }
        return $items[ ( $items.length + $n - 1 ) % $items.length ]
    }
    static [void]open_url( [string]$url ){
        $url = $url.replace('"','')
    
        if( $url -like "*[param]*" ){
            $url = $url.replace( "[param]", [System.Web.HttpUtility]::UrlEncode( $global:AppMan.Desk.Keyword() ) )
        }
        # Start-Process $url
        Start-Process "microsoft-edge:$url"
    
    }
    static [string]index_to_filepath( [string]$index ){
        switch -wildcard ( $index ){
            "thinktank*" { return "$global:TTRootDirPath\thinktank.md" }
            default      { return "$global:TTMemoDirPath\$index.txt" }
        }
        return ""
    }
    static [void]debug_message( [string]$place, [string]$message ){
        $header = (Get-Date).tostring( "[yyyy-MM-dd-HHmmss]" ) + "[$place]" + " "*55
        Write-Host "$($header.Substring(0,60))| $message"
    }
    static [void]setup_cache_folder(){
        if( $myInvocation.MyCommand.Name -match 'thinkank(?<num>.?)\.ps1' ){
            $script:cachefolder = "\cache" + $Matches.num
        }else{
            $script:cachefolder = "\cache"    
        }    
   }
    static [void]open_memo( [string]$id ){
        $tool = $script:app._get( "Desk.CurrentEditor" )
        $script:desk.tool( $tool ).load( $id )
    }
    static [void]display_resource( [string]$index, [string]$panel ){
        if( 0 -lt $index.length ){
            switch( $panel ){
                'index' { 
                    $script:library.unmark_column()
                    $script:index.initialize( $index )
                    $script:library.mark_column().refresh()
                }
                'shelf' {
                    $script:library.unmark_column()
                    $script:shelf.initialize( $index )        
                    $script:library.mark_column().refresh()
                }
            }
            $script:library.focus()
        }
    }
    static [void]shelf_keyword( $mes ){
        $script:shelf._keyword.text = $mes
        $script:shelf.focus()
    }
    static [void]desk_keyword( $mes ){
        $script:desk._keyword.text = $mes
    }
    static [void]message( $mes, $title ){
        [System.Windows.MessageBox]::Show( $mes, $title, 'OK', 'None' )    
    }

}
#endregion###############################################################################################################

#region　static TTClipboard
#########################################################################################################################
class TTClipboard {
    static [string] $_type
    static [object] $_target
    static [object] $_copied

    static [void]Copy( [string]$text ){                     #### text
        [Clipboard]::SetText( $text )    
    }
    static [void]Copy( [object]$object ){                   #### TTObject
        [Clipboard]::SetData( "TTObject", $object )
        [TTClipboard]::_copied = $object
    }
    static [void]Copy( [object]$object, [string]$text ){    #### TTObject, text
        $data = [DataObject]::New( "TTObject", $object )
        $data.SetText( $text )
        [Clipboard]::SetDataObject( $data )
        [TTClipboard]::_copied = $object
    }
    static [string]DataType(){
        $type = ''

        switch( $true ){
            { [Clipboard]::ContainsFileDropList() }             { $type += "FileDropList," }
            { [Clipboard]::ContainsAudio() }                    { $type += "Audio," }
            { [Clipboard]::ContainsText() }                     { $type += "Text," }
            { [Clipboard]::ContainsImage() }                    { $type += "Image," }
            { [Clipboard]::ContainsData("CSV") }                { $type += "CSV," }
            { [Clipboard]::ContainsData("Rich Text Format") }   { $type += "Rtf," }
            { [Clipboard]::ContainsData("HTML Format") }        { $type += "Html," }
            { [Clipboard]::ContainsData("DataInterchangeFormat") }  { $type += "DataInterchangeFormat," }
            { [Clipboard]::ContainsData("TTObject") }           { $type += "TTObject" }
            default{ $type += "no-category," }
        }

        return $type
    }
    static [string]GetText(){
        return [Clipboard]::GetText()
    }

}

#endregion###############################################################################################################

#region　TTTagAction
#########################################################################################################################
class TTTagAction{
    [System.Text.RegularExpressions.Match] $_ma
    [object] $_editor
    [int] $_offset

    $regex_tags = $global:TTResources.Getchild('Searchs').GetActionTagsRegex()
    [psobject[]] $_tags = @(
        @{  tag     = 'date'
            regex   = "(\[[0-9]{4}\-[0-9]{2}\-[0-9]{2}\])" },
        @{  tag     = 'check'
            regex   = '(\[[ox_]\])' },
        @{  tag     = 'url'
            regex   = "((https?://[^　 \[\],;<>\`"\']+)|(`"https?://[^\[\],;<>\`"\']+)`")" },
        @{  tag     = 'path'
            regex   = '(([a-zA-Z]:\\[\w\\\-\.]*|"[a-zA-Z]:\\[\w\\\-\.].*")|(\\\\[\w\\\-\.]*|"\\\\[\w\\\-\.].*"))' },
        @{  tag     = 'tag'    
            regex   = "\[(?<tag>$($this.regex_tags)):(?<param>[^\[\]]+)\]" }
    )
    TTTagAction( $tool ){
        $this._editor = $tool
    }
    [System.Text.RegularExpressions.Match] regex_at( $regex ){
        if( $null -eq $this._editor ){ return $null }
        return $this.regex_at( $regex, $this._editor.CaretOffset )
    }
    [System.Text.RegularExpressions.Match] regex_at( $regex, $offset ){
        if( $null -eq $this._editor ){ return $null }

        $line = $this._editor.Document.GetLineByOffset( $offset )
        $text = $this._editor.Document.GetText( $line.offset, $line.length ) 
        
        foreach( $ma in [RegEx]::Matches( $text, $regex ) ){
            $ma_offset = $line.offset + $ma.Index
            if(( $ma_offset - 1 -Lt $offset ) -and ( $offset -Lt $ma_offset + $ma.Length )){ 
                $this._ma = $ma
                return $ma
            }
        }
        return $null
        
    }
    [void] DoAction(){ 
        $this.invoke( $this._editor.CaretOffset )
    }
    [void] invoke( $line, $column ){
        $this.invoke( $this._editor.Document.GetOffset( $line, $column ) )
    }
    [void] invoke( $offset ){
        $this._offset = $offset

        foreach( $tag in $this._tags ){
            if( $null -eq $this.regex_at( $tag.regex ) ){ continue }
            switch( $tag.tag ){
                'date'  { $this.date_action(); break }
                'check' { $this.check_action(); break }
                'url'   { $this.url_action(); break }
                'path'  { $this.path_action(); break }
                'tag'   { $this.tag_action(); break }
            }
        }
    }


    [void] date_action(){ # 未実装
        return
    }
    [void] check_action(){
        $ma = $this._ma
        $offset = $this._offset
        $editor = $this._editor
        $curline = $editor.Document.GetLineByOffset( $offset )

        $editor.Document.Replace( $curline.offset + $ma.Index, 3, @{"[o]"="[x]";"[x]"="[_]";"[_]"="[o]"}[ $ma.Value ] )
        $editor.CaretOffset = $offset
    }
    [void] url_action(){
        $actions = [hashtable]@{
            "@URLを開く" =          'open url'
            "一つ上のURLを開く" =   'open parent url'
        }
        $selected = $global:AppMan.PopupMenu.Caption( 'URLを開く' ).Items( $actions.Keys ).Show()
        switch( $actions[$selected] ){
            'open url'        { [TTTool]::open_url( $this._ma.Value ) }
            'open parent url' { [TTTool]::open_url( (Split-Path $this._ma.Value -Parent) ) }
        }
    }
    [void] path_action(){
        $actions = @{
            "@ファイルを開く" =     'open file'
            "ディレクトリを開く" =  'open directory'
        }
        $selected = $global:AppMan.PopupMenu.Caption( 'Pathを開く' ).Items( $actions.Keys ).Show()
        switch( $actions[$selected] ){
            'open file'      { Start-Process $this._ma.Value }
            'open directory' { Start-Process (Split-Path ($this._ma.Value.replace('"','')) -Parent) }
        }

    }
    [void] tag_action(){
        $tag   = $this._ma.groups['tag'].Value
        $param = $this._ma.groups['param'].Value

        $search = $global:TTResources.GetChild('Searchs').children[$tag]

        switch ($search.Url){
            "thinktank_tag" {
                switch( $tag ){
                    'Route' { [TTTagAction]::route_tag( $param ); return }
                    'memo'  { [TTTagAction]::memo_tag( $param ); return }
                    'mail'  { [TTTagAction]::mail_tag( $param ); return }
                    'ref'   { [TTTagAction]::ref_tag( $param ); return }
                    'photo' { [TTTagAction]::photo_tag( $param ); return }
                }
            }
            default {
                [TTTool]::open_url( ( $_ -replace "\[param\]", $param ) )
            }
        }
    }


    static [void] route_tag( $param ){
        if( $param.Trim() -eq "" ){ return }
        $dest = ""
        $waypnt = ""
        $points = $param.split(",").foreach{$_.Trim()}
        $orig = $points[0]
        switch( $points.count ){
            1 {
                $dest = $points[0]
                $waypnt = ""
            }
            2 { 
                $dest = $points[1]
                $waypnt = ""
            }
            default{
                $dest = $points[-1]
                $waypnt = "&waypoints=" + ($points[1..($points.count-2)] -join "|") 
            }
        }
        [TTTool]::open_url( "https://www.google.com/maps/dir/?api=1&origin=$orig&destination=$dest&travelmode=driving&dir_action=navigate$waypnt" ) 
   
    }
    static [void] mail_tag( $param ){
        if( $param -eq "" ){ return }
    
        $outlook = New-Object -ComObject Outlook.Application
        try {
            $backupFolder = $null
            $backupFolderName = $global:TTResources.GetChild('Configs').GetChild("OutlookBackupFolder").Value
    
            $folders = $outlook.GetNamespace('MAPI').Folders
            for( $i = 1; $i -le $folders.count; $i++ ){ 
                if( $folders.Item($i).Name -eq $backupFolderName ){ $backupFolder = $folders.Item($i) }
            }
    
            if( $param -match "\d{4}\-\d{2}\-\d{2}\-\d{6}"){
                # display Mail with memoid 
                #'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                $time = [DateTime]::ParseExact( $param, "yyyy-MM-dd-HHmmss", $null )
                $time1 = $time.AddMinutes(-2).ToString("yyyy/MM/d H:mm")
                $time2 = $time.AddMinutes(+2).ToString("yyyy/MM/d H:mm")
                $items = $backupFolder.Items.Restrict( "[ReceivedTime] >= '$time1' AND [ReceivedTime] < '$time2'" )
                for( $j = 1; $j -Le $items.count; $j++ ){
                    if( $items.Item($j).ReceivedTime.ToString("yyyy-MM-dd-HHmmss") -eq $time.ToString("yyyy-MM-dd-HHmmss") ){
                        $items.Item($j).GetInspector().Display()
                    }
                } 
                
            }else{
                # show Mails with keyword
                #'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                $explorer = $backupFolder.GetExplorer( 2 ) # olFolderDisplayNoNavigation, 2
                # $explorer.SelectActions()
                $explorer.Search( $param, 2 ) # olSearchScopeAllOutlookItems, 2
                $explorer.Display()
                $explorer.WindowState = 0 # olMaximized, 0
                # SelectAllItems()
            }
        } finally {
            [void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($outlook)
        }
    
    }
    static [void] memo_tag( $param ){ # 中途

        switch -regex ( $param ){
            # [memo:xxxx-xx-xx-xxxxxx] MemoIDを開く
            "^(\d{4}\-\d{2}\-\d{2}\-\d{6}|thinktank)$" {        
                $global:appcon.tools.editor.load( $param )
                break
            }

            # [memo:xxxx-xx-xx-xxxxxx:数字:数字] MemoIDを開いて数字行に飛ぶ
            "^(?<index>(\d{4}\-\d{2}\-\d{2}\-\d{6}|thinktank)):(?<line>\d+(?<col>:\d+)?)$" { 
                $editor = $global:appcon.tools.editor.load( $Matches.index )
                $editor.move_to( $Matches.line )
                $editor.select_to('linestart')
                break
            }

            # [memo:xxxx-xx-xx-xxxxxx:#文字] MemoIDを開いて文字をキーワードに設定して、最初のSectionに飛ぶ
            "^(?<index>(\d{4}\-\d{2}\-\d{2}\-\d{6}|thinktank)):#(?<keyword>.+)$" {
                Write-Host "未完成"
                return

                $global:appcon.group.keyword( 'Desk', $Matches.line )
                $editor = $global:appcon.tools.editor.load( $Matches.index )
                $editor.move_to('documentstart')
                $editor.move_to('nextkeywordnode')
                $editor.select_to( $Matches.keyword )
                break
            }
            # [memo:xxxx-xx-xx-xxxxxx:文字] MemoIDを開いて文字をキーワードに設定して、最初の場所に飛ぶ
            "^(?<index>(\d{4}\-\d{2}\-\d{2}\-\d{6}|thinktank)):(?<keyword>.+)$" {
                Write-Host "未完成"
                return

                $global:appcon.group.keyword( 'Desk', $Matches.line )
                $editor = $global:appcon.tools.editor.load( $Matches.index )
                $editor.move_to('documentstart')
                $editor.move_to('nextkeyword')
                $editor.select_to( $Matches.keyword )
                break
            }

            # [memo:x文字] Cabinet.keywordに入力してタイトルでフィルターする
            "^(?<header>.)(?<keyword>.+)$" {
                Write-Host "未完成"
                return

                [TTTool]::display_resource( "Memo", 'shelf' )
                $script:shelf.search( $Matches.keyword ).focus()
                break
            }

            # [memo:#文字] 全文検索する
            "^#(?<keyword>.+)$" {
                write-host "全文検索#"
                break
            }

            # [memo:文字] 全文検索する
            "^(?<keyword>.+)$" {
                write-host "全文検索"
                break
            }

        }

        return
    }
    static [void] ref_tag( $param ){ # 未実装 
        Write-Host "ref_tag $param"
        return
    }
    static [void] photo_tag( $param ){ # 未実装
        Write-Host "photo_tag $param"
        return
    }
   
}

#endregion###############################################################################################################

#region　TTTagFormat
#########################################################################################################################
class TTTagFormat {
    static [hashtable] $tags = @{ # tag, std, jp2, jp1
        tag = @{ 
            id = 'tag'
            regex = '(\[(?<year>[0-9]{4})\-(?<month>[0-9]{2})\-(?<day>[0-9]{2})\](( (?<hour>[0-9]{2}):(?<min>[0-9]{2}))|(?<wd>\(...\)))?[ 　]*)'
            culture = { return New-Object cultureinfo('en-US') }
            format = @{
                standard = "[yyyy-MM-dd] "
                extend   = "[yyyy-MM-dd] HH:mm "
                weekday  = "[yyyy-MM-dd](ddd) "
            }
        }
        std = @{
            id = 'std'
            regex ='((?<year>[0-9]{4})\/(?<month>[0-9]{1,2})\/(?<day>[0-9]{1,2})(( (?<hour>[0-9]{2}):(?<min>[0-9]{2}))|(?<wd>\(...\)))?[ 　]*)'
            culture = { return New-Object cultureinfo('en-US') }
            format = @{
                standard = "yyyy/MM/dd "
                extend   = "yyyy/MM/dd HH:mm "
                weekday  = "yyyy/MM/dd(ddd) "
            }
        }
        jp2 = @{
            id = 'jp2'
            regex='((?<gengo>明治|大正|昭和|平成|令和)(?<nen>[0-9]{1,2})年(?<month>[0-9]{1,2})月(?<day>[0-9]{1,2})日((( (?<hour>[0-9]{2})時(?<min>[0-9]{2})分)|(?<wd>（.）)))?[ 　]*)'
            culture = { $cul = New-Object cultureinfo('ja-JP'); $cul.DateTimeFormat.Calendar = New-Object System.Globalization.JapaneseCalendar; return $cul }
            format = @{
                standard = "ggyy年MM月dd日 "
                extend   = "ggyy年MM月dd日 HH時mm分 "
                weekday  = "ggyy年MM月dd日（ddd） "
            }
        }
        jp1 = @{
            id = 'jp1'
            regex='((?<year>[0-9]{4})年(?<month>[0-9]{1,2})月(?<day>[0-9]{1,2})日((( (?<hour>[0-9]{2})時(?<min>[0-9]{2})分)|(?<wd>（.）)))?[ 　]*)'
            culture = { return New-Object cultureinfo('ja-JP') }
            format = @{
                standard = "yyyy年MM月dd日 "
                extend   = "yyyy年MM月dd日 HH時mm分 "
                weekday  = "yyyy年MM月dd日（ddd） "
            }
        }

    }
    [string] $id
    [string] $format
    [long] $offset
    [long] $length
    [DateTime] $date
    [DateTime] $init
    $formats = @( 'standard', 'extend', 'weekday' )
    

    TTTagFormat() { $this.reset() }

    [string] tag() {
        $fmt = [TTTagFormat]::tags[$this.id].format[$this.format] 
        return $this.date.tostring( $fmt )
    }
    [object[]] tags() {
        return @( 
            foreach( $tag in [TTTagFormat]::tags.Values ){
                $fmt = $tag.format[$this.format]
                $culture = &($tag.culture)
                $this.date.ToString( $fmt, $culture )
            }
        )
    }
    [TTTagFormat] AddYears( $n ){ $this.date = $this.date.AddYears( $n ); return $this }
    [TTTagFormat] AddMonths( $n ){ $this.date = $this.date.AddMonths( $n ); return $this }
    [TTTagFormat] AddDays( $n ){ $this.date = $this.date.AddDays( $n ); return $this }
    [TTTagFormat] AddFormat( $n ){ $this.format = $this.formats[ ( $n + $this.formats.IndexOf( $this.format ) ) % $this.formats.count ]; return $this }
    [TTTagFormat] date( $d ){ $this.date = $d; return $this }    
    [TTTagFormat] restore(){ $this.date = $this.ini; return $this }    

    [void] scan( $editor ){
        $ofst = $editor.CaretOffset
        $year = $month = $day = $hour = $min = $wd = $tag_id = $fmt = "" 
        $tag_offset = $tag_length = 0

        foreach( $tag in [TTTagFormat]::tags.Values ){
                $ma = [TTTagAction]::New($editor).regex_at($tag.regex)
            if( -not $ma ){ continue }
    
            $tag_offset = $editor.Document.GetLineByOffset( $ofst ).offset + $ma.Index
            $tag_length = $ma.Length
            $tag_id     = $tag.id 
    
            switch( $tag.id ){
                "jp2" { switch( $ma.groups["gengo"].Value ){
                    "明治" { $year = 1867 + $ma.groups['nen'].Value }
                    "大正" { $year = 1911 + $ma.groups['nen'].Value }
                    "昭和" { $year = 1925 + $ma.groups['nen'].Value }
                    "平成" { $year = 1988 + $ma.groups['nen'].Value }
                    "令和" { $year = 2018 + $ma.groups['nen'].Value }
                }}
                default { $year  = $ma.groups['year'].Value }
            }
            $month = $ma.groups['month'].Value
            $day   = $ma.groups['day'].Value
            $hour  = $ma.groups['hour'].Value
            $min   = $ma.groups['min'].Value
            $wd    = $ma.groups['wd'].Value
    
            switch( $true ){
                { $wd -ne "" }{ $fmt = 'weekday'; break }
                { $hour -ne "" }{ $fmt = 'extend'; break }
                default { $fmt = 'standard'; break }
            }
            break
        }

        if( $year ){ 
            $this.date = Get-Date -year $year -month $month -day $day -hour $hour -min $min
            $this.id     = $tag_id
            $this.format = $fmt
            $this.offset = $tag_offset
            $this.length = $tag_length
            $this.init   = $this.date
        }else{
            $this.date = Get-Date
            $this.id     = 'tag'
            $this.format = 'standard'
            $this.offset = 0
            $this.length = 0
            $this.init   = $this.date
        }        
    }
    [void] reset(){
        $this.id = ""
        $this.format = $this.formats[0]
        $this.offset = 0
        $this.length = 0
        $this.date = Get-Date
        $this.init = Get-Date
    }
    
}

#endregion###############################################################################################################

#region　static TTTentativeKeyBindingMode
#########################################################################################################################
class TTTentativeKeyBindingMode{
    static [string] $Name = ''
    static [string] $Mod = ''
    static [string] $Key = ''
    static [ScriptBlock] $OnExit = {}

    static [void] Initialize(){
        [TTTentativeKeyBindingMode]::Name = ''
        [TTTentativeKeyBindingMode]::Mod = ''
        [TTTentativeKeyBindingMode]::Key = ''
        [TTTentativeKeyBindingMode]::OnExit = {}
    }
    static [void] Start( $name, $mod, $key ){
        [TTTentativeKeyBindingMode]::Name = $name
        [TTTentativeKeyBindingMode]::Mod = $mod
        [TTTentativeKeyBindingMode]::Key = $key
    }
    static [void] Add_OnExit( $onexit ){
        [TTTentativeKeyBindingMode]::OnExit = $onexit
    }
    static [bool] Check( $key ){ 
        # Alt/CtrlのKeyUpは、Preview.KeyUpでkeyを確認できる。
        # KeyUpイベントで以下を用いてmodeから抜ける。
        # switch( "$([TTTentativeKeyBindingMode]::Mod)" ){
        switch( [TTTentativeKeyBindingMode]::Mod ){
                'Alt' {
                if( $key -in @('RightAlt', 'LeftAlt') ){
                    &([TTTentativeKeyBindingMode]::OnExit)
                    [TTTentativeKeyBindingMode]::Initialize()
                    return $true 
                }
            }
            'Control' {
                if( $key -in @('RightCtrl', 'LeftCtrl')){
                    &([TTTentativeKeyBindingMode]::OnExit)
                    [TTTentativeKeyBindingMode]::Initialize()
                    return $true
                }
            }
        }
        return $false
    }
    static [bool] IsNotActive(){
        return ( [TTTentativeKeyBindingMode]::Name -eq '' )
    }
}

#endregion###############################################################################################################

