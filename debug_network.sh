#!/bin/bash

# Network Diagnostic Script for ServiceNow
# This script helps identify network connectivity issues

set -e

echo "=== Network Diagnostic for ServiceNow ==="
echo ""

# Check if environment variables are set
if [ -z "$SNOW_INSTANCE" ]; then
    echo "❌ SNOW_INSTANCE is not set"
    echo "Please set it first: export SNOW_INSTANCE=your-instance"
    exit 1
fi

INSTANCE="$SNOW_INSTANCE"
echo "Testing connectivity to: $INSTANCE.service-now.com"
echo ""

# Test 1: DNS Resolution
echo "1. Testing DNS resolution..."
if nslookup "$INSTANCE.service-now.com" >/dev/null 2>&1; then
    echo "   ✅ DNS resolution successful"
else
    echo "   ❌ DNS resolution failed"
    echo "   This could mean:"
    echo "   - Instance name is incorrect"
    echo "   - DNS server issues"
    echo "   - Network connectivity problems"
fi

echo ""

# Test 2: Ping test
echo "2. Testing ping connectivity..."
if ping -c 3 "$INSTANCE.service-now.com" >/dev/null 2>&1; then
    echo "   ✅ Ping successful"
else
    echo "   ⚠️  Ping failed (this might be normal if ICMP is blocked)"
fi

echo ""

# Test 3: Port connectivity
echo "3. Testing port 443 connectivity..."
if nc -z -w 10 "$INSTANCE.service-now.com" 443 2>/dev/null; then
    echo "   ✅ Port 443 is reachable"
else
    echo "   ❌ Port 443 is not reachable"
    echo "   This could mean:"
    echo "   - Firewall blocking HTTPS traffic"
    echo "   - ServiceNow instance is down"
    echo "   - Network connectivity issues"
fi

echo ""

# Test 4: HTTP response headers
echo "4. Testing HTTP response headers..."
echo "   Making request to https://$INSTANCE.service-now.com"
HTTP_RESPONSE=$(curl -s -I --connect-timeout 30 --max-time 60 -k "https://$INSTANCE.service-now.com" 2>&1)
CURL_EXIT_CODE=$?

if [ $CURL_EXIT_CODE -eq 0 ]; then
    echo "   ✅ HTTP request successful"
    echo "   Response headers:"
    echo "$HTTP_RESPONSE" | head -10
else
    echo "   ❌ HTTP request failed with exit code: $CURL_EXIT_CODE"
    echo "   Response: $HTTP_RESPONSE"
fi

echo ""

# Test 5: API endpoint test
echo "5. Testing API endpoint..."
API_URL="https://$INSTANCE.service-now.com/api/now/table/change_request?sysparm_limit=1"
echo "   Testing: $API_URL"

if [ -n "$SNOW_USERNAME" ] && [ -n "$SNOW_PASSWORD" ]; then
    API_RESPONSE=$(curl -s -w "\n%{http_code}" \
        --connect-timeout 30 \
        --max-time 60 \
        -u "$SNOW_USERNAME:$SNOW_PASSWORD" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -k \
        "$API_URL" 2>&1)
    API_CURL_EXIT_CODE=$?
    
    if [ $API_CURL_EXIT_CODE -eq 0 ]; then
        HTTP_CODE=$(echo "$API_RESPONSE" | tail -n1)
        RESPONSE_BODY=$(echo "$API_RESPONSE" | head -n -1)
        echo "   ✅ API request completed"
        echo "   HTTP Status: $HTTP_CODE"
        echo "   Response preview:"
        echo "$RESPONSE_BODY" | head -5
    else
        echo "   ❌ API request failed with exit code: $API_CURL_EXIT_CODE"
        echo "   Response: $API_RESPONSE"
    fi
else
    echo "   ⚠️  Skipping API test (credentials not set)"
fi

echo ""
echo "=== Diagnostic Complete ==="
echo ""
echo "If you're still having issues, check:"
echo "1. Your instance name is correct"
echo "2. Your network allows HTTPS traffic to ServiceNow"
echo "3. Your credentials are correct"
echo "4. Your account has API access permissions" 