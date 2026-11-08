# ┌───────────────────────────────────────────────────────────────────────────┐
# │                  Multi‐file LaTeX + Typst Makefile                       │
# └───────────────────────────────────────────────────────────────────────────┘
#
#   make            build every PDF in the repo (all subdirectories)
#   make site       build every PDF and assemble the GitHub Pages site in _site/
#   make clean      remove LaTeX auxiliary files
#   make distclean  also remove the built PDFs and _site/

# 1) Change this if you want to use xelatex, lualatex, etc.
LATEX := pdflatex
TYPST := typst
SITE  := _site

# 2) Find every source file in the repo, skipping tool/output directories.
#    (rocket/rocket/ is a stray output dir a script can create from the wrong cwd.)
PRUNE := -path ./.git -prune -o -path ./.devenv -prune -o -path ./.direnv -prune \
         -o -path ./$(SITE) -prune -o -path ./rocket/rocket -prune -o
TYP_SOURCES := $(sort $(patsubst ./%,%,$(shell find . $(PRUNE) -name '*.typ' -print)))
TEX_SOURCES := $(sort $(patsubst ./%,%,$(shell find . $(PRUNE) -name '*.tex' -print)))

# 3) A .typ supersedes a same-named .tex, so papers mid-migration to Typst
#    don't get rebuilt from the stale LaTeX source.
TEX_ONLY := $(filter-out $(TYP_SOURCES:.typ=.tex),$(TEX_SOURCES))

# 4) For each source file, derive the corresponding .pdf name
PDFS := $(TYP_SOURCES:.typ=.pdf) $(TEX_ONLY:.tex=.pdf)

LATEX_AUX := aux log out toc lof lot fls fdb_latexmk synctex.gz bbl blg

# ───────────── Targets ────────────────────────────────────────────────────────

.PHONY: all site clean distclean

# Default: build every PDF
all: $(PDFS)

# Typst first: when both foo.typ and foo.tex exist, make picks the pattern rule
# listed earliest, so this keeps Typst the winner for migrated documents.
# Typst resolves image()/bibliography() paths relative to the source file.
%.pdf: %.typ
	@echo "→ Building $@ from $<..."
	@$(TYPST) compile $<
	@echo "✔ $@ done."

# Pattern rule: "To make foo.pdf from foo.tex, run pdflatex twice" (for
# cross-refs). Runs inside the source's directory so relative \input and
# \includegraphics paths work. The log is printed only if the build fails.
%.pdf: %.tex
	@echo "→ Building $@ from $<..."
	@cd $(@D) && for pass in 1 2; do \
		$(LATEX) -interaction=nonstopmode -halt-on-error $(<F) >/dev/null \
		|| { tail -n 40 $(basename $(<F)).log; exit 1; }; \
	done
	@echo "✔ $@ done."

# Assemble the static site: every PDF at its repo path plus an index.html.
site: all
	@./scripts/build-site.sh $(SITE) $(PDFS)

# Clean up ALL the usual LaTeX auxiliary files (but leave the PDFs intact).
clean:
	@echo "→ Cleaning auxiliary files…"
	@rm -f $(foreach ext,$(LATEX_AUX),$(TEX_SOURCES:.tex=.$(ext)))
	@echo "✔ Cleaned."

# Also delete the built PDFs and the assembled site.
distclean: clean
	@echo "→ Removing PDFs and $(SITE)/..."
	@rm -rf $(PDFS) $(SITE)
	@echo "✔ All PDFs removed."
