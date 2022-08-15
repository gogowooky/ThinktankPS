






#region　TTObject / TTCollection / TTResources
#########################################################################################################################
class TTObject {





    
    #region variants/ new/ GetDictionary/ GetFilename

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

    #region GetDisplay
    [hashtable] GetDisplay() {      # should be override 
        return @{
            Shelf = "flag,Name"
            Index = "flag,Name"
            Cabinet = "flag,Name"
        }
    }
    #endregion ----------------------------------------------------------------------------------------------------------

    #region variants/ InvokeAction/ GetActions
    static [string] $Action = ''
    static [string] $ActionDiscardResources = ''

    [bool] InvokeAction( $name, [object[]]$items ) {
        $func = Invoke-Expression "[$($this.gettype())]::$name"
        $title = ((Get-Help $func).synopsis)
        $ret = (&$func $this $items)
        [TTTool]::debug_message( $this.GetType().Name, "InvokeAction: @{ $title, $func }" )

        return $ret
    }
    [bool] InvokeAction( [object[]]$items ) {
        return $this.InvokeAction( 'Action', $items )
    }
    [hashtable] GetActions() {
        $title_funcs = [ordered] @{}
        ($this | Get-Member -static -member property).where{
            $_.Name -match 'Action.+'

        }.foreach{
            @{
                Action = $_.Name
                Function = (Invoke-Expression "[$($this.gettype())]::$($_.Name)" ) 
            }
        }.where{ 0 -lt $_.Function.length }.foreach{
            $no = $title_funcs.count + 1
            $title_funcs.Add( "$no) $((Get-Help $_.Function).synopsis)", $_.Action )

        }

        return $title_funcs
    }

    #endregion ----------------------------------------------------------------------------------------------------------

}

class TTCollection : TTObject {

    #region variants/ new/ GetDictionary/ GetFilename/ Initilaize 
    static [string] $MessageOnCacheSaved = 'False'

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

        ($this | Get-Member -static -member property).where{
            $_.Name -match 'Action.*'
        }.foreach{
            Invoke-Expression "[$($this.gettype().Name)]::$($_.Name) = [$($this.gettype().BaseType.Name)]::$($_.Name)"
        }

    }
    [hashtable] GetDictionary() {   # should be override
        return @{
            count      =    "件数"
            flag =          "覧"
            Name =          "名前"
            Description =   "説明"
            UpdateDate =    "更新日"
            Index =         "Name"
        }
    }
    [string] GetFilename() { 
        return "$global:TTCacheDirPath\$($this.Name).cache"
    }
    [void] Initialize(){            # should be override
        $this.children = @{}
        $this.LoadCache()
        $this.Update()
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region Add_Events
    static [ScriptBlock] $OnSaved = {}
    static [ScriptBlock] $OnLoaded = {}
    [void] Saved(){ &([TTCollection]::OnSaved) $this }
    [void] Loaded(){ &([TTCollection]::OnLoaded) $this }
    #endregion
    

    #region LoadCache/ Update/ ConfigLines/ AddChild/ SaveCache
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

        $this.Loaded()

        $this.UpdateDate = $tmp_update
    }
    [bool] Update() {               # should be defined
        if( $this.OnUpdate ){ &($this.OnUpdate) $this }
        if( $this.OnChange ){ &($this.OnChange) $this }
        return $true
    }
    [psobject[]] ConfigLines( [string]$tag ) {
        $lines = @()

        @(  Get-ChildItem -Path @( "$global:TTMemoDirPath\????-??-??-??????.txt", "$global:TTRootDirPath\thinktank.md" ) | `
            Where-Object { $this.UpdateDate -Lt $_.LastWriteTime.ToString("yyyy-MM-dd-HHmmss") } | `
            Select-String "^Thinktank:$tag" | `
            Select-Object -Property Filename, LineNumber, Line

        ).foreach{

            if( $_.Line -match "^Thinktank:$tag\s*(@(?<pcname>[^,@:]+)\s*)?:\s*(?<name>[^,@]+)\s*,\s*(?<value>.*)\s*$" ){
                if( (($null -eq $Matches.pcname) -and (-not $lines.contains( $Matches.name ))) -or
                    ($Env:COMPUTERNAME -eq $Matches.pcname) ){
                    $lines += [psobject]@{
                        name = $Matches.name
                        value = $Matches.value
                        filename = $_.Filename
                        linenumber = $_.LineNumber
                    }
                }
            }
        }
        
        return $lines
    }
    [void] AddChild( $item ) {      # should be override
        $child = ( $item -as $this.ChildType )
        $this.children[ $child.$($child.GetDictionary().Index) ] = $child

        if( $this.loading -eq $false ){
            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            $this.count = $this.children.count
            $this_name = $this.Name 
            if( $this.GetType().Name -eq 'TTResources' ){
                TTTimerResistEvent "TTResources:AddChild" 2 0 {
                    $global:Model.SaveCache()
                }
            }else{
                TTTimerResistEvent "$($this.GetType().Name):AddChild" 2 0 {
                    $global:Model.GetChild( $script:this_name ).SaveCache()
                }.GetNewClosure()
            }

            if( $this.OnAddChild ){ &$this.OnAddChild $this }
            if( $this.OnChange ){ &$this.OnChange $this }
        }

    }
    [void] SaveCache() {
        # 現データをファイルに保存する (空行, Format-List形式(自己プロパティ), 空行, CSV(子プロパティ))
        if( [TTCollection]::MessageOnCacheSaved -eq 'True' ){       
            [TTTool]::debug_message( $this, "saved >> $($this.GetFilename())" )
        }
        $this | Format-List | Out-File $this.GetFilename()
        $this.children.values | ConvertTo-Csv -NoTypeInformation | Out-File $this.GetFilename() -Append

        $this.Saved()
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region GetChildren/ GetChild/ DiscardResources/ DeleteChild/ Child
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
        }elseif( $this.Name -eq $index ){
            return $this
        } else {
            return $null
        }
    }
    [void] DiscardResources() {
        $deleted_date = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
        Move-Item -Path $this.GetFilename() -Destination $global:TTBackupDirPath -Force
        Rename-Item -Path "$global:TTBackupDirPath\$($this.Name).cache" -NewName "$($this.Name)_deleted_at_$($deleted_date).cache"
        $this.UpdateDate = $deleted_date
        # $this.SaveCache()
    }
    [void] DeleteChild( $index ) {
        $this.GetChild( $index ).DiscardResources()
        $this.children.Remove( $index )

        if( $this.loading -eq $false ){
            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            $_._count = $_.children.count
            $this.SaveCache()
        }
        if( $this.OnDeleteChild ){ &$this.OnDeleteChild $this }
        if( $this.OnChange ){ &$this.OnChange $this }

    }
    [TTObject] Child(){
        return (New-Object $this.ChildType)
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region variants/ GetDisplay
    hidden $menus = @(
        @{  Titles =    "_B)はじめに"
            Script =     {ttcmd_application_help_breifing} },
        @{  Titles =    "_U)使い方"
            Script =     {ttcmd_application_help_instruction} },
        @{  Titles =    "_O)その他,_S)ショートカットキー"
            Script =     {ttcmd_application_help_shortcuts} },
        @{  Titles =    "_O)その他,_V)バージョン"
            Script =     {ttcmd_application_help_version} },
        @{  Titles =    "_O)その他,_S)サイト"
            Script =     {ttcmd_application_help_site} }
    )

    [hashtable] GetDisplay(){
        return @{
            Library = "flag,Description,count,Name,UpdateDate"
            Shelf =   "flag,Description,count,Name,UpdateDate"
            Index =   "flag,Name,count,Description"
            Cabinet = "Description,count,Name,UpdateDate"
        }
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region variants/ (GetActions)
    static [string] $Action = ''
    static [string] $ActionDiscardResources = ''
    static [string] $ActionToShelf = ''
    static [string] $ActionToIndex = ''
    static [string] $ActionToCabinet = ''
    static [string] $ActionDataLocaiton = ''


    #endregion ----------------------------------------------------------------------------------------------------------

}

class TTResources : TTCollection {

    #region variantes/ new/ GetFilename/ Initialize
    hidden [string] $ChildType = "TTCollection"

    TTResources() {
        $this.Name =        "Thinktank"
        $this.Description = "全キャッシュ"
        $this.UpdateDate =  "1970-03-11-000000"
        $this.children =        @{}
        $this.count =          0
        $this.loading =         $false

        $this.Initialize()
    }
    [string] GetFilename() { 
        return "$global:TTCacheDirPath\thinktank.cache"

    }
    [TTResources] Initialize(){            # should be override
        ([TTCollection]$this).Initialize()

        $this.AddChild( [TTConfigs]::new() )
        $this.AddChild( [TTStatus]::new())
        $this.AddChild( [TTCommands]::new() )
        $this.AddChild( [TTSearchMethods]::new() )
        $this.AddChild( [TTExternalLinks]::new() )
        $this.AddChild( [TTMemos]::new() )
        $this.AddChild( [TTEditings]::new() )
        $this.InitializeChildren()

        return $this
        
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region LoadCache/ GGetChildren/ InitializeChildren
    [void] LoadCache() {
        $this.count = $this.children.count
        return
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

    #region variants/ (GetActions)
    static [string] $Action = ''
    static [string] $ActionDiscardResources = ''
    static [string] $ActionToShelf = ''
    static [string] $ActionToIndex = ''
    static [string] $ActionToCabinet = ''
    static [string] $ActionDataLocaiton = ''

    #endregion ----------------------------------------------------------------------------------------------------------

    
}

#endregion###############################################################################################################

#region　TTConfig / TTConfigs
#########################################################################################################################
class TTConfig : TTObject {

    #region variants/ GetDictionary/ GetFilename
    [string]$Description
    [string]$Value
    [string]$MemoPos
    [string]$UpdateDate

    [hashtable] GetDictionary() {   # should be override 
        return @{
            Name        = "名前"
            Description = "説明"
            Value       = "設定値"
            MemoPos     = "記載場所"
            UpdateDate  = "更新日"
            Index       = "Name"
        }
    }

    [string] GetFilename(){         # should be override
        $memoid = ( $this.MemoPos -replace "([^:]+):(\d+):(\d+)", '$1' )
        return "$global:TTMemoDirPath\$memoid.txt" 
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region GetDisplay
    [hashtable] GetDisplay() {      # should be override 
        return @{
            Shelf = "Name,Description,Value,PCName,MemoPos,UpdateDate"
            Index = "Name,Description"
            Cabinet = "Name,Description,Value,PCName,MemoPos,UpdateDate"
        }
    }
    #endregion ----------------------------------------------------------------------------------------------------------

    #region variants/ (GetActions)
    static [string] $Action = ''
    static [string] $ActionDiscardResources = ''
    static [string] $ActionDataLocaiton = ''
    #endregion ----------------------------------------------------------------------------------------------------------

}

class TTConfigs: TTCollection {

    #region variants/ new/ Initialize/ Update

    hidden [string] $ChildType = "TTConfig"

    TTConfigs() {                   # should be override 
        $this.Name          = "Configs"
        $this.Description   = "設定値"
    }
    [void] Initialize(){

        $this.AddChild( [TTConfig]@{ Name = "RootFolder"
            Description = "ルートフォルダ"
            Value = $global:TTRootDirPath
            MemoPos = "thinktank-model.ps1"
            UpdateDate = "1970-03-11-000000"
        })
        $this.AddChild( [TTConfig]@{ Name = "MemoFolder"
            Description = "メモフォルダ"
            Value = $global:TTMemoDirPath
            MemoPos = "thinktank-model.ps1"
            UpdateDate = "1970-03-11-000000"
        })
        $this.AddChild( [TTConfig]@{ Name = "CacheFolder"
            Description = "キャッシュフォルダ"
            Value = $global:TTCacheDirPath
            MemoPos = "thinktank-model.ps1"
            UpdateDate = "1970-03-11-000000"
        })
        $this.AddChild( [TTConfig]@{ Name = "BackupFolder"
            Description = "バックアップフォルダ"
            Value = $global:TTBackupDirPath
            MemoPos = "thinktank-model.ps1"
            UpdateDate = "1970-03-11-000000"
        })
        $this.AddChild( [TTConfig]@{ Name = "ScriptFolder"
            Description = "スクリプトアップフォルダ"
            Value = $global:TTScriptDirPath
            MemoPos = "thinktank-model.ps1"
            UpdateDate = "1970-03-11-000000"
        })

        ([TTCollection]$this).Initialize()

    }
    [bool] Update() {

        $count = $this.ConfigLines("設定").foreach{
            $file = Get-Item -Path ([TTTool]::index_to_filepath($_.filename))
            $description, $value = $_.value -split ',' 

            $child = New-Object -TypeName $this.ChildType
            $child.Name =           $_.name
            $child.Value =          $value
            $child.Description =    $description
            $child.UpdateDate =     $file.LastWriteTime.ToString("yyyy-MM-dd-HHmmss")
            $child.MemoPos =        "$($file.BaseName):$($_.linenumber)"
            $this.AddChild( $child )
        }.count

        if( 0 -lt $count ){
            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")

            if( $this.OnUpdate ){ &$this.OnUpdate $this }
            if( $this.OnChange ){ &$this.OnChange $this }
        }

        return $true    

    }
    #endregion ----------------------------------------------------------------------------------------------------------

    #region variants/ (GetActions)
    static [string] $Action = ''
    static [string] $ActionDiscardResources = ''
    static [string] $ActionToShelf = ''
    static [string] $ActionToIndex = ''
    static [string] $ActionToCabinet = ''
    static [string] $ActionDataLocaiton = ''
    #endregion ----------------------------------------------------------------------------------------------------------
    
}

#endregion###############################################################################################################

#region　TTState / TTStatus
#########################################################################################################################
class TTState : TTObject {

    #region variants/ new/ GetDictionary
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

    #region GetDisplay
    [hashtable] GetDisplay() {      # should be override 
        return @{
            Shelf = "Name,Value"
            Index = "Name,Value"
            Cabinet = "Name,Value"
        }
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region variants/ (GetActions)
    static [string] $Action = ''
    static [string] $ActionDiscardResources = ''
    static [string] $ActionFilter = ''
    #endregion ----------------------------------------------------------------------------------------------------------

}

class TTStatus : TTCollection {

    #region variants/ new/ Initialize/ Get/ Set

    hidden [string] $ChildType = "TTState"

    TTStatus() {
        $this.Name          = "Status"
        $this.Description   = "ステータス"
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

        if( '' -eq $value ){
            $this.children.remove( $value )
            return
        }
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

        if( $this.OnAdd ){ &$this.OnAdd $this }
        if( $this.OnChange ){ &$this.OnChange $this }

        if( $this.loading -eq $false ){
            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            $this.count = $this.children.count
            TTTimerResistEvent "TTStatus:Set" 2 0 {
                    $global:Model.GetChild( "Status" ).SaveCache()
                }
        }
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region variants/ (GetActions)
    static [string] $Action = ''
    static [string] $ActionDiscardResources = ''
    static [string] $ActionToShelf = ''
    static [string] $ActionToIndex = ''
    static [string] $ActionToCabinet = ''
    static [string] $ActionDataLocaiton = ''
    #endregion ----------------------------------------------------------------------------------------------------------
    
}

#endregion###############################################################################################################

#region　TTCommand / TTCommands
#########################################################################################################################
class TTCommand : TTObject {

    #region variants/ new/ GetDictionary
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

    #region GetDisplay
    [hashtable] GetDisplay() {      # should be override 
        return @{
            Shelf = "Name,Description"
            Index = "Name,Description"
            Cabinet = "Name,Description"
        }
    }
    #endregion ----------------------------------------------------------------------------------------------------------

    #region variants/ (GetActions)
    static [string] $Action = ''
    static [string] $ActionInvokeCommand = ''
    static [string] $ActionDiscardResources = ''
    static [string] $ActionFilter = ''
    #endregion ----------------------------------------------------------------------------------------------------------

}

class TTCommands: TTCollection {

    #region variants/ new/ Initialize/ Update/ DeleteChild

    hidden [string] $ChildType = "TTCommand"

    TTCommands() {                  # should be override
        $this.Name          = "Commands"
        $this.Description   = "コマンド"
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
            $value = [ScriptBlock]::Create( "`$global:TTCommands.GetChild(`"$($_.($_.GetDictionary().Index))`").DoAction()" )
            $this.menus += [psobject]@{ keys = $keys; value = $value }
        }

    }
    [bool] Update() {

        $count = @(
            Get-ChildItem -path function: | `
            ForEach-Object { $_.Name } | `
            Where-Object { $_ -like "ttcmd_*" }
        ).foreach{
            $child = [TTCommand]::New()
            $child.Name =           $_
            $child.Description =    ( Get-Help $_ | foreach-Object { $_.synopsis.split('|')[0] } )
            $this.AddChild( $child ) 
        }.count

        if( 0 -lt $count ){
            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")

            if( $this.OnUpdate ){ &$this.OnUpdate $this }
            if( $this.OnChange ){ &$this.OnChange $this }
   
        }

        return $true

    }
    [void] DeleteChild( $name ) {
        return
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region variants/ (GetActions)
    static [string] $Action = ''
    static [string] $ActionDiscardResources = ''
    static [string] $ActionToShelf = ''
    static [string] $ActionToIndex = ''
    static [string] $ActionToCabinet = ''
    static [string] $ActionDataLocaiton = ''
    #endregion ----------------------------------------------------------------------------------------------------------
    
}

#endregion###############################################################################################################

#region　TTSearchMethod / TTSearchMethods
#########################################################################################################################
class TTSearchMethod : TTObject {

    #region variants/ new/ GetDictionary/ GetFilename

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
    [string] GetFilename(){         # should be override
        $memoid = ( $this.MemoPos -replace "([^:]+):(\d+):(\d+)", '$1' )
        return "$global:TTMemoDirPath\$memoid.txt" 
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region Object GetDisplay
    [hashtable] GetDisplay() {      # should be override 
        return @{
            Shelf = "Name,Tag,Category,MemoPos,UpdateDate,Url"
            Index = "Tag,Name"
            Cabinet = "Name,Tag,Category,MemoPos,UpdateDate,Url"
        }
    }

    #endregion ----------------------------------------------------------------------------------------------------------
    
    #region variants/ (GetAction)
    static [string] $Action = ''
    static [string] $ActionDiscardResources = ''
    static [string] $ActionDataLocation = ''
    static [string] $ActionToEditor = ''
    static [string] $ActionOpenUrl = ''
    static [string] $ActionOpenUrlEx = ''
    static [string] $ActionToClipboard = ''
    #endregion ----------------------------------------------------------------------------------------------------------

}

class TTSearchMethods: TTCollection {

    #region variants/ new/ Initialize/ Update/ SaveCache/ DeleteChild/ GetActionTagsRegex

    hidden [string] $ChildType = "TTSearchMethod"

    TTSearchMethods(){              # should be override
        $this.Name          = "Searchs"
        $this.Description   = "検索"
    }
    [void] Initialize(){            # should be override
        ([TTCollection]$this).Initialize()

        $this.menus = @()
        $this.GetChildren().foreach{
            $keys = $_.Category.replace( ":", "," ) + "," + ($_.Name+(" "*30)).SubString(0,30).replace(","," ")
            $value = [ScriptBlock]::Create( "`$global:TTSearchs.GetChild(`"$($_.($_.GetDictionary().Index))`").DoAction()" )
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

        $count = $this.ConfigLines("検索").foreach{
            $file = Get-Item -Path ([TTTool]::index_to_filepath($_.filename))
            $tag = $_.name
            $name, $url, $category = $_.value.split(',').Trim()

            $child = [TTSearchMethod]::New()
            $child.Tag = $tag
            $child.Name = $name
            $child.Url = $url
            $child.Category = $category
            $child.UpdateDate = $file.LastWriteTime.ToString("yyyy-MM-dd-HHmmss")
            $child.MemoPos = "$($file.BaseName):$($_.LineNumber)"
            $this.AddChild( $child )
        }.count

        if( 0 -lt $count ){
            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")

            if( $this.OnUpdate ){ &$this.OnUpdate $this }
            if( $this.OnChange ){ &$this.OnChange $this }
   
        }

        return $true

    }
    [void] SaveCache() {
        # overwrite : thinktank.xshdも更新

        ([TTCollection]$this).SaveCache()

        $xaml_path = "$global:TTScriptDirPath\thinktank.xshd"
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

            if( $this.OnSave ){ &$this.OnSave $this }
    
        }
    }
    [void] DeleteChild( $index ) {
        $memo = $this.GetChild( $index ).MemoPos.split(":")
        $file = $memo[0] + ".txt"
        $line = $memo[1]
        Write-Host "ファイル$file $line 行目のアクションタグ[$index]を削除してください"
        if( $this.OnDelete ){ &$this.OnDelete $this }
        if( $this.OnChange ){ &$this.OnChange $this }

    }
    [string]GetActionTagsRegex(){
        return ( $this.children.Keys -join "|" )
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region variants/ (GetActions)
    static [string] $Action = ''
    static [string] $ActionDiscardResources = ''
    static [string] $ActionToShelf = ''
    static [string] $ActionToIndex = ''
    static [string] $ActionToCabinet = ''
    static [string] $ActionDataLocaiton = ''
    #endregion ----------------------------------------------------------------------------------------------------------
    
}

#endregion###############################################################################################################

#region　TTExternalLink / TTExternalLinks
#########################################################################################################################
class TTExternalLink : TTObject {

    #region variants/ new/ GetDictionary/ GetFilename
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
    [string] GetFilename(){         # should be override
        $memoid = ( $this.MemoPos -replace "([^:]+):(\d+):(\d+)", '$1' )
        return "$global:TTMemoDirPath\$memoid.txt" 
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region GetDisplay
    [hashtable] GetDisplay() {      # should be override 
        return @{
            Shelf = "Name,Category,MemoPos,UpdateDate,Uri"
            Index = "Name"
            Cabinet = "Name,Category,MemoPos,UpdateDate,Uri"
        }
    }

    #endregion ----------------------------------------------------------------------------------------------------------
    
    #region variants/ (GetActions)
    static [string] $Action = ''
    static [string] $ActionDiscardResources = ''
    static [string] $ActionDataLocation = ''
    static [string] $ActionOpenUrl = ''
    static [string] $ActionOpenUrlEx = ''
    static [string] $ActionToClipboard = ''
    #endregion ----------------------------------------------------------------------------------------------------------

}

class TTExternalLinks: TTCollection {

    #region variants/ new/ Initialize/ Update/ DeleteChild/ AddChildFromBrowser

    hidden [string] $ChildType = "TTExternalLink"
    
    TTExternalLinks(){              # should be override
        $this.Name          = "Links"
        $this.Description   = "リンク"
    }
    [void] Initialize(){            # should be override
        ([TTCollection]$this).Initialize()
    
        $this.menus = @()
        $this.GetChildren().foreach{
            $keys = $_.Category.replace( ":", "," ) + "," + ($_.Name+(" "*30)).SubString(0,30).replace(","," ")
            $value = [ScriptBlock]::Create( "`$global:TTLinks.GetChild(`"$($_.($_.GetDictionary().Index))`").DoAction()" )
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
            Get-ChildItem -Path @( "$global:TTMemoDirPath\????-??-??-??????.txt", "$global:TTRootDirPath\thinktank.md" ) | `
                Where-Object { $this.UpdateDate -Lt $_.LastWriteTime.ToString("yyyy-MM-dd-HHmmss") } | `
                Select-String "^Thinktank:URI:" | `
                Select-Object -Property Filename, LineNumber, Line
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
                $child.MemoPos = "$($file.BaseName):$($line.LineNumber)"
                $this.AddChild( $child )
            }

            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            if( $this.OnUpdate ){ &$this.OnUpdate $this }
            if( $this.OnChange ){ &$this.OnChange $this }
            return $true

        } else {
            $this.count = $this.children.count
            return $false
        }

    }
    [void] DeleteChild( $index ) {
        $memo = $this.GetChild( $index ).MemoPos.split(":")
        $file = $memo[0] + ".txt"
        $line = $memo[1]
        Write-Host "ファイル$file $line 行目のアクションタグ[$index]を削除してください"
        if( $this.OnDelete ){ &$this.OnDelete $this }
        if( $this.OnChange ){ &$this.OnChange $this }
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

    #region variants/ (GetActions)
    static [string] $Action = ''
    static [string] $ActionDiscardResources = ''
    static [string] $ActionToShelf = ''
    static [string] $ActionToIndex = ''
    static [string] $ActionToCabinet = ''
    static [string] $ActionDataLocaiton = ''
    #endregion ----------------------------------------------------------------------------------------------------------
    
}

#endregion###############################################################################################################

#region　TTMemo / TTMemos
#########################################################################################################################
class TTMemo : TTObject {

    #region variants/ new/ GetDictionary/ GetFilename

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
        return "$global:TTMemoDirPath\$($this.MemoID).txt" 
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region Add_Events
    static [ScriptBlock] $OnSaved = {}
    static [ScriptBlock] $OnLoaded = {}
    [void] Saved(){ &([TTMemo]::OnSaved) $this }
    [void] Loaded(){ &([TTMemo]::OnLoaded) $this }
    #endregion

    #region GetDisplay
    [hashtable] GetDisplay() {      # should be override 
        return @{
            Shelf = "flag,UpdateDate,MemoID,Title"
            Index = "flag,Title"
            Cabinet = "flag,UpdateDate,MemoID,Title"
        }
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region variants/ (GetActions)
    static [string] $Action = ''
    static [string] $ActionDiscardResources = ''
    static [string] $ActionOpen = ''
    static [string] $ActionDataLocation = ''
    static [string] $ActionToClipboard = ''
    #endregion ----------------------------------------------------------------------------------------------------------

}

class TTMemos: TTCollection {

    #region variants/ new/ Initialize/ Update/ CreateChild

    hidden [string] $ChildType = "TTMemo"

    TTMemos(){                      # should be override
        $this.Name          = "Memos"
        $this.Description   = "メモ"
    }
    [void] Initialize(){            # should be override
        ([TTCollection]$this).Initialize()

        $this.menus = @()
        $lines = @(
            Get-ChildItem -Path @( "$global:TTRootDirPath\thinktank.md" ) | `
                Select-String "^Thinktank@?(?<pcname>.*)?:Keywords:" | `
                Select-Object -Property Filename, LineNumber, Line
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
            Get-ChildItem -Path @(  "$global:TTMemoDirPath\????-??-??-??????.txt", "$global:TTRootDirPath\thinktank.md" ) | `
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

        } else {
            $this.count = $this.children.count
            if( $this.OnUpdate ){ &$this.OnUpdate $this }
            if( $this.OnChange ){ &$this.OnChange $this }
            return $false
        }
    }
    [string] CreateChild() {
        $time = Get-Date
        $memoid = $time.tostring('yyyy-MM-dd-HHmmss')
        $filepath = "$global:TTMemoDirPath\$memoid.txt"
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

    #region variants/ (GetActions)
    static [string] $Action = ''
    static [string] $ActionDiscardResources = ''
    static [string] $ActionToShelf = ''
    static [string] $ActionToIndex = ''
    static [string] $ActionToCabinet = ''
    static [string] $ActionDataLocaiton = ''
    #endregion ----------------------------------------------------------------------------------------------------------
    
}


#endregion###############################################################################################################

#region　TTEditing / TTEditings
#########################################################################################################################
class TTEditing : TTObject {

    #region variants/ new/ GetDictionary/ GetFilename

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
    [string] GetFilename(){         # should be override
        return "$global:TTMemoDirPath\$($this.MemoID).txt" 
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region GetDisplay
    [hashtable] GetDisplay() {      # should be override 
        return @{
            Shelf = "MemoID,UpdateDate,Offset,Foldings,WordWrap"
            Index = "MemoID"
            Cabinet = "MemoID,UpdateDate,Offset,Foldings,WordWrap"
        }
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region variants/ (GetActions)
    static [string] $Action = ''
    static [string] $ActionDiscardResources = ''
    static [string] $ActionOpen = ''
    static [string] $ActionDataLocation = ''
    #endregion ----------------------------------------------------------------------------------------------------------

}

class TTEditings: TTCollection {

    #region variants/ new/ Initialize/ AddChild
    hidden [string] $ChildType = "TTEditing"
    TTEditings() {                  # should be override
        $this.Name          = "Editings"
        $this.Description   = "編集状態"
    }
    [void] Initialize(){            # should be override
        $this.LoadCache()
    }
    [void] AddChild( [ICSharpCode.AvalonEdit.TextEditor]$editor, [string]$foldings ) {     # should be override
        $item = [TTEditing]::new()
        $item.MemoID = ( $editor.Document.FileName -replace '.+[\\/](?<memoid>[\w\-]+)\..{2,5}', '${memoid}' )
        $item.Offset = ( $editor.CaretOffset )
        $item.WordWrap = $editor.WordWrap
        $item.Foldings = $foldings
        $item.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
        $this.children[$item.MemoID] = $item

        if( $this.loading -eq $false ){
            $this.UpdateDate = ( Get-Date -Format "yyyy-MM-dd-HHmmss")
            $this.count = $this.children.count
            $this.SaveCache()
            if( $this.OnAdd ){ &$this.OnAdd $this }
            if( $this.OnChange ){ &$this.OnChange $this }
        }
    }

    #endregion ----------------------------------------------------------------------------------------------------------

    #region variants/ (GetActions)
    static [string] $Action = ''
    static [string] $ActionDiscardResources = ''
    static [string] $ActionToShelf = ''
    static [string] $ActionToIndex = ''
    static [string] $ActionToCabinet = ''
    static [string] $ActionDataLocaiton = ''
    #endregion ----------------------------------------------------------------------------------------------------------
    
}

#endregion###############################################################################################################



