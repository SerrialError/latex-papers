# Robotics Latex Papers

Built PDFs are published at **https://serrialerror.github.io/latex-papers/**.
Each paper lives at its repo path, e.g.
`https://serrialerror.github.io/latex-papers/motion-profiling.pdf`.

PDFs are not committed. A GitHub Actions workflow (`.github/workflows/pages.yml`)
builds every `.typ`/`.tex` file on each push to `main` and deploys them to GitHub Pages.

Local build (inside the devenv shell):

```sh
make         # build every PDF
make site    # also assemble the site in _site/
make clean   # remove LaTeX aux files
```
