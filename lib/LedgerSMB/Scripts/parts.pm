=head1 NAME

LedgerSMB::Scripts::parts

=cut

package LedgerSMB::Scripts::parts;
use strict;
use warnings;
use CGI::Simple;

use LedgerSMB::Part;
use LedgerSMB::REST_Format::json;

=head1 FUNCTIONS

=head2 partslist_json

Returns the part list in json

Minimal information is returned:

=over

=item id

=item partnumber

=item description

=item list_price

=item last_cost

=item sell_price

=item tax_accnos

=back

=cut

sub partslist_json {
    my ($request) = @_;
    $request->{partnumber} =~ s/\*//g if $request->{partnumber};
    my $type = $request->{type} // '';
    my $items = [ LedgerSMB::Part->basic_partslist(
                      partnumber => $request->{partnumber},
                      description => $request->{description}) ];
    @$items =
        grep { (! $type) ||
                   ($type eq 'sales' && $_->{income_accno_id}) ||
                   ($type eq 'purchase' && $_->{expense_accno_id}) }
        grep { ! $_->{obsolete} }
        map { $_->{label} = $_->{partnumber} . '--' . $_->{description}; $_ }
        @$items;
    my $json = LedgerSMB::REST_Format::json->to_output($items);
    my $cgi = CGI::Simple->new();
    binmode STDOUT, ':raw';
    print $cgi->header('application/json;charset=UTF-8', '200 Success');
    $cgi->put($json);
}

1;
