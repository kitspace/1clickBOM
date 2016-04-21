# The contents of this file are subject to the Common Public Attribution
# License Version 1.0 (the “License”); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://1clickBOM.com/LICENSE. The License is based on the Mozilla Public
# License Version 1.1 but Sections 14 and 15 have been added to cover use of
# software over a computer network and provide for limited attribution for the
# Original Developer. In addition, Exhibit A has been modified to be consistent
# with Exhibit B.
#
# Software distributed under the License is distributed on an
# "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
# the License for the specific language governing rights and limitations under
# the License.
#
# The Original Code is 1clickBOM.
#
# The Original Developer is the Initial Developer. The Original Developer of
# the Original Code is Kaspar Emanuel.
{browser} = require './browser'
{messenger} = require('./messenger')

offers = document.querySelectorAll(".col-sku a")
#offers += document.querySelectorAll('.offertable-links-skucol') #This is from an item page, rather than search result.
for offer in offers
  span = document.createElement('span')
  span.style.textAlign = 'right'
  cb = document.createElement('input')
  cb.type = 'checkbox' 
  offer_id = offer.innerText || offer.textContent
  cb.name = offer_id
  cb.value = offer_id #TODO
  cb.id = offer_id

  label = document.createElement('label')
  label.htmlFor = offer.innerHTML;
  label.innerHTML = "on <img src='"+chrome.extension.getURL('images/logo38.png')+"' alt='1clickBOM' />"
 
  span.appendChild(cb)
  span.appendChild(label)
  span.innerHTML = '('+span.innerHTML+')'
  offer.parentNode.appendChild(span)

  span.onclick = (e) ->
    setTimeout(() -> 
      name = e.target.name
      #debugger
      messenger.send('loadFromRef', name)
    , 1000
    )
