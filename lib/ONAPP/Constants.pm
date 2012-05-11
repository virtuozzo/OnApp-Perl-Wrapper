#!/usr/bin/perl
#####################################################
#Author:Andrew Yatskovets
#This is a base OnApp server perl wrapper constants
#that uses to manipulate OnApp server data
#####################################################
package ONAPP::Constants;

use strict; #Normally use to keep data clean

use constant ONAPP_DEFAULT_PORT          => 80;
use constant ONAPP_LWP_USERAGENT_TIMEOUT => 6;
use constant ONAPP_OPTION_API_TYPE       => 'xml';

use constant ONAPP_GETRESOURCE_VERSION => 'version';
use constant ONAPP_GETRESOURCE_LOAD    => 'load';
use constant ONAPP_GETRESOURCE_LIST    => 'list';
use constant ONAPP_GETRESOURCE_ADD     => 'add';
use constant ONAPP_GETRESOURCE_EDIT    => 'edit';
use constant ONAPP_GETRESOURCE_DELETE  => 'delete';
use constant ONAPP_GETRESOURCE_DEFAULT => 'default';

use constant ONAPP_ACTIVATE_LIST       => 'list';
use constant ONAPP_ACTIVATE_LOAD       => 'load';
use constant ONAPP_ACTIVATE_SAVE       => 'save';
use constant ONAPP_ACTIVATE_DELETE     => 'delete';

use constant ONAPP_IS_GETTER => 1;
use constant ONAPP_IS_SETTER => 2;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
@ISA = qw(Exporter);

@EXPORT = qw(
    ONAPP_DEFAULT_PORT
    ONAPP_LWP_USERAGENT_TIMEOUT 
    ONAPP_OPTION_API_TYPE

    ONAPP_ACTIVATE_LIST ONAPP_ACTIVATE_LOAD ONAPP_ACTIVATE_SAVE ONAPP_ACTIVATE_DELETE

    ONAPP_GETRESOURCE_VERSION ONAPP_GETRESOURCE_LOAD ONAPP_GETRESOURCE_LIST
    ONAPP_GETRESOURCE_ADD ONAPP_GETRESOURCE_EDIT ONAPP_GETRESOURCE_DELETE 
    ONAPP_GETRESOURCE_DEFAULT
);

@EXPORT_OK = @EXPORT;

1;

