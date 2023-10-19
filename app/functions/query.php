<?php

function select_stops($pdo) : array {
    $sth = $pdo->prepare("SELECT stop_id, stop_name FROM stops");
    $sth->execute();
    $result = $sth->fetchAll(\PDO::FETCH_ASSOC);

    return $result;
}
