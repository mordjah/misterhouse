# From Nicholas Brink:
#
#    Several months ago somebody was looking for code to control the cd 
#player.  I started the beginings of the following code that would control the
# cda player written by Ti Kan.  With the touch of a button I can start or stop 
#the player, mute, or change tracks.  My knowledge of perl is extrealmy limited 
#so if anyone can improve upon and finish the following please let me know.

my $cd_path ="/usr/bin/X11/cda";
#process items to control the cda and Xmcd by Ti Kan
$cd_player = new Process_Item;

    $cd_on    = new Process_Item("$cd_path on");
    $cd_off   = new Process_Item("$cd_path off");
    $cd_load  = new Process_Item("$cd_path disc load");
    $cd_eject = new Process_Item("$cd_path disc eject");
    $cd_next  = new Process_Item("$cd_path track next");
    $cd_prev  = new Process_Item("$cd_path track prev");
    $cd_play  = new Process_Item("$cd_path play");
    $cd_stop  = new Process_Item("$cd_path stop");
    $cd_pause = new Process_Item("$cd_path pause");
$cd_vol_norm  = new Process_Item("$cd_path volume 8");

#set up the play command, C6 ON.  If the player is already running then the player is paused
$switch_play    = new Serial_Item('XC6CJ');
$switch_pause   = new Serial_Item('XC6CK');
$switch_n_track = new Serial_Item('XC7CJ');
if (state_now $switch_play) {
    set   $cd_player "$cd_path play";
    start $cd_player;
}
if (state_now $switch_pause) {
    start $cd_pause;
}
if (state_now $switch_n_track) {
    start $cd_next;
}
#on start up runs the cd player and sets a default volume of 8
    if ($Startup or $Reread) {
	start $cd_on;
	start $cd_vol_norm;
    }

