all:
	git checkout master README.md
	sed -i '/demo.gif/d;/# 1clickBOM/d' README.md
	pandoc --standalone -c markdown7.css header.md README.md -o index.html

quick:
	pandoc -s -c markdown7.css header.md README.md -o index.html

