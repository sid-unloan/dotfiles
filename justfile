# Personal `just` recipes — invoked from dotfiles repo or anywhere on PATH
#
# Usage:
#   just              # list all recipes
#   just dozzle       # start dozzle in the background, print URL
#   just dozzle-stop  # stop dozzle
#   just dozzle-logs  # tail dozzle's own logs

set shell := ["bash", "-cu"]

dotfiles_dir := justfile_directory()
dozzle_compose := dotfiles_dir + "/dozzle/docker-compose.yml"
dozzle_url := "http://localhost:8888"

# Default — list recipes
default:
    @just --list

# Start Dozzle (Docker log viewer) in the background
dozzle:
    @docker compose -f {{dozzle_compose}} up -d
    @echo ""
    @echo "  Dozzle is running at {{dozzle_url}}"
    @echo "  Stop with: just dozzle-stop"

# Stop Dozzle
dozzle-stop:
    @docker compose -f {{dozzle_compose}} down

# Tail Dozzle container logs (for debugging Dozzle itself)
dozzle-logs:
    @docker compose -f {{dozzle_compose}} logs -f
