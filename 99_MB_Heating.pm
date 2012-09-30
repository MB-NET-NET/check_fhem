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

my $thres_heat	= 20;
my $thres_off	= 10;

sub check_heating($$@)
{
	my ($dummy, $actor, @FHTs) = @_;

	# Start des Heizungsprogramms
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

		# Entscheidung ob Wärme benötigt wird (Ja, wenn mindestens
		# ein Ventil mehr als $thres_heat geöffnet ist)
		if ($ventil >= $thres_heat) {
			$waermebedarf++;
		}

		# Hysterese zur Abschaltung der Heizung (Heizung aus,
		# wenn alle Ventile weniger als $thres_off geöffnet sind)
		if ($ventil < $thres_off) {
			$leerlauf++;
		}
	}	# foreach

	Log 1,"MB_Heating: Waermebedarf: ${waermebedarf}, Leerlauf: $leerlauf";

	# Steuerbefehl für Heizung
	if ($waermebedarf>0) {
		Log 3, "MB_Heating: Signalisiere Waermebedarf an Heizung";

		# fhem("set $actor On");
		fhem("set $dummy on");
	} else {
		# Heizung abschalten, wenn alle Ventile im Leerlauf.
		if ($leerlauf == @FHTs) {
			Log 3,"MB_Heating: Keine Wärme (mehr) benoetigt.";

			# fhem("set $actor output Heizung Off");
			fhem("set $dummy off");
		} else {
			Log 3,"MB_Heating: Heizbedarf: $leerlauf of " . @FHTs . " actuators are idle.";
		}	# ELSE leerlauf
	}	# ELSE wärmebedarf

	#
	# Regelmaessige Updates des logfiles
	#
#	if (Value("$dummy") eq "on") {
#		fhem("set $dummy on")
#	} else {
#		fhem("set $dummy off")
#	}
}	# check_heating

1;
