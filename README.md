# MailHog Server (Standalone)

Clean standalone MailHog setup with:

- Docker Compose
- HTTP basic auth
- Persistent mail storage (maildir)

## 1) Prepare files

```bash
cd mailhog-server
cp .env.example .env
cp auth/users.example auth/users
```

## 2) Set your auth user/password

Generate a bcrypt hash and write your own credentials:

```bash
cd mailhog-server
HASH=$(docker run --rm mailhog/mailhog bcrypt 'your-strong-password')
echo "stag-user:${HASH}" > auth/users
```

Or use the utility script:

```bash
cd mailhog-server
./add-user.sh stag-user
# or non-interactive:
./add-user.sh stag-user 'your-strong-password'
```

## 3) Start MailHog

```bash
cd mailhog-server
docker compose up -d
```

## Access

- Web UI: <http://127.0.0.1:8025>
- SMTP: 127.0.0.1:1025

## Persistence

Captured emails are stored at:

- `mailhog-server/data/maildir`

## Useful commands

```bash
cd mailhog-server
docker compose ps
docker compose logs -f mailhog
docker compose down
```
