<#
.SYNOPSIS
Use windows chart controls to plot score differences for visualization
.DESCRIPTION
8/29 Used by Report-QueryDiff; uses windows chart controls, builds spline chart using score differences; differences
can be user score diff (output of Diff-UserScores.ps1) or query score diff (output of Diff-QueryScores.ps1)
.PARAMETER DiffScores
Array of score differences; output of either Diff-UserScores.ps1 or Diff-QueryScores.ps1
.PARAMETER Label
Label for the chart; has a default
.EXAMPLE
Chart-ScoreDiff.ps1 -DiffScores $diffQueryScores -Label "Count of Query Score Differences"
#>

Param ([object]$DiffScores = $null, `
       $Label = "Count of Score Differences"
       )

# reference https://blogs.technet.microsoft.com/richard_macdonald/2009/04/28/charting-with-powershell/
	   
if ($DiffScores -eq $null) {throw "DiffScores required; can be user scores or query scores"}
	   
$result = $DiffScores | select  @{Name="bucket";Expression={[int]($_.ScoreChange / .1) * .1  }} `
    | group bucket | select @{Name="ScoreChange"; Expression={[float] $_.Name}}, Count `
	| sort ScoreChange -Descending
	
$result | convertto-csv 

$positiveCount = ($DiffScores | where {$_.ScoreChange -gt 0}).count
$negativeCount = ($DiffScores | where {$_.ScoreChange -lt 0}).count
write-host ("Score changes: {0} positive; {1} negative" -f $positiveCount, $negativeCount)

$load1 = [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$load2 = [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")
if ($load1 -eq $null -or $load2 -eq $null) {throw "Requires Microsoft Chart Controls for Microsoft .NET Framework 3.5"}

$Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart

$Chart.Width = 500
$Chart.Height = 400
$Chart.Left = 40
$Chart.Top = 30
$ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$Chart.ChartAreas.Add($ChartArea)
[void]$Chart.Series.Add("Data")
$Chart.Series["Data"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Spline
$Chart.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
$Chart.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor  [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left

# most of the score differences are in the zero, so omit the zero bucket when plotting
$X = $result | foreach {if ($_.ScoreChange -ne 0) {[float]$_.ScoreChange}}
$Y = $result | foreach {if ($_.ScoreChange -ne 0) {[int]$_.Count}}

if ($X.Count -le 1) {write-warning "One or fewer points to plot after removing zero bucket, so not displaying chart"}
else {

	$Chart.Series["Data"].Points.DataBindXY($X, $Y)

	[void]$Chart.Titles.Add($Label) 
	$ChartArea.AxisX.Title = "Score difference" 
	$ChartArea.AxisY.Title = "Count"
	$ChartArea.AxisX.LabelStyle.Format = "0.###"

	$Form = New-Object Windows.Forms.Form
	$Form.Text = $Label
	$Form.Width = 600
	$Form.Height = 600
	$Form.controls.add($Chart)
	$Form.Add_Shown({$Form.Activate()})
	$Form.ShowDialog()
	
	}
