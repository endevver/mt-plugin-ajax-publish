package AjaxPublish::Plugin;

use strict;

# TODO use template param callback
sub xfrm_list_entries {
    my ( $cb, $app, $html_ref ) = @_;

    $$html_ref =~ s{(<th class="view"><span><__trans phrase="View"></span></th>)}{<th class="publish"><span>Pub.</span></th>$1}msg;

    my $html = <<"EOF";
<td class="publish"><mt:if name="status_publish"><a href="javascript:void(0)"><span><__trans phrase="Publish"></span></a></mt:if></td>
EOF

    $$html_ref =~ s{(<td class="view si status-view)}{$html$1}msg;
}

sub xfrm_header {
    my ( $cb, $app, $html_ref ) = @_;
    return unless $app->mode =~ /entry/;

    my $html = <<"EOF";
<link rel="stylesheet" href="<mt:var name="static_uri">plugins/AjaxPublish/css/app.css" type="text/css" />
<script src="<mt:var name="static_uri">plugins/AjaxPublish/js/jquery-1.4.2.min.js" type="text/javascript"></script>
<script src="<mt:var name="static_uri">plugins/AjaxPublish/js/jquery.qtip-1.0.min.js" type="text/javascript"></script>
<script src="<mt:var name="static_uri">plugins/AjaxPublish/js/app.js" type="text/javascript"></script>
<script type="text/javascript">
/* <![CDATA[ */
BlogID = <mt:var name="blog_id">;
PluginStaticURI = '<mt:var name="static_uri">plugins/AjaxPublish/';
/* ]]> */
</script>
EOF

    $$html_ref =~
s{</head>}{$html</head>}m;
}

sub rebuild_entry {
    my $app = shift;
    my $blog = $app->blog;
    my $return_val = {
        success => 0
    };
    my $entries = MT->model('entry')->lookup_multi([ $app->param('id') ]);
  ENTRY: for my $entry (@$entries) {
      next ENTRY if !defined $entry;
      next ENTRY if $entry->blog_id != $blog->id;
      
      MT->log({ blog_id => $blog->id,
                message => "Republishing '".$entry->title."' via AJAX" });
      $return_val->{success} = $app->rebuild_entry(
          Blog     => $blog,
          Entry    => $entry,
          Force    => 1,
      );
      unless ($return_val->{success}) {
          $return_val->{errstr} = $app->errstr;
      }
    }
    return _send_json_response( $app, $return_val );
}


sub _send_json_response {
    my ( $app, $result ) = @_;
    require JSON;
    my $json = JSON::objToJson($result);
    $app->send_http_header("");
    $app->print($json);
    return $app->{no_print_body} = 1;
    return undef;
}

1;
