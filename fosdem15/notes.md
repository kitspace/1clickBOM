#1

#2
- My name is Kaspar
- I am a electronic design engineer and software developer
- I know all of these languages listed here, and some others and I use KiCad
  as my main layout tool. I've actually designed a few commercial mass
  manufactured products using KiCad
- I work as a consultant
- But I am here to talk about:

# 3
- 1clickBOM!
- 1clickBOM is a browser extension that let's you quickly fill your electronic
  component shopping carts.
- It is something I wrote to scratch my own itch and make purchasing
  components for projects a little less annoying

# 4

- I only have 15 minutes and I do want to leave some time for questions so
  with rapid pace I am going to cover these topics:
    1. What does 1clickBOM do?
    2. How does it do it?
    3. What will or might it do in the future?

- If you do have any questions feel free to interrupt as I am not sure we will
  actually have time at the end

# 5
- So let's jump right in: what does it do?

# 6 Video

- So 1clickBOM currently allows you, if you get your BOM into a particular order: which is :
    1. line-note
    2. quantity
    3. retailer-name
    4. retailer part number
- to quickly copy... and then switching over to the browser
- pasting these components into there
- you get a nice overview
- and then you can quickly open the cart pages
- bring them into focus
- and empty any if they already have components and
- but the main feature is of course that you can quickly add them to the cart

# 7
- Most of these sites already have quick-add features but the advantage of
  1clickBOM is that it is vendor agnostic: you don't need to worry about what
the vendor format for their quick-add tool is and in general 1clickBOM just
streamlines the interaction with the site when you already know what you want
to buy. On some sites it takes a surprising amount of clicks to empty your
cart for instance so, you no longer have to worry about that.
- I have made sure that the extension is very clear about what goes wrong when
  something goes wrong. So if you try and add a non-existing items, or add
negative quantities  or are not online then you will get notifications like
this one.

# 8
- Another neat little feature is that if you put your BOM as
  tab-seperated-values online then this blue button appears and you can load
that directly from any site ending in .tsv.

# 9
- The main features are ;
- Chrome extension with a Firefox port in the works
- Supports the retailers listed there
- Is set-up to work in over 100 locations, so it will use your local sites
- CPAL license which is an OSI and FSF approved license and I don't really
  have time to go into details

# 10
- So the application parses tab-seperated values, which is the clipboard
  format for most, if not all, spreadsheet applications. It's dead simple to
parse because no one really wants tabs in their data so it's a perfect
delimiter and you don't have to worry about escaping characters.
- The order of fields, that you saw before, which is line-note, quantity,
  retailer, part number was chosen so it could be expanded to include multiple
retailers per line-item in a backwards compatible way and i will talk about that a little more towards the end.
- The application mimicks the http requests that the sites themselves cause
  your browser to send. - From the responses the application quickly looks for particular html
  elementsto determine wether things are working as expected

# 11 A little note on http
- Your browser usually sends a GET or POST requests (there are some other types that are less common that I won't get into).
- GET is for retrieving info
- POST is for posting info, most commonly this is from filling in a form online and then you hit submit
- both have parameters that you send along with them
- the request will then return a status code, or timeout, you chose the timeout period
- the response will usually contain the document that the site wants your browser to display next, so this is where 1clickBOM will look for indicators as to wether this component was added successfully
- cookies persist data, so your shopping cart is usually a cookie stored in your browser

# 12

- So a lot of time was spent picking the http requests apart apart.
- most browsers now have really great tooling for that, you just press 12 and bring up a console where you can log and view all the requests and copy and paste them
- there are even some advanced extensions where you can tamper with outgoing requests before they go out which proved useful as well

# 13
- These are not clean APIs. Some of these requests are monster requests.
- This is what you would have to type on the command line to add a component to your shopping cart at mouser
- I have truncated this here but that viewstate item goes on for over 20000 characters

# 14
- So I want to talk a little bit about the architecture of the application
-  So this is an object-oriented application written in Coffeescript with a
   barrage of functional tests and a very simple GUI.
- Let's see if we can cover all of that.

# 15

- Coffeescript is a language that compiles to Javascript.

# 16
- I chose Coffeescript because I hadn't written any Javascript in a long long
  time and Coffeescript has this terse, pythonesque syntax.
- Javascript is very loose, it doesn't really guide you to writing good
  javascript which I felt coffeescript does to an extent.
- At the top we have a coffeescript list comprehension and the equivelent JS
  below

# 17
- CS has a simple classes with constructors and methods and inheritance.

#18
- it's not JS
- another level of abstraction that you need to compile
- errors in the browser will refer to JS line numbers not CS line numbers by
  default
- there are solutions for this but you do have to manage the solutions as well
- as I am working on the Firefox port for instance I haven't figured how to
  enale source-maps yet and it's just an extra thing that you have to do

- All in all I the pros do outweigh the cons, in my opinion, for this project.

# 19
- So we have touched on CS having classes and the extension is in an OO style

# 20
- I came up with a RetailerInterface class that has a notion of data that is
  some locally stored JSON with all the different sites (uk.farnell.com,
bg.farnell.com)
- It then has some default methods to refresh the pages and view them
- Every retailer type then "extends" this class, pointing it to the right data
  and adding methods to add items and empty carts.

# 21
- I feel this abstraction works well in some ways
- The moment when it really shone was when Farnell started switching some of
  their sites to a Newark style interface. They were re-using the Newark
site-design and I had already implemented the code to drive that site in a
Newark class.
- So the fix was to detect that this was happening, again a quick-and dirty
  HTML dom detection and then just replace all the methods with the ones from
Newark.
- Job done

# 22
- In some ways this abstraction really breaks down
- I implemented this BomManager class that holds all the retailer interfaces
  and offers methods to operate on all of them at once.
- But it really doesn't need to be a class. There will only ever be one BOM
  manager so why do I need to instantiate this guy.
- Similarily the retailer classes need to be instantiated but they are all
  singletons too because we are only ever in one country at a time

# 23
- From the start of this project I wanted to make sure that I had a lot of
  automated tests. I have worked on projects with few to no tests and this was
a way to vent my frustration. " With _my_ project I will do this right from
the start"

# 24
- So I chose a test framework and wrote some simple unit tests for my classes,
  made sure they all constructed alright and threw the right error when you
gave them stupid inputs

#25
- But that's where the straight-forward tests really ended already. Those
  tests you saw in the previous slide were all the proper unit tests I was
able to write.
- Nevertheless I do have this barrage of tests that goes through every
  possible country of every possible retailer and makes sure the main
operations behave as expecting when adding good data _and_ also bad data
- The rest of the application is so heavily network dependant, what this
  application does is interact with a website after all, that it is very hard
to get a pass-or-fail out of a test.
- The requests can time out, or be denied simply because you are sending too
  many at once, or is some instances because the site doesn't like some of the
cookies you have set
- The suite does need to be massaged a bit before you can reach a conclusion
  as to whether something is broken or not

# 26
- So the GUI is actually just a webpage, that's how modern browswer extensions
  work. It's all HTML/CSS and JS
- I didn't use an UI libraries like JQuery because I felt the DOM selection
  methods I had were adequate to do what I wanted to do
- I use chrome features as much as possible, it gave me an easy way to create
  notifications and that little OK badge you see up top is a little
chrome.runtime API, so i didn't have to mess with the icons too much

# 27
- So what are my plans for this little tool?

# 28
- First off let's see where it is currently
- As mentioned before it's chrome only for now
- It's on the chrome store and there are always about 200 people in the last
  week that opened their browser with the extension installed

# 29
- As mentioned, a Firefox version is planned and that will be the 0.2 release
- I don't think the port is super important to the users at this point, if you want to buy components you could just open chrome for this task, you likely don't do it that often unless you work in a purchasing department or something
- There is a whole road-map online and you can check that if you want more
  details but the features I am most excited about are
- Allowing multiple retailers per item and letting the user select their
  preferred retailers
- This would essentially, if you had a complete set of components across
  retailers in your BOM allow you to publish that and let anyone add it to
their prefferred retailer for easy order. You could combine that with a link
to a low-cost PCB manufacturer and you are essentially got an order a kit
button on your site, but you don't have to lift a finger
- Even further down the road it would be good to be able to generate the
  "complete" BOMs from a simple BOM and allow you to minimize the cost for
your order as well

# 30

- That's all for now, any questions?
