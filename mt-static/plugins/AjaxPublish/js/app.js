$(document).ready( function() {
    $('#list-entry td.publish a').click( function() {
        var id = $(this).parents('tr').find('.cb input').val();
        var link = $(this);
        link.css('background','url('+StaticURI+'images/ani-rebuild.gif) no-repeat center -1px');
        var url = ScriptURI + '?__mode=ap.rebuild_entry&amp;blog_id='+BlogID+'&amp;id=' + id; 
        $.ajax({
            url: url,
            dataType: 'json',
            error: function (xhr, status, error) {
                link.css('background','url('+PluginStaticURI+'images/icon-error.gif) no-repeat center -1px');
            },
            success: function (data, status, xhr) {
                if (data.success) {
                    link.css('background','url('+StaticURI+'images/nav-icon-rebuild.gif) no-repeat center 0px');
                    link.qtip('destroy');
                } else {
                    link.css('background','url('+PluginStaticURI+'images/icon-error.gif) no-repeat center -1px');
                    link.qtip({
                        content: data.errstr,
                        position: {
                            corner: {
                                tooltip: 'topRight',
                                target: 'bottomLeft'
                            }
                        },
                        show: {
                            solo: true
                        },
                        style: {
                            border: {
                                width: 3,
                                radius: 5
                            },
                            padding: 6, 
                            tip: true, // Give it a speech bubble tip with automatic corner detection
                            name: 'cream' // Style it according to the preset 'cream' style
                        }
                    });
                }
            }
        });
    });
});
