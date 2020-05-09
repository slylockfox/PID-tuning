Param ([object]$Rows = $null, `
       $FileName = "", `
       $Label = "Target V vs Actual V"
       )

if ($Rows -eq $null) {
	$Rows = Get-Content $FileName | ConvertFrom-Csv
	}

$boundaries = (@())

for ($i=0; $i -lt $Rows.Length-1; $i++) {
	$t1 = [math]::abs($rows[$i].target)
	$t2 = [math]::abs($rows[$i+1].target)
	$a1 = [math]::abs($rows[$i].actual)
	$a2 = [math]::abs($rows[$i+1].actual)
	if ( ($t1 -eq 0.0 -and $a1 -eq 0.0 -and ($t2 -ne 0.0 -or $a2 -ne 0.0)) -or (($t1 -ne 0.0 -or $a1 -ne 0.0) -and $t2 -eq 0.0 -and $a2 -eq 0.0) ) {
		$boundaries += $i
		}
	}

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
[void]$Chart.Series.Add("Target")
$Chart.Series["Target"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Spline
[void]$Chart.Series.Add("Actual")
$Chart.Series["Actual"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Spline
$Chart.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
$Chart.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor  [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left

$X = $rows[$boundaries[0]..$boundaries[1]].sec
$Y1 = $rows[$boundaries[0]..$boundaries[1]].target
$Y2 = $rows[$boundaries[0]..$boundaries[1]].actual

if ($X.Count -le 1) {write-warning "One or fewer points to plot"}
else {

	$Chart.Series["Target"].Points.DataBindXY($X, $Y1)
	$Chart.Series["Actual"].Points.DataBindXY($X, $Y2)

	[void]$Chart.Titles.Add($Label) 
	$ChartArea.AxisX.Title = "Time (sec)" 
	$ChartArea.AxisY.Title = "Velocity"
	$ChartArea.AxisX.LabelStyle.Format = "0.###"

	$Legend = New-Object System.Windows.Forms.DataVisualization.Charting.Legend
	$Chart.Legends.Add($Legend)
	$Chart.Legends[0].Docking = "Bottom"
	$Chart.Legends[0].Font = (New-Object System.Drawing.Font -ArgumentList "Segui", "12")
	$Chart.Legends[0].Alignment = "Center"

	$Form = New-Object Windows.Forms.Form
	$Form.Text = $Label
	$Form.Width = 600
	$Form.Height = 600
	$Form.controls.add($Chart)
	$Form.Add_Shown({$Form.Activate()})
	$dontcare = $Form.ShowDialog()
	
	}
