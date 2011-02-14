Quick Site
==========

** In Development **

Quick Site is a light-weight Sinatra app designed to make creating & deploying static websites a breeze.

To use quick site:

   git://github.com/citrus/quick_site.git
   cd quick_site
   bundle install
   
   # boot with your method of choice
   
   ruby app.rb
   shotgun -p 4567 $PWD/app.rb
   thin start -p 4567


Now open http://localhost:4567 in your favorite browser and start building sites.


http://localhost:4567/new is




Chameleon-like styles are currently achieved by symlinking from the site's root to the application's root. This is kind of ghetto and may change...




To Do:
------

* Add more fields to new site form
* Add Less/SCSS support
* Switch to a more clever name?

