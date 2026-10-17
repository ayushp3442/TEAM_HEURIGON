#!/usr/bin/env bash
# ==============================================================================
# End-to-End Test Script (Bash / curl / jq) - Peer Tutoring Board
# Tests the full user journey using only the public REST API:
# 1. Register a Tutor and a Student (unique accounts per run)
# 2. Tutor creates profile (bio, department, subjects)
# 3. Tutor posts an availability slot
# 4. Student searches for tutors (verifies filters and open slots)
# 5. Student requests the slot
# 6. Tutor accepts the request
# 7. Check post-session chat state (NOT_STARTED for future session)
# ==============================================================================

set -euo pipefail

BASE_URL="http://localhost:8080/api"
TIMESTAMP=$(date +%s)
RND=$(( RANDOM % 9000 + 1000 ))
TUTOR_EMAIL="tutor_${TIMESTAMP}_${RND}@campus.edu"
STUDENT_EMAIL="student_${TIMESTAMP}_${RND}@campus.edu"
PASSWORD="password123"

echo "=========================================================="
echo " PEER TUTORING BOARD - END-TO-END VERIFICATION (BASH)"
echo "=========================================================="
echo "Tutor Email   : ${TUTOR_EMAIL}"
echo "Student Email : ${STUDENT_EMAIL}"
echo ""

# 1. Health check
echo "[1/8] Checking API Health..."
HEALTH=$(curl -s "${BASE_URL}/health")
if [[ "${HEALTH}" != *"UP"* ]]; then
  echo "Backend health check failed: ${HEALTH}"
  exit 1
fi
echo "  -> Health status: UP"

# 2. Register Tutor and Student
echo "[2/8] Registering Unique Accounts..."
TUTOR_REG=$(curl -s -X POST "${BASE_URL}/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Prof. Test Tutor ${RND}\",\"email\":\"${TUTOR_EMAIL}\",\"password\":\"${PASSWORD}\",\"role\":\"TUTOR\"}")
TUTOR_TOKEN=$(echo "${TUTOR_REG}" | grep -o '"token":"[^"]*' | cut -d'"' -f4)

STUDENT_REG=$(curl -s -X POST "${BASE_URL}/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Student Tester ${RND}\",\"email\":\"${STUDENT_EMAIL}\",\"password\":\"${PASSWORD}\",\"role\":\"STUDENT\"}")
STUDENT_TOKEN=$(echo "${STUDENT_REG}" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
echo "  -> Both accounts registered successfully."

# 3. Tutor creates profile
echo "[3/8] Tutor Creates Profile..."
PROFILE_RESP=$(curl -s -X PUT "${BASE_URL}/tutors/me" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TUTOR_TOKEN}" \
  -d '{"bio":"Expert in Algorithms, Data Structures and DBMS.","department":"Computer Science","yearOfStudy":4,"subjectIds":[4,5]}')
TUTOR_PROFILE_ID=$(echo "${PROFILE_RESP}" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "  -> Tutor Profile created: ID ${TUTOR_PROFILE_ID}"

# 4. Tutor posts availability slot
echo "[4/8] Tutor Posts Availability Slot..."
SLOT_RESP=$(curl -s -X POST "${BASE_URL}/slots" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TUTOR_TOKEN}" \
  -d '{"startTime":"2026-11-01T14:00:00","endTime":"2026-11-01T15:00:00","mode":"ONLINE","locationOrLink":"https://meet.google.com/e2e-test-slot"}')
SLOT_ID=$(echo "${SLOT_RESP}" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "  -> Slot created: ID ${SLOT_ID}"

# 5. Student searches tutors
echo "[5/8] Student Searches for Tutors..."
SEARCH_RESP=$(curl -s -X GET "${BASE_URL}/tutors?subjectId=4&mode=ONLINE" \
  -H "Authorization: Bearer ${STUDENT_TOKEN}")
if [[ "${SEARCH_RESP}" != *"${TUTOR_PROFILE_ID}"* ]]; then
  echo "Expected tutor profile not found in search results: ${SEARCH_RESP}"
  exit 1
fi
echo "  -> Matching tutor found in search results."

# 6. Student sends request
echo "[6/8] Student Sends Session Request..."
REQ_RESP=$(curl -s -X POST "${BASE_URL}/requests" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${STUDENT_TOKEN}" \
  -d "{\"slotId\":${SLOT_ID},\"subjectId\":4,\"message\":\"Need assistance with graph algorithms.\"}")
REQ_ID=$(echo "${REQ_RESP}" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "  -> Request created: ID ${REQ_ID}"

# 7. Tutor accepts request
echo "[7/8] Tutor Accepts Request..."
ACCEPT_RESP=$(curl -s -X PATCH "${BASE_URL}/requests/${REQ_ID}/status" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TUTOR_TOKEN}" \
  -d '{"status":"ACCEPTED"}')
if [[ "${ACCEPT_RESP}" != *"ACCEPTED"* ]]; then
  echo "Failed to accept request: ${ACCEPT_RESP}"
  exit 1
fi
echo "  -> Request ACCEPTED successfully."

# 8. Check chat state and GET /chats
echo "[8/8] Verifying Chat State..."
MSGS_RESP=$(curl -s -X GET "${BASE_URL}/requests/${REQ_ID}/messages" \
  -H "Authorization: Bearer ${STUDENT_TOKEN}")
if [[ "${MSGS_RESP}" != *"NOT_STARTED"* ]]; then
  echo "Expected NOT_STARTED chat state, got: ${MSGS_RESP}"
  exit 1
fi
echo "  -> Chat state verified: NOT_STARTED"

CHATS_RESP=$(curl -s -X GET "${BASE_URL}/chats" \
  -H "Authorization: Bearer ${TUTOR_TOKEN}")
if [[ "${CHATS_RESP}" != *"${REQ_ID}"* ]]; then
  echo "Request not listed in GET /chats: ${CHATS_RESP}"
  exit 1
fi
echo "  -> Session confirmed in GET /chats"

echo ""
echo "=========================================================="
echo " ALL END-TO-END CHECKS PASSED SUCCESSFULLY! "
echo "=========================================================="
