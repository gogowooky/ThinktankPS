




#region　TTObject / TTCollection / TTResources
#########################################################################################################################
class TTObject {
    hidden [string] $flag
    [string] $Name

    TTObject(){ 
        $this.flag = ""
        $this.Name = ""
    }
    [string] GetFilename(){
        return "" 
    }
    [hashtable] GetDictionary() { 
        return @{
            _flag       = "フラグ"
            ShelfFormat = "_flag,Name"
            IndexFormat = "_flag,Name"
            Index       = "Name"
        }
    }
    [void] DoAction() {
        [TTTool]::debug_message( $this.GetType().Name, "Do Action $($this.Name)" )
    }
    [void] SelectActions() {
        [TTTool]::debug_message( $this.GetType().Name, "Select Actions $($this.Name)" )
    }
    [void] DiscardResources() {
        [TTTool]::debug_message( $this.GetType().Name, "Discard Resources $($this.Name)" )
    }
}

class TTCollection : TTObject {
    [string]$Description
    [string]$Type
    [string]$ChildType
    [string]$UpdateDate

    hidden [hashtable]$children = @{}
    hidden [int] $_count
    hidden [bool]$loading
    hidden [psobject[]]$menus = @(
        @{ keys = "_B)はじめに";                    value = {ttcmd_application_help_breifing} },
        @{ keys = "_U)使い方";                      value = {ttcmd_application_help_instruction} },
        @{ keys = "_O)その他,_S)ショートカットキー"; value = {ttcmd_application_help_shortcuts} },
        @{ keys = "_O)その他,_V)バージョン";        value = {ttcmd_application_help_version} }
        @{ keys = "_O)その他,_S)サイト";            value = {ttcmd_application_help_site} }
    )
    [void] DoAction() {
        ([TTObject]$this).DoAction()
        [TTTool]::display_resource( $this.Name, 'shelf' )
    }
    [void] SelectActions() {
        [TTTool]::debug_message( $this.Type, "Select Actions $($this.Name) in Index" )
        [TTTool]::display_resource( $this.Name, 'index' )
    }
    [string] GetFilename() { # Name.cahce
        return "$script:TTCacheDirPath\$($this.Name).cache"
    }
    [hashtable] GetDictionary(){ return @{
        _count      = "件数"
        Name        = "名前"
        Description = "説明"
        UpdateDate  = "更新日"
        ShelfFormat = "Description,_count,Name,UpdateDate"
        Index       = "Name"
    }}
    [void] LoadCache() { # 単純読込、　Clear無し、AddChildで登録
        # ファイルを読み込む (空行＊, Format-List形式(自己プロパティ), 空行＋, CSV(子プロパティ))

        if ( -not (Test-Path $this.GetFilename()) ) { return }

        $lines = (Get-Content $this.GetFilename() ) -as [string[]]
        $n = 0

        while ( $lines[$n] -eq '' ) { $n += 1 }
        while ( $lines[$n] -ne '' ) {
            $key, $val = ( $lines[$n].split(":", 2) ).Trim()
            $this.$key = $val
            $n += 1
        }
        $tmp_update = $this.UpdateDate
        while ( $lines[$n] -eq '' ) { $n += 1 }

        $itms = [psobject[]]@( ($lines[$n..$lines.count] -join "`r`n") | ConvertFrom-Csv )

        $this.loading = $true
        $itms.foreach{ $this.AddChild( ($_ -as $this.ChildType) ) }
        $this.loading = $false

        $this.UpdateDate = $tmp_update
    }
    [void] SaveCache() { # 単純書込、
        # 現データをファイルに保存する (空行, Format-List形式(自己プロパティ), 空行, CSV(子プロパティ))
        if( $script:app._istrue( "Config.CacheSavedMessage" ) ){       
            [TTTool]::debug_message( $this, "saved >> $($this.GetFilename())" )
        }
        $this                 | Format-List | Out-File $this.GetFilename()
        $this.children.values | ConvertTo-Csv -NoTypeInformation | Out-File $this.GetFilename() -Append
    }
    [array] GetChildren() { # 全Children
        return @($this.children.values)
    }
    [array] GetChildren( $filter ) { # filterに合致したChildren
        if ( 0 -lt $filter.length ) {
            return @(
                $this.children.Values.where{
                    $child = $_
                    $child_content = ( @($child.GetDictionary().Keys.foreach{ $child.$_ }) -join "," )
                    @($filter.Trim().split(",").foreach{
                            @($_.split(" ").foreach{
                                    if ( $_ -like "-*" ) {
                                        # 除外 
                                        $child_content -notlike "*$($_.substring(1))*" 
                                    }
                                    else {
                                        # 選択
                                        $child_content -like "*$_*"
                                    }
                                }) -notcontains $false
                        }) -contains $true
                }
            )
        }
        else {
            return @($this.children.values)
        }
    }
    [TTObject] GetChild( $index ) { # indexで特定child
        if ( $this.children.ContainsKey( $index ) ) {
            return ( $this.children[ $index ] -as $this.ChildType )
        }
        else {
            return $null
        }
    }
    [void] DiscardResources() {
        $deleted_date = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
        Move-Item -Path $this.GetFilename() -Destination $script:TTBackupDirPath -Force
        Rename-Item -Path "$script:TTBackupDirPath\$($this.Name).cache" -NewName "$($this.Name)_deleted_at_$($deleted_date).cache"
        $this.UpdateDate = $deleted_date
        $this.SaveCache()
    }

    # 派生型毎に要再定義
    [void] Initialize(){ # Clear - LoadCache - Update
        $this.Clear()
        $this.LoadCache()
        $this.Update()
    }
    [void] Clear(){ # childrenのみ
        $this.children = @{}        
    }
    [bool] Update() { # 定義すること
        return $true
    }
    [void] AddChild( $item ) { # 登録・更新日変更・保存。　loadCache中は登録のみ

        $this.children[ $item.$($item.GetDictionary().Index) ] = $item

        if( $this.loading -eq $false ){
            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            $this.SaveCache()
        }
    }
    [void] DeleteChild( $index ) {
        $this.GetChild( $index ).DiscardResources()
        $this.children.Remove( $index )
        $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
        $this.SaveCache()
    }
}

class TTResources : TTCollection {
    TTResources() {
        $this.Name =        "Thinktank"
        $this.Description = "全キャッシュ"
        $this.UpdateDate =  "1970-03-11-000000" # needs to be enough old
        $this.Type =        "TTResources"
        $this.ChildType =   "TTCollection"

    }
    [void] Initialize(){ # Clear - LoadCache - Update
        #region initialize folder 
        #'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
        $script:TTRootDirPath = (Split-Path $PSScriptRoot -Parent)
        $lines = @(
            Get-ChildItem -Path "$script:TTRootDirPath\thinktank.md" | `
            Select-String "^Thinktank:設定@?(?<pcname>.*)?:MemoFolder" | `
            Select-Object -Property Filename, LineNumber, Matches, Line
        )
        $memofolder = ""
        foreach ( $line in $lines ) {
            $line.Line -match "Thinktank:設定@?(?<pcname>.*)?:MemoFolder,\s*(?<description>[^,]+)\s*,\s*(?<value>[^,]+)\s*"
            $ma = $Matches
            if ( 0 -lt $ma.pcname.length ) {
                if ( $ma.pcname.Trim() -eq $Env:COMPUTERNAME ) { 
                    $memofolder = $ma.value.Trim()
                    break
                }
            }
            else {
                $memofolder = $ma.value.Trim()
            }
        }
        if ( $memofolder -eq "" ) { $memofolder = $script:TTRootDirPath + "\text" }
    

        $script:TTScriptDirPath = $script:TTRootDirPath + "\script"
        $script:TTMemoDirPath = $memofolder
        $script:TTScriptName -match 'thinktank(?<num>.?)\.ps1'
        $script:TTCacheDirPath = "$memofolder\cache" + $Matches.num
        $script:TTBackupDirPath = "$memofolder\backup"
        New-Item $script:TTMemoDirPath -ItemType Directory -Force
        New-Item $script:TTCacheDirPath -ItemType Directory -Force
        New-Item $script:TTBackupDirPath -ItemType Directory -Force
        #endregion''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

        $this.Clear()
        $this.LoadCache()
        $this.Update()
    }
    [void] AddChild( $item ) { # loadCache中はUpdate/SaveCacheしない
        # overwrite： TTResourcesはChildTypeに型変換しない（すべてTTCollectionがBase）

        if( ( -not $this.loading ) -or 
            ( $this.children -notcontains $item.Name ) -or 
            ( $this.children[ $item.Name ].UpdateDate -lt $item.UpdateDate )
        ){
            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            [TTTask]::Register( 
                "TTResources:AddChild", 30, 0, { $script:TTResources.SaveCache() }
            )
        }

        $this.children[ $item.Name ] = $item
    }
    [void] Update(){
        ForEach( $child in $this.children.Values ){
            if( $this.UpdateDate -lt $child.UpdateDate ){
                $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
                [TTTask]::Register( 
                    "TTResources:Update", 30, 0, { $script:TTResources.SaveCache() }
                )    
            }
        }
    }
    [array] GetChildren() { # 全Children
        $this.children.Values.foreach{ $_._count = $_.children.count }
        return @(([TTCollection]$this).GetChildren())
    }
    [array] GetChildren( $filter ) { # filterに合致したChildren
        $this.children.Values.foreach{ $_._count = $_.children.count }
        return @(([TTCollection]$this).GetChildren( $filter ))
    }

}

#endregion###############################################################################################################

#region　クラス TTConfig / TTConfigs
#########################################################################################################################
class TTConfig : TTObject {
    [string]$Description
    [string]$Value
    [string]$PCName
    [string]$MemoPos
    [string]$UpdateDate

    [hashtable] GetDictionary() { return @{
        Name        = "名前"
        Description = "説明"
        Value       = "設定値"
        PCName      = "PC名"
        MemoPos     = "記載場所"
        UpdateDate  = "更新日"
        ShelfFormat = "Name,Description,Value,PCName,MemoPos,UpdateDate"
        IndexFormat = "Name,Description"
        Index       = "Name"
    }}

    [void] DoAction() {
        switch -wildcard ( $this.Name ){
            "*Folder" { Start-Process $this.Value }
        }
    }

}

class TTConfigs: TTCollection {
    TTConfigs() {
        $this.Name          = "Config"
        $this.Description   = "設定値"
        $this.Type          = "TTConfigs"
        $this.ChildType     = "TTConfig"
        $this.UpdateDate    = "1970-03-11-000000" # needs to be enough old
    }
    [void] Initialize(){ # LoadCache - Update
        $this.LoadCache()
        $this.Update()

        $this.AddChild( [TTConfig]@{
            Name = "RootFolder"
            Description = "ルートフォルダ"
            Value = $script:TTRootDirPath
            PCName = ""
            MemoPos = "thinktank-modes.ps1"
            UpdateDate = "1970-03-11-000000"
        })
        $this.AddChild( [TTConfig]@{ 
            Name = "MemoFolder"
            Description = "メモフォルダ"
            Value = $script:TTMemoDirPath
            PCName = ""
            MemoPos = "thinktank-modes.ps1"
            UpdateDate = "1970-03-11-000000"
        })
        $this.AddChild( [TTConfig]@{ 
            Name = "CacheFolder"
            Description = "キャッシュフォルダ"
            Value = $script:TTCacheDirPath
            PCName = ""
            MemoPos = "thinktank-modes.ps1"
            UpdateDate = "1970-03-11-000000"
        })
        $this.AddChild( [TTConfig]@{ 
            Name = "BackupFolder"
            Description = "バックアップフォルダ"
            Value = $script:TTBackupDirPath
            PCName = ""
            MemoPos = "thinktank-modes.ps1"
            UpdateDate = "1970-03-11-000000"
        })
        $this.AddChild( [TTConfig]@{ 
            Name = "ScriptFolder"
            Description = "スクリプトアップフォルダ"
            Value = $script:TTScriptDirPath
            PCName = ""
            MemoPos = "thinktank-modes.ps1"
            UpdateDate = "1970-03-11-000000"
        })
        $this.AddChild( [TTConfig]@{ 
            Name = "ScriptFolder"
            Description = "スクリプトアップフォルダ"
            Value = $script:TTScriptDirPath
            PCName = ""
            MemoPos = "thinktank-modes.ps1"
            UpdateDate = "1970-03-11-000000"
        })

    }
    [void] AddChild( $item ) { # loadCache中はUpdate/SaveCacheしない
        # ChildTypeに型変換してから登録
        $child = $item -as $this.ChildType
        $this.children[ $child.$($child.GetDictionary().Index) ] = $child

        if( $this.loading -eq $false ){
            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            [TTTask]::Register( 
                "TTConfigs:AddChild", 30, 0, { $script:TTConfigs.SaveCache() }
            )
        }
    }
    [bool] Update() {

        $lines = @(
            Get-ChildItem -Path @( "$script:TTMemoDirPath\????-??-??-??????.txt", "$script:TTRootDirPath\thinktank.md" ) | `
                Where-Object { $this.UpdateDate -Lt $_.LastWriteTime.ToString("yyyy-MM-dd-HHmmss") } | `
                Select-String "^Thinktank:設定" | `
                Select-Object -Property Filename, LineNumber, Matches, Line
        )

        if ( 0 -Lt $lines.Count ) {
            ForEach ( $line in $lines ) {
                $file = Get-Item -Path ([TTTool]::index_to_filepath( $line.Filename ))
                $line.Line -match "Thinktank:設定@?(?<pcname>.*)?:(?<name>[^,@]+)\s*,\s*(?<description>[^,]+)\s*,\s*(?<value>[^,]+)\s*"
                $ma = $Matches
                if ( 0 -lt $ma.pcname.length ) {
                    if ( $ma.pcname.Trim() -ne $Env:COMPUTERNAME ) { continue }
                }
                else {
                    if ( $this.children.contains($ma.name.Trim()) ) { continue }
                }

                $child = New-Object -TypeName $this.ChildType
                $child.Name = $ma.name.Trim()
                $child.Value = $ma.value.Trim()
                $child.PCName = ($ma.pcname + "").Trim()
                $child.Description = $ma.description.Trim()
                $child.UpdateDate = $file.LastWriteTime.ToString("yyyy-MM-dd-HHmmss")
                $child.MemoPos = ([String]::Format( "{0}:{1}:{2}", $file.BaseName, $line.LineNumber, $line.Matches[0].Index ))
                $this.AddChild( $child )
            }

            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            return $true

        }
        else {
            return $false
        }
    }
    [void] DeleteChild( $index ) {
        $this.children.Remove( $index )

        $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
        [TTTask]::Register( 
            "TTConfigs:DeleteChild", 30, 0, { $script:TTConfigs.SaveCache() }
        )
    }

}

#endregion###############################################################################################################

#region　クラス TTState / TTStatus
#########################################################################################################################
class TTState : TTObject {
    [string]$Value

    [hashtable] GetDictionary() { return @{
        Name    = "名前"
        Value   = "設定値"
        ShelfFormat = "Name,Value"
        IndexFormat = "Name,Value"
        Index   = "Name"
    }}
    [void] DoAction() {
        [TTTool]::debug_message( "TTState", "$($this.Name) : $($this.Value)" )
    }

}

class TTStatus : TTCollection {
    TTStatus() {
        $this.Name          = "Status"
        $this.Description   = "ステータス"
        $this.UpdateDate    = "1970-03-11-000000" # needs to be enough old
        $this.Type          = "TTStatus"
        $this.ChildType     = "TTState"
    }
    [void] Initialize(){
        return
    }
    [string] Get( $name ) {
        $value = $this.children[$name].Value
        return $value
    }
    [void] Set( $name, $value ) {
        $name = $name.Trim()
        $value = ([string]$value).Trim()

        switch -regex ( $value ){
            '^[\-\+]\d+$' { 
                $value = [string]( [int]($value) + [int]$this.Get($name) ) 
            }
        }

        if( $this.children.Keys -contains $name ){
            $this.children[ $name ].Value = $value
        }else{
            $this.children[ $name ] = [TTState]@{ Name = $name; Value = $value }
        }

        $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")

        [TTTask]::Register( 
            "TTStatus:Set", 10, 0, {
                $script:TTStatus.SaveCache()
                $script:index.refresh()
                $script:TTStatus.menus = @()
                $script:TTStatus.GetChildren().foreach{
                    $value = [ScriptBlock]::Create( "`$script:TTStatus.GetChild(`"$($_.($_.GetDictionary().Index))`").DoAction()" )
                    $script:TTStatus.menus += [psobject]@{ keys = $_.Name.replace(".",","); value = $value }
                }
            }
        )
    }
}

#endregion###############################################################################################################

#region　クラス TTCommand / TTCommands
#########################################################################################################################
class TTCommand : TTObject {
    [string]$Description

    [hashtable] GetDictionary() { return @{
        Name        = "名前"
        Description = "説明"
        ShelfFormat = "Name,Description"
        IndexFormat = "Description,Name"
        Index       = "Name"
    }}
    [void] DoAction() {
        [TTTool]::debug_message( "TTCommand", "Execute Command: $($this.Name)" )
        Invoke-Expression -Command $this.Name
    }
}

class TTCommands: TTCollection {
    TTCommands() {
        $this.UpdateDate    = "1970-03-11-000000" # needs to be enough old
        $this.Name          = "Command"
        $this.Description   = "コマンド"
        $this.Type          = "TTCommands"
        $this.ChildType     = "TTCommand"
    }
    Initialize(){
        $this.Clear()
        # $this.LoadCache()
        $this.Update()

        $this.menus = @()
        $this.GetChildren().foreach{
            $keys = @( $_.Name.Replace( "ttcmd_", "" ).split("_").foreach{ 
                        (Get-Culture).TextInfo.ToTitleCase($_).Insert(1,")").Insert(0,"_")
                    }) -join ","
            $value = [ScriptBlock]::Create( "`$script:TTCommands.GetChild(`"$($_.($_.GetDictionary().Index))`").DoAction()" )
            $this.menus += [psobject]@{ keys = $keys; value = $value }
        }
        

    }
    [bool] Update() {
        $lines = @(
            Get-ChildItem -path function: | `
                ForEach-Object { $_.Name } | `
                Where-Object { $_ -like "ttcmd_*" }
        )

        if ( 0 -Lt $lines.Count ) {
            ForEach ( $line in $lines ) {
                $child = New-Object -TypeName $this.ChildType
                $child.Name = $line
                $child.Description = ( Get-Help $line | foreach-Object { $_.synopsis.split('|')[0] } )
                $this.AddChild( $child ) 
            }
            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            return $true

        }
        else {
            return $false
        }
    }
    [void] AddChild( $item ) {
        # ChildTypeに型変換してから登録
        $child = $item -as $this.ChildType
        $this.children[ $child.$($child.GetDictionary().Index) ] = $child

        if( $this.loading -eq $false ){
            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            [TTTask]::Register( 
                "TTCommands:AddChild", 30, 0, { $script:TTCommands.SaveCache() }
            )
        }
    }
    [void] DeleteChild( $name ) {
        return
    }
}

#endregion###############################################################################################################

#region　クラス TTSearchMethod / TTSearchMethods
#########################################################################################################################
class TTSearchMethod : TTObject {
    [string]$Category       # Google:Japan
    [string]$UpdateDate     # xxxx-xx-xx-xxxxxx
    [string]$MemoPos        # xxxx-xx-xx-xxxxxx:line:column
    [string]$Url            # http://www.google.co.jp/search?q=[param] 
    [string]$Tag            # Google

    [hashtable] GetDictionary() { return @{
        Name        = "名前"
        Category    = "分類"
        UpdateDate  = "更新日"
        MemoPos     = "記載場所"
        Url         = "URL"
        Tag         = "タグ"
        ShelfFormat = "Name,Tag,Category,MemoPos,UpdateDate,Url"
        IndexFormat = "Tag,Name"
        Index       = "Tag"
    }}
    [void] DoAction() {
        $keyword = $script:app.keyword()
        [TTTool]::debug_message( "TTSearchMethod", "Search $keyword at $($this.Name)" )
        [TTTagAction]::tag_action( $this.Tag, $keyword )
    }

}

class TTSearchMethods: TTCollection {
    TTSearchMethods() {
        $this.UpdateDate    = "1970-03-11-000000" # needs to be enough old
        $this.Name          = "Search"
        $this.Description   = "検索"
        $this.Type          = "TTSearchMethods"
        $this.ChildType     = "TTSearchMethod"

        $this.children = @{
            'Route' = [TTSearchMethod]@{  
                Name       = "グーグルルート検索"
                Category   = "Google:Route"
                UpdateDate = ( Get-Date ).ToString("yyyy-MM-dd-HHmmss")
                MemoPos    = "thinktank-model.ps1"
                Url        = "thinktank_tag"
                Tag        = 'Route'
            }
            'memo'  = [TTSearchMethod]@{
                Name       = "テキストタグ"
                Category   = "Thinktank:Tag"
                UpdateDate = ( Get-Date ).ToString("yyyy-MM-dd-HHmmss")
                MemoPos    = "thinktank-model.ps1"
                Url        = "thinktank_tag"
                Tag        = 'memo'
            }
            'mail'  = [TTSearchMethod]@{
                Name       = "メールタグ"
                Category   = "Thinktank:Mail"
                UpdateDate = ( Get-Date ).ToString("yyyy-MM-dd-HHmmss")
                MemoPos    = "thinktank-model.ps1"
                Url        = "thinktank_tag"
                Tag        = 'mail'
            }
            'ref'   = [TTSearchMethod]@{ 
                Name       = "参照タグ"
                Category   = "Thinktank:Reference"
                UpdateDate = ( Get-Date ).ToString("yyyy-MM-dd-HHmmss")
                MemoPos    = "thinktank-model.ps1"
                Url        = "thinktank_tag"
                Tag        = 'ref'
            }
            'photo' = [TTSearchMethod]@{ 
                Name       = "写真タグ"
                Category   = "Thinktank:Photo"
                UpdateDate = ( Get-Date ).ToString("yyyy-MM-dd-HHmmss")
                MemoPos    = "thinktank-model.ps1"
                Url        = "thinktank_tag"
                Tag        = 'photo'
            }
        }
    }
    [void] SaveCache() {
        # overwrite : thinktank.xshdも更新

        ([TTCollection]$this).SaveCache()

        $xaml_path = "$script:TTScriptDirPath\thinktank.xshd"
        if ( (Get-Item $xaml_path).LastWriteTime.ToString("yyyy-MM-dd-HHmmss") -Lt $this.UpdateDate ) {
            $tag = @()
            $searchtag = @()
            $this.children.values.foreach{
                if ( $_.Url -like "ttcmd_*" ) {
                    $tag += $_.Tag
                }
                else {
                    $searchtag += $_.Tag
                }
            }
            $content = (Get-Content $xaml_path)
            $content = ($content -replace '\<Span color\="Tag" (.*) \/\>', ('<Span color="Tag" begin="\[(' + ($tag -join "|") + '):" end="\]" />') )
            $content = ($content -replace '\<Span color\="SearchTag" (.*) \/\>', ('<Span color="SearchTag" begin="\[(' + ($searchtag -join "|") + '):" end="\]" />') )
            $content | Set-Content $xaml_path -Encoding UTF8
        }
    }
    [bool] Update() {
        $lines = @(
            Get-ChildItem -Path @( "$script:TTMemoDirPath\????-??-??-??????.txt", "$script:TTRootDirPath\thinktank.md" ) | `
                Where-Object { $this.UpdateDate -Lt $_.LastWriteTime.ToString("yyyy-MM-dd-HHmmss") } | `
                Select-String "^Thinktank:検索:" | `
                Select-Object -Property Filename, LineNumber, Matches, Line
        )

        if ( 0 -Lt $lines.Count ) {
            foreach ( $line in $lines ) {
                $file = Get-Item -Path ([TTTool]::index_to_filepath( $line.Filename ))
                $line.Line -match "Thinktank:検索:(?<title>[^,]+\s*)\[(?<tag>[^,]+)\]\s*,\s*(?<url>[^,]+)(,(?<catalog>.*))?"
                $ma = $Matches

                $child = New-Object -TypeName $this.ChildType
                $child.Tag = $ma.tag
                $child.Name = $ma.title.Trim()
                $child.Url = $ma.url.Trim()
                $child.Category = $ma.catalog.Trim()
                $child.UpdateDate = $file.LastWriteTime.ToString("yyyy-MM-dd-HHmmss")
                $child.MemoPos = ([String]::Format( "{0}:{1}:{2}", $file.BaseName, $line.LineNumber, $line.Matches[0].Index ))
                $this.AddChild( $child )
            }

            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            return $true

        }
        else {
            return $false
        }
    }
    [void] AddChild( $item ) {
        # ChildTypeに型変換してから登録
        $child = $item -as $this.ChildType
        $this.children[ $child.$($child.GetDictionary().Index) ] = $child

        if( $this.loading -eq $false ){
            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            [TTTask]::Register( 
                "TTSearchMethods:AddChild", 30, 0, { $script:TTSearchs.SaveCache() }
            )
        }
    }
    [void] DeleteChild( $index ) {
        $memo = $this.GetChild( $index ).MemoPos.split(":")
        $file = $memo[0] + ".txt"
        $line = $memo[1]
        Write-Host "ファイル$file $line 行目のアクションタグ[$index]を削除してください"
    }
    [string]GetActionTagsRegex(){
        return ( $this.children.Keys -join "|" )
    }
    [void] Initialize(){
        $this.LoadCache()
        $this.Update()

        $this.menus = @()
        $this.GetChildren().foreach{
            $keys = $_.Category.replace( ":", "," ) + "," + ($_.Name+(" "*30)).SubString(0,30).replace(","," ")
            $value = [ScriptBlock]::Create( "`$script:TTSearchs.GetChild(`"$($_.($_.GetDictionary().Index))`").DoAction()" )
            $this.menus += [psobject]@{ keys = $keys; value = $value }
        }
    
    }

}

#endregion###############################################################################################################

#region　クラス TTExternalLink / TTExternalLinks
#########################################################################################################################
class TTExternalLink : TTObject {
    [string]$Category
    [string]$UpdateDate
    [string]$MemoPos
    [string]$Uri
    
    [hashtable] GetDictionary() { return @{
        Name        = "名前"
        Category    = "分類"
        UpdateDate  = "更新日"
        MemoPos     = "記載場所"
        Uri         = "URI"
        ShelfFormat = "Name,Category,MemoPos,UpdateDate,Uri"
        IndexFormat = "Name"
        Index       = "Uri"
    }}
    [void] DoAction() {
        [TTTool]::debug_message( "TTExternalLink", "Open Site of $($this.Name)" )
        [TTTool]::open_url( $this.Uri )
    }

}

class TTExternalLinks: TTCollection {
    TTExternalLinks() {
        $this.UpdateDate    = "1970-03-11-000000" # needs to be enough old
        $this.Name          = "Link"
        $this.Description   = "リンク"
        $this.Type          = "TTExternalLinks"
        $this.ChildType     = "TTExternalLink"
    }
    hidden [void] AddChildFromBrowser( $folder, $foldernames ) {
        foreach ( $item in $folder.children ) {
            switch ( $item.type ) {
                "url" {
                    $child = New-Object -TypeName $this.ChildType
                    $child.Name = $item.name
                    $child.Uri = $item.url
                    $child.Category = $foldernames
                    $child.UpdateDate = (Get-Date).ToString("yyyy-MM-dd-HHmmss")
                    $child.MemoPos = $foldernames.split(":")[0]
                    $this.AddChild( $child )
                }
                "folder" {
                    $this.AddChildFromBrowser( $item, "$($foldernames):$($item.name)" )
                }
            }
        }
    }
    [bool] Update() {
        $upd = $this.UpdateDate

        $appdata = [Environment]::GetFolderPath("LocalApplicationData")
        $bookmarks = @( 
            Get-ChildItem -Path @(
                "$appdata\Microsoft\Edge\User Data\Default\Bookmarks", 
                "$appdata\Google\Chrome\User Data\Default\Bookmarks" ) | `
                Where-Object { $this.UpdateDate -Lt $_.LastWriteTime.ToString("yyyy-MM-dd-HHmmss") }
        )
        foreach ( $bookmark in $bookmarks ) {
            $json = ( Get-Content -Encoding UTF8 $bookmark | out-string | ConvertFrom-Json )
            switch -wildcard ( $bookmark ) {
                "*Edge*" { $this.AddChildFromBrowser( $json.roots.bookmark_bar, "Edge" ) }
                "*Chrome*" { $this.AddChildFromBrowser( $json.roots.bookmark_bar, "Chrome" ) }
            }                
        }

        $this.UpdateDate = $upd

        $lines = @(
            Get-ChildItem -Path @( "$script:TTMemoDirPath\????-??-??-??????.txt", "$script:TTRootDirPath\thinktank.md" ) | `
                Where-Object { $this.UpdateDate -Lt $_.LastWriteTime.ToString("yyyy-MM-dd-HHmmss") } | `
                Select-String "^Thinktank:URI:" | `
                Select-Object -Property Filename, LineNumber, Matches, Line
        )
        if ( 0 -Lt $lines.Count ) {
            foreach ( $line in $lines ) {
                $file = Get-Item -Path ([TTTool]::index_to_filepath( $line.Filename ))
                $line.Line -match "Thinktank:URI:(?<title>[^,]+)\s*,\s*(?<uri>[^,]+)(,(?<shortcut>.*))?"
                $ma = $Matches

                $child = New-Object -TypeName $this.ChildType
                $child.Name = $ma.title.Trim()
                $child.Uri = $ma.uri.Trim()
                $child.Category = $ma.shortcut.Trim()
                $child.UpdateDate = $file.LastWriteTime.ToString("yyyy-MM-dd-HHmmss")
                $child.MemoPos = ([String]::Format( "{0}:{1}:{2}", $file.BaseName, $line.LineNumber, $line.Matches[0].Index ))
                $this.AddChild( $child )
            }

            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            return $true

        }
        else {
            return $false
        }

    }
    [void] AddChild( $item ) {
        # ChildTypeに型変換してから登録
        $child = $item -as $this.ChildType
        $this.children[ $child.$($child.GetDictionary().Index) ] = $child

        if( $this.loading -eq $false ){
            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            [TTTask]::Register( 
                "TTExternalLinks:AddChild", 30, 0, { $script:TTLinks.SaveCache() }
            )
        }
    }
    [void] DeleteChild( $index ) {
        $memo = $this.GetChild( $index ).MemoPos.split(":")
        $file = $memo[0] + ".txt"
        $line = $memo[1]
        Write-Host "ファイル$file $line 行目のアクションタグ[$index]を削除してください"
    }
    [void] Initialize(){
        $this.LoadCache()
        $this.Update()
    
        $this.menus = @()
        $this.GetChildren().foreach{
            $keys = $_.Category.replace( ":", "," ) + "," + ($_.Name+(" "*30)).SubString(0,30).replace(","," ")
            $value = [ScriptBlock]::Create( "`$script:TTLinks.GetChild(`"$($_.($_.GetDictionary().Index))`").DoAction()" )
            $this.menus += [psobject]@{ keys = $keys; value = $value }
        }

    }
        
}

#endregion###############################################################################################################

#region　クラス TTMemo / TTMemos
#########################################################################################################################
class TTMemo : TTObject {
    [string]$MemoID
    [string]$UpdateDate
    [string]$Title

    [hashtable] GetDictionary() { return @{
        MemoID      = "メモID"
        UpdateDate  = "更新日"
        Title       = "タイトル"
        flag        = "編"
        ShelfFormat = "flag,UpdateDate,MemoID,Title"
        IndexFormat = "flag,Title"
        Index       = "MemoID"
    }}

    [void] DoAction() {
        [TTTool]::debug_message( "TTMemo", "Open Memo $($this.MemoID) : $($this.Title)" )
        [TTTool]::open_memo( $this.MemoID )
    }

    [void] SelectActions() {
        [TTTool]::debug_message( "TTMemo", "Activate Memo $($this.MemoID) : $($this.Title)" )
        [TTTool]::open_memo( $this.MemoID )
    }

    [string] GetFilename() { return "$script:TTMemoDirPath\$($this.MemoID).txt" }

    [void] DiscardResources() {
        $deleted_date = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
        Move-Item -Path $this.GetFilename() -Destination $script:TTBackupDirPath -Force
        Rename-Item -Path "$script:TTBackupDirPath\$($this.MemoID).txt" -NewName "$($this.MemoID)_deleted_at_$($deleted_date).txt"
    }

}

class TTMemos: TTCollection {
    TTMemos() {
        $this.UpdateDate    = "1970-03-11-000000" # needs to be enough old
        $this.Name          = "Memo"
        $this.Description   = "メモ"
        $this.Type          = "TTMemos"
        $this.ChildType     = "TTMemo"
    }
    [void] Initialize(){
        $this.LoadCache()
        $this.Update()

        $this.menus = @()
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
                $value = [ScriptBlock]::Create( "[TTTool]::shelf_keyword(`"$($ma.keywords.Trim())`")" )
                $this.menus += [psobject]@{ keys = $keys; value = $value }    
            }
        }

    }

    [bool] Update() {
        $lines = @( 
            Get-ChildItem -Path @(  "$script:TTMemoDirPath\????-??-??-??????.txt", "$script:TTRootDirPath\thinktank.md" ) | `
                Where-Object { $this.UpdateDate -Lt $_.LastWriteTime.ToString("yyyy-MM-dd-HHmmss") } 
        )

        if ( 0 -Lt $lines.Count ) {
            foreach ( $line in $lines ) {
                $child = New-Object -TypeName $this.ChildType
                $child.MemoID = $line.BaseName
                $child.Title = Get-Content $line.FullName -totalcount 1 -Encoding UTF8
                $child.UpdateDate = $line.LastWriteTime.ToString("yyyy-MM-dd-HHmmss")
                $this.AddChild( $child )
            }

            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            return $true

        }
        else {
            return $false
        }
    }
    [void] AddChild( $item ) {
        # ChildTypeに型変換してから登録
        $child = $item -as $this.ChildType
        $this.children[ $child.$($child.GetDictionary().Index) ] = $child

        if( $this.loading -eq $false ){
            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            [TTTask]::Register( 
                "TTMemos:AddChild", 30, 0, { $script:TTMemos.SaveCache() }
            )
        }
    }
    [void] DeleteChild( $index ) {
        $this.GetChild( $index ).DiscardResources()
        $this.children.Remove( $index )
        $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
        $this.SaveCache()
    }
    [string] CreateChild() {
        $time = Get-Date
        $memoid = $time.tostring('yyyy-MM-dd-HHmmss')
        $filepath = "$script:TTMemoDirPath\$memoid.txt"
        $title = "[$memoid] New Memo"
        $text = "$title`r`n==========================================================================================================`r`n"
        $text | Out-File $filepath  -Encoding utf8

        $child = New-Object -TypeName $this.ChildType
        $child.MemoID = $memoid
        $child.Title = $title
        $child.UpdateDate = $memoid
        $this.AddChild( $child )

        return $memoid
    }
}



#endregion###############################################################################################################

#region　クラス TTExMemo / TTExMemos
#########################################################################################################################
class TTExMemo : TTMemo {
    [string]$MemoID
    [string]$UpdateDate
    [string]$Title
    [string]$Snippet

    [hashtable] GetDictionary() { return @{
        MemoID      = "メモID"
        UpdateDate  = "更新日"
        Title       = "タイトル"
        Snippet     = "ヒット文字列"
        flag        = "編"
        ShelfFormat = "flag,UpdateDate,MemoID,Snippet,Title"
        IndexFormat = "flag,Snippet"
        Index       = "MemoID"
    }}
    [void] DoAction() {
        [TTTool]::debug_message( "TTExMemo", "Open Memo $($this.MemoID) : $($this.Title)" )
        [TTTool]::open_memo( $this.MemoID )
    }
    [void] SelectActions() {
        [TTTool]::debug_message( "TTExMemo", "Activate Memo $($this.MemoID) : $($this.Title)" )
        [TTTool]::open_memo( $this.MemoID )
    }

}

class TTExMemos : TTMemos {
    hidden [string]$search_keyword

    TTExMemos() {
        $this.UpdateDate    = "1970-03-11-000000" # needs to be enough old
        $this.Name          = "MemoEx_0000-00-00-000000"
        $this.Description   = "検索語"
        $this.Type          = "TTExMemos"
        $this.ChildType     = "TTExMemo"
    }
    [TTExMemos] Keyword( $keyword ) {
        $this.search_keyword = $keyword
        $time = (Get-Date).tostring( "yyyy-MM-dd-HHmmss")

        $this.Name = "ExMemo_$time"
        $this.Description = $keyword
        $this.UpdateDate = "1970-03-11-000000" # needs to be enough old
        $this.Update()

        return $this
    }
    [bool] Update() {
        $lines = @( 
            Get-ChildItem -Path @( "$script:TTMemoDirPath\????-??-??-??????.txt", "$script:TTRootDirPath\thinktank.md" ) | `
            Where-Object { $this.UpdateDate -Lt $_.LastWriteTime.ToString("yyyy-MM-dd-HHmmss") } | `
            Select-String $this.search_keyword -List -SimpleMatch | `
            Select-Object -Property Filename, LineNumber, Matches, Line
        )

        if ( 0 -Lt $lines.Count ) { # ここできてない
            foreach ( $line in $lines ) {
                $child = New-Object -TypeName $this.ChildType
                $child.MemoID = $line.FileName -replace "\..*", ""
                $child.Title = $script:TTMemos.GetChild( $child.MemoID ).Title
                $child.UpdateDate = $script:TTMemos.GetChild( $child.MemoID ).UpdateDate
                $child.Snippet = ( $line.Line + ' ' * 80 ).Substring(0,80).trim()
                $this.AddChild( $child )
            }

            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            return $true

        }
        else {
            return $false
        }

    }

}


#endregion###############################################################################################################

#region　クラス TTEditing / TTEditings
#########################################################################################################################
class TTEditing : TTObject {
    [string]$MemoID     # xxxx-xx-xx-xxxxxx or thinktank
    [string]$UpdateDate
    [string]$Offset     # offset
    [bool]$WordWrap     
    [string]$Foldings   # 3,5,6,15,22,30

    [hashtable] GetDictionary() { return @{
        MemoID      = "メモID"
        UpdateDate  = "更新日"
        Offset      = "カーソル位置"
        WordWrap    = "ワードラップ"
        Foldings    = "折畳み位置"
        ShelfFormat = "MemoID,UpdateDate,Offset,Foldings,WordWrap"
        IndexFormat = "MemoID"
        Index       = "MemoID"
    }}

}

class TTEditings: TTCollection {
    TTEditings() {
        $this.UpdateDate    = "1970-03-11-000000" # needs to be enough old
        $this.Name          = "Editing"
        $this.Description   = "編集状態"
        $this.Type          = "TTEditings"
        $this.ChildType     = "TTEditing"
    }
    [void] AddChild( [ICSharpCode.AvalonEdit.TextEditor]$editor ) {
        $name = $editor.Name
        $config = $script:DocMan.config.$name
        
        $item = [TTEditing]::new()
        $item.MemoID = ( $editor.Document.FileName -replace '.+[\\/](?<memoid>[\w\-]+)\..{2,5}', '${memoid}' )
        $item.Offset = ( $editor.CaretOffset )
        $item.Foldings = @( $config.foldman.AllFoldings.where{ $_.IsFolded }.foreach{ $_.StartOffset } ) -join ","
        $item.WordWrap = $editor.WordWrap
        $item.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
        $this.children[$item.MemoID] = $item

        if( $this.loading -eq $false ){
            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            $this.SaveCache()
        }
    }
    [void] Initialize(){
        $this.LoadCache()
    }
}
#endregion###############################################################################################################



