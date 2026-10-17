#!/usr/bin/env bash
set -euo pipefail

BASE_URL="http://localhost:8080/api"

echo "=========================================================="
echo " REAL CHAT E2E VERIFICATION (WITH REAL CLOCK)"
echo "=========================================================="

SUFFIX=$(date +%s%N 2>/dev/null || date +%s)
TUTOR_EMAIL="tutor_chat_${SUFFIX}@campus.edu"
STUDENT1_EMAIL="student1_chat_${SUFFIX}@campus.edu"
STUDENT2_EMAIL="student2_chat_${SUFFIX}@campus.edu"

# 1. Check API Health and server time
HEALTH_JSON=$(curl -s "${BASE_URL}/health")
SERVER_TIME=$(echo "${HEALTH_JSON}" | grep -o '"serverTime":"[^"]*' | cut -d'"' -f4)
TIME_ZONE=$(echo "${HEALTH_JSON}" | grep -o '"timeZone":"[^"]*' | cut -d'"' -f4)
echo "[1/7] Campus Server Time: ${SERVER_TIME} (${TIME_ZONE})"

# 2. Register Tutor, Student 1, Student 2
TUTOR_REG=$(curl -s -X POST "${BASE_URL}/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Tutor Chat Tester\",\"email\":\"${TUTOR_EMAIL}\",\"password\":\"password123\",\"role\":\"TUTOR\"}")
TUTOR_TOKEN=$(echo "${TUTOR_REG}" | grep -o '"token":"[^"]*' | cut -d'"' -f4)

S1_REG=$(curl -s -X POST "${BASE_URL}/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Student One\",\"email\":\"${STUDENT1_EMAIL}\",\"password\":\"password123\",\"role\":\"STUDENT\"}")
S1_TOKEN=$(echo "${S1_REG}" | grep -o '"token":"[^"]*' | cut -d'"' -f4)

S2_REG=$(curl -s -X POST "${BASE_URL}/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Student Two (Third Party)\",\"email\":\"${STUDENT2_EMAIL}\",\"password\":\"password123\",\"role\":\"STUDENT\"}")
S2_TOKEN=$(echo "${S2_REG}" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
echo "[2/7] Registered Tutor, Student 1, and Student 2"

# 3. Create Tutor Profile with Subject 1
curl -s -X PUT "${BASE_URL}/tutors/me" \
  -H "Authorization: Bearer ${TUTOR_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"bio":"Real chat test tutor","department":"CSE","yearOfStudy":4,"subjectIds":[1]}' > /dev/null
echo "[3/7] Tutor profile created"

# 4. Calculate slot times (Slot 1 starts in 2 min, ends in 7 min)
# Parse server time using python3 or date
SLOT1_TIMES=$(python3 -c "
from datetime import datetime, timedelta
now = datetime.fromisoformat('${SERVER_TIME}')
s1_start = now + timedelta(minutes=2, seconds=10)
s1_end = s1_start + timedelta(minutes=5)
s2_start = now + timedelta(minutes=60)
s2_end = now + timedelta(minutes=90)
print(f'{s1_start.strftime(\"%Y-%m-%dT%H:%M:%S\")},{s1_end.strftime(\"%Y-%m-%dT%H:%M:%S\")},{s2_start.strftime(\"%Y-%m-%dT%H:%M:%S\")},{s2_end.strftime(\"%Y-%m-%dT%H:%M:%S\")}')
")

IFS=',' read -r S1_START S1_END S2_START S2_END <<< "${SLOT1_TIMES}"

SLOT1_RESP=$(curl -s -X POST "${BASE_URL}/slots" \
  -H "Authorization: Bearer ${TUTOR_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"startTime\":\"${S1_START}\",\"endTime\":\"${S1_END}\",\"mode\":\"ONLINE\",\"locationOrLink\":\"https://meet.google.com/slot1\"}")
SLOT1_ID=$(echo "${SLOT1_RESP}" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

SLOT2_RESP=$(curl -s -X POST "${BASE_URL}/slots" \
  -H "Authorization: Bearer ${TUTOR_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"startTime\":\"${S2_START}\",\"endTime\":\"${S2_END}\",\"mode\":\"ONLINE\",\"locationOrLink\":\"https://meet.google.com/slot2\"}")
SLOT2_ID=$(echo "${SLOT2_RESP}" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "[4/7] Created Slot 1 (ID: ${SLOT1_ID}, ends: ${S1_END}) and Slot 2 (ID: ${SLOT2_ID})"

# 5. Request & Accept both sessions
REQ1_RESP=$(curl -s -X POST "${BASE_URL}/requests" \
  -H "Authorization: Bearer ${S1_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"slotId\":${SLOT1_ID},\"subjectId\":1,\"message\":\"Request 1\"}")
REQ1_ID=$(echo "${REQ1_RESP}" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

curl -s -X PATCH "${BASE_URL}/requests/${REQ1_ID}/status" \
  -H "Authorization: Bearer ${TUTOR_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"status":"ACCEPTED"}' > /dev/null

REQ2_RESP=$(curl -s -X POST "${BASE_URL}/requests" \
  -H "Authorization: Bearer ${S1_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"slotId\":${SLOT2_ID},\"subjectId\":1,\"message\":\"Request 2\"}")
REQ2_ID=$(echo "${REQ2_RESP}" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

curl -s -X PATCH "${BASE_URL}/requests/${REQ2_ID}/status" \
  -H "Authorization: Bearer ${TUTOR_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"status":"ACCEPTED"}' > /dev/null
echo "[5/7] Accepted Request 1 and Request 2"

# 6. Poll GET /api/chats until OPEN
echo "[6/7] Polling GET /api/chats every 20s until Session 1 ends (expected ~7 min)..."
START_TS=$(date +%s)
IS_OPEN=0

while [ $(($(date +%s) - START_TS)) -lt 600 ]; do
  sleep 20
  CHATS_RESP=$(curl -s "${BASE_URL}/chats" -H "Authorization: Bearer ${S1_TOKEN}")
  STATE=$(echo "${CHATS_RESP}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for c in data:
    if c['requestId'] == ${REQ1_ID}:
        print(c['chat']['state'])
        break
" 2>/dev/null || echo "UNKNOWN")
  ELAPSED=$(($(date +%s) - START_TS))
  echo "  [Elapsed ${ELAPSED}s] Chat 1 state: ${STATE}"
  if [ "${STATE}" = "OPEN" ]; then
    IS_OPEN=1
    break
  fi
done

if [ "${IS_OPEN}" -ne 1 ]; then
  echo "ERROR: Timeout waiting for chat to become OPEN"
  exit 1
fi

# 7. Verification Actions
echo "[7/7] Verifying chat sorting and message exchanges..."
# Order check: OPEN before NOT_STARTED
ORDER_CHECK=$(curl -s "${BASE_URL}/chats" -H "Authorization: Bearer ${S1_TOKEN}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
states = [c['chat']['state'] for c in data]
if len(states) >= 2 and states[0] == 'OPEN' and states[1] == 'NOT_STARTED':
    print('PASS')
else:
    print(f'FAIL: {states}')
")
if [ "${ORDER_CHECK}" != "PASS" ]; then
  echo "ERROR: Ordering failed: ${ORDER_CHECK}"
  exit 1
fi
echo "  -> Sorting confirmed: OPEN is sorted before NOT_STARTED"

# Student sends message
MSG1=$(curl -s -X POST "${BASE_URL}/requests/${REQ1_ID}/messages" \
  -H "Authorization: Bearer ${S1_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"content":"Hello tutor!"}')
MSG1_ID=$(echo "${MSG1}" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

# Tutor replies
MSG2=$(curl -s -X POST "${BASE_URL}/requests/${REQ1_ID}/messages" \
  -H "Authorization: Bearer ${TUTOR_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"content":"You are welcome!"}')
MSG2_ID=$(echo "${MSG2}" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

# Verify ?afterId=0
COUNT0=$(curl -s "${BASE_URL}/requests/${REQ1_ID}/messages?afterId=0" -H "Authorization: Bearer ${S1_TOKEN}" | python3 -c "import sys, json; print(len(json.load(sys.stdin)['messages']))")
if [ "${COUNT0}" -ne 2 ]; then
  echo "ERROR: Expected 2 messages with afterId=0, got ${COUNT0}"
  exit 1
fi

# Verify ?afterId=<first id>
COUNT1=$(curl -s "${BASE_URL}/requests/${REQ1_ID}/messages?afterId=${MSG1_ID}" -H "Authorization: Bearer ${S1_TOKEN}" | python3 -c "import sys, json; print(len(json.load(sys.stdin)['messages']))")
if [ "${COUNT1}" -ne 1 ]; then
  echo "ERROR: Expected 1 message with afterId=${MSG1_ID}, got ${COUNT1}"
  exit 1
fi

# Verify 403 for non-participant
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${BASE_URL}/requests/${REQ1_ID}/messages" -H "Authorization: Bearer ${S2_TOKEN}")
if [ "${HTTP_CODE}" -ne 403 ]; then
  echo "ERROR: Expected 403 for third user, got ${HTTP_CODE}"
  exit 1
fi

echo "=========================================================="
echo " ALL REAL-TIME CHAT E2E CHECKS PASSED SUCCESSFULLY!"
echo "=========================================================="
