<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project</title>

    <link rel="stylesheet" href="./styles/bootstrap/bootstrap.min.css">
    <link rel="stylesheet" href="./styles/styles.css">
</head>

<?php
    $bg = array('wallpaper_1.jpg', 'wallpaper_2.jpg', 'wallpaper_3.jpg', 'wallpaper_4.jpg', 'wallpaper_5.jpg', 'wallpaper_6.jpg', 'wallpaper_7.jpg' ); // array of filenames
    $selectedBg = $bg[rand(1, count($bg)-1)];

?>
<style type="text/css">
    .list{
        background: url('../ressources/img/<?php echo $selectedBg; ?>') no-repeat center center;
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

<body>

    <section class="form">
        <?php include("./modules/form.php") ?>
    </section>

    <section class="list">
        <?php include("./modules/table.php") ?>
    </section>

    <script src="script/bootstrap/bootstrap.bundle.min.js"></script>
    <script src="script/jquery-3.7.1.min.js"></script>
    <script>
        $('.form-control').each(function() {
            floatedLabel($(this));
        });

        $('.form-control').on('input', function() {
            floatedLabel($(this));
        });

        function floatedLabel(input) {
            var $field = input.closest('.form-group');
            if (input.val()) {
                $field.addClass('input-not-empty');
            } else {
                $field.removeClass('input-not-empty');
            }
        }
    </script>
</body>

</html>