# DiffPlex

A module for using DiffPlex to generate side by side or inline HTML diffs of text.

Thanks to the DiffPlex project for all the real work:
https://github.com/mmanela/diffplex

## Example Usage
```powershell
$left = @"
ABC abc
DEF def
HIJ
KLM
"@

$right = @"
ABC abc
DEF DEF
KLM
XYZ
"@
```

```powershell
Get-DiffPlexSideBySideHtml -Left $left -Right $right | Out-File "~\Desktop\SideBySideSample.html"
& "~\Desktop\SideBySideSample.html"
```
![Side by Side Sample](/Examples/SideBySideSample.png)

```powershell
Get-DiffPlexInlineHtml -Left $left -Right $right | Out-File "~\Desktop\InlineSample.html"
& "~\Desktop\InlineSample.html"
```
![Inline Sample](/Examples/InlineSample.png)
