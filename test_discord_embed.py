#!/usr/bin/env python3
"""
Test script to send a Discord embed
"""

import urllib.request
import urllib.parse
import json
import time
from datetime import datetime

def send_discord_embed():
    """Send a test Discord embed"""
    
    discord_webhook_url = "https://discord.com/api/webhooks/1436816359907393761/8gxTJs0lWY_S8Rh4n5kO072sqwFM8h35bBbWBdDa9iELI-A25wgd-pc0OZ3RWTWkGfZC"
    
    # Format date like Swift DateFormatter (short date, short time)
    date_str = datetime.now().strftime('%m/%d/%y, %I:%M %p')
    
    embed = {
        "title": "📱 Test Discord Embed",
        "description": "This is a test embed to verify Discord webhook integration.",
        "color": 0x5865F2,
        "footer": {
            "text": f"Sent on {date_str}"
        },
        "author": {
            "name": "Zentra App",
            "icon_url": "https://i.imgur.com/zPyOczX.png"
        },
        "fields": [
            {
                "name": "Test Field",
                "value": "This is a test message from the server",
                "inline": False
            },
            {
                "name": "Status",
                "value": "✅ Working",
                "inline": True
            }
        ]
    }
    
    payload = {
        "content": None,
        "embeds": [embed]
    }
    
    try:
        print(f"[TEST] Sending test embed to Discord...")
        print(f"[TEST] Time: {date_str}")
        
        req = urllib.request.Request(
            discord_webhook_url,
            data=json.dumps(payload).encode('utf-8'),
            headers={
                'Content-Type': 'application/json',
                'User-Agent': 'Zentra-Server/1.0'
            }
        )
        
        with urllib.request.urlopen(req, timeout=10) as response:
            response_data = response.read()
            if response.status == 200 or response.status == 204:
                print(f"[TEST] ✅ Successfully sent to Discord!")
                return True
            else:
                response_body = response_data.decode('utf-8') if response_data else "No response"
                print(f"[TEST] ⚠️ Discord returned status {response.status}: {response_body}")
                return False
    except urllib.error.HTTPError as e:
        try:
            error_body = e.read().decode('utf-8') if hasattr(e, 'read') else str(e)
        except:
            error_body = str(e)
        print(f"[TEST] ❌ Discord HTTP Error {e.code}: {error_body}")
        return False
    except Exception as e:
        print(f"[TEST] ❌ Failed to send: {str(e)}")
        return False

if __name__ == '__main__':
    print("=" * 60)
    print("Discord Embed Test")
    print("=" * 60)
    send_discord_embed()
    print("=" * 60)

