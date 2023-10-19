var sizeInput = 3;

var inputFrom       = document.querySelector("#from"); // Selects the input.
var inputTo         = document.querySelector("#to"); // Selects the input.
var datalistFrom    = document.querySelector(".from"); // Selects the datalist.
var datalistTo      = document.querySelector(".to"); // Selects the datalist.

inputFrom.addEventListener("keyup", (e) => {
    if (e.target.value.length >= sizeInput) {
        datalistFrom.setAttribute("id", "citynameFrom");
    } else {
        datalistFrom.setAttribute("id", "");
    }
});
inputTo.addEventListener("keyup", (e) => {
    if (e.target.value.length >= sizeInput) {
        datalistTo.setAttribute("id", "citynameTo");
    } else {
        datalistTo.setAttribute("id", "");
    }
});