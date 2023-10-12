<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project</title>

    <link rel="stylesheet" href="./styles/bootstrap/bootstrap.min.css">
    <link rel="stylesheet" href="./styles/styles.css">
</head>

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