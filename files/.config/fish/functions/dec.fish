# base64 dec(ode)
function dec
    printf "%s" $argv | base64 -d
end
