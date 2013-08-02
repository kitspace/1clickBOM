save_options = () ->
    select = document.getElementById "country"
    country = select.children[select.selectedIndex].value
    localStorage["country"] = country;

    status = document.getElementById "status"
    status.innerHTML = "Options Saved.";
    setTimeout ()->
        status.innerHTML = ""
    , 750

restore_options = () ->
    stored = localStorage["country"]
    if (!stored) 
        return
    select = document.getElementById("country")
    for child in select.children
        if child.value == stored
            child.selected = "true"
            break

xhr = new XMLHttpRequest()
xhr.open "GET", chrome.extension.getURL("/data/countries.json"), false
xhr.send()
if xhr.status == 200
    countries = JSON.parse xhr.responseText

select = document.getElementById "country"
for name, code of countries
    opt = document.createElement("option")
    opt.innerHTML = name 
    opt.value = code 
    select.appendChild(opt)

document.addEventListener "DOMContentLoaded", restore_options
document.querySelector("#save").addEventListener "click", save_options
