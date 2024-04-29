# Sync flake.lock with what is currently being used by my dotfiles
function nix-flake-sync
    set -l source_inputs (list-inputs (nix flake metadata --refresh --json "github:itsdalmo/dotfiles"))
    set -l target_inputs (list-inputs (nix flake metadata --json .))

    for input in (echo $target_inputs | jq -r 'keys[]')
        if test (echo $source_inputs | jq "has(\"$input\")") = false
            echo "$input is not present in dotfiles (skipping)"
            continue
        end

        set -l source_url (echo $source_inputs | jq -r --arg input $input '.[$input].url')
        set -l source_ref (echo $source_inputs | jq -r --arg input $input '.[$input].ref')
        set -l target_url (echo $target_inputs | jq -r --arg input $input '.[$input].url')
        set -l target_ref (echo $target_inputs | jq -r --arg input $input '.[$input].ref')
        if test "$target_url/$target_ref" != "$source_url/$source_ref"
            echo "$input is not tracking the same upstream as dotfiles: $target_url/$target_ref != $source_url/$source_ref (skipping)"
            continue
        end

        set -l source_rev (echo $source_inputs | jq -r --arg input $input '.[$input].rev')
        set -l target_rev (echo $target_inputs | jq -r --arg input $input '.[$input].rev')
        if test "$source_rev" = "$target_rev"
            echo "$input is already in sync (rev: $target_rev)"
            continue
        end

        echo "Updating nixpkgs revision: $target_rev => $source_rev"
        nix flake update --refresh --override-input "$input" "$source_url/$source_rev"
    end
end

function list-inputs --argument metadata
    echo $metadata | jq -r \
        '.locks.nodes | to_entries | map(select(.key != "root")) | map({
          (.key): {
            url: (.value.original.type + ":" + .value.original.owner + "/" + .value.original.repo),
            ref: (.value.original.ref // "default"),
            rev: .value.locked.rev,
          }
        }) | add'
end
