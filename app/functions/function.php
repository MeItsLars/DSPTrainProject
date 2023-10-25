<?php


function convertTimeToSec($time) : string {
    return intval(explode(":", $time)[0]) * 3600 + intval(explode(":", $time)[1]) * 60;
}

function convertSecToTime($sec) : string {
    return gmdate("H:i:s", $sec);
}
function convertSecToDateTime($sec) : string {
    return date('d/m/Y H:i', $sec);
}

function getTimeTravel($datas) : string {
    $timeTravel = 0;
    foreach ($datas as $result) {
        $timeTravel += $result['travel_time'];
    }
    return convertSecToTime($timeTravel);
}