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

`TECHNITIUM_NODE0_TOKEN`, `TECHNITIUM_NODE1_TOKEN`, and `TECHNITIUM_NODE2_TOKEN` are used for Companion background checks. They must be real Technitium DNS API tokens from the matching node. A random secret, or a token from a different Technitium node, will start the UI, but Companion will show:

```text
Background token validation failed
TECHNITIUM_*_TOKEN was rejected by node "node0": invalid token.
```

## Getting the background tokens

Repeat this once per Technitium node.

1. Open the node's Technitium DNS web console, for example `https://technitium-0.koala-dominant.ts.net`.
2. Prefer a dedicated non-admin user if the permissions you need can be limited.
3. Add that user to a group with the DNS permissions Companion needs.
4. Log in as that user.
5. Open the username menu in the top right.
6. Click `Create API Token`.
7. Name it `technitium-companion-background`.
8. Copy the token immediately; Technitium shows it once.
9. Put it in the real repo `.env`:

```dotenv
TECHNITIUM_NODE0_TOKEN="token-from-technitium-0"
TECHNITIUM_NODE1_TOKEN="token-from-technitium-1"
TECHNITIUM_NODE2_TOKEN="token-from-technitium-2"
```

10. Re-sync or redeploy `homelab-networking` in Komodo so the updated environment reaches the container.

The current stack uses per-node tokens:

```yaml
TECHNITIUM_NODE0_TOKEN: ${TECHNITIUM_NODE0_TOKEN}
TECHNITIUM_NODE1_TOKEN: ${TECHNITIUM_NODE1_TOKEN}
TECHNITIUM_NODE2_TOKEN: ${TECHNITIUM_NODE2_TOKEN}
```

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
- `Background token validation failed`: replace the rejected node's `TECHNITIUM_NODE*_TOKEN` with a token created on that same Technitium node, then redeploy the stack.
- Docktail service missing or OAuth errors: check `TAILSCALE_OAUTH_CLIENT_ID` and `TAILSCALE_OAUTH_CLIENT_SECRET`, then redeploy `docktail`.
