# Sausage Reporter

## Installation

1. Install `Golang`
2. Set environment variables `PORT` and `DB`
3. Run `go run main.go`

Example: `PORT=8080 DB=mongodb://localhost:27017/reports go run main.go`

## Health endpoint

Application exposes `/api/v1/health` endpoint according to the 12-factors app

## Testing

Run unit tests via `go test ./app/services/health`

## Local run with docker and local mongoDB

```bash
docker build -t sausage-reporter .
docker run -d --name mongo -p 27017:27017 mongo
docker run --name sausage-reporter -ti -e PORT=8080 -e DB=mongodb://host.docker.internal:27017/reports -p 8080:8080 sausage-reporter
```
