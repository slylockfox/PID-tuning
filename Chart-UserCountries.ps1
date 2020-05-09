<#
.SYNOPSIS
Use windows chart controls to plot bar chart of country representation for set of users
.DESCRIPTION
8/29 Use windows chart controls to plot bar chart of country representation for set of users, which should be output
of Select-RandomUsers.ps1
.PARAMETER Users
Array of users, output of Select-RandomUsers.ps1
.PARAMETER TopNToShow
Default is 8; plot this many companies max
.EXAMPLE
Chart-UserCountries.ps1 -Users $randomUsers
#>

Param ([object]$Users = $null, `
       $TopNToShow = 8 `
       )

# reference: https://blogs.technet.microsoft.com/richard_macdonald/2009/04/28/charting-with-powershell/
	   
#if ($Users -eq $null) {throw "Users required; get using Select-RandomUsers.ps1"}
#$topUsers = $Users | group Country | select Name, Count | sort Count -Descending | select -first $TopNToShow
	   
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

# convert top users to map
#$topUserMap = @{}
#$topUsers | foreach { $topUserMap[$_.Name] = $_.Count }

$Cities = @{London=7556900; Berlin=3429900; Madrid=3213271; Rome=2726539; Paris=2188500}

[void]$Chart.Series.Add("Data")
$Chart.Series["Data"].Points.DataBindXY($Cities.Keys, $Cities.Values)
$Chart.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
$Chart.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor  [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
[void]$Chart.Titles.Add("Top Countries by User Count") 
$ChartArea.AxisX.Title = "Countries" 
$ChartArea.AxisY.Title = "User Count"

$Form = New-Object Windows.Forms.Form
$Form.Text = "Top Countries by User Count"
$Form.Width = 600
$Form.Height = 600
$Form.controls.add($Chart)
$Form.Add_Shown({$Form.Activate()})
$Form.ShowDialog()
