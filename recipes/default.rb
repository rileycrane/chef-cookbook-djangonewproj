# Setup VirtualenvWrapper
python_pip "virtualenvwrapper" do
  action :install
  not_if "test -e /usr/local/bin/virtualenvwrapper.sh"
end

bash "configure virtualenvwrapper" do
  user "vagrant"
  code <<-EOH
    echo "export WORKON_HOME=/vagrant/.virtualenvs" >> /home/vagrant/.profile
    echo "source /usr/local/bin/virtualenvwrapper.sh" >> /home/vagrant/.profile
    echo "workon djangoproj" >> /home/vagrant/.profile
  EOH
  not_if "cat /home/vagrant/.profile | grep virtualenvwrapper.sh"
end

# Create the Virtual Environment
python_virtualenv "/vagrant/.virtualenvs/djangoproj" do
  interpreter "python2.7"
  owner "vagrant"
  action :create
  not_if "test -d /vagrant/.virtualenvs/djangoproj"
end

# Create Bash Aliases
bash "create aliases" do
  user "vagrant"
  code <<-EOH
    echo "alias cw='compass watch myproject/static_media/stylesheets'" >> /home/vagrant/.profile
    echo "alias sh='python manage.py shell'" >> /home/vagrant/.profile
    echo "alias rs='python manage.py runserver [::]:8000'" >> /home/vagrant/.profile
    echo "alias dj='python manage.py '" >> /home/vagrant/.profile
  EOH
  not_if "cat /home/vagrant/.profile | grep compass"
end

# Configure Git
bash "configure git" do
  code <<-EOH
    git config --global color.branch auto
    git config --global color.diff auto
    git config --global color.interactive auto
    git config --global color.status auto
    git config --global merge.summary true
    git config --global alias.st status
    git config --global alias.ci commit
    git config --global alias.co checkout
    git config --global alias.br branch
  EOH
  not_if "git config --get color.diff"
end

# Create Symlinks for PIL
bash "create symlinks" do
  code <<-EOH
    sudo ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib
    sudo ln -s /usr/lib/x86_64-linux-gnu/libfreetype.so /usr/lib
    sudo ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib
  EOH
  not_if "ls /usr/lib | grep libz.so"
end

# Create the Database
bash "create database" do
  code <<-EOH
    echo "CREATE USER django_login WITH SUPERUSER PASSWORD 'secret';" | sudo -u postgres psql
    sudo -u postgres createdb -O django_login -E UTF8 --lc-ctype=en_US.utf8 --lc-collate=en_US.utf8 -T template0 django_db
  EOH
  not_if "sudo -u postgres psql -l | grep django_db"
end

# Install Compass / Susy
gems = Array.new

gems |= %w/
  compass
  susy
/

gems.each do |gem|
  gem_package gem do
    action :install
  end
end

# Configure the project
bash "configure the project" do
  user "vagrant"
  code <<-EOH
    source /vagrant/.virtualenvs/djangoproj/bin/activate
    cd /vagrant/.virtualenvs/djangoproj
    pip install -r https://raw.github.com/jbergantine/django-newproj-template/master/stable-req.txt
    django-admin.py startproject --template=https://github.com/jbergantine/django-newproj-template/zipball/master --extension=py,rst myproject
    git init
    cd /vagrant/.virtualenvs/djangoproj.git/hooks
    wget https://gist.github.com/raw/3868519/aa2c85600d760912f3cb27cb79c82eebd6f9b4c8/post-merge -O post-merge
    cd /vagrant/.virtualenvs/djangoproj/myproject
    chmod u+x manage.py
    cd /vagrant/.virtualenvs/djangoproj/myproject/myproject
    mkdir media static static_media
    cd /vagrant/.virtualenvs/djangoproj/myproject/myproject/static_media
    compass create stylesheets --syntax sass -r susy -u susy
    cd /vagrant/.virtualenvs/djangoproj/myproject/myproject/static_media/stylesheeets/sass
    rm _base.sass screen.sass
    git clone https://github.com/jbergantine/compass-gesso/ .
    touch ie.sass
    cd /vagrant/.virtualenvs/djangoproj/myproject/myproject/static_media/
    mkdir -p javascripts/libs
    cd /vagrant/.virtualenvs/djangoproj/myproject/myproject/static_media/javascripts/libs
    wget http://code.jquery.com/jquery-1.8.1.min.js
    wget https://raw.github.com/gist/3868451/a313411f080ab542a703b805e4d1494bcbf23a0b/gistfile1.js -O modernizr.js
    cd /vagrant/.virtualenvs/djangoproj/
    git add -A
    git commit -am "initial commit"
    echo "export DJANGO_SETTINGS_MODULE=myproject.settings.dev" >> $VIRTUAL_ENV/bin/postactivate
    echo "unset DJANGO_SETTINGS_MODULE" >> $VIRTUAL_ENV/bin/postdeactivate
    echo "cd /vagrant/.virtualenvs/djangoproj/myproject" >> /home/vagrant/.profile
  EOH
  not_if "test -d /vagrant/.virtualenvs/djangoproj/lib/python2.7/site-packages/django"
end
