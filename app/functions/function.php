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

function enleverCaracteresSpeciaux($text) {
    $utf8 = array(
    '/[áàâäãåª]/u'  => 'a',
    '/[ÁÀÂÄÃÅ]/u'   => 'A',
    '/[ÍÏÎÌ]/u'     => 'I',
    '/[íìîï]/u'     => 'i',
    '/[éèêë]/u'     => 'e',
    '/[ÉÈÊË]/u'     => 'E',
    '/[óòôöõº]/u'   => 'o',
    '/[ÓÒÔÖÕ]/u'    => 'O',
    '/[úùûü]/u'     => 'u',
    '/[ÚÙÛÜ]/u'     => 'U',
    '/[Ý]/u'        => 'Y',
    '/[ýÿ]/u'       => 'y',
    '/ç/' => 'c',
    '/Ç/' => 'C',
    '/ñ/' => 'n',
    '/Ñ/' => 'N',
    );
    return preg_replace(array_keys($utf8), array_values($utf8), $text);
}
