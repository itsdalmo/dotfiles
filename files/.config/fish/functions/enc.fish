# base64 enc(ode)
function enc
    printf "%s" $argv | base64 -w 0
end
