=head1 B<Insteon::BaseLight>

=head2 DESCRIPTION

A generic base class for all Insteon lighting objects.

=head2 INHERITS

L<Insteon::BaseDevice|Insteon::BaseInsteon/Insteon::BaseDevice>

=head2 METHODS

=over

=cut

package Insteon::BaseLight;

use strict;
use Insteon::BaseInsteon;

@Insteon::BaseLight::ISA = ('Insteon::BaseDevice');

=item C<new()>

Instantiates a new object.

=cut

sub new
{
	my ($class,$p_deviceid,$p_interface) = @_;

	my $self = new Insteon::BaseDevice($p_deviceid,$p_interface);
	bless $self,$class;
        # include very basic states
        @{$$self{states}} = ('on','off');

	return $self;
}

=item C<level(p_level)>

Takes the p_level, and stores it as a numeric level in memory.

=cut

sub level
{
	my ($self, $p_level) = @_;
	if (defined $p_level) {
		my $level = 100;
		if ($p_level eq 'off')
		{
			$level = 0;
		}
		$$self{level} = $level;
	}
	return $$self{level};

}

=back

=head2 AUTHOR

Gregg Limming 

=head2 LICENSE

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=cut

=head1 B<Insteon::DimmableLight>

=head2 DESCRIPTION

A generic base class for all dimmable Insteon lighting objects.

=head2 INHERITS

L<Insteon::BaseLight|Insteon::Lighting/Insteon::BaseLight>

=head2 METHODS

=over

=cut

package Insteon::DimmableLight;

use strict;
use Insteon::BaseInsteon;

@Insteon::DimmableLight::ISA = ('Insteon::BaseLight');

my %message_types = (
	%SUPER::message_types,
	bright => 0x15,
	dim => 0x16
);

my %ramp_h2n = (
						'00' => 540,
						'01' => 480,
						'02' => 420,
						'03' => 360,
						'04' => 300,
						'05' => 270,
						'06' => 240,
						'07' => 210,
						'08' => 180,
						'09' => 150,
						'0a' => 120,
						'0b' =>  90,
						'0c' =>  60,
						'0d' =>  47,
						'0e' =>  43,
						'0f' =>  39,
						'10' =>  34,
						'11' =>  32,
						'12' =>  30,
						'13' =>  28,
						'14' =>  26,
						'15' =>  23.5,
						'16' =>  21.5,
						'17' =>  19,
						'18' =>   8.5,
						'19' =>   6.5,
						'1a' =>   4.5,
						'1b' =>   2,
						'1c' =>    .5,
						'1d' =>    .3,
						'1e' =>    .2,
						'1f' =>    .1
);

=item C<convert_ramp(ramp_seconds)>

Takes ramp_seconds in numeric seconds and returns the hexadecimal value of that 
ramp rate or the next lowest value if the passed value doesn't exist.  Possible
ramp rates are:

540, 480, 420, 360, 300, 270, 240, 210, 180, 150, 120, 90, 60, 47, 43, 39, 34, 
32, 30, 28, 26, 23.5, 21.5, 19, 8.5, 6.5, 4.5, 2, .5, .3, .2, and  .1

=cut

sub convert_ramp
{
	my ($ramp_in_seconds) = @_;
	if ($ramp_in_seconds) {
		foreach my $rampkey (sort keys %ramp_h2n) {
			return $rampkey if $ramp_in_seconds >= $ramp_h2n{$rampkey};
		}
	} else {
		return '1f';
	}
}

=item C<get_ramp_from_code(ramp_code)>

Takes ramp_code as a hexadecimal representation of the device's ramp rate and
returns the equivalent ramp rate in decimal seconds.

=cut

sub get_ramp_from_code
{
	my ($ramp_code) = @_;
	if ($ramp_code) {
		return $ramp_h2n{$ramp_code};
	} else {
		return 0;
	}
}

=item C<convert_level(on_level)>

Takes on_level as an integer percentage and converts it to a hexadecimal 
representation of that on_level that is used by a device.

=cut

sub convert_level
{
	my ($on_level) = @_;
	my $level = 'ff';
	if (defined ($on_level)) {
		$on_level =~ s/(\d+)%?/$1/;
		if ($on_level eq '100') {
			$level = 'ff';
		} elsif ($on_level eq '0') {
			$level = '00';
		} else {
			$level = sprintf('%02X',$on_level * 2.55);
		}
	}
	return $level;
}

=item C<new()>

Instantiates a new object.

=cut

sub new
{
	my ($class,$p_deviceid,$p_interface) = @_;

	my $self = new Insteon::BaseLight($p_deviceid,$p_interface);
	bless $self,$class;
	return $self;
}

=item C<level(p_level)>

Takes the p_level, and stores it as a numeric level in memory.  If the p_level 
is ON and the device has a defined local_onlevel, the local_onlevel is stored 
as the numeric level in memory.

=cut

sub level
{
	my ($self, $p_level) = @_;
	if (defined $p_level) {
		my $level = undef;
		if ($p_level eq 'on')
		{
			# set the level based on any locally defined on level
			$level = $self->local_onlevel if $self->can('local_onlevel');
			# set to 100 if a local on level is not defined
			$level=100 unless defined($level);
		} elsif ($p_level eq 'off')
		{
			$level = 0;
		} elsif ($p_level =~ /^([1]?[0-9]?[0-9])%?$/)
		{
			if ($1 < 1) {
				$level = 0;
			} else {
				$level = $1;
			}
		}
		$$self{level} = $level if defined $level;
	}
	return $$self{level};

}

=back

=head2 AUTHOR

Gregg Limming 

=head2 LICENSE

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=cut

=head1 B<Insteon::ApplianceLinc>

=head2 SYNOPSIS

User code:

    use Insteon::ApplianceLinc;
    $appliance_device = new Insteon::ApplianceLinc('12.34.56',$myPLM);

In mht file:

    INSTEON_APPLIANCELINC, 12.34.56, appliance_device, appliance_group

=head2 DESCRIPTION

Provides support for the Insteon ApplianceLinc.

=head2 INHERITS

L<Insteon::BaseLight|Insteon::Lighting/Insteon::BaseLight>

=head2 METHODS

=over

=cut

package Insteon::ApplianceLinc;

use strict;
use Insteon::BaseInsteon;

@Insteon::ApplianceLinc::ISA = ('Insteon::BaseLight');

=item C<new()>

Instantiates a new object.

=cut

sub new
{
	my ($class,$p_deviceid,$p_interface) = @_;

	my $self = new Insteon::BaseLight($p_deviceid,$p_interface);
	bless $self,$class;
	return $self;
}

=item C<set(state[,setby,response])>

Handles setting and receiving states from the device.

NOTE - Maybe this should be moved to BaseLight, or something farther up the stack?
The only thing this routine does is convert p_state with derive_link_state.

=cut

sub set
{
	my ($self, $p_state, $p_setby, $p_respond) = @_;

	my $link_state = &Insteon::BaseObject::derive_link_state($p_state);

	return $self->Insteon::BaseDevice::set($link_state, $p_setby, $p_respond);
}

=back

=head2 AUTHOR

Gregg Limming 

=head2 LICENSE

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=cut

=head1 B<Insteon::LampLinc>

=head2 SYNOPSIS

User code:

    use Insteon::LampLinc;
    $lamp_device = new Insteon::LampLinc('12.34.56',$myPLM);

In mht file:

    INSTEON_LAMPLINC, 12.34.56, lamp_device, All_Lights

=head2 DESCRIPTION

Provides support for the Insteon LampLinc.

=head2 INHERITS

L<Insteon::DimmableLight|Insteon::Lighting/Insteon::DimmableLight>, 
L<Insteon::DeviceController|Insteon::BaseInsteon/Insteon::DeviceController>

=head2 METHODS

=over

=cut

package Insteon::LampLinc;

use strict;
use Insteon::BaseInsteon;

@Insteon::LampLinc::ISA = ('Insteon::DimmableLight','Insteon::DeviceController');

=item C<new()>

Instantiates a new object.

=cut

sub new
{
	my ($class,$p_deviceid,$p_interface) = @_;

	my $self = new Insteon::DimmableLight($p_deviceid,$p_interface);
	bless $self,$class;
	return $self;
}

=back

=head2 AUTHOR

Gregg Limming 

=head2 LICENSE

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=cut

=head1 B<Insteon::SwitchLincRelay>

=head2 SYNOPSIS

User code:

    use Insteon::SwitchLincRelay;
    $light_device = new Insteon::SwitchLincRelay('12.34.56',$myPLM);

In mht file:

    INSTEON_SWITCHLINCRELAY, 12.34.56, light_device, All_Lights

=head2 DESCRIPTION

Provides support for the Insteon SwitchLinc Relay.

=head2 INHERITS

L<Insteon::BaseLight|Insteon::Lighting/Insteon::BaseLight>,
L<Insteon::DeviceController|Insteon::BaseInsteon/Insteon::DeviceController>

=head2 METHODS

=over

=cut

package Insteon::SwitchLincRelay;

use strict;
use Insteon::BaseInsteon;

@Insteon::SwitchLincRelay::ISA = ('Insteon::BaseLight','Insteon::DeviceController');

=item C<new()>

Instantiates a new object.

=cut

sub new
{
	my ($class,$p_deviceid,$p_interface) = @_;

	my $self = new Insteon::BaseLight($p_deviceid,$p_interface);
	bless $self,$class;
	return $self;
}

=item C<set(state[,setby,response])>

Handles setting and receiving states from the device.

NOTE - Maybe this should be moved to BaseLight, or something farther up the stack?
The only thing this routine does is convert p_state with derive_link_state.

=cut

sub set
{
	my ($self, $p_state, $p_setby, $p_respond) = @_;

	my $link_state = &Insteon::BaseObject::derive_link_state($p_state);

	return $self->Insteon::DeviceController::set($link_state, $p_setby, $p_respond);
}

=back

=head2 AUTHOR

Gregg Limming 

=head2 LICENSE

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=cut

=head1 B<Insteon::SwitchLinc>

=head2 SYNOPSIS

User code:

    use Insteon::SwitchLinc;
    $light_device = new Insteon::SwitchLinc('12.34.56',$myPLM);

In mht file:

    INSTEON_SWITCHLINC, 12.34.56, light_device, All_Lights

=head2 DESCRIPTION

Provides support for the Insteon SwitchLinc.

=head2 INHERITS

L<Insteon::DimmableLight|Insteon::Lighting/Insteon::DimmableLight>, 
L<Insteon::DeviceController|Insteon::BaseInsteon/Insteon::DeviceController>

=head2 METHODS

=over

=cut

package Insteon::SwitchLinc;

use strict;
use Insteon::BaseInsteon;

@Insteon::SwitchLinc::ISA = ('Insteon::DimmableLight','Insteon::DeviceController');

=item C<new()>

Instantiates a new object.

=cut

sub new
{
	my ($class,$p_deviceid,$p_interface) = @_;

	my $self = new Insteon::DimmableLight($p_deviceid,$p_interface);
	bless $self,$class;
	return $self;
}

=item C<set(state[,setby,response])>

Handles setting and receiving states from the device.

NOTE - This is just silly, the only thing this routine does is push the set 
command to the L<Insteon::DeviceController|Insteon::BaseInsteon/Insteon::DeviceController> 
class.  Simply reording the class 
inheritance of this object would remove the need to do this.

=cut

sub set
{
	my ($self, $p_state, $p_setby, $p_respond) = @_;

	return $self->Insteon::DeviceController::set($p_state, $p_setby, $p_respond);
}

=back

=head2 AUTHOR

Gregg Limming 

=head2 LICENSE

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=cut

=head1 B<Insteon::KeyPadLincRelay>

=head2 SYNOPSIS

User code:

    use Insteon::KeyPadLincRelay;
    $light_device = new Insteon::KeyPadLincRelay('12.34.56:01',$myPLM);
    $button1_device = new Insteon::KeyPadLincRelay('12.34.56:02',$myPLM);
    $button2_device = new Insteon::KeyPadLincRelay('12.34.56:03',$myPLM);

In mht file:

    INSTEON_KEYPADLINCRELAY, 12.34.56:01, light_device, All_Lights
    INSTEON_KEYPADLINCRELAY, 12.34.56:02, button1_device, All_Buttons
    INSTEON_KEYPADLINCRELAY, 12.34.56:03, button2_device, All_Buttons

=head2 DESCRIPTION

Provides support for the Insteon KeypadLinc Relay.

=head2 INHERITS

L<Insteon::BaseLight|Insteon::Lighting/Insteon::BaseLight>, 
L<Insteon::DeviceController|Insteon::BaseInsteon/Insteon::DeviceController>

=head2 METHODS

=over

=cut

package Insteon::KeyPadLincRelay;

use strict;
use Insteon::BaseInsteon;

@Insteon::KeyPadLincRelay::ISA = ('Insteon::BaseLight','Insteon::DeviceController');

=item C<new()>

Instantiates a new object.

=cut

sub new
{
	my ($class,$p_deviceid,$p_interface) = @_;

	my $self = new Insteon::BaseLight($p_deviceid,$p_interface);
	bless $self,$class;
	return $self;
}

=item C<set(state[,setby,response])>

Handles setting and receiving states from the device and specifically its 
subordinate buttons.

=cut

sub set
{
	my ($self, $p_state, $p_setby, $p_respond) = @_;

	my $link_state = &Insteon::BaseObject::derive_link_state($p_state);

	if (!($self->is_root))
	{
		my $rslt_code = $self->Insteon::BaseController::set($p_state, $p_setby, $p_respond);
		return $rslt_code if $rslt_code;

		if (ref $p_setby and $p_setby->isa('Insteon::BaseDevice'))
		{
			$self->Insteon::BaseObject::set($p_state, $p_setby, $p_respond);
		}
		elsif (ref $$self{surrogate} && ($$self{surrogate}->isa('Insteon::InterfaceController')))
		{
			$$self{surrogate}->set($link_state, $p_setby, $p_respond)
				unless ref $p_setby and $p_setby eq $self;
		}
		else
		{
			&::print_log("[Insteon::KeyPadLinc] You may not directly attempt to set a keypadlinc's button "
				. "unless you have defined a reverse link with the \"surrogate\" keyword");
		}
	}
	else
	{
		return $self->Insteon::DeviceController::set($link_state, $p_setby, $p_respond);
	}

	return 0;

}

=back

=head2 AUTHOR

Gregg Limming 

=head2 LICENSE

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=cut

=head1 B<Insteon::KeyPadLinc>

=head2 SYNOPSIS

User code:

    use Insteon::KeyPadLinc;
    $light_device = new Insteon::KeyPadLinc('12.34.56:01',$myPLM);
    $button1_device = new Insteon::KeyPadLinc('12.34.56:02',$myPLM);
    $button2_device = new Insteon::KeyPadLinc('12.34.56:03',$myPLM);

In mht file:

    INSTEON_KEYPADLINC, 12.34.56:01, light_device, All_Lights
    INSTEON_KEYPADLINC, 12.34.56:02, button1_device, All_Buttons
    INSTEON_KEYPADLINC, 12.34.56:03, button2_device, All_Buttons

=head2 DESCRIPTION

Provides support for the Insteon KeypadLinc.

=head2 INHERITS

L<Insteon::DimmableLight|Insteon::Lighting/Insteon::DimmableLight>, 
L<Insteon::DeviceController|Insteon::BaseInsteon/Insteon::DeviceController>

=head2 METHODS

=over

=cut

package Insteon::KeyPadLinc;

use strict;
use Insteon::BaseInsteon;

@Insteon::KeyPadLinc::ISA = ('Insteon::DimmableLight','Insteon::DeviceController');

=item C<new()>

Instantiates a new object.

=cut

sub new
{
	my ($class,$p_deviceid,$p_interface) = @_;

	my $self = new Insteon::DimmableLight($p_deviceid,$p_interface);
	bless $self,$class;
	return $self;
}

=item C<set(state[,setby,response])>

Handles setting and receiving states from the device and specifically its 
subordinate buttons.

NOTE: This could be merged somehow with the set() function in 
C<Insteon::KeyPadLincRelay>

=cut

sub set
{
	my ($self, $p_state, $p_setby, $p_respond) = @_;

	if (!($self->is_root))
	{
		my $rslt_code = $self->Insteon::BaseController::set($p_state, $p_setby, $p_respond);
		return $rslt_code if $rslt_code;

		my $link_state = &Insteon::BaseObject::derive_link_state($p_state);

		if (ref $p_setby and $p_setby->isa('Insteon::BaseDevice'))
		{
			$self->Insteon::BaseObject::set($p_state, $p_setby, $p_respond);
		}
		elsif (ref $$self{surrogate} && ($$self{surrogate}->isa('Insteon::InterfaceController')))
		{
			$$self{surrogate}->set($link_state, $p_setby, $p_respond)
				unless ref $p_setby and $p_setby eq $self;
		}
		else
		{
			&::print_log("[Insteon::KeyPadLinc] You may not directly attempt to set a keypadlinc's button "
				. "unless you have defined a reverse link with the \"surrogate\" keyword");
		}
	}
	else
	{
		return $self->Insteon::DeviceController::set($p_state, $p_setby, $p_respond);
	}

	return 0;

}

=back

=head2 AUTHOR

Gregg Limming 

=head2 LICENSE

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=cut

=head1 B<Insteon::FanLinc>

=head2 SYNOPSIS

User code:

    use Insteon::FanLinc;
    $light_device = new Insteon::FanLinc('12.34.56:01',$myPLM);
    $fan_device = new Insteon::FanLinc('12.34.56:02',$myPLM);

In mht file:

    INSTEON_FANLINC, 12.34.56:01, light_device, All_Lights
    INSTEON_FANLINC, 12.34.56:02, fan_device, All_Fans

=head2 DESCRIPTION

Provides support for the Insteon FanLinc.

=head2 INHERITS

L<Insteon::DimmableLight|Insteon::Lighting/Insteon::DimmableLight>, 
L<Insteon::DeviceController|Insteon::BaseInsteon/Insteon::DeviceController>

=head2 METHODS

=over

=cut

package Insteon::FanLinc;

use strict;
use Insteon::BaseInsteon;

@Insteon::FanLinc::ISA = ('Insteon::DimmableLight','Insteon::DeviceController');

=item C<new()>

Instantiates a new object.

=cut

sub new
{
	my ($class,$p_deviceid,$p_interface) = @_;
	my $self = new Insteon::DimmableLight($p_deviceid,$p_interface);
	bless $self,$class;
	return $self;
}

=item C<set(state[,setby,response])>

Handles setting and receiving states from the device and specifically its 
fan object.

=cut

sub set
{
	my ($self, $p_state, $p_setby, $p_respond) = @_;
	if ($self->is_root()){
		return $self->Insteon::DeviceController::set($p_state, $p_setby, $p_respond);
	} else {
		if ($self->_is_valid_state($p_state)) {
			# always reset the is_locally_set property unless set_by is the device
			$$self{m_is_locally_set} = 0 unless ref $p_setby and $p_setby eq $self;

			# handle invalid state for non-dimmable devices
			my $level = $p_state;
			if ($p_state eq 'dim' or $p_state eq 'bright') {
				$p_state = 'on';
			}
			elsif ($p_state eq 'toggle')
			{
				$p_state = 'off' if ($self->state eq 'on');
				$p_state = 'on' if ($self->state eq 'off');
			}
			$level = '00' if ($p_state eq 'off');
			$level = 'ff' if ($p_state eq 'on');
			# Setting Fan Level
			my $setby_name = $p_setby;
			$setby_name = $p_setby->get_object_name() if (ref $p_setby and $p_setby->can('get_object_name'));
			my $parent = $self->get_root();
			$level = ::Insteon::DimmableLight::convert_level($level) if ($level ne '00' && $level ne 'ff');
			my $extra = $level ."0200000000000000000000000000";
			my $message = new Insteon::InsteonMessage('insteon_ext_send', $parent, 'on', $extra);
			$parent->_send_cmd($message);
			::print_log("[Insteon::FanLinc] " . $self->get_object_name() . "::set($p_state, $setby_name)")
				if $main::Debug{insteon};
			$self->is_acknowledged(0);
			$$self{pending_state} = $p_state;
			$$self{pending_setby} = $p_setby;
			$$self{pending_response} = $p_respond;
			$$parent{child_pending_state} = $self->group();
		} else {
			::print_log("[Insteon::FanLinc] failed state validation with state=$p_state");
		}	
	}
}

=item C<request_status()>

Will request the status of the device.  For the light device, the process is 
handed off to the L<Insteon::BaseObject::request_status()|Insteon::BaseInsteon/Insteon::BaseObject> routine.  This routine
specifically handles the fan request.

=cut

sub request_status
{
	my ($self,$requestor) = @_;
	if ($self->is_root()){
		return $self->SUPER::request_status($requestor);
	} else {
		# Setting Fan Level
		my $parent = $self->get_root();
		$$parent{child_status_request_pending} = $self->group;
		$$self{m_status_request_pending} = ($requestor) ? $requestor : 1;
		my $message = new Insteon::InsteonMessage('insteon_send', $parent, 'status_request', '03');
		$parent->_send_cmd($message);
	}
}

=item C<_is_info_request()>

Handles incoming messages from the device which are unique to the FanLinc, 
specifically this handles the C<request_status()> response for the Fan device, 
all other responses are handed off to the C<Insteon::BaseObject::request_status()>.

=cut

sub _is_info_request
{
	my ($self, $cmd, $ack_setby, %msg) = @_;
	my $is_info_request = 0;
	my $parent = $self->get_root();
	if ($$parent{child_status_request_pending}) {
		$is_info_request++;
		my $child_obj = Insteon::get_object($self->device_id, '02');
		my $child_state = &Insteon::BaseObject::derive_link_state(hex($msg{extra}));
		&::print_log("[Insteon::FanLinc] received status for " .
			$child_obj->{object_name} . " of: $child_state "
			. "hops left: $msg{hopsleft}") if $main::Debug{insteon};
		$ack_setby = $$child_obj{m_status_request_pending} if ref $$child_obj{m_status_request_pending};
		$child_obj->SUPER::set($child_state, $ack_setby);
		delete($$parent{child_status_request_pending});
	} else {
		$is_info_request = $self->SUPER::_is_info_request($cmd, $ack_setby, %msg);
	}
	return $is_info_request;
}

=item C<is_acknowledged()>

Handles command acknowledgement messages received from the device that are 
unique to the FanLinc, specifically the acknowledgement of commands sent to the
fan device.  All other instances are handed off to the C<Insteon::BaseObject>.

=cut

sub is_acknowledged
{
	my ($self, $p_ack) = @_;
	my $parent = $self->get_root();
        if ($p_ack && $$parent{child_pending_state})
        {
        	my $child_obj = Insteon::get_object($self->device_id, '02');
		$child_obj->set_receive($$child_obj{pending_state},$$child_obj{pending_setby}, $$child_obj{pending_response}) if defined $$child_obj{pending_state};
		$$child_obj{is_acknowledged} = $p_ack;
		$$child_obj{pending_state} = undef;
		$$child_obj{pending_setby} = undef;
		$$child_obj{pending_response} = undef;
		$$parent{child_pending_state} = undef;
		&::print_log("[Insteon::FanLinc] received command/state acknowledge from " . $child_obj->{object_name}) if $main::Debug{insteon};
		return $$self{is_acknowledged};
	} else {
		return $self->SUPER::is_acknowledged($p_ack);
	}
}

=back

=head2 AUTHOR 

Kevin Robert Keegan 

=head2 LICENSE

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=cut

1