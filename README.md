# rahish.dev — Flutter Web Portfolio

Dark-theme, fully animated portfolio built 100% in Flutter.

**What's animated:** particle constellation background that reacts to the mouse, typewriter role text,
a live wallet-app phone mockup that tilts in 3D toward the cursor, scroll-reveal on every section,
count-up stats, 3D tilt project cards, orbiting feature ring, pop-in skill chips, endless tech marquee,
rotating gradient border on the contact panel, scroll-progress nav bar, and an HTML loading splash.

## Run locally

```bash
cd rahish_portfolio
flutter create . --platforms web --project-name rahish_portfolio   # one time: adds icons/manifest, keeps my files
flutter pub get
flutter run -d chrome
```

## Edit your content

Everything (text, projects, skills, links) is in **`lib/data/portfolio_data.dart`**.
- GitHub link: set `github` to your URL — an icon appears in the footer automatically.
- Resume button: drop your PDF at `web/resume.pdf`.

## Deploy free on GitHub Pages

1. Create a repo on GitHub — name it `<your-username>.github.io` for the URL `https://<your-username>.github.io`
   (any other name works too: it becomes `https://<your-username>.github.io/<repo>/`).
2. Push:
   ```bash
   git init
   git add .
   git commit -m "Portfolio v1"
   git branch -M main
   git remote add origin https://github.com/<your-username>/<repo>.git
   git push -u origin main
   ```
3. On GitHub: **Settings → Pages → Source: GitHub Actions**.
4. Every push to `main` now builds and deploys automatically (`.github/workflows/deploy.yml`).

## Structure

```
lib/
  main.dart                   page, scroll + nav wiring
  data/portfolio_data.dart    ALL content lives here
  theme/app_theme.dart        colours, fonts, breakpoints
  widgets/                    background, reveal, buttons, nav bar, phone mockup
  sections/                   hero, about, experience, projects, skills, contact
web/index.html                SEO meta + loading splash
```
