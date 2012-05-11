package ONAPP::BillingPlan;

use strict;

use constant SETTINGS => {
    resource => '/billing_plans',
    root_tag => 'billing-plan',
};

use vars qw(@ISA);

require ONAPP;
@ISA = qw(ONAPP);

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);

    $self->{__resource} = &SETTINGS->{'resource'};
    $self->{__root_tag} = &SETTINGS->{'root_tag'};

    return $self;
}

sub __init_fields {
    my $class = shift;
                
    my %h = (   
        version => undef
        @_  
    );      
                
    my $version = $h{'version'} || $class->{__version};
    my $fields;

    if ( $version =~ /^2\.[0|1]\..*$/ ) {
        $fields = {
            'id' => array(
                field     => '_id',
                read_only => 1,
            ),
            'label' => array(
                field     => '_label',
                default   => ''
            ),
            'created_at' => array(
                field     => '_created_at',
                read_only => 1
            ),
            'updated_at' => array(
                field     => '_updated_at',
                read_only => 1
            ),
            'currency_code' => array(
                field     => '_currency_code',
                reqired   => 1,
                read_only => 1,
            ),
            'show_price' => array(
                field     => '_show_price',
                reqired   => 1,
                default   => 1,
                read_only => 1
            )
        };

        return $fields;
    }
}

1;
