# Demo web apps for sso\_sap gem

This repo has two Sinatra web apps.  One is named fake\_sap\_portal and simulates an SAP portal for testing convenience.  The other is named your\_app.  It doesn't do anything except demonstrate that you can login to it.

Instructions:

* `bundle install`
* `bundle exec ruby your_app.rb &`
* `bundle exec ruby fake_sap_portal.rb &`
* Browse to http://localhost:4567/ (the fake SAP portal)
* Login
* Click on the link to "your app" at http://localhost:4568/
