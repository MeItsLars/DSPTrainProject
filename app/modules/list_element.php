<?php

function list_element($title, $infos, $sec) {
    if($sec == null) {
        echo "<li class='event' data-date=''>";

    } else {
        echo "<li class='event' data-date='".convertSecToTime($sec)."'>";
    }
    echo "
        <h3>$title</h3>
        <p>".$infos['route_name']." - ".$infos['route_short_name']."</p>
    </li>
    ";
}

function list_walk($stop_1, $stop_2) {
    echo "<li>
        <p>Walk from ".$stop_1['s2_stop']." to ".$stop_2['s1_stop']."</p>
    </li>
    ";
}


