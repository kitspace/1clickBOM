all:
	git checkout master README.md LICENSE
	pandoc header.md > header.html
	pandoc --standalone -c markdown7.css README.md footer.md > index.html
	sed -i '/<body>/ r header.html' index.html
	rm header.html
	sed -i 's!^<li><a href="#section.*"></a></li>!!' index.html
	sed -i 's!<body>!<body><div id="title"><img src="logo.png"/><span>1clickBOM</span></div>!' index.html
	sed -i 's!<head>!<head>\n <title>1clickBOM.com</title>\n!' index.html
	sed -i '/<head>/ r piwik.html' index.html

MSG=$(shell git log --oneline -n1 master -- README.md)
commit:
	git commit -a -m 'Update with $(MSG)'
