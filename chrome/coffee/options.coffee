save_options = () ->
    select = document.getElementById "color"
    color = select.children[select.selectedIndex].value
    localStorage["favorite_color"] = color;

    status = document.getElementById "status"
    status.innerHTML = "Options Saved.";
    setTimeout ()->
        status.innerHTML = ""
    , 750

restore_options = () ->
    favorite = localStorage["favorite_color"]
    if (!favorite) 
        return
    select = document.getElementById("color")
    for child in select.children
        if child.value == favorite
            child.selected = "true"
            break


document.addEventListener "DOMContentLoaded", restore_options
document.querySelector("#save").addEventListener "click", save_options
