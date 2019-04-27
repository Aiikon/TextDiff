Import-Module (Get-Module TextDiff).Path -Force

$script1 = {
Get-ChildItem C:\Windows |
    Where-Object { $_.Length } |
    Select-Object Name, Length
}.ToString().Trim()

$script2 = {
Get-ChildItem C:\Windows\System32 |
    Where-Object { $_.Length } |
    Select-Object Name, Length, Count |
    Sort-Object LastWriteTime
}.ToString().Trim()

& {
    '<h2>Side by Side</h2>'
    Get-TextDiffSideBySideHtml $script1 $script2
    '<h2>Inline</h2>'
    Get-TextDiffInlineHtml $script1 $script2
} |
    Out-File '~\Desktop\TextDiffSample.html'

& '~\Desktop\TextDiffSample.html'