#
# 99_MB_Heating.pm
#
# 2012-10-01	Michael Bussmann <support@mb-net.net>
#		http://mb-net.net/
#

my $thres_heat	= 20;
my $thres_off	= 10;

sub check_heating_1()
{
	# Start des Heizungsprogramms
	my $waermebedarf = 0;
	my $leerlauf = 0;

	# Kopieren aller Werte der Raumthermostaten in das Array @FHTs
	my @FHTs=devspec2array("model=HM-CC-TC");

	# Abfrage aller Aktuatoren
	foreach(@FHTs) {

		# Extrahieren des Ventilstandes
		my $ventil=ReadingsVal($_, "actuator", "101%");
		$ventil=(substr($ventil, 0, (length($ventil)-1)));

		# Entscheidung ob W�rme ben�tigt wird (Ja, wenn mindestens
		# ein Ventil mehr als $thres_heat ge�ffnet ist)
		if ($ventil >= $thres_heat) {
			$waermebedarf++;
		}

		# Hysterese zur Abschaltung der Heizung (Heizung aus,
		# wenn alle Ventile weniger als $thres_off ge�ffnet sind)
		if ($ventil < $thres_off) {
			$leerlauf++;
		}
	}	# foreach

	Log 1,"MB_Heating: Waermebedarf: ${waermebedarf}, Leerlauf: $leerlauf";

	# Steuerbefehl f�r Heizung
	if ($waermebedarf>0) {
		Log 3, "MB_Heating: Signalisiere Waermebedarf an Heizung";

		# fhem("set <1wire> On");
		fhem("set EG_HEATING on");
	} else {
		# Heizung abschalten, wenn alle Ventile im Leerlauf.
		if ($leerlauf == @FHTs) {
			Log 3,"MB_Heating: Keine W�rme (mehr) benoetigt.";

			# fhem("set <1wire> output Heizung Off");
			fhem("set EG_HEATING off");
		} else {
			Log 3,"MB_Heating: Heizbedarf: $leerlauf of " . @FHTs . " actuators are idle.";
		}	# ELSE leerlauf
	}	# ELSE w�rmebedarf

	#
	# Regelmaessige Updates des logfiles
	#
	if (Value("EG_HEATING") eq "on") {
		fhem("set EG_HEATING on")
	} else {
		fhem("set EG_HEATING off")
	}
}	# check_heating_1

