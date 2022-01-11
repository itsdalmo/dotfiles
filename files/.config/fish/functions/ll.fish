# ll with exa (instead of ls)
function ll
    exa -la --icons --group-directories-first $argv
end
