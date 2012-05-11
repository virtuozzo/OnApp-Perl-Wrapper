#!/usr/bin/perl
#####################################################
# Author:Andrew Yatskovets
# This is a base OnApp server perl wrapper class that
# uses to manipulate OnApp server data
#####################################################

package ONAPP::VirtualMachine;

use constant SETTINGS => {
    resource => '/virtual_machines',
    root_tag => 'virtual-machine',
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
                read_only => 1,
            },
            'booted' => {
                field     => '_booted',
                read_only => 1,
            },
            'built' => {
                field     => '_built',
                read_only => 1,
            },
            'cpu_shares' => {
                field     => '_cpu_shares',
                reqired   => 1,
                default   => '0',
            },
            'cpus' => {
                field     => '_cpus',
                reqired   => 1,
                default   => 0,
              },
            'created_at' => {
                field     => '_created_at',
                read_only => 1,
            },
            'hostname' => {
                field     => '_hostname',
                reqired   => 1,
            },
              'hypervisor_id' => {
                field     => '_hypervisor_id',
                reqired   => 1,
                default   => '0',
            },
            'identifier' => {
                field     => '_identifier',
                read_only => 1,
            },
            'initial_root_password' => {
                field     => '_initial_root_password',
                reqired   => 1,
                default   => ''
            },
            'label' => {
                field     => '_label',
                reqired   => 1,
            },
            'local_remote_access_port' => {
                field     => '_local_remote_access_port',
                read_only => 1,
            },
            'locked' => {
                field     =>'_locked',
                read_only => 1,
            },
            'memory' => {
                field     => '_memory',
                reqired   => 1,
                default   => 256
            },
            'recovery_mode' => {
                field     => '_recovery_mode',
                read_only => 1,
            },
            'remote_access_password' => {
                field     => '_remote_access_password',
                read_only => 1,
            },
            'template_id' => {
                field     => '_template_id',
                reqired   => 1,
                default   => ''
            },
            'user_id' => {
                field     => '_user_id',
                read_only => 1,
            },
            'xen_id' => {
                field     => '_xen_id',
                read_only => 1,
            },
            'allowed_swap' => {
                field     => '_allowed_swap',
                read_only => 1,
            },
            'allow_resize_without_reboot' => {
                field     => '_allow_resize_without_reboot',
                read_only => 1,
            },
            'ip_addresses' => {
                field     => '_ip_addresses',
                read_only => 1,
                class     => 'IpAddress',
            },
            'min_disk_size' => {
                field     => '_min_disk_size',
                read_only => 1,
            },
            'monthly_bandwidth_used' => {
                field     => '_monthly_bandwidth_used',
                read_only => 1,
            },
            'operating_system' => {
                field     => '_operating_system',
                read_only => 1,
            },
            'operating_system_distro' => {
                field     => '_operating_system_distro',
                read_only => 1,
            },
            'template_label' => {
                field     => '_template_label',
                read_only => 1,
            },
            'total_disk_size' => {
                field     => '_total_disk_size',
                read_only => 1,
            },
        };
=pub
        if ( is_null($this->_id) ) {
            $this->_fields["primary_disk_size"] = {
                field           => '_primary_disk_size',

                reqired      => 1,
                default   => 1
            );
            $this->_fields["swap_disk_size"] = {
                field           => '_swap_disk_size',

                reqired      => 1,
                default   => 0
            );
            $this->_fields["primary_network_id"] = {
                field           => '_primary_network_id',

                reqired      => 1,
                default   => ''
            );
            $this->_fields["required_automatic_backup"] = {
                field           => '_required_automatic_backup',

                reqired      => 1,
                default   => ''
            );
            $this->_fields["rate_limit"] = {
                field           => '_rate_limit',

                reqired      => 1,
                default   => ''
            );
            $this->_fields["required_ip_address_assignment"] = {
                field           => '_required_ip_address_assignment',

                reqired      => 1,
                default   => ''
            );
            $this->_fields["required_virtual_machine_build"] = {
                field           => '_required_virtual_machine_build',

                reqired      => 1,
                default   => ''
            );
        };

      };
=cut
      return $fields;

    }
}

1;
