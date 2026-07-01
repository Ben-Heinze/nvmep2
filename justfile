
default:
  cmake -S ./playground/cpp/ -B build/ && cmake --build build/ && ./build/hello

check:
  nix flake check -L

fmt:
  nix fmt


jq:
  nix develop . --command bash -c "find ./build -name 'compile_commands.json' -exec cat {} + | jq -s add > compile_commands.json"

run:
  nix run .

fmt:
  nix develop . --command stylua nvim

lint:
  nix develop . --command luacheck nvim

test:
  nix flake check -L
