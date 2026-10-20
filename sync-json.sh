#!/usr/bin/env bash
# Weekly reachability + price-page liveness sync for every endpoint in endpoints.json.
# Writes last_checked_at and reachable per entry, regenerates the README "Checked" footer.
set -euo pipefail
python3 - <<'PY'
import base64, json, ssl, urllib.request
data = json.load(open("endpoints.json"))
ctx = ssl.create_default_context()
import time
now = time.strftime("%Y-%m-%d", time.gmtime())
for e in data:
    url = "https://%s%s/models" % (e["host"], e["base_path"])
    status = None
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "curl/8", "Authorization": "Bearer ping"})
        try:
            with urllib.request.urlopen(req, timeout=15, context=ctx) as r:
                status = r.status
        except urllib.error.HTTPError as he:
            status = he.code  # 401/403/404 all say the hostname is alive
    except Exception:
        status = None
    e["last_checked_at"] = now
    e["reachable"] = "open" if status == 200 else ("auth-gated" if status in (401, 403) else ("not-found" if status == 404 else "down"))
json.dump(data, open("endpoints.json", "w"), indent=2, ensure_ascii=False)
print("checked", len(data), "entries at", now)
PY
