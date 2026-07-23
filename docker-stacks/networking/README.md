# Networking stack

This stack is deployed by Komodo as `homelab-networking`.

Services:

- `docktail`: global service that advertises stack endpoints through Tailscale.
- `technitium-0`: DNS node on `docker-svc-0`.
- `technitium-1`: DNS node on `sentinel-1`.
- `technitium-2`: DNS node on `sentinel-0`.
- `technitium-companion`: Companion UI on `sentinel-0`, exposed as `https://technitium-companion.koala-dominant.ts.net`.

`technitium-companion` listens on HTTPS port `3443` with a self-signed certificate. The Docktail label must stay `docktail.service.protocol: https+insecure`; plain `https` can produce a 502 from Tailscale Serve because the upstream certificate is not trusted.

## Companion login

Technitium DNS Companion uses the Technitium DNS username and password for normal UI login.

`TECHNITIUM_BACKGROUND_TOKEN` is only for Companion background checks. It must be a real Technitium DNS API token. A random secret will start the UI, but Companion will show:

```text
Background token validation failed
TECHNITIUM_BACKGROUND_TOKEN was rejected by node "node0": invalid token.
```

## Getting the background token

1. Open a Technitium DNS web console, for example `https://technitium-0.koala-dominant.ts.net`.
2. Prefer a dedicated non-admin user if the permissions you need can be limited.
3. Add that user to a group with the DNS permissions Companion needs.
4. Log in as that user.
5. Open the username menu in the top right.
6. Click `Create API Token`.
7. Name it `technitium-companion-background`.
8. Copy the token immediately; Technitium shows it once.
9. Put it in the real repo `.env`:

```dotenv
TECHNITIUM_BACKGROUND_TOKEN="paste-token-here"
```

10. Re-sync or redeploy `homelab-networking` in Komodo so the updated environment reaches the container.

If one token is not valid for every DNS node, switch this stack to per-node tokens instead:

```yaml
TECHNITIUM_NODE0_TOKEN: ${TECHNITIUM_NODE0_TOKEN}
TECHNITIUM_NODE1_TOKEN: ${TECHNITIUM_NODE1_TOKEN}
TECHNITIUM_NODE2_TOKEN: ${TECHNITIUM_NODE2_TOKEN}
```

The current stack uses the single global `TECHNITIUM_BACKGROUND_TOKEN`.

## Checks

```sh
curl -kI https://technitium-companion.koala-dominant.ts.net
```

On `sentinel-0`:

```sh
curl -sk https://127.0.0.1:3443/api/health
tailscale serve status --json
```

Expected Serve proxy for Companion:

```text
https+insecure://localhost:3443
```

## Troubleshooting

- 502 from `technitium-companion.koala-dominant.ts.net`: Companion is down, or Docktail/Tailscale Serve is not using `https+insecure://localhost:3443`.
- `Background token validation failed`: replace `TECHNITIUM_BACKGROUND_TOKEN` with a real Technitium API token and redeploy the stack.
- Docktail service missing or OAuth errors: check `TAILSCALE_OAUTH_CLIENT_ID` and `TAILSCALE_OAUTH_CLIENT_SECRET`, then redeploy `docktail`.
