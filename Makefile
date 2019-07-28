# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = python -m sphinx
SOURCEDIR     = source
BUILDDIR      = build

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)



# TODO: create targets for
# cd source
# sphinx-build -b gettext . _build/gettext # regenerate *.pot files
# sphinx-intl update -p _build/gettext -l ru # regenerate *.po files
# Edit *.po files (translate and remove 'fuzzy' markers) then commit *.po files


syncpackages:
	pip install --user -r requirements.txt

install_hooks:
	cp -r ./git-hooks/. ./.git/hooks

install_tools:
	pip install sphinx==1.8.5
