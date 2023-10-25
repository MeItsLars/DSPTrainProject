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
                                $results = array_reverse(select_path($pdo));
                                foreach ($results as $result) {
                                    if (!array_key_exists($result['trip_id'], $stops)) {
                                        $stops[$result['trip_id']][0] = $result;
                                    } else {
                                        array_push($stops[$result['trip_id']], $result);
                                    }
                                }
                                // var_dump($stops);
                                $currentStop = 0;
                                $idTranfert = 1;
                                foreach ($stops as $key => $stop) {
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
                                    }
                                    // echo sizeof($stops[""]);
                                    // echo $idTranfert;
                                    // echo $currentStop;
                                    // echo sizeof($stops) - 1;
                                    if($currentStop !== 0 && $currentStop !== (sizeof($stops) - 1)) {
                                        echo "<div class='group_list'>";
                                        echo "<div class='borderLeft borderDash'></div>";
                                        list_walk(
                                            $stops[""][$idTranfert],
                                            $stops[""][$idTranfert + 1]
                                        );
                                        echo "</div>";
                                        $idTranfert += 2; 
                                    }
                                    $currentStop++;
                                }
                            ?>

                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>