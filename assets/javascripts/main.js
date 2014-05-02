(function($) {
    $.QueryString = (function(a) {
        if (a == "") return {};
        var b = {};
        for (var i = 0; i < a.length; ++i)
        {
            var p=a[i].split('=');
            if (p.length != 2) continue;
            b[p[0]] = decodeURIComponent(p[1].replace(/\+/g, " "));
        }
        return b;
    })(window.location.search.substr(1).split('&'))
})(jQuery);

(function() {
    var filterbox = $('#filter');
    if (!filterbox) {
        return;
    }
    var query = $.QueryString['q'] || '';
    if(query) {
        filterbox.val(query);
    }
    var sort = $.QueryString['s'] || 'url';
    var timeout = null;
    filterbox.on("change keydown", function () {
        clearTimeout(timeout);
        timeout = window.setTimeout(onChange, 200);
    });
    var onUpdateHtml = function(data) {
        var result = $('<div />').append(data).find('#linklist tbody').html();
        $('#linklist tbody').html(result);
        history.pushState(null, null, this.url);
    };
    var updateHtml = function() {
        $.ajax({
            url: '/list',
            data: {
                q: query,
                s: sort
            },
            type: 'get',
            dataType: 'html',
            success: onUpdateHtml
        });
    };
    var onChange = function() {
        query = filterbox.val();
        updateHtml();
    };
    $('#url_sort').click(function(e) {
        e.preventDefault();
        sort = 'url';
        updateHtml();
    });
    $('#hits_sort').click(function(e) {
        e.preventDefault();
        sort = 'hits';
        updateHtml();
    });
})();
