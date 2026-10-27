# Personal homepage

Built with [Jekyll](https://jekyllrb.com) and [Hyde](https://github.com/poole/hyde) (MIT, see `LICENSE-hyde.md`), hosted on GitHub Pages.

## What's where

| File | What it is |
| --- | --- |
| `_config.yml` | Site title, sidebar blurb, color theme, and your Letterboxd / IGN Playlist / Goodreads links |
| `index.html` | Home page: a short intro plus your 5 latest posts |
| `posts.html` | The Posts page: every post, grouped by year |
| `media.html` | The Media page: your recent Letterboxd diary and Goodreads shelf (usernames come from `elsewhere:` in `_config.yml`) |
| `japanese.md` | Space for your Japanese tracking chart embeds |
| `resume.html` | Resume page: directing, performance, and education (entries live in `_data/resume.yml`) |
| `portfolio.md` | Director portfolio, **hidden** until you turn it on |
| `_posts/` | Your posts |
| `public/css/site.css` | Your own style tweaks (the Hyde files next to it are left as they came) |
| `_includes/letterboxd-diary.html` | The "Recently watched" list |
| `scripts/fetch-letterboxd.rb` | Pulls your Letterboxd RSS feed into `_data/letterboxd.json` |
| `_includes/goodreads-shelf.html` | The "Recently read" list |
| `scripts/fetch-goodreads.rb` | Pulls your Goodreads "read" shelf RSS feed into `_data/goodreads.json` |
| `.github/workflows/pages.yml` | Builds and publishes the site, and refreshes Letterboxd and Goodreads every 6 hours |

## Writing a post

Add a file to `_posts/` named `YYYY-MM-DD-some-title.md`:

```markdown
---
layout: post
title: Some title
---

Write here in Markdown.
```

Commit and push. It's live in a minute or two.

## Adding a page to the sidebar

Any page with `nav_order: <number>` in its front matter shows up in the sidebar, lowest number first.

## Launching the portfolio

In `portfolio.md`, delete `published: false` and add `nav_order: 5`.

## Putting it on GitHub Pages

1. Create a repo on GitHub named **`<your-username>.github.io`**. Make it public; Pages needs a paid plan for private repos.
2. Push this folder to it:
   ```bash
   git init && git add . && git commit -m "First version of homepage"
   git branch -M main
   git remote add origin https://github.com/<your-username>/<your-username>.github.io.git
   git push -u origin main
   ```
3. In the repo: **Settings → Pages → Build and deployment → Source: GitHub Actions**. (Not "Deploy from a branch": the workflow in `.github/workflows/pages.yml` does the building, so it can fetch your Letterboxd diary first.)
4. The first deploy starts on your next push. To start one now, go to **Actions → Build and deploy site → Run workflow**.
5. The site will be at `https://<your-username>.github.io`.

### Moving brentirw.in over (so you can cancel the server)

1. In **Settings → Pages → Custom domain**, enter `brentirw.in` and save. GitHub commits a `CNAME` file for you.
2. At your domain registrar, replace the DNS records that point at your current server with:
   - `A` records for `@` → `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`
   - (optional) `CNAME` for `www` → `<your-username>.github.io`
3. Wait for DNS to update (minutes to a few hours), then tick **Enforce HTTPS**.
4. Once the new site loads at brentirw.in, you can shut down the old server. If the server also handles your **email** for that domain, leave the `MX` records alone.

## Letterboxd diary

The Letterboxd section on the Media page comes from your public Letterboxd RSS feed. You don't have to do anything: GitHub rebuilds the site every 6 hours, so a film you log shows up within about 6 hours. To update sooner, use **Run workflow** on the Actions tab.

- Show more or fewer films: `{% include letterboxd-diary.html count=20 %}` (default is 10; the feed holds your last ~50).
- Put it on another page: add that same include line.
- Refresh the copy in the repo by hand (used for local previews, and as a fallback if Letterboxd is down during a build): `ruby scripts/fetch-letterboxd.rb`

GitHub pauses scheduled workflows on repos with no activity for 60 days. If the diary stops updating, push any commit or press **Run workflow** to wake it up.

## Goodreads shelf

The Goodreads section on the Media page works the same way as the Letterboxd diary, from your Goodreads "read" shelf RSS feed, refreshed every 6 hours.

- Instead of star ratings it shows your `loved-it`, `liked-it` and `not-for-me` shelves. Books without one of those just show no verdict. Other shelves (like `owned`) are ignored. To change the wording or add a shelf, edit `VERDICTS` in `scripts/fetch-goodreads.rb` and the `case` block in `_includes/goodreads-shelf.html`.
- Show more or fewer books: `{% include goodreads-shelf.html count=10 %}` (default is 5).
- Refresh the copy in the repo by hand: `ruby scripts/fetch-goodreads.rb`

## Japanese charts

The Japanese page shows Google Sheets charts layered on top of each other, set in `_data/japanese_charts.yml`. Each chart uses its **Publish to web** link. A link ending in `format=interactive` is embedded with hover tooltips (used for the pie chart at the bottom); one ending in `format=image` is shown as a picture (used for the overlays, so the mouse passes through them to the pie). Both stay live as your sheet changes. On narrow screens the whole group shrinks together, so the overlays stay lined up.

To position the overlays, open `/japanese/?arrange` (on the live site or a local preview), drag the charts into place, and copy the numbers shown under the charts into the data file. The charts update on their own whenever your sheet changes.

## Previewing locally (optional)

The Ruby that comes with macOS is too old for Jekyll. Install a newer one once:

```bash
brew install ruby
```

Homebrew doesn't replace the system Ruby, so add it to your PATH (put this line in `~/.zshrc` to make it stick):

```bash
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
```

Then, from this folder:

```bash
bundle install
bundle exec jekyll serve --unpublished
```

and open http://localhost:4000. `--unpublished` also shows the hidden portfolio page.
