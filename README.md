Quick Site
==========

** ---- In Development ---- **

Quick Site is a light-weight Sinatra app designed to make creating & deploying static websites a breeze. Quick Site was inspired by [StaticMatic](https://github.com/staticmatic/staticmatic).

To use quick site:

    git://github.com/citrus/quick_site.git
    cd quick_site
    bundle install
    
Now boot with your method of choice:
    
    ruby app.rb
    thin start -p 4567
    unicorn -p 4567
    
If you'd like to restart the app on each request: (for development)
    
    shotgun -p 4567 $PWD/app.rb
    


Open [http://localhost:4567](http://localhost:4567) in your favorite browser and enter the name of your new site. After it's created, navigate to http://localhost:4567/sites/your_site/your-new-page to automatically create additional pages.




Testing
-------

Shouda tests can be run with:

    git clone git://github.com/citrus/quick_site.git
    cd quick_site
    rake



To Do
-----

* Add some real styles and views
* Nested pages can't be created
* Add more fields to new site form
* Add Less/SCSS support
* Switch to a more clever name?


License
-------

Copyright (c) 2011 Spencer Steffen, released under the New BSD License All rights reserved.