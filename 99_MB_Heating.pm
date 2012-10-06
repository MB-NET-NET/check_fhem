#
# 99_MB_Heating.pm
#
# 2012-10-01	Michael Bussmann <support@mb-net.net>
#		http://mb-net.net/
#

package main;

use strict;
use warnings;
use POSIX;

sub
MB_Heating_Initialize($$)
{
  my ($hash) = @_;
}

my $thres_heat	= 15;
my $thres_off	= 9;

sub check_heating($$@)
{
	my ($dummy, $actor, @FHTs) = @_;

	my $waermebedarf = 0;
	my $temp_low = 0;
	my $leerlauf = 0;

	my $ventil_summe = 0;

	# Abfrage aller Aktuatoren
	foreach(@FHTs) {

		# Extrahieren des Readings
		my $ventil=ReadingsVal($_, "actuator", "101%");
		$ventil=(substr($ventil, 0, (length($ventil)-1)));
		my $desired=ReadingsVal($_, "desired-temp", "20");
		my $measured=ReadingsVal($_, "measured-temp", "20");
		$measured=(substr($measured, 0, (length($measured)-10)));	# XXX: FIXME

		Log 3, "MB_Heating: FHT $_: A=$ventil D=$desired M=$measured";

		$ventil_summe+=$ventil;

		# Wärmebedarf: Ventilstellung>$thres oder Tempdiff>0.6 C
		if ( ($ventil >= $thres_heat) || (($desired-$measured)>0.6) ) {
			$waermebedarf++;
		}
		if ( ($ventil < $thres_off)) {
			$leerlauf++;
		}
	}	# foreach

	Log 1,"MB_Heating: Wärmeanforderung: ${waermebedarf}, Leerlauf: ${leerlauf}, VS=${ventil_summe}";

	# Steuerbefehl für Heizung
	if (($waermebedarf>0) || ($ventil_summe>35)) {
		Log 3, "MB_Heating: Signalisiere Wärmeanforderung";

		fhem("set $dummy on");
	} else {
		# Heizung abschalten, wenn alle Ventile im Leerlauf.
		if (($leerlauf == @FHTs) || ($ventil_summe<7)) {
			Log 3,"MB_Heating: Keine Wärme (mehr) benoetigt.";
			fhem("set $dummy off");
		} else {
			Log 3,"MB_Heating: $leerlauf of " . @FHTs . " actuators are idle.";
			# Send last state
			if (Value("$dummy") eq "on") {
				fhem("set $dummy on")
			} else {
				fhem("set $dummy off")
			}
		}	# ELSE leerlauf
	}	# ELSE wärmebedarf
}	# check_heating

1;
