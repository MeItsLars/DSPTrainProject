<?php

function select_stops($pdo) : array {
    $sth = $pdo->prepare("SELECT stop_id, stop_name FROM stops where location_type=1");
    $sth->execute();
    $result = $sth->fetchAll(\PDO::FETCH_ASSOC);

    return $result;
}

function select_path($pdo) {
    if(!isset($_SESSION["post"]) || $_SESSION['post'] != $_POST) {
        $_SESSION["post"] = $_POST;
        $date = explode("-", $_POST['date']);
        $d = $date[2];
        $m = $date[1];
        $y = $date[0];
        $date = "$d-$m-$y";
        $travel_time_converted = convertTimeToSec($_POST['time']);
    
        $sth = $pdo->prepare("SELECT
                CONCAT(s1.stop_name, COALESCE(CONCAT(' (', s1.platform_code, ')'), '')) AS s1_stop,
                CONCAT(s2.stop_name, COALESCE(CONCAT(' (', s2.platform_code, ')'), '')) AS s2_stop,
                e.trip_id, r.route_short_name, st.stop_headsign, r.route_type, rt.name as route_name, e.travel_time, e.departure_time, t.service_id
            FROM edges e
            INNER JOIN (SELECT astar_search(".$_POST['from_result'].", ".$_POST['to_result'].", TO_DATE('".$date."', 'DD-MM-YYYY'), '".$travel_time_converted."') AS edge_id) AS pathfinder_result
                ON e.edge_id = pathfinder_result.edge_id
            INNER JOIN stops s1 ON e.from_stop_id = s1.stop_id
            INNER JOIN stops s2 ON e.to_stop_id = s2.stop_id
            LEFT JOIN stop_times st ON e.trip_id = st.trip_id AND e.from_stop_id = st.stop_id
            LEFT JOIN trips t ON e.trip_id = t.trip_id
            LEFT JOIN routes r ON t.route_id = r.route_id
            LEFT JOIN route_types rt ON rt.code = r.route_type;");
    
        // var_dump($sth->queryString);
        $sth->execute();
        // var_dump($result);
        $_SESSION["results"] = $sth->fetchAll(\PDO::FETCH_ASSOC);
    }

}