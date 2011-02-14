Quick Site
==========

** ---- Work in progress! ---- **

Quick Site is a light-weight Sinatra app designed to make creating & deploying static websites a breeze. Quick Site was inspired by [StaticMatic](https://github.com/staticmatic/staticmatic), [Nesta](http://effectif.com/nesta) and mostly just the idea of being able to use modern tools like HAML & Less to create simple static sites.

To use quick site:

    git://github.com/citrus/quick_site.git
    cd quick_site
    bundle install
    
Now boot with your method of choice:
    
    ruby app.rb
    thin start -p 4567
    unicorn -p 4567
    

Open [http://localhost:4567](http://localhost:4567) in your favorite browser and enter the name of your new site. After it's created, navigate to http://localhost:4567/sites/your_site/**your-new-page** to automatically create additional pages.



** TO DO **
Once you're happy with your site, visit http://localhost:4567/**deploy/site_name** to upload your changes to your server. 



If you'd like to restart the app on each request: (for development)
    
    shotgun -p 4567 $PWD/app.rb


Documentation
-------------

RDoc's can be generated by running the `rake rdoc` command:

    git clone git://github.com/citrus/quick_site.git
    cd quick_site
    rake rdoc

Now open `rdoc/index.html` in your browser...


Testing
-------

Shouda tests can be run with:

    git clone git://github.com/citrus/quick_site.git
    cd quick_site
    rake



To Do
-----

* Write deploy code..
* Improve styles and views
* Nested pages don't get nested (/this/is/a/page becomes this_is_a_page.haml)
* Add more fields to new site form
* Add image_tag helper
* Add Less/SCSS support
* Switch to a more clever name?


License
-------

Copyright (c) 2011 Spencer Steffen, released under the New BSD License All rights reserved.