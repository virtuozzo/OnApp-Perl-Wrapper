package ONAPP;

our $VERSION = '0.10';

=head1 NAME

    ONAPP - Easy OnApp API wrapper to maintain OnApp server

=head1 SYNOPSIS

    package ONAPP::OnAppControler;
    
    use vars qw(@ISA);

    require ONAPP;
    @ISA = qw(ONAPP);

    sub new {
        my $class = shift;

        my $self = $class->SUPER::new(@_);

        $self->{__resource} = &SETTINGS->{'url_alias'};
        $self->{__root_tag} = &SETTINGS->{'xml_or_json_root_tag'};

        return $self;
    }

    sub __init_fields {
        return {
            field1 => { ## getter
                field     => '_field1',
                read_only => 1,
            },
            field2 => { ## getter and setter
                field     => '_field2',
            },
            field3 => { ## getter, setter and reqired
                field     => '_field3',
                reqired   => 1,
            },
        }
    }

    1;

=cut

# See after __END__ for more POD documentation

use JSON qw/jsonToObj objToJson/;
use XML::Simple;
#use HTTP::Request;
use HTTP::Request::Common qw(DELETE GET POST PUT);
use LWP::UserAgent;
use HTTP::Status;

use ONAPP::Constants;

use strict;
use Data::Dumper;

sub AUTOLOAD {
    our $AUTOLOAD;

    my $class  = shift;
    my $value  = shift;
    my $method;

    my $fields =  $class->__init_fields();
    $method = $1 if ($AUTOLOAD =~ /^.*::(\w+)$/);

    if( $fields && (grep { $_ eq $method} keys %{$fields}) && 
        ( ! $value || ($value && ! $fields->{$method}->{'read_only'} ) )
    ) {
        if ($value) { ## setter
            return $class->{__values}->{$method} = $value;
        } else {      ## getter
            return $class->{__values}->{$method};
        };
    } else {
        $method = "SUPER::$method";
        return $class->$method(@_);
    };
}

sub new {
    my $class = shift;

    my %h = (
        adress   => undef,
        port     => ONAPP_DEFAULT_PORT,
        username => undef,
        password => undef,
##        proxy    => undef,
        timeout  => ONAPP_LWP_USERAGENT_TIMEOUT,
        @_
    );

    my $self = {
        __adress   => $h{'adress'},
        __port     => $h{'port'},
        __username => $h{'username'},
        __password => $h{'password'},
        __timeout  => $h{'timeout'},
    };

    bless $self, $class;

    ## get version

    $self->{__version} = $self->__get_version();

    ## show error if something wrong

    if ( $self->{__version} ne "" ) {
        $self->{__is_auth} = 1;
    };

    return $self;
}

sub clone {
    my $self = shift;
    my $copy;

    foreach my $key ( grep { $_ ne '__ua' && $_ ne '__values'}  keys %$self ) {
        $copy->{$key} = $self->{$key};
    }

    bless $copy, ref $self;
}

sub __get_version {
    my $class = shift;

    $class->{__ua} = $class->__send_request(
        resource => $class->__get_controller( action => ONAPP_GETRESOURCE_VERSION ),
        method   => 'POST',
    );

    if ($class->{__ua}->{_rc} eq '200') {
        return $class->{__ua}->content();
    } else {
        $class->{__ua} = $class->__send_request(
            resource => $class->__get_controller( action => ONAPP_GETRESOURCE_VERSION ).".".ONAPP_OPTION_API_TYPE,
            method   => 'POST',
        );

        if ($class->{__ua}->{_rc} eq '200') {
            return $class->{__ua}->content();
        } else {
            return undef;
        };
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

    if ( $action eq ONAPP_GETRESOURCE_DEFAULT ) {
        $resource = $class->{__resource};
    } elsif ( $action eq ONAPP_GETRESOURCE_VERSION ) {
        $resource = $class->__get_controller()."/version";
    } elsif( scalar grep {$_ eq $action} (ONAPP_GETRESOURCE_LOAD, ONAPP_GETRESOURCE_EDIT, ONAPP_GETRESOURCE_DELETE) ) {
        $resource = $class->__get_controller()."/". $class->{__id}.".".ONAPP_OPTION_API_TYPE;
    } elsif ( scalar grep {$_ eq $action} (ONAPP_GETRESOURCE_LIST, ONAPP_GETRESOURCE_ADD) ) {
        $resource = $class->__get_controller().".".ONAPP_OPTION_API_TYPE;
    } else {
        $class->{__error} = "OnApp PERL wrapper don't support controller $action";
    };

    return $resource;
}

sub __send_request {
    my $class = shift;

    my %h = (
        resource => undef,
        method   => undef,
        data     => undef,
        @_
    );

    my $req;
    my $method = $h{'method'};
    my $data   = $h{'data'};

    my $ua = LWP::UserAgent->new;
    $ua->timeout($class->{__timeout});

    if ( $method eq 'POST') {
        $req = POST $class->{__adress}.":".$class->{__port}.$h{resource};
        $req->content($data);
        $req->header('Content-Length' => length($data)) unless ref($data);
        $req->content_type("text/xml; charset=utf-8");
    } elsif ( $method eq 'GET' ) {
        $req = GET $class->{__adress}.":".$class->{__port}.$h{resource};
    } elsif ( $method eq 'PUT' ) {
        $req = PUT $class->{__adress}.":".$class->{__port}.$h{resource};
        $req->content($data);
        $req->content_type("text/xml; charset=utf-8");
    } elsif ( $method eq 'DELETE' ) {
        $req = DELETE $class->{__adress}.":".$class->{__port}.$h{resource};
    };

    if ( ! $class->{__error} ) {

        $req->authorization_basic(
            $class->{__username},
            $class->{__password}
        );

        return $ua->request($req);
    };
}

sub __activate{ }

sub save {
    my $class = shift;

    $class->__activate( action => ONAPP_ACTIVATE_SAVE );

    return $class->{__is_load} ? $class->__edit(@_) : $class->__create(@_);
}

sub __get_required_data {
    my $class  = shift;

    my %h = (
        action => undef,
        @_
    );

    my $fields =  $class->__init_fields( action => $h{'action'});
    my ($result, $data);

    foreach my $field ( grep { $fields->{$_}->{'reqired'} }  keys %{$fields} ) {
        $data->{$field} = $class->{__values}->{$field} 
            || $fields->{$field}->{'default'}; 
    };

    my $xml = new XML::Simple;

    $result = $xml->XMLout(
        $data,
        noattr   => 1,
        RootName => $class->{__root_tag},
    );

    return $result;
}

sub __create {
    my $class = shift;

    $class->{__ua} = $class->__send_request(
        resource => $class->__get_controller( action => ONAPP_GETRESOURCE_ADD ) ,
        data     => $class->__get_required_data( action => ONAPP_GETRESOURCE_ADD ),
        method   => 'POST',
    );

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

    if ($class->{__ua}->{_rc} eq '200') {
        $class->{__is_load} = 1;
    };
}

sub __edit {
    my $class = shift;

    $class->{__ua} = $class->__send_request(
        resource => $class->__get_controller( action => ONAPP_GETRESOURCE_EDIT ) , 
        data     => $class->__get_required_data( action => ONAPP_GETRESOURCE_EDIT ),
        method   => 'PUT',
    );
}

sub load {
    my $class = shift;

    $class->__activate( action => ONAPP_ACTIVATE_LOAD );

    my %h = (
        id => undef,
        @_
    );

    $class->{__id} = $class->{__values}->{'id'}  || $h{'id'};

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

sub delete {
    my $class = shift;

    $class->__activate( action => ONAPP_ACTIVATE_DELETE );

    $class->{__ua} = $class->__send_request(
        resource => $class->__get_controller( action => ONAPP_GETRESOURCE_DELETE ),
        method   => 'DELETE',
    );

    if ($class->{__ua}->{_rc} eq '200') {
        $class->{__is_ideleted} = 1;
    };

    return $class->{__ua}->{_rc};
}

sub list {
    my $class = shift;

    $class->__activate( action => ONAPP_ACTIVATE_LIST );

    my @return;

    $class->{__ua} = $class->__send_request(
        resource => $class->__get_controller( action => ONAPP_GETRESOURCE_LIST ),
        method   => 'GET',
    );

    if ($class->{__ua}->{_rc} eq '200') {

        my $content = $class->{__ua}->content();
        my $xml = new XML::Simple;
        my $data = $xml->XMLin($content);

        foreach my $item ( @{$data->{ $class->{__root_tag} }} ) {
            my $obj = $class->clone();

            while ( my ($key, $value) = each(%{$item})){

                my $content = undef;
                if ( ref $value eq 'HASH' ) {
                    my %value = %{$value};
                    $content = $value{content};
                } else {
                    $content =  $value;
                };

                $obj->{__values}->{"__$key"} = $content;
            };

            push(@return, $obj);
        };
    };

    return @return;
}

1;

__END__

=head1 DESCRIPTION

This module provides an interface that allows OnApp classes creation
using this base class

=head1 SEE ALSO

	<ONAPP::BillingPlan>
	L<ONAPP::Console>,
	L<ONAPP::DataStore>,
	L<ONAPP::Disk>,
	L<ONAPP::Group>,
	L<ONAPP::Hypervisor>,
	L<ONAPP::IpAddress>,
	L<ONAPP::Nameserver>,
	L<ONAPP::Network>,
	L<ONAPP::Payment>,
	L<ONAPP::ResourceLimit>,
	L<ONAPP::Role>,
	L<ONAPP::Template>,
	L<ONAPP::Transaction>,
	L<ONAPP::UsageStatistic>,
	L<ONAPP::User>,
	L<ONAPP::VirtualMachine>,

=head1 AUTHOR

Andrew Yatskovets <ayatsk@onapp.com>
