#!/bin/bash
# Smart fullscreen script for AeroSpace
# Auto-fullscreen when single window, exit fullscreen when multiple windows

# Count windows on the focused workspace
WINDOW_COUNT=$(aerospace list-windows --workspace focused 2>/dev/null | wc -l | tr -d ' ')

# Get current fullscreen state
IS_FULLSCREEN=$(aerospace list-windows --focused --format '%{window-is-fullscreen}' 2>/dev/null)

if [ "$WINDOW_COUNT" -eq 1 ]; then
    # Single window - fullscreen it if not already
    if [ "$IS_FULLSCREEN" != "true" ]; then
        aerospace fullscreen on --no-outer-gaps 2>/dev/null
    fi
elif [ "$WINDOW_COUNT" -gt 1 ]; then
    # Multiple windows - exit fullscreen if active
    if [ "$IS_FULLSCREEN" = "true" ]; then
        aerospace fullscreen off 2>/dev/null
    fi
fi
