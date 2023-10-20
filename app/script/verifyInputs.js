let dateVerify = false;
let hourVerify = false;
let fromVerify = false;
let toVerify = false;

function myFunction() {
    const valueFrom = document.getElementById("from").value;
    const valueTo = document.getElementById("to").value;

    fromVerify = valueFrom.length !== 0 && document.querySelector('option[value="' + valueFrom + '"]') !== null;
    toVerify = valueTo.length !== 0 && document.querySelector('option[value="' + valueTo + '"]') !== null;
    disableSubmit();
}

$(function() {
    var dtToday = new Date();

    var month = dtToday.getMonth() + 1;
    var day = dtToday.getDate();
    var year = dtToday.getFullYear();
    if (month < 10)
        month = '0' + month.toString();
    if (day < 10)
        day = '0' + day.toString();

    var minDate = year + '-' + month + '-' + day;

    $('#date').attr('min', minDate);
});

function verifyDate(params) {
    if(params.value == null || params.value == "") {
        console.log('complet date');
        dateVerify = false;
    } else {
        console.log('completed date');
        dateVerify = true;
    }
    disableSubmit();
}
// function verifyDate(params) {
//     const date = new Date();
//     let day = date.getDate();
//     let month = date.getMonth() + 1;
//     let year = date.getFullYear();
//     let currentDate = `${year}-${month}-${day}`;
//     if (currentDate > params.value) {
//         clearInput(params);
//         document.getElementById("errorMessageDate").style.visibility = "visible";
//         dateVerify = false;
//     } else {
//         document.getElementById("errorMessageDate").style.visibility = "hidden";
//         dateVerify = true;
//     }
//     verifyHour(document.getElementById("time"))
//     disableSubmit()
// }

function verifyHour(params) {
    if(params.value == null || params.value == "") {
        console.log('complet hour');
        hourVerify = false;
    } else {
        console.log('completed hour');
        hourVerify = true;
    }
    disableSubmit();
}
// function verifyHour(params) {
//     var dateSelect = document.getElementById("date").value;
//     console.log(params.value != "" );
//     if(params.value != "") {
//         if(dateSelect === "") {
//             hourVerify = true;
//         } else {
//             const date = new Date();
//             let day = date.getDate();
//             let month = date.getMonth() + 1;
//             let year = date.getFullYear();
//             let currentDate = `${year}-${month}-${day}`;
//             const hour = date.getHours();
//             const min = date.getMinutes();
//             if(currentDate === dateSelect) {
//                 currentHour = `${hour}:${min}`;
//                 if (currentHour > params.value) {
//                     clearInput(params);
//                     document.getElementById("errorMessageHour").style.visibility = "visible";
//                     hourVerify = false;
//                 } else {
//                     document.getElementById("errorMessageHour").style.visibility = "hidden";
//                     hourVerify = true;
//                 }
//             } else {
//                 document.getElementById("errorMessageHour").style.visibility = "hidden";
//                 hourVerify = true;
//             }
//         }
//     }
//     disableSubmit();
// }

function disableSubmit() {
    console.log("dateVerify", dateVerify);
    console.log("hourVerify", hourVerify);
    console.log("fromVerify", fromVerify);
    console.log("toVerify", toVerify);

    console.log("peut envoyer", (dateVerify && hourVerify && fromVerify && toVerify));
    document.getElementById("mySubmit").disabled = !(dateVerify && hourVerify && fromVerify && toVerify);
}

function clearInput(target) {
    target.value = "";
}