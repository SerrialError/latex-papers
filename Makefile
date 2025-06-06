# ┌───────────────────────────────────────────────────────────────────────────┐
# │                    Multi‐file LaTeX Makefile                             │
# └───────────────────────────────────────────────────────────────────────────┘

# 1) Change this if you want to use xelatex, lualatex, etc.
LATEX := pdflatex

# 2) Find every .tex file in the current directory
TEX_SOURCES := $(wildcard *.tex)

# 3) For each .tex file, derive the corresponding .pdf name
PDFS := $(TEX_SOURCES:.tex=.pdf)

# ───────────── Targets ────────────────────────────────────────────────────────

.PHONY: all clean

# Default: build every PDF
all: $(PDFS)

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
