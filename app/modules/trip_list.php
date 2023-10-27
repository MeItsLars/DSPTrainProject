<div class="container">
    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-body">
                    <h6 class="card-title">Timeline</h6>
                    <div id="content" style="
                        max-height: 80vh;
                        overflow: auto;">
                        <ul class="timeline">
                            <?php
                                $stops = array();
                                select_path($pdo);
                                if(isset($_SESSION['results'])) {
                                    $results = array_reverse($_SESSION['results']);
                                    foreach ($results as $result) {
                                        if (!array_key_exists($result['trip_id'], $stops)) {
                                            $stops[$result['trip_id']][0] = $result;
                                        } else {
                                            array_push($stops[$result['trip_id']], $result);
                                        }
                                    }
                                    $currentStop = 0;
                                    $idTranfert = 1;
                                    $prevStop = null;
                                    foreach ($stops as $key => $stop) {
                                        if($currentStop > 1 && $currentStop !== (sizeof($stops))) {
                                            echo "<div class='group_list'>";
                                            echo "<div class='borderLeft borderDash'></div>";
                                            list_walk(
                                                $prevStop,
                                                $stop[0]
                                            );
                                            echo "</div>";
                                        }

                                        if($key != "") {
                                            echo "<div class='group_list'>";
                                            echo "<div class='borderLeft'></div>";
                                            list_element(
                                                $stop[0]['s1_stop'], 
                                                $stop[0], 
                                                $stop[0]['departure_time']
                                            );
                                            $lastElemen = $stop[sizeof($stop)-1];
                                            list_element(
                                                $lastElemen['s2_stop'], 
                                                $lastElemen, 
                                                $lastElemen['departure_time']
                                            );
                                            echo "</div>";
                                            $prevStop = $lastElemen;
                                        }
                                        $currentStop++;
                                    }
                                }

                            ?>

                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>