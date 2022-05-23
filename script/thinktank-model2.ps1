




#region　TTObject / TTCollection / TTResources
#########################################################################################################################
class TTObject {

    #region Object itself (Dictionary)

    hidden [string] $flag
    [string] $Name
    
    TTObject(){                     # should be override
        $this.flag = ""
        $this.Name = ""
    }
    [hashtable] GetDictionary() {   # should be override 
        return @{
            flag =  "フラグ"
            Name =  "名前"
            Index = "Name"
        }
    }
    [string] GetFilename(){         # should be override
        return "" 
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    
    #region Object Display
    [hashtable] GetDisplay() {      # should be override 
        return @{
            ShelfFormat = "flag,Name"
            IndexFormat = "flag,Name"
        }
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    
    #region Object Action
    [psobject[]] GetActions() {     # should be override
        return @( 
            @{  Name = "InvokeAction"
                Description = "実行する"
                Script = {
                    param($e)
                    return $true
                }
            },
            @{  Name = "Discard"
                Description = "リソースを開放する"
                Script = {
                    param($e)
                    return $true
                }
            }
        )
    }
    [bool] DoAction( $name ){
        $script = $this.GetActions().where{ $_.Name -eq $name }[0].Script
        return &$script $this
    }
    [bool] SelectActions() {
        $ttl = "$($this.Name):アクション選択"
        $acts = $this.GetActions().Description
        $select = [TTPopupMenu]::Initialize().title( $ttl ).items( $acts ).show()
        if ( $null -eq $select ){ return $false }
        return $this.DoAction( $this.GetActions().where{ $_.Description -eq $select }[0].Name )
    }

    #endregion ----------------------------------------------------------------------------------------------------------

}

class TTCollection : TTObject {

    #region Object itself

    static [string] $MessageOnSaving = "False"

    [string]$Description
    [string]$UpdateDate

    hidden [hashtable]$children
    hidden [int] $count
    hidden [bool]$loading
    hidden [string] $ChildType = "TTObject"

    TTCollection(){                 # should be override
        $this.Name =            "TTCollection"
        $this.Description  =    ""
        $this.UpdateDate =      "1970-03-11-000000"
        $this.children =        @{}
        $this.count =          0
        $this.loading =         $false
    }
    [hashtable] GetDictionary() {   # should be override
        return @{
            count      =   "件数"
            flag =         "フラグ"
            Name =          "名前"
            Description =   "説明"
            UpdateDate =    "更新日"
            Index =         "Name"
        }
    }
    [string] GetFilename() { 
        return "$script:TTCacheDirPath\$($this.Name).cache"
    }
    [void] Initialize(){            # should be override
        $this.children = @{}
        $this.LoadCache()
        $this.Update()
    }
    [void] LoadCache() {
        # ファイルを読み込む (空行＊, Format-List形式(自己プロパティ), 空行＋, CSV(子プロパティ))

        if (( 0 -eq $this.GetFilename().length ) -or
            ( -not (Test-Path $this.GetFilename())) ) { return }

        $lines = ( Get-Content $this.GetFilename() ) -as [string[]]
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
    [bool] Update() {               # should be defined
        return $true
    }
    [void] AddChild( $item ) {      # should be override
        $child = ( $item -as $this.ChildType )
        $this.children[ $child.$($child.GetDictionary().Index) ] = $child

        if( $this.loading -eq $false ){
            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            $this.count = $this.children.count
            $this_name = $this.Name 
            [TTTask]::Register( 
                "($this.GetType().Name):AddChild", 30, 0, 
                { 
                    $script:Resources.GetChild( $script:this_name ).SaveCache()
                }.GetNewClosure()
            )
        }


    }
    [void] SaveCache() {
        # 現データをファイルに保存する (空行, Format-List形式(自己プロパティ), 空行, CSV(子プロパティ))
        if( [bool]([TTCollection]::MessageOnSaving) -eq 'True' ){       
            [TTTool]::debug_message( $this, "saved >> $($this.GetFilename())" )
        }
        $this                 | Format-List | Out-File $this.GetFilename()
        $this.children.values | ConvertTo-Csv -NoTypeInformation | Out-File $this.GetFilename() -Append
    }
    [array] GetChildren() {
        return @($this.children.values)
    }
    [array] GetChildren( $keyword ) {

        $keyword = $keyword.Trim()
        if ( 0 -eq $keyword.length ) { return @($this.children.Values) }

        return @(
            $this.children.Values.where{
                $child = $_
                $child_content = ( @($child.GetDictionary().Keys.foreach{ $child.$_ }) -join "," )
                @($keyword.split(",").foreach{
                    @($_.Trim().split(" ").foreach{
                        if ( $_ -like "-*" ) { # 除外 
                            $child_content -notlike "*$($_.substring(1))*" 
                        } else { # 選択
                            $child_content -like "*$_*"
                        }
                    }) -notcontains $false
                }) -contains $true
            }
        )
    }
    [TTObject] GetChild( $index ) {
        if ( $this.children.ContainsKey( $index ) ) {
            return ( $this.children[ $index ] -as $this.ChildType )
        } else {
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
    [void] DeleteChild( $index ) {
        $this.GetChild( $index ).DiscardResources()
        $this.children.Remove( $index )

        if( $this.loading -eq $false ){
            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            $_._count = $_.children.count
            $this.SaveCache()
        }
    }

    #endregion ----------------------------------------------------------------------------------------------------------


    #region Object Display
    $menus = @(
        @{  Titles =    "_B)はじめに"
            Value =     {ttcmd_application_help_breifing} },
        @{  Titles =    "_U)使い方"
            Value =     {ttcmd_application_help_instruction} },
        @{  Titles =    "_O)その他,_S)ショートカットキー"
            Value =     {ttcmd_application_help_shortcuts} },
        @{  Titles =    "_O)その他,_V)バージョン"
            Value =     {ttcmd_application_help_version} },
        @{  Titles =    "_O)その他,_S)サイト"
            Value =     {ttcmd_application_help_site} }
    )

    [hashtable] GetDispaly(){
        return @{
            ShelfFormat = "Description,_count,Name,UpdateDate"
            IndexFormat = "Name,_count,Description"
        }
    }

    #endregion ----------------------------------------------------------------------------------------------------------


    #region Object Action
    [psobject[]] GetActions() {
        return @( 
            @{  Name = "DisplayShelf"
                Description = "Shelfに表示する"
                Script = {
                    param($e)
                    return $true
                }
            },
            @{  Name = "DisplayIndex"
                Description = "Indexに表示する"
                Script = {
                    param($e)
                    return $true
                }
            },
            @{  Name = "Discard"
                Description = "キャッシュを開放する"
                Script = {
                    param($e)
                    return $true
                }
            }
        )
    }
    #endregion ----------------------------------------------------------------------------------------------------------

}

class TTResources : TTCollection {

    #region Object itself

    hidden [string] $ChildType = "TTCollection"

    TTResources() {
        $this.Name =        "Thinktank"
        $this.Description = "全キャッシュ"
        $this.UpdateDate =  "1970-03-11-000000"
        $this.children =        @{}
        $this.count =          0
        $this.loading =         $false
    }
    [string] GetFilename() { 
        return "$script:TTCacheDirPath\thinktank.cache"

    }
    [array] GetChildren() {
        $this.children.Values.foreach{ $this.count = $this.children.count }
        return @(([TTCollection]$this).GetChildren())
    }
    [array] GetChildren( $filter ) {
        $this.children.Values.foreach{ $_._count = $_.children.count }
        return @(([TTCollection]$this).GetChildren( $filter ))
    }
    [void] InitializeChildren(){
        $this.GetChildren().foreach{
            $_.Initialize()
        }
    }
    #endregion ----------------------------------------------------------------------------------------------------------

}

#endregion###############################################################################################################

#region　TTConfig / TTConfigs
#########################################################################################################################
class TTConfig : TTObject {

    #region Object itself (Dictionary)

    [string]$Description
    [string]$Value
    [string]$PCName
    [string]$MemoPos
    [string]$UpdateDate

    [hashtable] GetDictionary() {   # should be override 
        return @{
            Name        = "名前"
            Description = "説明"
            Value       = "設定値"
            PCName      = "PC名"
            MemoPos     = "記載場所"
            UpdateDate  = "更新日"
            Index       = "Name"
        }
    }
    #endregion ----------------------------------------------------------------------------------------------------------

    #region Object Display
    [hashtable] GetDisplay() {      # should be override 
        return @{
            ShelfFormat = "Name,Description,Value,PCName,MemoPos,UpdateDate"
            IndexFormat = "Name,Description"
        }
    }
    #endregion ----------------------------------------------------------------------------------------------------------

    #region Object Action
    [psobject[]] GetActions() {     # should be override
        return @( 
            @{  Name = "InvokeAction"
                Description = "フォルダを開く"
                Script = {
                    param($e)
                    Start-Process $e.Value
                    return $true
                }
            },
            @{  Name = "Discard"
                Desription = "リソースを開放する"
                Script = {
                    param($e)
                    return $true
                }
            }
        )
    }
    #endregion ----------------------------------------------------------------------------------------------------------

}

class TTConfigs: TTCollection {

    #region Object itself

    hidden [string] $ChildType = "TTConfig"

    TTConfigs() {                   # should be override 
        $this.Name          = "Config"
        $this.Description   = "設定値"
    }
    [string] GetFilename() { 
        return ""
    }
    [void] Initialize(){
        ([TTCollection]$this).Initialize()

        $this.AddChild( [TTConfig]@{ Name = "RootFolder"
            Description = "ルートフォルダ"
            Value = $script:TTRootDirPath
            PCName = ""
            MemoPos = "thinktank-modes.ps1"
            UpdateDate = "1970-03-11-000000"
        })
        $this.AddChild( [TTConfig]@{ Name = "MemoFolder"
            Description = "メモフォルダ"
            Value = $script:TTMemoDirPath
            PCName = ""
            MemoPos = "thinktank-modes.ps1"
            UpdateDate = "1970-03-11-000000"
        })
        $this.AddChild( [TTConfig]@{ Name = "CacheFolder"
            Description = "キャッシュフォルダ"
            Value = $script:TTCacheDirPath
            PCName = ""
            MemoPos = "thinktank-modes.ps1"
            UpdateDate = "1970-03-11-000000"
        })
        $this.AddChild( [TTConfig]@{ Name = "BackupFolder"
            Description = "バックアップフォルダ"
            Value = $script:TTBackupDirPath
            PCName = ""
            MemoPos = "thinktank-modes.ps1"
            UpdateDate = "1970-03-11-000000"
        })
        $this.AddChild( [TTConfig]@{ Name = "ScriptFolder"
            Description = "スクリプトアップフォルダ"
            Value = $script:TTScriptDirPath
            PCName = ""
            MemoPos = "thinktank-modes.ps1"
            UpdateDate = "1970-03-11-000000"
        })

    }
    [bool] Update() {

        $lines = @(
            Get-ChildItem -Path @( "$script:TTMemoDirPath\????-??-??-??????.txt", "$script:TTRootDirPath\thinktank.md" ) | `
                Where-Object { $this.UpdateDate -Lt $_.LastWriteTime.ToString("yyyy-MM-dd-HHmmss") } | `
                Select-String "^Thinktank:設定" | `
                Select-Object -Property Filename, LineNumber, Matches, Line
        )

        if ( 0 -eq $lines.Count ) { return $false }

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
    [void] AddChild( $item ) {      # should be override
        $child = [TTConfig]$item
        $this.children[ $child.$($child.GetDictionary().Index) ] = $child

        if( $this.loading -eq $false ){
            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            $this.count = $_.children.count

            [TTTask]::Register( 
                "TTConfigs:AddChild", 30, 0, { $script:TTConfigs.SaveCache() }
            )
        }
    }
    #endregion ----------------------------------------------------------------------------------------------------------

}

#endregion###############################################################################################################

#region　TTState / TTStatus
#########################################################################################################################
class TTState : TTObject {

    #region Object itself (Dictionary)
    [string]$Value

    TTState(){                      # should be override
        $this.Value = ""
    }

    [hashtable] GetDictionary() {   # should be override
        return @{
            flag =  "フラグ"
            Name=   "名前"
            Value=  "設定値"
            Index = "Name"
        }
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region Object Display
    [hashtable] GetDisplay() {      # should be override 
        return @{
            ShelfFormat = "Name,Value"
            IndexFormat = "Name,Value"
            }
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region Object Action
    [psobject[]] GetActions() {     # should be override
        return @( 
            @{  Name = "InvokeAction"
                Description = "実行する"
                Script = {
                    param($e)
                    return $true
                }
            },
            @{  Name = "Discard"
                Desription = "リソースを開放する"
                Script = {
                    param($e)
                    return $true
                }
            }
        )
    }
    #endregion ----------------------------------------------------------------------------------------------------------
}

class TTStatus : TTCollection {

    #region Object itself

    hidden [string] $ChildType = "TTState"

    TTStatus() {
        $this.Name          = "Status"
        $this.Description   = "ステータス"
    }
    [string] GetFilename() { 
        return ""
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

    #endregion ----------------------------------------------------------------------------------------------------------

}

#endregion###############################################################################################################

#region　TTCommand / TTCommands
#########################################################################################################################
class TTCommand : TTObject {

    #region Object itself (Dictionary)

    [string]$Description

    TTCommand(){
        $this.Description = ""
    }
    [hashtable] GetDictionary() {
        return @{
            Name        = "名前"
            Description = "説明"
            Index       = "Name"
        }
    }

    #endregion ----------------------------------------------------------------------------------------------------------


    #region Object Display
   [hashtable] GetDisplay() {      # should be override 
        return @{
            ShelfFormat = "Name,Description"
            IndexFormat = "Description,Name"
        }
    }
    #endregion ----------------------------------------------------------------------------------------------------------


    #region Object Action
    [psobject[]] GetActions() {     # should be override
        return @( 
            @{  Name = "InvokeAction"
                Description = "実行する"
                Script = {
                    param($e)
                    Invoke-Expression -Command $e.Name
                    return $true
                }
            },
            @{  Name = "Discard"
                Desription = "リソースを開放する"
                Script = {
                    param($e)
                    return $true
                }
            }
        )
    }

    #endregion ----------------------------------------------------------------------------------------------------------

}

class TTCommands: TTCollection {

    #region Object itself

    hidden [string] $ChildType = "TTCommand"

    TTCommands() {                  # should be override
        $this.Name          = "Command"
        $this.Description   = "コマンド"
    }
    [string] GetFilename() { 
        return ""
    }
    [void] Initialize(){            # should be override
        $this.children = @{}
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
                $child = [TTCommand]::New()
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
    [void] AddChild( $item ) {      # should be override
        $child = [TTCommand]$item
        $this.children[ $child.$($child.GetDictionary().Index) ] = $child

        if( $this.loading -eq $false ){
            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            $this.count = $this.children.count
            [TTTask]::Register( 
                "TTCommands:AddChild", 30, 0, { $script:TTCommands.SaveCache() }
            )
        }
    }
    [void] DeleteChild( $name ) {
        return
    }

    #endregion ----------------------------------------------------------------------------------------------------------

}

#endregion###############################################################################################################

#region　TTSearchMethod / TTSearchMethods
#########################################################################################################################
class TTSearchMethod : TTObject {

    #region Object itself (Dictionary)

    [string]$Category       # Google:Japan
    [string]$UpdateDate     # 
    [string]$MemoPos        # xxxx-xx-xx-xxxxxx:line:column
    [string]$Url            # http://www.google.co.jp/search?q=[param] 
    [string]$Tag            # Google

    TTSearchMethod(){               # should be override
        $this.Category = ""
        $this.MemoPos = ""
        $this.Url = ""
        $this.Tag = ""
    }
    [hashtable] GetDictionary() {   # should be override 
        return @{
            Name        = "名前"
            Category    = "分類"
            UpdateDate  = "更新日"
            MemoPos     = "記載場所"
            Url         = "URL"
            Tag         = "タグ"
            Index       = "Tag"
        }
    }

    #endregion ----------------------------------------------------------------------------------------------------------


    #region Object Display
    [hashtable] GetDisplay() {      # should be override 
        return @{
            ShelfFormat = "Name,Tag,Category,MemoPos,UpdateDate,Url"
            IndexFormat = "Tag,Name"
        }
    }

    #endregion ----------------------------------------------------------------------------------------------------------
    

    #region Object Action
    [psobject[]] GetActions() {     # should be override
        return @( 
            @{  Name = "InvokeAction"
                Description = "キーワードで検索する"
                Script = {
                    param($e)
                    $keyword = $script:app.keyword()
                    [TTTagAction]::tag_action( $e.Tag, $keyword )
                    return $true
                }
            },
            @{  Name = "Discard"
                Desription = "リソースを開放する"
                Script = {
                    param($e)
                    return $true
                }
            }
        )
    }

    #endregion ----------------------------------------------------------------------------------------------------------

}

class TTSearchMethods: TTCollection {

    #region Object itself

    hidden [string] $ChildType = "TTSearchMethod"

    TTSearchMethods(){              # should be override
        $this.Name          = "Search"
        $this.Description   = "検索"
    }

    [void] Initialize(){            # should be override
        ([TTCollection]$this).Initialize()

        $this.menus = @()
        $this.GetChildren().foreach{
            $keys = $_.Category.replace( ":", "," ) + "," + ($_.Name+(" "*30)).SubString(0,30).replace(","," ")
            $value = [ScriptBlock]::Create( "`$script:TTSearchs.GetChild(`"$($_.($_.GetDictionary().Index))`").DoAction()" )
            $this.menus += [psobject]@{ keys = $keys; value = $value }
        }
   
        $this.AddChild( [TTSearchMethod]@{ Tag = 'Route'
            Name       = "グーグルルート検索"
            Category   = "Google:Route"
            UpdateDate = ( Get-Date ).ToString("yyyy-MM-dd-HHmmss")
            MemoPos    = "thinktank-model.ps1"
            Url        = "thinktank_tag"
        })
        $this.AddChild( [TTSearchMethod]@{ Tag = 'memo'
            Name       = "テキストタグ"
            Category   = "Thinktank:Tag"
            UpdateDate = ( Get-Date ).ToString("yyyy-MM-dd-HHmmss")
            MemoPos    = "thinktank-model.ps1"
            Url        = "thinktank_tag"
        })
        $this.AddChild( [TTSearchMethod]@{ Tag = 'mail'
            Name       = "メールタグ"
            Category   = "Thinktank:Mail"
            UpdateDate = ( Get-Date ).ToString("yyyy-MM-dd-HHmmss")
            MemoPos    = "thinktank-model.ps1"
            Url        = "thinktank_tag"
        })
        $this.AddChild( [TTSearchMethod]@{ Tag = 'ref'
            Name       = "参照タグ"
            Category   = "Thinktank:Reference"
            UpdateDate = ( Get-Date ).ToString("yyyy-MM-dd-HHmmss")
            MemoPos    = "thinktank-model.ps1"
            Url        = "thinktank_tag"
        })
        $this.AddChild( [TTSearchMethod]@{ Tag = 'photo'
            Name       = "写真タグ"
            Category   = "Thinktank:Photo"
            UpdateDate = ( Get-Date ).ToString("yyyy-MM-dd-HHmmss")
            MemoPos    = "thinktank-model.ps1"
            Url        = "thinktank_tag"
        })
    }
    [bool] Update() {               # should be defined
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

                $child = [TTSearchMethod]::New()
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
    [void] AddChild( $item ) {      # should be override
        $child = [TTSearchMethod]$item
        $this.children[ $child.$($child.GetDictionary().Index) ] = $child

        if( $this.loading -eq $false ){
            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            [TTTask]::Register( 
                "TTSearchMethods:AddChild", 30, 0, { $script:TTSearchs.SaveCache() }
            )
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
    [void] DeleteChild( $index ) {
        $memo = $this.GetChild( $index ).MemoPos.split(":")
        $file = $memo[0] + ".txt"
        $line = $memo[1]
        Write-Host "ファイル$file $line 行目のアクションタグ[$index]を削除してください"
    }
    [string]GetActionTagsRegex(){
        return ( $this.children.Keys -join "|" )
    }

    #endregion ----------------------------------------------------------------------------------------------------------

}

#endregion###############################################################################################################

#region　TTExternalLink / TTExternalLinks
#########################################################################################################################
class TTExternalLink : TTObject {

    #region Object itself (Dictionary)

    [string]$Category
    [string]$UpdateDate
    [string]$MemoPos
    [string]$Uri
   
    TTExternalLink(){               # should be override
        $this.Category = ""
        $this.UpdateDate = ""
        $this.MemoPos = ""
        $this.Uri = ""
           
    }
    [hashtable] GetDictionary() {   # should be override 
        return @{
            Name        = "名前"
            Category    = "分類"
            UpdateDate  = "更新日"
            MemoPos     = "記載場所"
            Uri         = "URI"
            Index       = "Uri"
        }
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region Object Display
    [hashtable] GetDisplay() {      # should be override 
        return @{
            ShelfFormat = "Name,Category,MemoPos,UpdateDate,Uri"
            IndexFormat = "Name"
        }
    }

    #endregion ----------------------------------------------------------------------------------------------------------
    
    #region Object Action
    [psobject[]] GetActions() {     # should be override
        return @( 
            @{  Name = "InvokeAction"
                Description = "URIを外部ブラウザで開く"
                Script = {
                    param($e)
                    [TTTool]::open_url( $e.Uri )
                    return $true
                }
            },
            @{  Name = "OpenInnerBrowser"
                Description = "URIを内部ブラウザで開く"
                Script = {
                    param($e)
                    return $true
                }
            },
            @{  Name = "CopyToClipboard"
                Description = "URIをクリップボードにコピーする"
                Script = {
                    param($e)
                    return $true
                }
            },
            @{  Name = "OpenMemo"
                Description = "データ記載場所を開く"
                Script = {
                    param($e)
                    return $true
                }
            },
            @{  Name = "Discard"
                Description = "リソースを開放する"
                Script = {
                    param($e)
                    return $true
                }
            }
        )
    }

    #endregion ----------------------------------------------------------------------------------------------------------

}

class TTExternalLinks: TTCollection {

    #region Object itself

    hidden [string] $ChildType = "TTExternalLink"
    
    TTExternalLinks(){              # should be override
        $this.Name          = "Link"
        $this.Description   = "リンク"
    }
    [void] Initialize(){            # should be override
        ([TTCollection]$this).Initialize()
    
        $this.menus = @()
        $this.GetChildren().foreach{
            $keys = $_.Category.replace( ":", "," ) + "," + ($_.Name+(" "*30)).SubString(0,30).replace(","," ")
            $value = [ScriptBlock]::Create( "`$script:TTLinks.GetChild(`"$($_.($_.GetDictionary().Index))`").DoAction()" )
            $this.menus += [psobject]@{ keys = $keys; value = $value }
        }

    }
    [bool] Update() {               # should be defined
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
    [void] AddChild( $item ) {      # should be override
        $child = [TTExternalLink]$item
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
    #endregion ----------------------------------------------------------------------------------------------------------

}

#endregion###############################################################################################################

#region　TTMemo / TTMemos
#########################################################################################################################
class TTMemo : TTObject {

    #region Object itself (Dictionary)

    [string]$MemoID
    [string]$UpdateDate
    [string]$Title

    TTMemo(){                       # should be override
        $this.MemoID = ""
        $this.UpdateDate = ""
        $this.Title = ""
    }

    [hashtable] GetDictionary() {   # should be override 
        return @{
            MemoID      = "メモID"
            UpdateDate  = "更新日"
            Title       = "タイトル"
            flag        = "編"
            Index       = "MemoID"
        }
    }

    [string] GetFilename(){         # should be override
        return "$script:TTMemoDirPath\$($this.MemoID).txt" 
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region Object Display
    [hashtable] GetDisplay() {      # should be override 
        return @{
            ShelfFormat = "flag,UpdateDate,MemoID,Title"
            IndexFormat = "flag,Title"
        }
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region Object Action
    [psobject[]] GetActions() {     # should be override
        return @( 
            @{  Name = "InvokeAction"
                Description = "メモを開く"
                Script = {
                    param($e)
                    [TTTool]::open_memo( $this.MemoID )
                    return $true
                }
            },
            @{  Name = "Discard"
                Description = "リソースを開放する"
                Script = {
                    param($e)
                    $deleted_date = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
                    Move-Item -Path $e.GetFilename() -Destination $script:TTBackupDirPath -Force
                    Rename-Item -Path "$script:TTBackupDirPath\$($e.MemoID).txt" -NewName "$($e.MemoID)_deleted_at_$($deleted_date).txt"
                    return $true
                }
            }
        )
    }
    #endregion ----------------------------------------------------------------------------------------------------------

}

class TTMemos: TTCollection {

    #region Object itself

    hidden [string] $ChildType = "TTMemo"

    TTMemos(){                      # should be override
        $this.Name          = "Memo"
        $this.Description   = "メモ"
    }

    [void] Initialize(){            # should be override
        ([TTCollection]$this).Initialize()

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
    [bool] Update() {               # should be defined
        $lines = @( 
            Get-ChildItem -Path @(  "$script:TTMemoDirPath\????-??-??-??????.txt", "$script:TTRootDirPath\thinktank.md" ) | `
                Where-Object { $this.UpdateDate -Lt $_.LastWriteTime.ToString("yyyy-MM-dd-HHmmss") } 
        )

        if ( 0 -Lt $lines.Count ) {
            foreach ( $line in $lines ) {
                $child = [TTMemo]::New()
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
    [void] AddChild( $item ) {      # should be override
        $child = [TTMemo]$item
        $this.children[ $child.$($child.GetDictionary().Index) ] = $child

        if( $this.loading -eq $false ){
            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            $this.count = $this.children.count
            [TTTask]::Register( 
                "TTMemos:AddChild", 30, 0, { $script:TTMemos.SaveCache() }
            )
        }
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

    #endregion ----------------------------------------------------------------------------------------------------------

}


#endregion###############################################################################################################

#region　chache ではなくて memo に結果を書き込む：　TTExMemo / TTExMemos
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

#region　TTEditing / TTEditings
#########################################################################################################################
class TTEditing : TTObject {

    #region Object itself (Dictionary)

    [string]$MemoID     # xxxx-xx-xx-xxxxxx or thinktank
    [string]$UpdateDate
    [string]$Offset     # offset
    [bool]$WordWrap     
    [string]$Foldings   # 3,5,6,15,22,30

    TTEditing(){                    # should be override
        $this.MemoID = ""
        $this.UpdateDate = ""
        $this.Offset = ""
        $this.WordWrap = ""
        $this.Foldings = ""
    }

    [hashtable] GetDictionary() {
        return @{
            MemoID      = "メモID"
            UpdateDate  = "更新日"
            Offset      = "カーソル位置"
            WordWrap    = "ワードラップ"
            Foldings    = "折畳み位置"
            Index       = "MemoID"
        }
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region Object Display
    [hashtable] GetDisplay() {      # should be override 
        return @{
            ShelfFormat = "MemoID,UpdateDate,Offset,Foldings,WordWrap"
            IndexFormat = "MemoID"
        }
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region Object Action
    [psobject[]] GetActions() {     # should be override
        return @( 
            @{  Name = "InvokeAction"
                Description = "実行する"
                Script = {
                    param($e)
                    return $true
                }
            },
            @{  Name = "Discard"
                Description = "リソースを開放する"
                Script = {
                    param($e)
                    return $true
                }
            }
        )
    }

    #endregion ----------------------------------------------------------------------------------------------------------

}

class TTEditings: TTCollection {

    #region Object itself

    hidden [string] $ChildType = "TTEditing"

    TTEditings() {                  # should be override
        $this.Name          = "Editing"
        $this.Description   = "編集状態"
    }
    [void] Initialize(){            # should be override
        $this.LoadCache()
    }
    [void] AddChild( [ICSharpCode.AvalonEdit.TextEditor]$editor ) {     # should be override
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

    #endregion ----------------------------------------------------------------------------------------------------------

}

#endregion###############################################################################################################



