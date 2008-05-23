Github Commit Emails
====================

This is a Merb "very-flat" application.  You need to first do:

$ gem install merb-core merb-mailer json

In order to get Merb installed.  Once that's done, you can fire up your new github commit email
bot with:

merb -I github-commit-email.rb

Before you start sending things through it, I recommend you pop open the source and edit the
variables at the top.  Specifically:

  c[:project] = "Example",
  c[:mailto] = "<adam@example.com>",
  c[:mailfrom] = "Commit Bot <noreply@example.com>",

  Merb::Mailer.config = {
     :host   => 'localhost',
     :port   => '25',
     :domain => "commitbot" # the HELO domain provided by the client to the server
  }

You'll want to set all of those to reasonable settings.

Good luck!

Adam
