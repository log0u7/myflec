# ~/.bash/docker.bash
# export Docker & Docker compose env
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Sherlock
alias sherloc="docker run --rm -it sherlock/sherlock"

# Dive is a docker layer analysing tool.
alias dive="docker run -ti --rm -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive"

# Lazydocker
alias lazydocker="docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v /yourpath:/.config/jesseduffield/lazydocker lazyteam/lazydocker"

# Docker and Docker Compose aliases

# Docker basics
alias d='docker'                              # Short alias for docker
alias dps='docker ps'                         # Show running containers
alias dpsa='docker ps -a'                     # Show all containers
alias di='docker images'                      # List all images
alias dvol='docker volume ls'                 # List all volumes
alias dnet='docker network ls'                # List all networks
alias dlogs='docker logs -f'                  # Follow logs of a container
alias dlogsl='docker logs --tail 100 -f'      # Show last 100 lines of logs
alias dsh='docker exec -it'                   # Attach shell to a running container
alias dstop='docker stop'                     # Stop a running container
alias drm='docker rm'                         # Remove a container
alias drmi='docker rmi'                       # Remove an image
alias dstart='docker start'                   # Start a stopped container
alias drestart='docker restart'               # Restart a container
alias dprune='docker system prune -f'         # Clean up unused containers, images, networks, volumes

# Docker build and run
alias dbuild='docker build .'                 # Build an image from Dockerfile
alias dbuildt='docker build -t'               # Build and tag an image
alias drun='docker run -it --rm'              # Run a container interactively and remove it on exit
alias drund='docker run -d'                   # Run a container in detached mode
alias drunit='docker run -it'                 # Run a container interactively

# Docker Compose
alias dc='docker compose'                     # Short alias for docker compose
alias dcu='docker compose up -d'              # Start services in detached mode
alias dcd='docker compose down'               # Stop and remove containers
alias dcrestart='docker compose restart'      # Restart all services
alias dclogs='docker compose logs -f'         # Follow logs of all services
alias dcps='docker compose ps'                # Show running services
alias dcbuild='docker compose build'          # Build images for services
alias dcstop='docker compose stop'            # Stop services
alias dcrm='docker compose rm'                # Remove stopped services
alias dcrestart='docker compose restart'      # Restart services

# Miscellaneous
alias dinspect='docker inspect'               # Inspect a container or image
alias dip='docker inspect -f "{{ .NetworkSettings.IPAddress }}"' # Get container IP
alias dport='docker port'                     # Show port mappings
alias dtop='docker top'                       # Show running processes inside a container
