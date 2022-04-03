<#
  A DNS Name resolving function
  Designed to be flexible, and work with a list of hostnames
  Can use a specific DNS server/s, or use the one for local interfaces
  Also allows for Type/s, or ALL (either text or * character)
#>
function Get-DNSResolved {
  [cmdletbinding()]
  param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeLine)]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $Hostname,
    [Parameter(Mandatory=$false, Position=1)]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $Server,
    [Parameter(Mandatory=$false, Position=2)]
    [ValidateSet("UNKNOWN", "A_AAAA", "A", "NS", "MD", "MF", "CNAME", "SOA", "MB", "MG", "MR", "NULL", "WKS", "PTR", "HINFO", "MINFO", "MX", "TXT", "RP",
    "AFSDB", "X25", "ISDN", "RT", "AAAA", "SRV", "DNAME", "OPT", "DS", "RRSIG", "NSEC", "DNSKEY", "DHCID", "NSEC3", "NSEC3PARAM", "ANY", "ALL", "WINS",
    "*", ignorecase=$true)]
    [string[]]
    $Type = @("A")
  )
  begin{
    if($type -contains "*"){$Type = @("ALL")}
    $results = @()
  }
  process{
    foreach($hn in $hostname){
      foreach($typ in $type){
        if($null -eq $server -or $server -eq @()){
          $results += Resolve-DNSName -Name $hn -Type $Typ
        }
        else{
          foreach($serv in $server){
            $cnt = $results.count
            $results += Resolve-DNSName -Name $hn -Type $Typ -Server $serv
            $results[(($results.count - $cnt) * -1)..-1] | ForEach-Object{$_.Name += " ($($serv))"}
          }
        }
      }
    }
  }
  end{
    return $results
  }
}

# No TLS / SSL support yet...
function Run-SMTPTest {
  [cmdletbinding()]
  param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeLine)]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $Recipient,
    [Parameter(Mandatory=$false, Position=1)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Subject,
    [Parameter(Mandatory=$false, Position=2)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Sender,
    [Parameter(Mandatory=$false, Position=3)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Server,
    [Parameter(Mandatory=$false, Position=4)]
    [ValidateNotNullOrEmpty()]
    [int32]
    $ServerPort,
    [Parameter(Mandatory=$false, Position=5)]
    [ValidateNotNullOrEmpty()]
    [string]
    $RecipientServer,
    [Parameter(Mandatory=$false, Position=6)]
    [ValidateNotNullOrEmpty()]
    [int32]
    $RecipientPort
  )
  begin{

  }
  process{

  }
  end{

  }
}


while($tcp.connected)
{
write-host ([char]$Reader.Read()) -NoNewLine
while(($reader.Peek() -ne -1) -or ($tcp.Available)){
write-host ([char]$reader.Read()) -NoNewLine
}
if($tcp.connected)
{
write-host -NoNewLine "_"
$command = Read-Host
if($command -eq "escape")
{
break
}
$writer.WriteLine($command)|Out-Null
}
}
$reader.Close()
$writer.close()
$tcp.Close()
