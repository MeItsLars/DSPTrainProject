<?php

function select_stops($pdo) : array {
    $sth = $pdo->prepare("SELECT stop_id, stop_name FROM stops where location_type=1");
    $sth->execute();
    $result = $sth->fetchAll(\PDO::FETCH_ASSOC);

    return $result;
}
