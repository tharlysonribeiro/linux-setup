## How to Run with Docker Compose

Make sure you have Docker and Docker Compose installed. Then, follow the steps below to start the project:

```bash
git clone https://github.com/your-user/your-repo.git
cd your-repo
cp .env.example .env     # optional, if the project uses environment variables
docker compose up -d     # starts containers in detached mode
docker compose ps        # check running containers
docker compose logs -f   # view logs
docker compose down      # stop the containers
docker compose down -v   # stop and remove volumes
docker compose up -d --build   # rebuild the containers
docker exec -it <container-name> bash   # access a container's shell
