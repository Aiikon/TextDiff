# TextDiff

A module for using DiffPlex to generate side by side or inline HTML diffs of text.

Utilizes a modified copy of the DiffPlex source code:
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
Get-TextDiffSideBySideHtml -Left $left -Right $right | Out-File "~\Desktop\SideBySideSample.html"
& "~\Desktop\SideBySideSample.html"
```
![Side by Side Sample](/Examples/SideBySideSample.png)

```powershell
Get-TextDiffInlineHtml -Left $left -Right $right | Out-File "~\Desktop\InlineSample.html"
& "~\Desktop\InlineSample.html"
```
![Inline Sample](/Examples/InlineSample.png)
