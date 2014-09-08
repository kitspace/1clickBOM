all:
	git checkout master README.md
	git checkout master chrome/data/example.tsv
	pandoc README.md -o index.html
