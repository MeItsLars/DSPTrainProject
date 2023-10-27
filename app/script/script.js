
$(document).ready(function() {
    $('.loader').show().fadeOut(2000);
});

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
