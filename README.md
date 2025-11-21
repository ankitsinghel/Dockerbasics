# DockerBasics

This is a minimal Node.js project packaged into a Docker image for demonstration and learning purposes.

**What this repo contains:**

- `dockerfile`: The Docker image instructions used to build this project's container image.
- `index.js`: The Node.js entrypoint for the application (simple server or script).
- `package.json`: Node package metadata and dependencies.

**Quick usage (Windows PowerShell)**

Run these commands to build and run the image exactly as requested:

```powershell
docker build -t ankitsinghel/dockerbasics (username/image) it makes the image unique
docker push nkitsinghel/dockerbasics (to push the image to docker hub)
docker run -it -p 1200:1200 ankitsinghel/dockerbasics
```

Note: The `docker build` command above is shown as you requested. Docker normally expects a build context (for example `.` for the current directory). The common working command is:

```powershell
docker build -t ankitsinghel/dockerbasics .
```

This will build an image named `ankitsinghel/dockerbasics` using the files in the current directory as the build context.

Then run it with the published port mapping:

```powershell
docker run -it -p 1200:1200 ankitsinghel/dockerbasics
```

This maps port `1200` on your host to port `1200` in the container and starts an interactive terminal (`-it`).

**Contents of `dockerfile` and line-by-line explanation**

The `dockerfile` in this repo has the following contents:

```dockerfile
# each line is called layer
FROM node:latest

COPY . /home/app

WORKDIR /home/app/

RUN npm install

CMD [ "node" , "index" ]

EXPOSE 1200

```

- `FROM node:latest` : Uses the official Node.js image (latest tag) as the base image. It includes Node.js and npm preinstalled.
- `COPY . home/app` : Copies all files from the build context (the directory you pass to `docker build`) into the image at `home/app`. Note: many Dockerfiles use `/home/app` or `/usr/src/app` — here the path is `home/app` (no leading slash). That creates a `home` folder in the image root.
- `WORKDIR /home/app/` : Sets the working directory for subsequent instructions to `/home/app/`. If the directory does not exist, Docker will create it. Note: the `COPY` target used `home/app` (no leading slash) but `WORKDIR` uses an absolute path `/home/app/`. Docker treats those paths slightly differently; best practice is to use absolute paths consistently (e.g., `/home/app`).
- `RUN npm install` : Runs `npm install` inside the image (in the working directory `/home/app/`) to install dependencies defined in `package.json`.
- `CMD [ "node" , "index" ]` : The container's default command. When the container starts, it executes `node index`. This expects an entrypoint file named `index` (commonly `index.js`) to exist in the working directory.
- `EXPOSE 1200` : Documents that the container listens on port `1200`. This does not publish the port to the host by itself — you must use `-p` or `--publish` with `docker run` to map container ports to the host.

Common suggestions :

- Use `COPY package*.json ./` then `RUN npm install` followed by `COPY . .` to optimize Docker layer caching (faster rebuilds when only app code changes).
- Consider pinning a Node.js version instead of `latest` (e.g., `node:20-alpine`) for reproducible builds.

**About `index.js` and `package.json`**

- `index.js` (in this repo): The Node.js entrypoint. Typically this will start an HTTP server that listens on port `1200`. If you open that file you will find the exact behavior (server, CLI, or script).
- `package.json`: Lists application metadata and dependencies. `npm install` in the Dockerfile installs the packages listed here.

## Docker image layers and caching

Docker builds images as a series of filesystem layers, one per Dockerfile instruction (for most instructions). Understanding layers and Docker's layer cache helps you build images faster and keep image sizes small.

- How caching works:
  - Each instruction (for example `FROM`, `COPY`, `RUN`) creates a new layer. Docker computes a cache key for each instruction based on the instruction itself and the state of the files used by that instruction.
  - If Docker finds an existing image layer with the same cache key, it reuses the cached layer and skips re-running that instruction.
  - When a layer is reused / a new layer is created, all following layers are also reused — until Docker encounters an instruction whose inputs changed.

- `package.json` and lockfiles (why they matter):
  - Copying `package.json` (and the lockfile: `package-lock.json`,`package.json`) separately before running dependency installation keeps the install step cached until your dependencies change.
  - Always place the static files first like package.* and source code at the end so the npm i only revokes when static files changes not when source code changes each time which is more frequent.
  - Example: `COPY package*.json ./`  then `RUN npm ci` (or `RUN npm install`) — when only application source files change, Docker will reuse the cached dependency-install layer.
  - Any change to `package.json` or the lockfile will invalidate the cached install layer and force dependency installation again.
**Verifying the container**

1. Build the image (recommended form):

```powershell
docker build -t ankitsinghel/dockerbasics .
```

2. Run the container and map the port:

```powershell
docker run -it -p 1200:1200 ankitsinghel/dockerbasics
```

3. In a browser or with `curl`, visit `http://localhost:1200` to confirm the app responds (if `index.js` starts an HTTP server).

---
