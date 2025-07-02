#!/bin/bash

# ServiceNow Connection Test Script
# This script helps debug connection issues with ServiceNow

set -e

echo "=== ServiceNow Connection Test ==="
echo ""

# Check environment variables
echo "1. Checking environment variables..."
if [ -z "$SNOW_INSTANCE" ]; then
    echo "   ❌ SNOW_INSTANCE is not set"
else
    echo "   ✅ SNOW_INSTANCE: $SNOW_INSTANCE"
fi

if [ -z "$SNOW_USERNAME" ]; then
    echo "   ❌ SNOW_USERNAME is not set"
else
    echo "   ✅ SNOW_USERNAME: $SNOW_USERNAME"
fi

if [ -z "$SNOW_PASSWORD" ]; then
    echo "   ❌ SNOW_PASSWORD is not set"
else
    echo "   ✅ SNOW_PASSWORD: [HIDDEN]"
fi

echo ""

# Check dependencies
echo "2. Checking dependencies..."
if command -v curl &> /dev/null; then
    echo "   ✅ curl is installed"
else
    echo "   ❌ curl is not installed"
    exit 1
fi

if command -v jq &> /dev/null; then
    echo "   ✅ jq is installed"
else
    echo "   ❌ jq is not installed"
    exit 1
fi

echo ""

# Test basic connectivity
echo "3. Testing basic connectivity..."
INSTANCE="$SNOW_INSTANCE"
if [ -n "$INSTANCE" ]; then
    echo "   Testing connection to https://$INSTANCE.service-now.com"
    
    # Test basic HTTP connectivity
    echo "   Testing connection to https://$INSTANCE.service-now.com"
    if curl -s --connect-timeout 30 --max-time 60 -k -I "https://$INSTANCE.service-now.com" >/dev/null 2>&1; then
        echo "   ✅ Basic connectivity successful"
    else
        echo "   ❌ Basic connectivity failed"
        echo "   This could mean:"
        echo "   - Instance name is incorrect"
        echo "   - Network connectivity issues"
        echo "   - ServiceNow instance is down"
        exit 1
    fi
else
    echo "   ⚠️  Skipping connectivity test (no instance set)"
fi

echo ""

# Test API access
echo "4. Testing API access..."
if [ -n "$SNOW_INSTANCE" ] && [ -n "$SNOW_USERNAME" ] && [ -n "$SNOW_PASSWORD" ]; then
    echo "   Testing API endpoint..."
    
    API_URL="https://$INSTANCE.service-now.com/api/now/table/change_request?sysparm_limit=1"
    
    RESPONSE=$(curl -s -w "\n%{http_code}" \
        --connect-timeout 30 \
        --max-time 60 \
        -u "$SNOW_USERNAME:$SNOW_PASSWORD" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -k \
        "$API_URL")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    RESPONSE_BODY=$(echo "$RESPONSE" | head -n -1)
    
    echo "   HTTP Status Code: $HTTP_CODE"
    
    case $HTTP_CODE in
        200)
            echo "   ✅ API access successful"
            echo "   Response preview:"
            echo "$RESPONSE_BODY" | jq '.' | head -10
            ;;
        401)
            echo "   ❌ Authentication failed"
            echo "   Please check your username and password"
            ;;
        403)
            echo "   ❌ Access forbidden"
            echo "   Please check your permissions"
            ;;
        404)
            echo "   ❌ API endpoint not found"
            echo "   Please check your instance name"
            ;;
        *)
            echo "   ❌ Unexpected response: $HTTP_CODE"
            echo "   Response: $RESPONSE_BODY"
            ;;
    esac
else
    echo "   ⚠️  Skipping API test (missing credentials)"
fi

echo ""
echo "=== Test Complete ===" 