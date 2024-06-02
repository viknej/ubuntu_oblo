#!/bin/bash

PARENT=""
DOSM=""
if [[ "$PLATFORM_NAME" == "doc400" ]]; then
    PARENT=""
    DOSM="dosm"
elif [[ "$PLATFORM_NAME" == "shh600" ]]; then
    PARENT="/userdata"
    DOSM="S99dosm"
fi

colored_log() {
    local oblo_app=$1
    local log_view=${2:-cat}
    local log_file

    case $oblo_app in
        ohm)
            log_file="$PARENT/mnt/log/oblomanager.log"
            ;;
        osm)
            log_file="$PARENT/mnt/log/osm.log"
            ;;
        omb)
            log_file="$PARENT/mnt/log/oblomb.log"
            ;;
        ogb)
            log_file="$PARENT/mnt/log/ogb.log"
            ;;
        *)
            echo "Unknown application: $oblo_app"
            return 1
            ;;
    esac

    if [[ "$log_view" == "tail" ]]; then
        log_view="tail -f -n200"
    fi

    eval "$log_view $log_file" | awk '
    function format_json(json_string) {
        local formatted_json, i, len, c, current_indent
        len = length(json_string)
        formatted_json = ""
        indent = 0
        additional_indent = 35
        closing_brace_indent = 2
        for (i = 1; i <= len; i++) {
            c = substr(json_string, i, 1)
            if (c == "{" || c == "[") {
                indent++
                formatted_json = formatted_json c "\n" sprintf("%" (indent * 4 + additional_indent) "s", "")
            } else if (c == "}" || c == "]") {
                indent--
                formatted_json = formatted_json "\n" sprintf("%" (indent * 4 + additional_indent + closing_brace_indent) "s", "") c
            } else if (c == ",") {
                formatted_json = formatted_json c "\n" sprintf("%" (indent * 4 + additional_indent) "s", "")
            } else {
                formatted_json = formatted_json c
            }
        }
        return formatted_json
    }

    # date time [app] [serial] level [class] thread:  message
    # time class thread message

    # $0      = 2024-05-21 15:38:14,622 [ohm] [C83DD40F0EC1] I [Onvif] 18: Synchronization thread activated
    # time    = 15:38:14,622
    # rest    = [Onvif] 18: Synchronization thread activated
    # part[1] = [Onvif] 18
    # class   = [Onvif]
    # thread  = 18
    # message = Synchronization thread activated

    {
        time = substr($0, 12, 12);
        rest = substr($0, 47);
        split(rest, parts, ":");

        # See color codes at https://michurin.github.io/xterm256-color-picker/
        time_c = "\033[94m";
        class_c = "\033[38;5;106;48;5;16m";
        thread_c = "\033[95m";
        error_c = "\033[38;5;161;48;5;16m";
        warning_c = "\033[38;5;142;48;5;16m";
        trace_c = "\033[38;5;172;48;5;16m";
        info_c = "\033[38;5;251;48;5;16m";
        message_c = info_c;

        if (length(parts) >= 2) {
            class_and_thread = parts[1];
            split(class_and_thread, elements, "]");
            class = substr(elements[1], 3);
            thread = substr(class_and_thread, length(class) + 4);
            message = substr(rest, length(class_and_thread) + 2);
            class_f = sprintf("%20s", class);
            thread_f = sprintf("%4s", thread);

            if ($0 ~ / E /) {
                message_c = error_c;
            } else if ($0 ~ / W /) {
                message_c = warning_c;
            } else if ($0 ~ / T /) {
                message_c = trace_c;
            }

            # Start DETECTED JSON FORMATTING

            match(message, /(\{.*\})/)

            if (RSTART != 0) {
                json_str = substr(message, RSTART, RLENGTH)
                before_json = substr(message, 1, RSTART-1)
                after_json = substr(message, RSTART+RLENGTH)
                message = before_json format_json(json_str) after_json
            }

            # End DETECTED JSON FORMATTING

            print time_c time class_c class_f thread_c thread_f message_c message info_c;
        } else {
            print $0;
        }
    }'
}

alias ohmtail='colored_log ohm tail'
alias osmtail='colored_log osm tail'
alias ombtail='colored_log omb tail'
alias ogbtail='colored_log ogb tail'
alias ohmcat='colored_log ohm'
alias osmcat='colored_log osm'
alias ombcat='colored_log omb'
alias ogbcat='colored_log ogb'
alias logs='cd $PARENT/mnt/log && ls'
alias creds='updmngr -n get; updmngr -s get'
alias versionini='vi /etc/version.ini'
alias ohmprop='vi $PARENT/usr/data/ohm/cfg/ohm.properties'
alias osmprop='vi $PARENT/usr/data/osm/cfg/osm.properties'
alias ombprop='vi $PARENT/usr/data/omb/cfg/oblomb.properties'
alias ogbprop='vi $PARENT/usr/data/ogb/cfg/ogb.properties'
alias pids='echo " " &&
            echo " ohm $(pidof oblomanager)" &&
            echo " osm $(pidof systemManager)" &&
            echo " omb $(pidof oblomb)" &&
            echo " ogb $(pidof gatewayBridge)" &&
            echo " "'
alias dosmstop='/etc/init.d/$DOSM stop'
alias dosmstart='/etc/init.d/$DOSM start'
alias killapps='killall -9 oblomb oblomanager gatewayBridge'
alias deldbs='rm -rf $PARENT/mnt/data/*/*'
alias ll='ls -la'
alias cls='clear'
alias q='exit'
alias al='clear &&
          echo " ----------------------------------------------" &&
          echo "              ALIASES" &&
          echo " ----------------------------------------------" &&
          echo " ohmtail    = tail ohm log" &&
          echo " osmtail    = tail osm log" &&
          echo " ombtail    = tail omb log" &&
          echo " ogbtail    = tail ogb log" &&
          echo " " &&
          echo " ohmcat     = cat ohm log" &&
          echo " osmcat     = cat osm log" &&
          echo " ombcat     = cat omb log" &&
          echo " ogbcat     = cat ogb log" &&
          echo " " &&
          echo " ohmprop    = edit ohm.properties" &&
          echo " osmprop    = edit osm.properties" &&
          echo " ombprop    = edit oblomb.properties" &&
          echo " ogbprop    = edit ogb.properties" &&
          echo " " &&
          echo " creds      = print GW serial and security code" &&
          echo " logs       = navigate to logs folder" &&
          echo " pids       = PIDs of ohm, osm, omb, ogb" &&
          echo " versionini = edit version.ini" &&
          echo " " &&
          echo " deldbs     = delete all databases" &&
          echo " dosmstart  = start dosm" &&
          echo " dosmstop   = stop dosm" &&
          echo " killapps   = kill omb, ohm, ogb" &&
          echo " " &&
          echo " al         = list all aliases" &&
          echo " cls        = clear screen" &&
          echo " ll         = ls -la (detailed folder content)" &&
          echo " q          = exit telnet" &&
          echo " ----------------------------------------------"'
