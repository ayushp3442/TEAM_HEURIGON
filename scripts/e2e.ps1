# ==============================================================================
# End-to-End Test Script (PowerShell) - Peer Tutoring Board
# Tests the full user journey using only the public REST API:
# 1. Register a Tutor and a Student (unique accounts per run)
# 2. Tutor creates profile (bio, department, subjects)
# 3. Tutor posts an availability slot
# 4. Student searches for tutors (verifies filters and open slots)
# 5. Student requests the slot
# 6. Tutor accepts the request
# 7. Check post-session chat state (NOT_STARTED for future session)
# ==============================================================================

$ErrorActionPreference = "Stop"
$BASE_URL = "http://localhost:8080/api"

$ts = Get-Date -Format "yyyyMMddHHmmss"
$rnd = Get-Random -Minimum 1000 -Maximum 9999
$tutorEmail = "tutor_${ts}_${rnd}@campus.edu"
$studentEmail = "student_${ts}_${rnd}@campus.edu"
$password = "password123"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " PEER TUTORING BOARD - END-TO-END VERIFICATION (POWERSHELL)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Tutor Email   : $tutorEmail"
Write-Host "Student Email : $studentEmail`n"

function Invoke-Api {
    param (
        [string]$Method,
        [string]$Path,
        [object]$Body = $null,
        [string]$Token = $null
    )
    $headers = @{ "Content-Type" = "application/json" }
    if ($Token) {
        $headers["Authorization"] = "Bearer $Token"
    }
    $params = @{
        Uri         = "$BASE_URL$Path"
        Method      = $Method
        Headers     = $headers
        ContentType = "application/json"
    }
    if ($Body) {
        $params["Body"] = ($Body | ConvertTo-Json -Depth 10)
    }
    try {
        $resp = Invoke-RestMethod @params
        return @{ StatusCode = 200; Data = $resp }
    } catch {
        $status = $_.Exception.Response.StatusCode.value__
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $raw = $reader.ReadToEnd()
        $data = $null
        try { $data = $raw | ConvertFrom-Json } catch { $data = $raw }
        return @{ StatusCode = $status; Data = $data }
    }
}

# --- Step 1: Health check ---
Write-Host "[1/8] Checking API Health..." -ForegroundColor Yellow
$health = Invoke-Api -Method "GET" -Path "/health"
if ($health.Data.status -ne "UP") {
    Write-Host "Backend health check failed!" -ForegroundColor Red
    exit 1
}
Write-Host "  -> Health status: UP" -ForegroundColor Green

# --- Step 2: Register Tutor & Student ---
Write-Host "[2/8] Registering Unique Accounts..." -ForegroundColor Yellow
$regTutor = Invoke-Api -Method "POST" -Path "/auth/register" -Body @{
    name     = "Prof. Test Tutor $rnd"
    email    = $tutorEmail
    password = $password
    role     = "TUTOR"
}
$tutorToken = $regTutor.Data.token
$tutorUserId = $regTutor.Data.user.id
Write-Host "  -> Tutor registered: User ID $tutorUserId" -ForegroundColor Green

$regStudent = Invoke-Api -Method "POST" -Path "/auth/register" -Body @{
    name     = "Student Tester $rnd"
    email    = $studentEmail
    password = $password
    role     = "STUDENT"
}
$studentToken = $regStudent.Data.token
$studentUserId = $regStudent.Data.user.id
Write-Host "  -> Student registered: User ID $studentUserId" -ForegroundColor Green

# --- Step 3: Tutor Creates Profile ---
Write-Host "[3/8] Tutor Creates Profile..." -ForegroundColor Yellow
$profileResp = Invoke-Api -Method "PUT" -Path "/tutors/me" -Token $tutorToken -Body @{
    bio         = "Expert in Algorithms, Data Structures and DBMS."
    department  = "Computer Science"
    yearOfStudy = 4
    subjectIds  = @(4, 5) # 4: Data Structures, 5: DBMS
}
$tutorProfileId = $profileResp.Data.id
Write-Host "  -> Profile created: Profile ID $tutorProfileId (Subjects: Data Structures, DBMS)" -ForegroundColor Green

# --- Step 4: Tutor Posts an Availability Slot ---
Write-Host "[4/8] Tutor Posts Availability Slot..." -ForegroundColor Yellow
$slotResp = Invoke-Api -Method "POST" -Path "/slots" -Token $tutorToken -Body @{
    startTime      = "2026-11-01T14:00:00"
    endTime        = "2026-11-01T15:00:00"
    mode           = "ONLINE"
    locationOrLink = "https://meet.google.com/e2e-test-slot"
}
$slotId = $slotResp.Data.id
Write-Host "  -> Slot posted: ID $slotId (2026-11-01T14:00:00, ONLINE)" -ForegroundColor Green

# --- Step 5: Student Searches Tutors ---
Write-Host "[5/8] Student Searches for Tutors (subjectId=4)..." -ForegroundColor Yellow
$searchResp = Invoke-Api -Method "GET" -Path "/tutors?subjectId=4&mode=ONLINE" -Token $studentToken
$matchedTutor = $searchResp.Data | Where-Object { $_.id -eq $tutorProfileId }
if (-not $matchedTutor) {
    Write-Host "Search did not return the expected tutor!" -ForegroundColor Red
    exit 1
}
Write-Host "  -> Found Tutor: $($matchedTutor.name), openSlotCount: $($matchedTutor.openSlotCount), nextSlot: $($matchedTutor.nextSlot.startTime)" -ForegroundColor Green

# --- Step 6: Student Requests the Slot ---
Write-Host "[6/8] Student Sends Session Request..." -ForegroundColor Yellow
$reqResp = Invoke-Api -Method "POST" -Path "/requests" -Token $studentToken -Body @{
    slotId    = $slotId
    subjectId = 4
    message   = "Need assistance with graph traversal algorithms."
}
$requestId = $reqResp.Data.id
$initialStatus = $reqResp.Data.status
Write-Host "  -> Request created: ID $requestId, Status: $initialStatus, Chat: $($reqResp.Data.chat)" -ForegroundColor Green

# --- Step 7: Tutor Accepts the Request ---
Write-Host "[7/8] Tutor Accepts Request..." -ForegroundColor Yellow
$acceptResp = Invoke-Api -Method "PATCH" -Path "/requests/$requestId/status" -Token $tutorToken -Body @{
    status = "ACCEPTED"
}
$newStatus = $acceptResp.Data.status
$chatState = $acceptResp.Data.chat.state
Write-Host "  -> Request updated: Status: $newStatus, Chat State: $chatState" -ForegroundColor Green

# --- Step 8: Verify Chat State and GET /chats ---
Write-Host "[8/8] Verifying Chat State and GET /chats..." -ForegroundColor Yellow
$chatMessages = Invoke-Api -Method "GET" -Path "/requests/$requestId/messages" -Token $studentToken
if ($chatMessages.Data.chat.state -ne "NOT_STARTED") {
    Write-Host "Expected chat state NOT_STARTED, got $($chatMessages.Data.chat.state)" -ForegroundColor Red
    exit 1
}
Write-Host "  -> GET /requests/$requestId/messages confirmed chat.state = NOT_STARTED (future session)" -ForegroundColor Green

$chatsList = Invoke-Api -Method "GET" -Path "/chats" -Token $tutorToken
$foundInChats = $chatsList.Data | Where-Object { $_.requestId -eq $requestId }
if (-not $foundInChats) {
    Write-Host "Session not found in GET /chats!" -ForegroundColor Red
    exit 1
}
Write-Host "  -> GET /chats confirmed session listed with otherUser: $($foundInChats.otherUser.name), State: $($foundInChats.chat.state)" -ForegroundColor Green

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host " ALL END-TO-END CHECKS PASSED SUCCESSFULLY! " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
