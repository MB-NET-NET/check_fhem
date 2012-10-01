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

my $thres_heat	= 25;
my $thres_off	= 15;

sub check_heating($$@)
{
	my ($dummy, $actor, @FHTs) = @_;

	my $waermebedarf = 0;
	my $leerlauf = 0;

	# Kopieren aller Werte der Raumthermostaten in das Array @FHTs
	###my @FHTs=devspec2array("model=HM-CC-TC");

	# Abfrage aller Aktuatoren
	foreach(@FHTs) {

		# Extrahieren des Ventilstandes
		my $ventil=ReadingsVal($_, "actuator", "101%");
		$ventil=(substr($ventil, 0, (length($ventil)-1)));

		Log 3, "MB_Heating: FHT $_: Ventilstellung $ventil";

		if ($ventil >= $thres_heat) {
			$waermebedarf++;
		}

		if ($ventil < $thres_off) {
			$leerlauf++;
		}
	}	# foreach

	Log 1,"MB_Heating: Wärmeanforderung: ${waermebedarf}, Leerlauf: $leerlauf";

	# Steuerbefehl für Heizung
	if ($waermebedarf>0) {
		Log 3, "MB_Heating: Signalisiere Wärmeanforderung";

		fhem("set $dummy on");
	} else {
		# Heizung abschalten, wenn alle Ventile im Leerlauf.
		if ($leerlauf == @FHTs) {
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
