$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Net.Http
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$port = 8765
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $port)
$base = 'https://phongdaotao.cdytehatinh.edu.vn'

function Send-Response($stream, [int]$status, [string]$reason, [string]$contentType, [byte[]]$body) {
    $header = "HTTP/1.1 $status $reason`r`nContent-Type: $contentType`r`nContent-Length: $($body.Length)`r`nCache-Control: no-store`r`nConnection: close`r`nX-Content-Type-Options: nosniff`r`n`r`n"
    $headBytes = [System.Text.Encoding]::ASCII.GetBytes($header)
    $stream.Write($headBytes, 0, $headBytes.Length)
    if ($body.Length -gt 0) { $stream.Write($body, 0, $body.Length) }
    $stream.Flush()
}

try {
    $listener.Start()
    Write-Host ''
    Write-Host ' THOI KHOA BIEU - CAO DANG Y TE HA TINH' -ForegroundColor Cyan
    Write-Host ' Dang chay noi bo tren may nay. Khong can hosting.' -ForegroundColor Green
    Write-Host " Mo trinh duyet: http://127.0.0.1:$port/" -ForegroundColor Yellow
    Write-Host ' Giu cua so nay mo trong luc xem thoi khoa bieu.' -ForegroundColor Gray
    Write-Host ' Nhan Ctrl+C de tat.' -ForegroundColor Gray
    Write-Host ' Log yeu cau API se hien ben duoi.' -ForegroundColor DarkGray
    Start-Sleep -Milliseconds 500
    Start-Process "http://127.0.0.1:$port/"
    while ($listener.Server.IsBound) {
        $client = $listener.AcceptTcpClient()
        try {
            $client.ReceiveTimeout = 10000
            $stream = $client.GetStream()
            $reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::ASCII, $false, 1024, $true)
            $requestLine = $reader.ReadLine()
            if ([string]::IsNullOrWhiteSpace($requestLine)) { continue }
            $parts = $requestLine.Split(' ')
            $method = $parts[0]
            $target = $parts[1]
            while (($line = $reader.ReadLine()) -ne $null -and $line -ne '') { }
            Write-Host ("[{0}] {1} {2}" -f (Get-Date -Format 'HH:mm:ss'), $method, $target) -ForegroundColor DarkCyan
            if ($method -ne 'GET') {
                $body = [System.Text.Encoding]::UTF8.GetBytes('{"error":"Method not allowed"}')
                Send-Response $stream 405 'Method Not Allowed' 'application/json; charset=utf-8' $body
                continue
            }
            if ($target -eq '/' -or $target.StartsWith('/index.html')) {
                $body = [System.IO.File]::ReadAllBytes((Join-Path $root 'index.html'))
                Send-Response $stream 200 'OK' 'text/html; charset=utf-8' $body
            }
            elseif ($target -eq '/api/ping') {
                $body = [System.Text.Encoding]::UTF8.GetBytes('{"ok":true,"message":"Local helper dang hoat dong"}')
                Send-Response $stream 200 'OK' 'application/json; charset=utf-8' $body
            }
            elseif ($target.StartsWith('/api/attendance/')) {
                $remote = $base + $target
                try {
                    $webRequest = [System.Net.HttpWebRequest]::Create($remote)
                    $webRequest.Method = 'GET'
                    $webRequest.Timeout = 35000
                    $webRequest.ReadWriteTimeout = 35000
                    $webRequest.UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/126.0.0.0 Safari/537.36'
                    $webRequest.Accept = 'application/json, text/plain, */*'
                    $webRequest.Headers['Cache-Control'] = 'no-cache'
                    $webRequest.Headers['Pragma'] = 'no-cache'
                    $webRequest.Referer = "$base/xem-lich-hoc/lich-cong-khai"
                    try {
                        $remoteResponse = $webRequest.GetResponse()
                    } catch [System.Net.WebException] {
                        $remoteResponse = $_.Exception.Response
                        if (-not $remoteResponse) { throw }
                    }
                    $remoteStream = $remoteResponse.GetResponseStream()
                    $memory = [System.IO.MemoryStream]::new()
                    $remoteStream.CopyTo($memory)
                    $body = $memory.ToArray()
                    $ct = $remoteResponse.ContentType
                    if ([string]::IsNullOrWhiteSpace($ct)) { $ct = 'application/json; charset=utf-8' }
                    $status = [int]$remoteResponse.StatusCode
                    $reason = $remoteResponse.StatusDescription
                    Write-Host ("  -> HTTP {0} {1} ({2} bytes)" -f $status, $reason, $body.Length) -ForegroundColor Green
                    Send-Response $stream $status $reason $ct $body
                    $memory.Dispose(); $remoteStream.Dispose(); $remoteResponse.Close()
                } catch {
                    $msg = $_.Exception.ToString().Replace('"', "'")
                    Write-Host ("  -> LOI: " + $_.Exception.Message) -ForegroundColor Red
                    $json = @{error=('Khong goi duoc API truong: ' + $_.Exception.Message); detail=$msg} | ConvertTo-Json -Compress
                    $body = [System.Text.Encoding]::UTF8.GetBytes($json)
                    Send-Response $stream 502 'Bad Gateway' 'application/json; charset=utf-8' $body
                }
            }
            else {
                $body = [System.Text.Encoding]::UTF8.GetBytes('{"error":"Not found"}')
                Send-Response $stream 404 'Not Found' 'application/json; charset=utf-8' $body
            }
        }
        catch {
            try {
                $msg = $_.Exception.Message.Replace('"', "'")
                $body = [System.Text.Encoding]::UTF8.GetBytes('{"error":"Local helper error: ' + $msg + '"}')
                Send-Response $stream 502 'Bad Gateway' 'application/json; charset=utf-8' $body
            } catch { }
        }
        finally { if ($client) { $client.Close() } }
    }
}
catch {
    Write-Host "Khong khoi dong duoc may chu noi bo: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host 'Hay dong ung dung dang dung cong 8765 roi chay lai.' -ForegroundColor Yellow
    Read-Host 'Nhan Enter de dong'
}
finally {
    if ($listener) { $listener.Stop() }
}
