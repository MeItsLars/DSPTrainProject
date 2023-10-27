<link rel="stylesheet" href="./styles/form.css">
<?php 
    $stops = select_stops($pdo);
?>
<div class="booking-form">
    <div class="form-header">
        <h1>Find your way</h1>
    </div>
    <form action="#" method="post">
        <div class="form-group">
            <input 
                class="form-control" 
                value="<?php if(!empty($_POST['from'])) echo $_POST['from']; ?>" 
                id="from" 
                type="text" 
                name="from" 
                list="citynameFrom" 
                oninput="myFunction(this)">
            <span class="form-label">from</span>
            <datalist id="citynameFrom" class="from">
                <?php
                    foreach ($stops as $stop) { 
                        echo '<option value="'.enleverCaracteresSpeciaux($stop["stop_name"]).'">'.$stop["stop_id"].'</option>';                   
                    }
                ?>
            </datalist>
            <input type="hidden" value="<?php if(!empty($_POST['from_result'])) echo $_POST['from_result']; ?>" name="from_result" id="from_result">
        </div>
        <script>
            document.getElementById('from').addEventListener('input', function() {
                const selectedOption = document.querySelector(`#citynameFrom option[value="${this.value}"]`);
                if (selectedOption) {
                    const selectedLabel = selectedOption.textContent;
                    console.log(`Selected Label: ${selectedLabel}`);
                    console.log(`Selected Value: ${this.value}`);
                    document.getElementById('from_result').value = selectedLabel;
                }
            });
        </script>

        <div class="form-group">
            <input class="form-control" value="<?php if(!empty($_POST['to'])) echo $_POST['to']; ?>" id="to" type="text" name="to"  list="citynameTo" oninput="myFunction(this)">
            <span class="form-label">to</span>

            <datalist id="citynameTo" class="to">

                <?php
                    foreach ($stops as $stop) { 
                        echo '<option value="'.enleverCaracteresSpeciaux($stop["stop_name"]).'">'.$stop["stop_id"].'</option>';                   
                    }
                ?>
            </datalist>
            <input type="hidden" value="<?php if(!empty($_POST['to_result'])) echo $_POST['to_result']; ?>" name="to_result" id="to_result">
            <script>
                document.getElementById('to').addEventListener('input', function() {
                    const selectedOption = document.querySelector(`#citynameTo option[value="${this.value}"]`);
                    if (selectedOption) {
                        const selectedLabel = selectedOption.textContent;
                        console.log(`Selected Label: ${selectedLabel}`);
                        console.log(`Selected Value: ${this.value}`);
                        document.getElementById('to_result').value = selectedLabel;
                    }
                });
            </script>
        </div>
        <div class="row">
            <div class="col-md-6">
                <div class="form-group">
                    <input class="form-control" value="<?php if(!empty($_POST['date'])) echo $_POST['date']; ?>" id="date" onblur="verifyDate()" name="date" type="date">
                    <span class="form-label">Date</span>
                    <p class="errorMessageDate" id="errorMessageDate">Invalide date</p>
                </div>
            </div>
            <div class="col-md-6">
                <div class="form-group">
                    <input class="form-control" value="<?php if(!empty($_POST['time'])) echo $_POST['time']; ?>" id="time" onblur="verifyHour()" name="time" type="time">
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