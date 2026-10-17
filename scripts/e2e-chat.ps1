# ==============================================================================
# Peer Tutoring Board - End-to-End Real-Time Post-Session Chat Verification
# ==============================================================================

$ErrorActionPreference = "Stop"
$baseUrl = "http://localhost:8080/api"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " REAL CHAT E2E VERIFICATION (WITH REAL CLOCK)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Helper for JSON REST requests
function Invoke-Api([string]$method, [string]$endpoint, [hashtable]$headers = @{}, $body = $null) {
    $uri = "$baseUrl$endpoint"
    $reqHeaders = @{ "Content-Type" = "application/json; charset=utf-8" }
    foreach ($k in $headers.Keys) { $reqHeaders[$k] = $headers[$k] }

    $params = @{
        Uri = $uri
        Method = $method
        Headers = $reqHeaders
    }
    if ($null -ne $body) {
        $json = if ($body -is [string]) { $body } else { $body | ConvertTo-Json -Compress }
        $params["Body"] = [System.Text.Encoding]::UTF8.GetBytes($json)
    }

    try {
        return Invoke-RestMethod @params
    } catch {
        $resp = $_.Exception.Response
        $status = if ($resp) { [int]$resp.StatusCode } else { 0 }
        $reader = if ($resp) { New-Object System.IO.StreamReader($resp.GetResponseStream()) } else { $null }
        $errBody = if ($reader) { $reader.ReadToEnd() } else { $_.Exception.Message }
        return @{
            _error = $true
            _status = $status
            _body = $errBody
        }
    }
}

# 1. Check API Health and current campus server time
Write-Host "`n[1/7] Fetching campus server time from /api/health..." -ForegroundColor Yellow
$health = Invoke-Api "GET" "/health"
if ($health._error) {
    Write-Error "Failed to reach /api/health: $($health._body)"
}
$serverTimeStr = $health.serverTime
$serverTime = [DateTime]::Parse($serverTimeStr)
Write-Host "  -> Health status: $($health.status), Campus Server Time: $serverTimeStr ($($health.timeZone))" -ForegroundColor Green

# 2. Register Accounts: Tutor, Student 1, Student 2 (third party)
$suffix = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
$tutorEmail = "tutor_chat_$suffix@campus.edu"
$student1Email = "student1_chat_$suffix@campus.edu"
$student2Email = "student2_chat_$suffix@campus.edu"

Write-Host "`n[2/7] Registering participants..." -ForegroundColor Yellow
$tutorReg = Invoke-Api "POST" "/auth/register" @{} @{
    name = "Tutor Chat Tester"
    email = $tutorEmail
    password = "password123"
    role = "TUTOR"
}
$tutorToken = $tutorReg.token
$tutorHeaders = @{ "Authorization" = "Bearer $tutorToken" }

$s1Reg = Invoke-Api "POST" "/auth/register" @{} @{
    name = "Student One"
    email = $student1Email
    password = "password123"
    role = "STUDENT"
}
$s1Token = $s1Reg.token
$s1Headers = @{ "Authorization" = "Bearer $s1Token" }

$s2Reg = Invoke-Api "POST" "/auth/register" @{} @{
    name = "Student Two (Third Party)"
    email = $student2Email
    password = "password123"
    role = "STUDENT"
}
$s2Token = $s2Reg.token
$s2Headers = @{ "Authorization" = "Bearer $s2Token" }
Write-Host "  -> Registered Tutor, Student 1, and Student 2 successfully." -ForegroundColor Green

# 3. Create Tutor Profile with Subject 1
Invoke-Api "PUT" "/tutors/me" $tutorHeaders @{
    bio = "Real chat test tutor"
    department = "CSE"
    yearOfStudy = 4
    subjectIds = @(1)
} | Out-Null
Write-Host "  -> Tutor profile created." -ForegroundColor Green

# 4. Create Slots:
# Refresh current campus server time
$healthNow = Invoke-Api "GET" "/health"
$now = [DateTime]::Parse($healthNow.serverTime)

# Slot 1: Starts in 2 minutes 10 seconds (>= 2 min lead time), lasts 5 minutes -> session ends in 7m10s, opening chat!
$s1StartDt = $now.AddMinutes(2).AddSeconds(10)
$s1EndDt = $s1StartDt.AddMinutes(5)
$slot1Start = $s1StartDt.ToString("yyyy-MM-ddTHH:mm:ss", [System.Globalization.CultureInfo]::InvariantCulture)
$slot1End = $s1EndDt.ToString("yyyy-MM-ddTHH:mm:ss", [System.Globalization.CultureInfo]::InvariantCulture)

Write-Host "`n[3/7] Creating test slots..." -ForegroundColor Yellow
$slot1 = Invoke-Api "POST" "/slots" $tutorHeaders @{
    startTime = $slot1Start
    endTime = $slot1End
    mode = "ONLINE"
    locationOrLink = "https://meet.google.com/real-chat-slot1"
}
if ($slot1._error) {
    Write-Error "Failed to create Slot 1: $($slot1._body)"
}
Write-Host "  -> Slot 1 (Test Chat): ID $($slot1.id), starts $slot1Start, ends $slot1End" -ForegroundColor Green

# Slot 2: Later slot (starts in 60 min, ends in 90 min) -> stays NOT_STARTED for order check
$s2StartDt = $now.AddMinutes(60)
$s2EndDt = $now.AddMinutes(90)
$slot2Start = $s2StartDt.ToString("yyyy-MM-ddTHH:mm:ss", [System.Globalization.CultureInfo]::InvariantCulture)
$slot2End = $s2EndDt.ToString("yyyy-MM-ddTHH:mm:ss", [System.Globalization.CultureInfo]::InvariantCulture)
$slot2 = Invoke-Api "POST" "/slots" $tutorHeaders @{
    startTime = $slot2Start
    endTime = $slot2End
    mode = "ONLINE"
    locationOrLink = "https://meet.google.com/real-chat-slot2"
}
if ($slot2._error) {
    Write-Error "Failed to create Slot 2: $($slot2._body)"
}
Write-Host "  -> Slot 2 (Later Session): ID $($slot2.id), starts $slot2Start, ends $slot2End" -ForegroundColor Green

# 5. Request & Accept Both Sessions
Write-Host "`n[4/7] Requesting and accepting sessions..." -ForegroundColor Yellow
$req1 = Invoke-Api "POST" "/requests" $s1Headers @{
    slotId = $slot1.id
    subjectId = 1
    message = "Request for Slot 1 chat verification"
}
$accept1 = Invoke-Api "PATCH" "/requests/$($req1.id)/status" $tutorHeaders @{ status = "ACCEPTED" }
Write-Host "  -> Request 1 accepted (ID: $($req1.id)). Initial Chat State: $($accept1.chat.state)" -ForegroundColor Green

$req2 = Invoke-Api "POST" "/requests" $s1Headers @{
    slotId = $slot2.id
    subjectId = 1
    message = "Request for Slot 2 later session"
}
$accept2 = Invoke-Api "PATCH" "/requests/$($req2.id)/status" $tutorHeaders @{ status = "ACCEPTED" }
Write-Host "  -> Request 2 accepted (ID: $($req2.id)). Initial Chat State: $($accept2.chat.state)" -ForegroundColor Green

# 6. Polling GET /api/chats every 20 seconds until Chat 1 opens (when slot1End is reached)
Write-Host "`n[5/7] Polling GET /api/chats every 20s until Session 1 ends and chat becomes OPEN..." -ForegroundColor Yellow
Write-Host "  Expected open time: $slot1End (in ~7 minutes from start)" -ForegroundColor Gray

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$isChatOpen = $false

while ($stopwatch.Elapsed.TotalMinutes -lt 10) {
    Start-Sleep -Seconds 20
    $chats = Invoke-Api "GET" "/chats" $s1Headers
    $chat1Item = $chats | Where-Object { $_.requestId -eq $req1.id }

    $currentState = if ($chat1Item -and $chat1Item.chat) { $chat1Item.chat.state } else { "UNKNOWN" }
    $elapsedSec = [int]$stopwatch.Elapsed.TotalSeconds
    Write-Host "  [Elapsed ${elapsedSec}s] Chat 1 state: $currentState" -ForegroundColor Gray

    if ($currentState -eq "OPEN") {
        $isChatOpen = $true
        Write-Host "  -> CHAT IS NOW OPEN! (Total wait: ${elapsedSec}s)" -ForegroundColor Green
        break
    }
}

if (-not $isChatOpen) {
    Write-Error "Timeout waiting for chat to become OPEN after 10 minutes."
}

# 7. Verification Actions
Write-Host "`n[6/7] Verifying chat sorting and message exchanges..." -ForegroundColor Yellow

# A. Sort order in /api/chats: OPEN must be before NOT_STARTED
$chatsList = Invoke-Api "GET" "/chats" $s1Headers
if ($chatsList.Count -lt 2) {
    Write-Error "Expected at least 2 chats in /api/chats, got $($chatsList.Count)"
}
$firstState = $chatsList[0].chat.state
$secondState = $chatsList[1].chat.state
Write-Host "  -> Order in /api/chats: [0] = $firstState, [1] = $secondState" -ForegroundColor Cyan
if ($firstState -ne "OPEN" -or $secondState -ne "NOT_STARTED") {
    Write-Error "Invalid chat ordering! Expected OPEN before NOT_STARTED, got $firstState then $secondState"
}
Write-Host "  -> SUCCESS: /api/chats correctly sorts OPEN before NOT_STARTED." -ForegroundColor Green

# B. Student 1 sends message (expect 201)
$msg1Content = "Hello tutor, thanks for the session!"
$send1 = Invoke-Api "POST" "/requests/$($req1.id)/messages" $s1Headers @{ content = $msg1Content }
if ($send1._error) {
    Write-Error "Student send message failed: $($send1._body)"
}
Write-Host "  -> Student sent message (ID: $($send1.id), sender: $($send1.senderName), content: '$($send1.content)')" -ForegroundColor Green

# C. Tutor replies (expect 201)
$msg2Content = "You're welcome! Great progress today."
$send2 = Invoke-Api "POST" "/requests/$($req1.id)/messages" $tutorHeaders @{ content = $msg2Content }
if ($send2._error) {
    Write-Error "Tutor send reply failed: $($send2._body)"
}
Write-Host "  -> Tutor sent reply (ID: $($send2.id), sender: $($send2.senderName), content: '$($send2.content)')" -ForegroundColor Green

# D. GET /requests/{id}/messages?afterId=0 returns both messages in order
$allMsgs = Invoke-Api "GET" "/requests/$($req1.id)/messages?afterId=0" $s1Headers
if ($allMsgs._error -or $allMsgs.messages.Count -ne 2) {
    Write-Error "Expected 2 messages with afterId=0, got $($allMsgs.messages.Count)"
}
Write-Host "  -> GET ?afterId=0 returned $($allMsgs.messages.Count) messages in order." -ForegroundColor Green

# E. GET /requests/{id}/messages?afterId=<first id> returns only the second message
$afterFirst = Invoke-Api "GET" "/requests/$($req1.id)/messages?afterId=$($send1.id)" $s1Headers
if ($afterFirst._error -or $afterFirst.messages.Count -ne 1 -or $afterFirst.messages[0].id -ne $send2.id) {
    Write-Error "Expected only message 2 with afterId=$($send1.id), got: $($afterFirst | ConvertTo-Json)"
}
Write-Host "  -> GET ?afterId=$($send1.id) returned only the second message." -ForegroundColor Green

# F. GET /api/chats shows lastMessage filled
$chatsAfter = Invoke-Api "GET" "/chats" $s1Headers
$chatItem = $chatsAfter | Where-Object { $_.requestId -eq $req1.id }
if (-not $chatItem.lastMessage -or $chatItem.lastMessage.content -ne $msg2Content) {
    Write-Error "Expected lastMessage to have content '$msg2Content', got: $($chatItem.lastMessage | ConvertTo-Json)"
}
Write-Host "  -> GET /api/chats confirmed lastMessage is populated with: '$($chatItem.lastMessage.content)'" -ForegroundColor Green

# G. Third user (Student 2) gets 403 Forbidden
Write-Host "`n[7/7] Verifying security checks (non-participant gets 403)..." -ForegroundColor Yellow
$s2Get = Invoke-Api "GET" "/requests/$($req1.id)/messages" $s2Headers
if (-not $s2Get._error -or $s2Get._status -ne 403) {
    Write-Error "Expected 403 for third user GET messages, got status $($s2Get._status)"
}
Write-Host "  -> Non-participant GET returned 403 Forbidden as expected." -ForegroundColor Green

$s2Post = Invoke-Api "POST" "/requests/$($req1.id)/messages" $s2Headers @{ content = "Intruder message" }
if (-not $s2Post._error -or $s2Post._status -ne 403) {
    Write-Error "Expected 403 for third user POST message, got status $($s2Post._status)"
}
Write-Host "  -> Non-participant POST returned 403 Forbidden as expected." -ForegroundColor Green

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host " ALL REAL-TIME CHAT E2E CHECKS PASSED SUCCESSFULLY!" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
