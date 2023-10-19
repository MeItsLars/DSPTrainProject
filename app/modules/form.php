<link rel="stylesheet" href="./styles/form.css">
<?php 
    include "./functions/query.php";
    $stops = select_stops($pdo);
?>
<div class="booking-form">
    <div class="form-header">
        <h1>Find your way</h1>
    </div>
    <form action="#" method="post">
        <div class="form-group">
            <input class="form-control" id="from"  type="text" name="from" list="citynameFrom" oninput="myFunction(this)">
            <span class="form-label">from</span>
            <datalist id="" class="from">
                <?php
                    foreach ($stops as $stop) { 
                        echo '<option value="'.$stop["stop_id"].'">'.$stop["stop_name"].'</option>\n';                    
                    }
                ?>
            </datalist>
        </div>
        <script>

        </script>
        <div class="form-group">
            <input class="form-control" id="to" type="text" name="to"  list="citynameTo" oninput="myFunction(this)">
            <span class="form-label">to</span>

            <datalist id="" class="to">

                <?php
                    foreach ($stops as $stop) { 
                        echo '<option value="'.$stop["stop_id"].'">'.$stop["stop_name"].'</option>\n';                    
                    }
                ?>
            </datalist>
        </div>
        <div class="form-group">
            <div class="form-checkbox">
                <label for="Departure">
                    <input type="radio" id="Departure" name="Departure" checked>
                    <span></span>Departure
                </label>
                <label for="Arrival">
                    <input type="radio" id="Arrival" name="Arrival">
                    <span></span>Arrival
                </label>
            </div>
        </div>
        <div class="row">
            <div class="col-md-6">
                <div class="form-group">
                    <input class="form-control" id="date" onblur="verifyDate(this)" name="date" type="date">
                    <span class="form-label">Date</span>
                    <p class="errorMessageDate" id="errorMessageDate">Invalide date</p>
                </div>
            </div>
            <div class="col-md-6">
                <div class="form-group">
                    <input class="form-control" id="time" onblur="verifyHour(this)" name="time" type="time">
                    <span class="form-label">Hour</span>
                    <p class="errorMessageHour" id="errorMessageHour">Invalide hour</p>
                </div>
            </div>
        </div>


        <div class="form-btn">
            <button class="submit-btn" id="mySubmit" disabled>Check availability</button>
        </div>
    </form>
</div>
<script src="script/jquery-3.7.1.min.js"></script>
<script src="./script/minInputDatatlist.js"></script>
<script src="./script/verifyInputs.js"></script>