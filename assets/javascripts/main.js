(function() {
    var filterbox = $('#filter');
    if (!filterbox) {
        return;
    }
    var timeout = null;
    filterbox.on("change keydown", function () {
        clearTimeout(timeout);
        timeout = window.setTimeout(onChange, 200);
    });
    var onChange = function() {
        var value = filterbox.val();
        $.ajax({
            url: '/list',
            data: {
                q: value
            },
            type: 'get',
            dataType: 'html',
            success: function(data) {
                var result = $('<div />').append(data).find('#linklist tbody').html();
                $('#linklist tbody').html(result);
            }
        })
    };
})();
