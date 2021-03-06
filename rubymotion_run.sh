#!/bin/sh

TERMINAL_ID="RubyMotionBuilder"
TERMINAL_APP="$1"
ACTIVATE_TERMINAL="$2"
PROJECT_DIR="$3"
OPTIONS="$4"

if [ "${PROJECT_DIR}" = "" ]; then
    exit 1
fi

if [ "${OPTIONS}" = "" ]; then
    RAKE="rake"
else
    RAKE="rake ${OPTIONS}"
fi

if [ "${TERMINAL_APP}" = "iTerm" ]; then
    osascript<<END
        tell application "iTerm"
            if "${ACTIVATE_TERMINAL}" is "true" then activate
            set current_session to (the first session of the current terminal)
            select current_session

            tell current_session
                if (name is "ruby" or name is "rake" or name is "sim") then 
                    write text "exit"
                end if

                write text "cd ${PROJECT_DIR}"
                write text "${RAKE}"
            end tell
        end tell
END
else
    osascript<<END
        try
            tell application "Terminal"
                if "${ACTIVATE_TERMINAL}" is "true" then activate
                try
                    set buildWindow to item 1 of (every window whose custom title is "${TERMINAL_ID}")
                    set index of buildWindow to 1
                    do script "quit" in buildWindow
                    do script "cd \"${PROJECT_DIR}\"" in buildWindow
                on error
                    do script "alias quit='' && cd \"${PROJECT_DIR}\" && clear"
                    tell window 1
                        set custom title to "${TERMINAL_ID}"
                    end tell
                end try
            delay 0.1
            do script "${RAKE}" in front window
            end tell
        end try
END
fi
