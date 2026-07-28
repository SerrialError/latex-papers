# ┌───────────────────────────────────────────────────────────────────────────┐
# │                  Multi‐file LaTeX + Typst Makefile                       │
# └───────────────────────────────────────────────────────────────────────────┘

# 1) Change this if you want to use xelatex, lualatex, etc.
LATEX := pdflatex
TYPST := typst

# 2) Find every source file in the current directory
TEX_SOURCES := $(wildcard *.tex)
TYP_SOURCES := $(wildcard *.typ)

# 3) A .typ supersedes a same-named .tex, so papers mid-migration to Typst
#    don't get rebuilt from the stale LaTeX source.
TEX_ONLY := $(filter-out $(TYP_SOURCES:.typ=.tex),$(TEX_SOURCES))

# 4) For each source file, derive the corresponding .pdf name
PDFS := $(TYP_SOURCES:.typ=.pdf) $(TEX_ONLY:.tex=.pdf)

# ───────────── Targets ────────────────────────────────────────────────────────

.PHONY: all clean

# Default: build every PDF
all: $(PDFS)

# Typst first: when both foo.typ and foo.tex exist, make picks the pattern rule
# listed earliest, so this keeps Typst the winner for migrated documents.
%.pdf: %.typ
	@echo "→ Building $@ from $<..."
	@$(TYPST) compile $<
	@echo "✔ $@ done."

# Pattern rule: “To make foo.pdf from foo.tex, run pdflatex twice.”
# (you can bump to 3 passes if you have very complicated cross‐refs, or
# switch to bibtex/biber, etc. – just add those steps here.)
%.pdf: %.tex
	@echo "→ Building $@ from $<..."
	@$(LATEX) -interaction=nonstopmode $< >/dev/null
	@$(LATEX) -interaction=nonstopmode $< >/dev/null
	@echo "✔ $@ done."

# Clean up ALL the usual LaTeX auxiliary files (but leave the PDFs intact).
clean:
	@echo "→ Cleaning auxiliary files…"
	@rm -f \
		*.aux \
		*.log \
		*.out \
		*.toc \
		*.lof \
		*.lot \
		*.fls \
		*.fdb_latexmk \
		*.synctex.gz
	@echo "✔ Cleaned."

# (Optional) If you really want a “distclean” that also deletes PDFs, add:
distclean: clean
	@echo "→ Removing PDFs..."
	@rm -f $(PDFS)
	@echo "✔ All PDFs removed."
