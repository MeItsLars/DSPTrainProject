<?php 
session_start();

include "./functions/query.php";
include "./functions/function.php";
include "./modules/list_element.php";

$envFile = './.env';
$connection = (array) null;
if (file_exists($envFile)) {
    $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        list($key, $value) = explode('=', $line, 2);
        $connection[$key] = $value;
    }

} else {
    die(".env file not found.");
}

try {
    $pdo = new PDO(
        'pgsql:host=' . $connection['DB_HOST'] . 
        ';port=' . $connection['DB_PORT'] . 
        ';dbname=' . $connection['DB_NAME'],
        $connection['DB_USER'],
        $connection['DB_PASS']
    );

    // Set PDO to throw exceptions on error
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // You're c onnected! You can now use $pdo to interact with the database.
} catch (PDOException $e) {
    die("Database connection failed: " . $e);
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta Content-Type="text/html" charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Find your way</title>

    <link rel="stylesheet" href="./styles/bootstrap/bootstrap.min.css">
    <link rel="stylesheet" href="./styles/style.css">
</head>

<?php
    $bg = array('wallpaper_1.jpg', 'wallpaper_2.jpg', 'wallpaper_3.jpg', 'wallpaper_4.jpg', 'wallpaper_5.jpg', 'wallpaper_6.jpg', 'wallpaper_7.jpg' ); // array of filenames
    $selectedBg = $bg[rand(1, count($bg)-1)];

?>
<style type="text/css">
    pre {
        background-color: wheat;
        padding: 10px;
        height: 80vh;
    }  
    .list{
        background: url('./ressources/img/<?php echo $selectedBg; ?>') no-repeat center center;
        width: 70vw;
        position: relative;
        height: 100vh;
        background-size: cover;
        background-attachment: fixed;
        display: flex;
        justify-content: center;
        align-items: center;
    }
</style>

<body id="contents" onload="verifyOnLoad()">
    <div class="loader">
        <div class="cont">
            <div class="track"></div>
            <div class="train"></div>
        </div>
        <p class="credit">
            Created by <a href="https://lenadesign.org/2021/04/12/css-train-front-animation-loader/">Lena Stanley</a>    
        </p>
    </div>

    <section class="form">
        <?php include("./modules/form.php") ?>
    </section>

    <section class="list">
        <?php 
            if(!empty($_POST)) {
                include("./modules/trip_list.php");
            } 
        ?>
    </section>

    <script src="script/bootstrap/bootstrap.bundle.min.js"></script>
    <script src="script/jquery-3.7.1.min.js"></script>
    <script src="script/script.js"></script>
</body>

</html>