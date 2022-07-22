


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
            $url = $url.replace( "[param]", [System.Web.HttpUtility]::UrlEncode($script:app.keyword()) )
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
    static [string] $_modkey
    static [string] $_key
    static [object] $_copied

    static [void]Copy( [string]$text ){
        [Clipboard]::SetText( $text )    
    }
    static [void]Copy( [object]$object ){ # TTObject
        [Clipboard]::SetData( "TTObject", $object )
        [TTClipboard]::_copied = $object
    }
    static [void]Copy( [object]$object, [string]$text ){ # text,TTObject
        $data = [DataObject]::New( "TTObject", $object )
        $data.SetText( $text )
        [Clipboard]::SetDataObject( $data )
        [TTClipboard]::_copied = $object
    }
    static [void]PasteTo( $target, $modkey, $key ){
        [TTClipboard]::_target = $target
        [TTClipboard]::_modkey = $modkey
        [TTClipboard]::_key = $key
        [TTClipboard]::_type = ""

        switch( $true ){
            { [Clipboard]::ContainsFileDropList() }             { [TTClipboard]::_type += "FileDropList," }
            { [Clipboard]::ContainsAudio() }                    { [TTClipboard]::_type += "Audio," }
            { [Clipboard]::ContainsText() }                     { [TTClipboard]::_type += "Text," }
            { [Clipboard]::ContainsImage() }                    { [TTClipboard]::_type += "Image," }
            { [Clipboard]::ContainsData("CSV") }                { [TTClipboard]::_type += "CSV," }
            { [Clipboard]::ContainsData("Rich Text Format") }   { [TTClipboard]::_type += "Rtf," }
            { [Clipboard]::ContainsData("HTML Format") }        { [TTClipboard]::_type += "Html," }
            { [Clipboard]::ContainsData("DataInterchangeFormat") }  { [TTClipboard]::_type += "DataInterchangeFormat," }
            { [Clipboard]::ContainsData("TTObject") }           { [TTClipboard]::_type += "TTObject" }
            default{ [TTClipboard]::_type += "no-category," }
        }

        switch( [TTClipboard]::_type ){
            "Text,"                  { [TTClipboard]::paste_url_text() }
            "FileDropList,Text,CSV," { [TTClipboard]::paste_outlookmail() }
            "Text,CSV,"              { [TTClipboard]::paste_outlookmails() } 
            "FileDropList,Text,"     { [TTClipboard]::paste_outlookschedule() }
            "Image,"                 { [TTClipboard]::paste_image() } 
            "Image,Html,"            { [TTClipboard]::paste_image() } 
            "Text,Rtf,Html,"         { [TTClipboard]::paste_word() } 
            "FileDropList,"          { [TTClipboard]::paste_files_folders() }
            "Text,Html,"             { [TTClipboard]::paste_favorites_and_text() }
            "Text,Image,CSV,Rtf,Html,DataInterchangeFormat," { [TTClipboard]::paste_excelrange() } 
            "TTObject"               { [TTClipboard]::paste_ttobject() } 
            "Text,TTObject"          { [TTClipboard]::paste_ttobject_text() } 
            default                  { Write-Host "not supported: $([TTClipboard]::_type)" }
        }
    }
    static [void] paste_ttobject_text(){
        $text   = [Clipboard]::GetText()
        $doc    = [TTClipboard]::_target.Document
        $offset = [TTClipboard]::_target.CaretOffset
        $modkey = [TTClipboard]::_modkey
        $key = [TTClipboard]::_key
        $target = [TTClipboard]::_target 
        $copied = [TTClipboard]::_copied

        switch( $copied.GetType().Name ){
            'TTMemo' { 
                $items = @{
                    "@[memo:$($copied.MemoID):$text]"     = 'memoid'
                    "[memo:$($copied.MemoID):$text] $($copied.Title)"  = 'title'
                }
                switch( $items[ [string](ShowPopupMenu $items.keys $modkey $key "Memo" $target) ] ){
                    'memoid' { $doc.Insert( $offset, "[memo:$($copied.MemoID):$text]" ) }
                    'title'  { $doc.Insert( $offset, "[memo:$($copied.MemoID):$text] $($copied.Title)" ) }
                }    
            }
        }
    }
    static [void] paste_ttobject(){
        $doc    = [TTClipboard]::_target.Document
        $offset = [TTClipboard]::_target.CaretOffset
        $modkey = [TTClipboard]::_modkey
        $key = [TTClipboard]::_key
        $target = [TTClipboard]::_target 
        $copied = [TTClipboard]::_copied

        switch( $copied.GetType().Name ){
            'TTMemo' { 
                $items = @{
                    "@[memo:$($copied.MemoID)]"     = 'memoid'
                    "[memo:$($copied.MemoID)] $($copied.Title)"  = 'title'
                }
                switch( $items[ [string](ShowPopupMenu $items.keys $modkey $key "Memo" $target) ] ){
                    'memoid' { $doc.Insert( $offset, "[memo:$($copied.MemoID)]" ) }
                    'title'  { $doc.Insert( $offset, "[memo:$($copied.MemoID)] $($copied.Title)" ) }
                }    
            }
        }
    
    }
    static [void] paste_url_text(){

        $text   = [Clipboard]::GetText()
        $doc    = [TTClipboard]::_target.Document
        $offset = [TTClipboard]::_target.CaretOffset
        $modkey = [TTClipboard]::_modkey
        $key = [TTClipboard]::_key
        $target = [TTClipboard]::_target 

        if( $text -match "^https?://[^　 \[\],;`&lt;&gt;&quot;&apos;]+"){
    
            # url
            #'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
            $items = @{
                "@そのまま"     = 'raw'
                "URLデコード"   = 'decode'
                "# ⇒ [タイトル](URL)"  = 'title'
            }
            switch( $items[ [string](ShowPopupMenu $items.keys $modkey $key "URL" $target) ] ){
                'raw'    { $doc.Insert( $offset, $text ) }
                'decode' { $doc.Insert( $offset, [System.Web.HttpUtility]::UrlDecode($text) ) }
                'title'  {
                    if( ( Invoke-WebRequest $text ).Content -match "\<title\>(.+)\<\/title\>" ){
                        $text = [System.Web.HttpUtility]::UrlDecode( $text )
                        $doc.Insert( $offset, "[$($Matches[1])]($text)" )
                    }else{
                        $text = [System.Web.HttpUtility]::UrlDecode( $text )
                        $doc.Insert( $offset, "[NoTitle]($text)" )
                    }
                }
            }
    
        }else{
    
            # text
            #'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
            $items = @{
                "@そのまま"     = 'raw'
                "コメント化"    = 'commentize'
                "URLデコード"   = 'decode'
                "URLエンコード" = 'encode'
            }
            switch( $items[ [string](ShowPopupMenu $items.keys $modkey $key "Text" $target) ] ){
                'raw'    { $doc.Insert( $offset, $text ) }
                'decode' { $doc.Insert( $offset, [System.Web.HttpUtility]::UrlDecode($text) ) }
                'encode' { $doc.Insert( $offset, [System.Web.HttpUtility]::UrlEncode($text) ) }
                'commentize' {
                    $text =  @($text.split("`r`n").where{$_ -ne ""}.foreach{ "; $_" }) -join "`r`n"
                    $doc.Insert( $offset, $text )
                }
            }
        }
    }
    static [void] paste_outlookmail(){
        [TTClipboard]::paste_outlookmails()
    }
    static [void] paste_outlookmails(){
        $titles = (([Clipboard]::GetText() -replace "`t", ",")).件名
        $outlook = New-Object -ComObject Outlook.Application
    
        try {
            $fmt = ""
            $mails = $outlook.ActiveExplorer().Selection
    
            for( $i = 1; $i -le $mails.count; $i++ ){
                $mail = $mails.Item($i)
                if( $mail.Subject -notin $titles ){ continue }
    
                $id    = (Get-Date $mail.ReceivedTime).tostring("yyyy-MM-dd-HHmmss")
                $title = $mail.Subject
                $sendername = $mail.Sender.Name
                $body = @(($mail.body.split("From")[0]).split("`r`n").where{ $_ -ne "" }.foreach{ "; "+$_ }) -join "`r`n"
    
                $modkey = [TTClipboard]::_modkey
                $key = [TTClipboard]::_key
                $target = [TTClipboard]::_target

                if( $fmt -eq "" ){
                    $items = @{
                        "[mail:$($id)]"                = '"[mail:$($id)]"'
                        "[mail:$($id)]:$sendername"    = '"`r`n[mail:$($id)]:$sendername"'
                        "⇒ $title[mail:$($id)]"      = '"⇒ $title[mail:$($id)]`r`n"'
                        "⇒ $title[mail:$($id)]＋本体"  = '"`r`n# ⇒ $title[mail:$($id)]`r`n$body`r`n"'
                    }

                    $fmt = $items[ [string](ShowPopupMenu $items.keys $modkey $key "メール" $target) ]
                    if( 0 -eq $fmt.length ){ return }
                }
                $target.Document.Insert( $target.CaretOffset, (Invoke-Expression $fmt) )
    
                $backupFolderName = $global:TTConfigs.GetChild("OutlookBackupFolder").Value
                $mailFolderName = $mail.parent.FolderPath.substring(2)
                foreach( $folder in $outlook.GetNamespace("MAPI").Folders ){
                    if( ($folder.Name -eq $backupFolderName) -and
                        ($folder.Name -ne $mailFolderName) ){ $mail.Move( $folder ) } 
                }
            }
        
        } finally {
            [void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($outlook)
        }
    }
    static [void] paste_outlookschedule(){ # 未実装
        $text = [Clipboard]::GetText()                   # 件名（場所）
        $filedroplist = [Clipboard]::GetFileDropList()   # error
    }
    static [void] paste_image(){ # 未実装
    
        # $image = [Clipboard]::GetImage()  # image:System.Windows.Interop.InteropBitmap
    
        $folder = $global:TTConfigs.GetChild("CaptureFolder").value
        if( (Test-Path $folder) -eq $false ){ $folder = [Environment]::GetFolderPath('MyPictures') }
        $folder = $folder + "\thinktank\" + (Get-Date).ToString("yyyy-MM-dd")
        if( (Test-Path $folder) -eq $false ){ New-Item $folder -ItemType Directory }
        $filename = $folder + "\" + (Get-Date).ToString("yyyy-MM-dd-HHmmss") + ".png"
    
        (Get-Clipboard -Format Image).Save( $filename )
    
        [TTClipboard]::_target.Document.Insert( [TTClipboard]::_target.CaretOffset, "$filename`r`n" )
    }
    static [void] paste_word(){
        [TTClipboard]::paste_url_text()
        # $text = [Clipboard]::GetText()                              # word text
        # $rtf = [Clipboard]::GetDataObject("Rich Text Format")       # no datd
        # $html = [Clipboard]::GetDataObject("Html")                  # no data
    }
    static [void] paste_files_folders(){ # 未実装
        $filedroplist = [Clipboard]::GetFileDropList()
        Write-Host "filedroplist:$filedroplist" # [stringcollection]fullpath
    }
    static [void] paste_favorites_and_text(){
        [TTClipboard]::paste_url_text()
        # $text = [Clipboard]::GetText()                # ブラウザ text, thinktank text, ブラウザリンク
        # $html = [Clipboard]::GetDataObject("Html")    # no data
    }
    static [void] paste_excelrange(){ # 未実装
        # $text = [Clipboard]::GetText()
        # $image = [Clipboard]::GetImage()            # string
        # $csv = [Clipboard]::GetDataObject("CSV")    # image:System.Windows.Interop.InteropBitmap
        # $rtf = [Clipboard]::GetDataObject("Rich Text Format")      # no datd
        # $html = [Clipboard]::GetDataObject("Html")                 # no datd
        # $dif = [Clipboard]::GetDataObject("DataInterchangeFormat") # no datd
    }

}

#endregion###############################################################################################################

#region　TTTagAction
#########################################################################################################################
class TTTagAction{
    [System.Text.RegularExpressions.Match] $_ma
    [object] $_editor
    [int] $_offset

    [psobject[]] $_tags = @(
        @{  tag     = 'tag'    
            regex   = "\[(?<tag>$($global:TTSearchs.GetActionTagsRegex())):(?<param>[^\[\]]+)\]" }, 
        @{  tag     = 'date'
            regex   = "(\[[0-9]{4}\-[0-9]{2}\-[0-9]{2}\])" },
        @{  tag     = 'event'
            regex   = '(\[(?<date>[0-9]{4}\-[0-9]{2}\-[0-9]{2}):(?<tag>\w+)(?<alert>:\d+[dmy])?\])' },
        @{  tag     = 'check'
            regex   = '(\[[ox_]\])' },
        @{  tag     = 'url'
            regex   = "((https?://[^　 \[\],;<>\`"\']+)|(`"https?://[^\[\],;<>\`"\']+)`")" },
        @{  tag     = 'path'
            regex   = '(([a-zA-Z]:\\[\w\\\-\.]*|"[a-zA-Z]:\\[\w\\\-\.].*")|(\\\\[\w\\\-\.]*|"\\\\[\w\\\-\.].*"))' }
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
                'tag'   { $this.tag_DoAction(); break }
                'date'  { $this.date_DoAction(); break }
                'event' { $this.event_DoAction(); break }           
                'check' { $this.check_DoAction(); break }
                'url'   { $this.url_DoAction(); break }
                'path'  { $this.path_DoAction(); break }
            }
        }
    }

    [void] tag_DoAction(){
        $tag   = $this._ma.groups['tag'].Value
        $param = $this._ma.groups['param'].Value 
        [TTTagAction]::tag_action( $tag, $param )
    }
    [void] date_DoAction(){ # 未実装
        return
    }
    [void] event_DoAction(){ # 未実装
        return
    }
    [void] check_DoAction(){
        $ma = $this._ma
        $offset = $this._offset
        $editor = $this._editor
        $curline = $editor.Document.GetLineByOffset( $offset )

        $editor.Document.Replace( $curline.offset + $ma.Index, 3, @{"[o]"="[x]";"[x]"="[_]";"[_]"="[o]"}[ $ma.Value ] )
        $editor.CaretOffset = $offset
    }
    [void] url_DoAction(){
        $actions = [hashtable]@{
            "@URLを開く"        = 'open url'
            "一つ上のURLを開く" = 'open parent url'
        }
        $select = (ShowPopupMenu $actions.Keys 'Control' 'Space' "URL" $this._editor )
        switch( $actions[$select] ){
            'open url'        { [TTTool]::open_url( $this._ma.Value ) }
            'open parent url' { [TTTool]::open_url( (Split-Path $this._ma.Value -Parent) ) }
        }
    }
    [void] path_DoAction(){
        $actions = @{
            "@ファイルを開く"    = 'open file'
            "ディレクトリを開く" = 'open directory'
        }
        $select = (ShowPopupMenu $actions.keys 'Control' 'Space' "ファイル" $this._editor )
        switch( $actions[$select] ){
            'open file'      { Start-Process $this._ma.Value }
            'open directory' { Start-Process (Split-Path ($this._ma.Value.replace('"','')) -Parent) }
        }

    }


    static [void] tag_action( $tag, $param ){
        $search = $global:TTSearchs.children[$tag]

        switch ($search.Url){
            "thinktank_tag" {
                switch($search.Tag){
                    'Route' { [TTTagAction]::tag_route( $param ); return }
                    'memo'  { [TTTagAction]::tag_memo( $param ); return }
                    'mail'  { [TTTagAction]::tag_mail( $param ); return }
                    'ref'   { [TTTagAction]::tag_ref( $param ); return }
                    'photo' { [TTTagAction]::tag_photo( $param ); return }
                }
            }
            default {
                [TTTool]::open_url( ( $_ -replace "\[param\]", $param ) )
            }
        }
    }
    static [void] tag_route( $param ){
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
    
        Start-Process "https://www.google.com/maps/dir/?api=1&origin=$orig&destination=$dest&travelmode=driving&dir_action=navigate$waypnt"
   
    }
    static [void] tag_mail( $param ){
        if( $param -eq "" ){ return }
    
        $outlook = New-Object -ComObject Outlook.Application
        try {
            $backupFolder = $null
            $backupFolderName = $global:TTConfigs.GetChild("OutlookBackupFolder").Value
    
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
                        $items.Item($j).GetDictionary()
                    }
                } 
                
            }else{
                # show Mails with keyword
                #'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                $explorer = $backupFolder.GetExplorer( 2 ) # olFolderDisplayNoNavigation, 2
                $explorer.SelectActions()
                $explorer.Search( $param, 2 ) # olSearchScopeAllOutlookItems, 2
                $explorer.WindowState = 0 # olMaximized, 0
                $explorer.SelectAllItems
            }
        } finally {
            [void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($outlook)
        }
    
    }
    static [void] tag_memo( $param ){ # 未完成

        switch -regex ( $param ){
            # [memo:xxxx-xx-xx-xxxxxx] MemoIDを開く
            "^(\d{4}\-\d{2}\-\d{2}\-\d{6}|thinktank)$" {        
                $script:desk.tool( 'Editor2' ).load( $param )
                ttcmd_desk_borderstyle_work12
                ttcmd_desk_works_focus_work2
                break
            }

            # [memo:xxxx-xx-xx-xxxxxx:数字:数字] MemoIDを開いて数字行に飛ぶ
            "^(?<index>(\d{4}\-\d{2}\-\d{2}\-\d{6}|thinktank)):(?<line>\d+(:\d+)?)$" { 
                $script:desk.tool( 'Editor2' ).load( $Matches.index ).move_to( $Matches.line )
                ttcmd_desk_borderstyle_work12
                ttcmd_desk_works_focus_work2
                break
            }

            # [memo:xxxx-xx-xx-xxxxxx:#文字] MemoIDを開いて文字をキーワードに設定して、最初のSectionに飛ぶ
            "^(?<index>(\d{4}\-\d{2}\-\d{2}\-\d{6}|thinktank)):#(?<keyword>.+)$" {
                $script:desk.tool( 'Editor2' ).load( $Matches.index ).search( $Matches.keyword ).move_to( 'nextkeywordnode' )
                ttcmd_desk_borderstyle_work12
                ttcmd_desk_works_focus_work2
                break
            }
            # [memo:xxxx-xx-xx-xxxxxx:文字] MemoIDを開いて文字をキーワードに設定して、最初の場所に飛ぶ
            "^(?<index>(\d{4}\-\d{2}\-\d{2}\-\d{6}|thinktank)):(?<keyword>.+)$" {
                $script:desk.tool( 'Editor2' ).load( $Matches.index ).search( $Matches.keyword ).move_to( 'nextkeyword' )
                ttcmd_desk_borderstyle_work12
                ttcmd_desk_works_focus_work2
                break
            }

            # [memo:shelf:文字] Shelf.keywordに入力してタイトルでフィルターする
            "^shelf:(?<keyword>.+)$" {
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
    static [void] tag_ref( $param ){ # 未実装 
        Write-Host "tag_ref $param"
        return
    }
    static [void] tag_photo( $param ){ # 未実装
        Write-Host "tag_photo $param"
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
        switch( "$([TTTentativeKeyBindingMode]::Mod)" ){
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

