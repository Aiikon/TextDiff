Function Get-DiffPlexSideBySide
{
    Param
    (
        [Parameter(Position=0)] [string[]] $Left,
        [Parameter(Position=1)] [string[]] $Right
    )
    End
    {
        Add-Type -Path $PSScriptRoot\DiffPlex.dll
        Add-Type -AssemblyName System.Web

        $leftText = $Left -join "`r`n"
        $rightText = $Right -join "`r`n"

        $differ = New-Object DiffPlex.Differ
        $diffBuilder = New-Object DiffPlex.DiffBuilder.SideBySideDiffBuilder $differ
        $diffModel = $diffBuilder.BuildDiffModel($leftText, $rightText)

        $deltaLookup = @{}
        $deltaLookup.[DiffPlex.DiffBuilder.Model.ChangeType]::Unchanged = '=='
        $deltaLookup.[DiffPlex.DiffBuilder.Model.ChangeType]::Modified = '<>'
        $deltaLookup.[DiffPlex.DiffBuilder.Model.ChangeType]::Imaginary = '>>'
        $deltaLookup.[DiffPlex.DiffBuilder.Model.ChangeType]::Deleted = '<<'

        for ($i = 0; $i -lt $diffModel.OldText.Lines.Count; $i++)
        {
            $result = [ordered]@{}
            $oldLine = $diffModel.OldText.Lines[$i]
            $newLine = $diffModel.NewText.Lines[$i]
            $result.L = $oldLine.Position
            $result.Left = $oldLine.Text
            $result.Delta = $deltaLookup[$oldLine.Type]
            $result.Right = $newLine.Text
            $result.R = $newLine.Position
            $result.LeftPieces = $oldLine.SubPieces
            $result.RightPieces = $newLine.SubPieces
            [pscustomobject]$result
        }
    }
}

Function HtmlEncode
{
    Param($Text)
    [System.Web.HttpUtility]::HtmlEncode($Text).Replace(' ', '&nbsp;')
}

Function Get-DiffPlexSideBySideHtml
{
    <#
    .EXAMPLE

    $left = "
        ABC abc
        DEF def
        HIJ
        KLM
    " -replace '  +'
    $right = "
        ABC abc
        DEF DEF
        KLM
        XYZ
    " -replace '  +'

    Get-DiffPlexSideBySideHtml $left $right | Out-File "~\Desktop\SideBySideSample.html"
    & "~\Desktop\SideBySideSample.html"

    #>
    Param
    (
        [Parameter(Position=0)] [string[]] $Left,
        [Parameter(Position=1)] [string[]] $Right
    )
    End
    {
        $lineData = Get-DiffPlexSideBySide -Left $Left -Right $Right

        $getDiffPieces = {
            param ($Pieces)
            $lastStateChanged = $false
            foreach ($piece in $Pieces)
            {
                $changed = $piece.Type -ne 'Unchanged'
                if ($changed -ne $lastStateChanged)
                {
                    if ($changed) { "<span style='background: yellow;'>" }
                    else { "</span>" }
                    $lastStateChanged = $changed
                }
                HtmlEncode $piece.Text
            }
            if ($lastStateChanged) { "</span>" }
        }

        $readyData = foreach ($line in $lineData)
        {
            if ($line.Delta -eq '<>')
            {
                $line.Left = (& $getDiffPieces $line.LeftPieces) -join ''
                $line.Right = (& $getDiffPieces $line.RightPieces) -join ''
            }
            elseif ($line.Delta -eq '<<')
            {
                $line.Left = "<span style='background: yellow;'>$(HtmlEncode $line.Left)</span>"
            }
            elseif ($line.Delta -eq '>>')
            {
                $line.Right = "<span style='background: yellow;'>$(HtmlEncode $line.Right)</span>"
            }
            else
            {
                $line.Left = HtmlEncode $line.Left
                $line.Right = HtmlEncode $line.Right
            }
            $line
        }

        "
        <style>
        table.DiffPlexSideBySide {
            border-collapse: collapse;
            border-spacing: 0;
        }
        table.DiffPlexSideBySide th {
            text-align: left;
            border-style: none none solid none;
            border-width: 0px 0px 2px 0px;
            border-color: black;
            padding: 1px 10px 1px 10px;
            page-break-inside: avoid;
            font-family: calibri;
        }
        table.DiffPlexSideBySide td {
            border-style: solid none none none;
            border-width: 1px 0px 0px 0px;
            border-color: black;
            padding: 1px 10px 1px 10px;
            page-break-inside: avoid;
            font-family: consolas;
        }
        </style>
        <table class='DiffPlexSideBySide'>
        <tr><th>L</th><th>Left</th><th>Delta</th><th>Right</th><th>R</th></tr>" -replace "        "
        foreach ($line in $readyData)
        {
            "<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td></tr>" -f $line.L, $line.Left, $line.Delta, $line.Right, $line.R
        }
        "</table>"
    }
}

Function Get-DiffPlexInlineHtml
{
    <#
    .EXAMPLE

    $left = "
        ABC abc
        DEF def
        HIJ
        KLM
    " -replace '  +'
    $right = "
        ABC abc
        DEF DEF
        KLM
        XYZ
    " -replace '  +'

    Get-DiffPlexInlineHtml $left $right | Out-File "~\Desktop\InlineSample.html"
    & "~\Desktop\InlineSample.html"

    #>
    Param
    (
        [Parameter(Position=0)] [string[]] $Left,
        [Parameter(Position=1)] [string[]] $Right
    )
    End
    {
        $lineData = Get-DiffPlexSideBySide -Left $Left -Right $Right

        $redLight = 255,220,224 -join ','
        $redDark = 253,184,192 -join ','
        $greenLight = 230,255,237 -join ','
        $greenDark = 172,242,189 -join ','

        $getDiffPieces = {
            param ($Pieces, $Color)
            $lastStateChanged = $false
            foreach ($piece in $Pieces)
            {
                $changed = $piece.Type -ne 'Unchanged'
                if ($changed -ne $lastStateChanged)
                {
                    if ($changed) { "<span style='background-color: rgb($Color);'>" }
                    else { "</span>" }
                    $lastStateChanged = $changed
                }
                HtmlEncode $piece.Text
            }
            if ($lastStateChanged) { "</span>" }
        }

        $getTr = {
            param ($record, $class)
            if ($class) { $class = " class='$class'" }
            "<tr$class><td class='rb'>$($record.L)</td><td class='rb'>$($record.R)</td><td>$($record.D)</td><td>$($record.Text)</td></tr>"
        }

        "
        <style>
        table.DiffPlexInline {
            border-collapse: collapse;
            border-spacing: 0;
            font-size: 11pt;
            border-style: none none none none;
            font-family: consolas;
        }
        table.DiffPlexInline tr.green {
            background-color: rgb($greenLight);
        }
        table.DiffPlexInline tr.red {
            background-color: rgb($redLight);
        }
        table.DiffPlexInline th, td {
            text-align: left;
            padding: 1px 8px 1px 8px;
        }
        table.DiffPlexInline th.rb, td.rb {
            border-style: none solid none none;
            border-width: 0px 1px 0px 0px;
        }
        </style>
        <table class='DiffPlexInline'>
        <thead><tr><th class='rb'>L</th><th class='rb'>R</th><th>D</th><th>Line</th></tr></thead><tbody>"

        foreach ($set in $lineData)
        {
            if ($set.Delta -eq '==')
            {
                $record = [ordered]@{}
                $record.L = $set.L
                $record.R = $set.R
                $record.D = ''
                $record.Text = HtmlEncode $set.Left
                & $getTr $record
            }
            elseif ($set.Delta -eq '<<')
            {
                $record = [ordered]@{}
                $record.L = $set.L
                $record.R = $null
                $record.D = '-'
                $record.Text = HtmlEncode $set.Left
                & $getTr $record 'red'
            }
            elseif ($set.Delta -eq '>>')
            {
                $record = [ordered]@{}
                $record.L = $null
                $record.R = $set.R
                $record.D = '+'
                $record.Text = HtmlEncode $set.Right
                & $getTr $record 'green'
            }
            elseif ($set.Delta -eq '<>')
            {
                $record = [ordered]@{}
                $record.L = $set.L
                $record.R = $null
                $record.D = '-'
                $record.Text = (& $getDiffPieces $set.LeftPieces $redDark) -join ''
                & $getTr $record 'red'

                $record = [ordered]@{}
                $record.L = $null
                $record.R = $set.R
                $record.D = '+'
                $record.Text = (& $getDiffPieces $set.RightPieces $greenDark) -join ''
                & $getTr $record 'green'
            }
        }

        "</tbody></table>"
    }
}
