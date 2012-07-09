#  rp-transact.rb - a Ruby library for multiple ratpoison commands
#
#  Copyright (C) 2006 rubikitch <rubikitch@ruby-lang.org>
#  Version: $Id: rp-transact.rb,v 1.2 2006/04/05 08:10:48 rubikitch Exp $

#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#    This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#    You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

#### Utility method ####
require 'tmpdir'
require 'fileutils'

class << IO
  # Redirects $stdout to STDOUT and executes the block.
  def redirect(stdout)
    begin
      stdout_sv = STDOUT.dup
      STDOUT.reopen(stdout)
      yield
    ensure
      STDOUT.flush
      STDOUT.reopen(stdout_sv)
    end
  end
end

@@__system_to_string_count__ = 0
def system_to_string(*args)
  begin
    tmpf = File.join(Dir.tmpdir, "#{$$}-#{@@__system_to_string_count__}")
    @@__system_to_string_count__ += 1
    ret = nil
    open(tmpf,"w") do |f|
      IO.redirect(f) {
        system *args
      }
    end
    File.read(tmpf)
  ensure
    FileUtils.rm_f tmpf
  end
end

#### the main part ####

# This class stocks multiple ratpoison commands and execute them at a time.
# It is faster than forking many RP commands.
#
# Example. This is equivalent to
#   `ratpoison -c 'gselect noselect' -c 'select ProcMeter' -c 'gselect default'`
# 
# rp = RpTransact.new
# rp << "gselect noselect"
# rp << "select ProcMeter"
# rp << "gselect default"
# rp.commit
# 
class RpTransact

  RATPOISON = ENV['RATPOISON'] || "/usr/local/bin/ratpoison"

  # Create a RpTransact object.
  def initialize
    @cmds = []
  end

  # Add a ratpoison command.
  def <<(cmd)
    @cmds << cmd
    self
  end

  # Clear stored ratpoison commands.
  def clear
    @cmds.clear
  end

  # Execute stored ratpoison commands and return the output.
  def commit
    a = system_to_string(RATPOISON, *@cmds.map{|c| ["-c", c]}.flatten)
    clear
    a
  end

end
