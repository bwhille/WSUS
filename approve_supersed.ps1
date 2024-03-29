﻿$server = 'wsus'
$port = '8530'

$WSUSserver = Get-WsusServer -Name $server -PortNumber $port
Write-Progress -Activity 'Getting unapproved needed updates...' -PercentComplete 0
$updatesneeded = Get-WsusUpdate -UpdateServer $WSUSserver -Approval Unapproved -Status needed
$i = 0
$total = $updatesneeded.Count
foreach ($update in $updatesneeded) 
{ 
    Write-Progress -Activity 'Approving needed updates...' -Status "$($update.Update.Title)" -PercentComplete (($i/$total) * 100)
    Approve-WsusUpdate -Update $update -Action Install -TargetGroupName 'all computers'
    $i++
}
Write-Host "Updates approved: $total" -ForegroundColor Yellow
Write-Progress -Activity 'Getting unapproved not needed updates...' -PercentComplete 0
$updatesNOTneeded = Get-WsusUpdate -UpdateServer $WSUSserver -Approval Unapproved -Status InstalledOrNotApplicable
$i = 0
$total = $updatesNOTneeded.Count
foreach ($update in $updatesNOTneeded) 
{ 
    Write-Progress -Activity 'Denying updates not needed...' -Status "$($update.Update.Title)" -PercentComplete (($i/$total) * 100)
    Deny-WsusUpdate -Update $update 
    $i++
}
Write-Host "Declined updates: $total" -ForegroundColor Yellow