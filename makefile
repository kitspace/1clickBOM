all:
	git checkout master README.md LICENSE
	sed -i '/demo.gif/d;/# 1clickBOM/d' README.md
	pandoc --standalone -c markdown7.css header.md README.md -o index.html
	sed -i 's/<h1 class="title">.*<\/h1>/<div id="title"><img src="logo.png"\/><span>1clickBOM<\/span><\/div>/' index.html
	sed -i 's/<head>/<head>\n  <meta name="google-site-verification" content="no3OyqIUt7RYgKwphZ6du5ZjhIwZt3eEik9OnVbldeM" \/>/' index.html
