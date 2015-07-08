$deployHost = 'wrockhost'

if(!$global:session) {
    $global:session = New-Session -ComputerName $deployHost
}

