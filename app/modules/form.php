<link rel="stylesheet" href="./styles/form.css">
<?php 
    
?>
<div class="booking-form">
    <div class="form-header">
        <h1>Find your way</h1>
    </div>
    <form>
        <div class="form-group">
            <input class="form-control" type="text">
            <span class="form-label">from</span>
        </div>
        <div class="form-group">
            <input class="form-control" type="text">
            <span class="form-label">to</span>
        </div>
        <div class="form-group">
            <div class="form-checkbox">
                <label for="roundtrip">
                    <input type="radio" id="roundtrip" name="flight-type" checked>
                    <span></span>Departure
                </label>
                <label for="one-way">
                    <input type="radio" id="one-way" name="flight-type">
                    <span></span>Arrival
                </label>
            </div>
        </div>
        <div class="row">
            <div class="col-md-6">
                <div class="form-group">
                    <input class="form-control" id="date" onblur="verifyDate(this)" name="date" type="date">
                    <span class="form-label">Date</span>
                    <p class="errorMessageDate">Invalide date</p>
                </div>
            </div>
            <div class="col-md-6">
                <div class="form-group">
                    <input class="form-control" id="time" name="time" type="time">
                    <span class="form-label">Hour</span>
                    <p class="errorMessageHour">Invalide hour</p>
                </div>
            </div>
        </div>


        <div class="form-btn">
            <button class="submit-btn">Check availability</button>
        </div>
    </form>
</div>
<script src="script/jquery-3.7.1.min.js"></script>
<script>
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
        const date = new Date();

        let day = date.getDate();
        let month = date.getMonth() + 1;
        let year = date.getFullYear();
        let currentDate = `${year}-${month}-${day}`;

        console.log(params.value);
        console.log(currentDate);
        console.log(currentDate > params.value);
        if (currentDate > params.value) {
            clearInput(params);
            document.getElementsByClassName("errorMessageDate")[0].style.visibility = "visible";

        }
    }

    function clearInput(target) {
        target.value = "";
    }
</script>