all:
	git checkout master README.md LICENSE
	sed -i '/\[Demo\]/d;/# 1clickBOM/d' README.md
	pandoc --standalone -c markdown7.css header.md README.md footer.md -o index.html
	sed -i 's/<h1 class="title">.*<\/h1>/<div id="title"><img src="logo.png"\/><span>1clickBOM<\/span><\/div>/' index.html
	sed -i 's/<head>/<head>\n  <meta name="google-site-verification" content="no3OyqIUt7RYgKwphZ6du5ZjhIwZt3eEik9OnVbldeM" \/>\n  <link rel="chrome-webstore-item" href="https:\/\/chrome.google.com\/webstore\/detail\/mflpmlediakefinapghmabapjeippfdi">/' index.html
	sed -i '/<img src="https:\/\/raw.githubusercontent.com\/monostable\/1clickBOM\/master\/readme_images\/chrome.png" alt="Available on Chrome" \/>/d' index.html

MSG=$(shell git log --oneline -n1 master)
commit:
	git commit -a -m 'Update with $(MSG)'
