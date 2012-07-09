#!/usr/bin/perl -w

# Notify user via ratpoison when a private message is received, or
# when a channel message contains the user's nick.

# TODO: Handle login notifications.

IRC::register("rp-notify.pl","0.1","","");

sub onPRIVMSG {
    # Get current nick
    my $nick = IRC::get_info(1);
    
    # Parse message
    $_[0] =~ m/:(.+)!(.+)\sPRIVMSG\s(.+)\s:(.+)/;
    my $sender = $1;
    my $channel = $3;
    my $msg = $4;

    unless ($channel =~ /^\#/) { $channel=''; }

    # Notify the user appropriately.
    if ($channel) {
        if ($msg =~ /$nick/i) {
            if ($sender eq $nick) { return; }
            system "ratpoison -c 'echo IRC Message from $sender on $channel: $msg'";
        }
    } else {
        system "ratpoison -c 'echo IRC: Message from $sender: $msg'";
    }
}
IRC::add_message_handler("PRIVMSG", "onPRIVMSG");
