function Test-Command($cmdname)
{
    try {
      Get-Command -Name $cmdname
      return $true
    }
    catch {
      $global:error.RemoveAt(0)
      return $false
    }
}
