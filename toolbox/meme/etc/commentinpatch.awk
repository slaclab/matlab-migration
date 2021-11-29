$1~/^!/ && $0~"CALL" && $0~patchfilename {
    sub(/^!/,"",$0);
}
{ print $0 }
