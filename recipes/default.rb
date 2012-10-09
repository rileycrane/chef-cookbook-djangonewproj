# Setup VirtualenvWrapper

python_pip "virtualenvwrapper" do
  action :install
  not_if "test -e /usr/local/bin/virtualenvwrapper.sh"
end

bash "Configure virtualenvwrapper" do
  user "vagrant"
  code <<-EOH
  echo "export WORKON_HOME=/home/vagrant/.virtualenvs" >> /home/vagrant/.profile
  echo "source /usr/local/bin/virtualenvwrapper.sh" >> /home/vagrant/.profile
  echo "workon myproject" >> /home/vagrant/.profile
  echo "cd /myproject" >> /home/vagrant/.profile
  EOH
  not_if "cat /home/vagrant/.profile | grep virtualenvwrapper.sh"
end

# Create the Virtual Environment
python_virtualenv "/home/vagrant/.virtualenvs/myproject" do
  interpreter "python2.7"
  owner "vagrant"
  action :create
  not_if "test -d /home/vagrant/.virtualenvs/myproject"
end

# Create Bash Aliases
bash "Create aliases" do
  user "vagrant"
  code <<-EOH
    echo "alias cw='compass watch myproject/static_media/stylesheets'" >> /home/vagrant/.profile
    echo "alias py='python manage.py shell'" >> /home/vagrant/.profile
    echo "alias rs='python manage.py runserver [::]:8000'" >> /home/vagrant/.profile
    echo "alias dj='python manage.py '" >> /home/vagrant/.profile
  EOH
  not_if "cat /home/vagrant/.profile | grep compass"
end

# Configure Git
execute 'create dir' do
  command "git config --global color.branch auto"
  command "git config --global color.diff auto"
  command "git config --global color.interactive auto"
  command "git config --global color.status auto"
  command "git config --global merge.summary true"
end

# Create symlinks for PIL
bash "Create symlinks" do
  user "vagrant"
  code <<-EOH
    ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib
    ln -s /usr/lib/x86_64-linux-gnu/libfreetype.so /usr/lib
    ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib
  EOH
end
