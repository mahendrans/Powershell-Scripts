$lists = Import-Csv C:\users\ahd0\Desktop\quota.csv

foreach ($list in $lists){
$1 = $list.Email
$2 = $list.Path
$3 = ($list.size / 1gb) * 1Gb

$mailid = $1
$qpath = $2
$qsize = $3


 $MailAction = New-FsrmAction Email -MailCC "$mailid" -MailTo "$mailid" -Subject "[Quota Threshold]% quota threshold exceeded" -Body "User [Source Io Owner] has exceeded the [Quota Threshold]% quota threshold for quota on $qpath in Corp. The quota limit is [Quota Limit MB] MB, and [Quota Used MB] MB currently is in use ([Quota Used Percent]% of limit)."
 $EventAction = New-FsrmAction Event -EventType Information -Body "User [Source Io Owner] has exceeded the [Quota Threshold]% quota threshold for the quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB, and [Quota Used MB] MB currently is in use ([Quota Used Percent]% of limit)."
 $Threshold100M = (New-FsrmQuotaThreshold -Percentage 100 -Action $MailAction , $EventAction),(New-FsrmQuotaThreshold -Percentage 80 -Action $MailAction)
 New-FsrmQuota -Path "$qpath" -Size $qsize -Threshold $Threshold100M

 }
