# Getting the code up now, and live later

Two separate things, and only the second one costs anything:

| | Costs Netlify credits? |
|---|---|
| Pushing to GitHub | **No** — GitHub is free and unlimited here |
| Netlify running a build | **Yes** — this is what you are out of |

So you can back everything up on GitHub today and deploy whenever.

---

## Step 1 — put the code on GitHub today (free)

From this folder, in PowerShell:

```powershell
.\save-to-github.ps1
```

That commits everything and pushes to `main`, with `[skip netlify]` in the
commit message. Netlify sees that tag and **skips the build entirely**, so no
credits are used. Your code is safe on GitHub either way.

If you would rather type it yourself:

```powershell
git add -A
git commit -m "your message

[skip netlify]"
git push origin main
```

The blank line before `[skip netlify]` matters — it needs to be its own line.

### Belt and braces
If you want to be certain no build can start, pause them in Netlify first:

**Netlify → your site → Site configuration → Build & deploy → Continuous
deployment → Stop builds.**

While stopped, pushes never trigger anything. This is the safest option if you
are close to zero.

---

## Step 2 — deploy when your credits are back

Pick whichever is easier:

**A. Resume and trigger from the Netlify UI**
1. Site configuration → Build & deploy → **Start builds** (if you stopped them)
2. Deploys tab → **Trigger deploy** → *Deploy site*

That builds the code already sitting on GitHub. No new commit needed.

**B. Push one more commit without the skip tag**

```powershell
git commit --allow-empty -m "Deploy latest"
git push origin main
```

Netlify builds it as normal.

---

## Checking it worked

- GitHub: open <https://github.com/nishan13551/chess> — `index.html` should show
  your latest commit time.
- Netlify: the Deploys tab will say *Skipped* for the `[skip netlify]` pushes.
  That is what you want to see.
- Live: <https://chess.ferdousnishan.com> only changes after a real deploy.

---

## Worth knowing

- This is a **single static HTML file**. There is no build step to speak of, so
  a deploy is quick and cheap when you do run one.
- Because there is no build, you can also skip Netlify's build system entirely
  and drag the folder onto **Netlify Drop** (app.netlify.com/drop) — that
  publishes without using build minutes. You would then point the subdomain at
  that deploy, so only do it if the normal route is still blocked.
- `robots.txt`, `_headers` and the `noindex` tags keep the site out of search
  engines. Leave them in place; they are why it does not show up on Google.
