package ONAPP::Console;

use ONAPP::Constants;
use XML::Simple;
use strict;

use constant SETTINGS => {
    resource => '/remote_access_session',
    root_tag => 'remote_access_session',
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
            'id' => {
                field     => '_id',
                read_only => 1
            },
            'called_in_at' => {
                field     => '_called_in_at',
                read_only => 1
            },
            'created_at' => {
                field     => '_created_at',
                read_only => 1
            },
            'port' => {
                field     => '_port',
                read_only => 1
            },
            'updated_at' => {
                field     => '_updated_at',
                read_only => 1
            },
            'virtual_machine_id' => {
                field     => '_virtual_machine_id',
                read_only => 1,
            },
            'remote_key' => {
                field     => '_remote_key',
                read_only => 1,
            },
        };

        return $fields;
    }
}

sub load {
    my $class = shift;
    
    $class->__activate( action => ONAPP_ACTIVATE_LOAD );
    
    my %h = (
        vm_id => undef,
        @_
    );  
    
    $class->{__vm_id} = $h{'vm_id'} || die "Can't get a Virtual Machine ID (vm_id)";
    
    $class->{__ua} = $class->__send_request(
        resource => $class->__get_controller( action => ONAPP_GETRESOURCE_LOAD ),
        method   => 'GET',
    );  
    
    if ($class->{__ua}->{_rc} eq '200') {
        my $content = $class->{__ua}->content();
        
        my $xml = new XML::Simple;
        
        my $data = $xml->XMLin($content);
        
        while ( my ($key, $value) = each(%{$data})) {
        
            my $content = undef;
            if ( ref $value eq 'HASH' ) {
                my %value = %{$value};
                $content = $value{content};
            } else {
                $content = $value;
            };  

            $class->{__values}->{"$key"} = $content;
        };

        $class->{__is_load} = 1;

        return 1;
    };

    return undef;
}

sub __activate {
    my $class = shift;

    my %h = (
        action => undef,
        @_
    );

    my $action  = $h{'action'};

    my @methods = (ONAPP_ACTIVATE_LIST, ONAPP_ACTIVATE_SAVE, ONAPP_ACTIVATE_DELETE);

    if ( grep {  $_ eq $action } @methods ) {
        die "Can't locate object method '$h{'action'}' via package \"ONAPP::Console\"";
    };
}

sub __get_controller {
    my $class = shift;

    my %h = (
        action => ONAPP_GETRESOURCE_DEFAULT,
        @_
    );

    my $action = $h{'action'};
    my $resource;

    if ( $action eq ONAPP_GETRESOURCE_LOAD ) {
        $resource = "/virtual_machines/" . $class->{__vm_id} . "/console".".".ONAPP_OPTION_API_TYPE;
    } else {
        $resource = $class->SUPER::__get_controller(@_);
    };

    return $resource;
}

1;
