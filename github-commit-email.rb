# Author:: Adam Jacob (<adam@hjksolutions.com>)
# Copyright:: Copyright (c) 2008 HJK Solutions, LLC
# License:: GNU General Public License version 2 or later
# 
# This program and entire repository is free software; you can
# redistribute it and/or modify it under the terms of the GNU 
# General Public License as published by the Free Software 
# Foundation; either version 2 of the License, or any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

require 'rubygems'
require 'json'

Merb::Config.use { |c|
  c[:project] = "Example",
  c[:mailto] = "<adam@example.com>",
  c[:mailfrom] = "Commit Bot <noreply@example.com>",
  c[:framework]           = {},
  c[:session_store]       = 'none',
  c[:exception_details]   = true
}

require "merb-mailer"

Merb::Mailer.config = {
   :host   => 'localhost',
   :port   => '25',
   :domain => "commitbot" # the HELO domain provided by the client to the server
}

Merb::Router.prepare do |r|
  r.resources :commit
  r.match('/').to(:controller => 'commit', :action =>'index')
end

class Commit < Merb::Controller
  
  def index
    "I accept github post-commits and relay them.  POST to /commit"
  end  
  
  def create
    ch = JSON.parse(params[:payload])
    subject = "Commit to #{ch['repository']['owner']['name'].pluralize} #{ch['repository']['name']}"
    body = <<-EOH
=== Repository Information ===

Name: #{ch['repository']['name']}
Owner: #{ch['repository']['owner']['name']} (#{ch['repository']['owner']['email']})
URL: #{ch['repository']['url']}
Before Commit: #{ch['before']}
After Commit: #{ch['after']}
Ref: #{ch['ref']}      

=== Commits ===

EOH
    ch['commits'].each do |gitsha, commit|
      body << <<-EOH
#{gitsha}
  Author: #{commit['author']['name']} (#{commit['author']['email']})
  Commit Message: #{commit['message']}
  URL: #{commit['url']}
  Timestamp: #{commit['timestamp']}
  
EOH
    end
    m = Merb::Mailer.new(
          :to => Merb::Config[:mailto],
          :from => Merb::Config[:mailfrom],
          :subject => subject,
          :text => body
        )
    m.deliver!
    "#{subject}\n\n#{body}" 
  end
end

