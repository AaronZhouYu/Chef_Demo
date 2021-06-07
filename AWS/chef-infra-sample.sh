sudo yum update -y
sudo yum install -y ntp

sudo hostnamectl set-hostname ec2-13-212-154-245.ap-southeast-1.compute.amazonaws.com
wget https://packages.chef.io/files/stable/chef-server/14.4.4/amazon/2/chef-server-core-14.4.4-1.el7.x86_64.rpm
sudo rpm -Uvh chef-server-core-14.4.4-1.el7.x86_64.rpm
sudo chef-server-ctl reconfigure  --accept-license
sudo chef-server-ctl user-create aaron Yu Zhou aaron.zhouyu@chef.io 'passw0rd' --filename ~/aaron.pem
sudo chef-server-ctl org-create chef 'Chef Software' --association_user aaron --filename ~/chef-validator.pem

echo 'topology "standalone"' | sudo tee -a /etc/opscode/chef-server.rb",
echo 'api_fqdn "ec2-13-212-154-245.ap-southeast-1.compute.amazonaws.com"' | sudo tee -a /etc/opscode/chef-server.rb",
sudo chef-server-ctl reconfigure

sudo chef-server-ctl set-secret data_collector token 'PLyURi7Tv5grACjb6kjZ1xHDRx0='
sudo chef-server-ctl restart nginx && sudo chef-server-ctl restart opscode-erchef
echo 'data_collector["root_url"] =  "https://ec2-13-212-21-38.ap-southeast-1.compute.amazonaws.com/data-collector/v0/"' | sudo tee -a /etc/opscode/chef-server.rb
echo 'data_collector["proxy"] = true' | sudo tee -a /etc/opscode/chef-server.rb",
echo 'profiles["root_url"] = "https://ec2-13-212-21-38.ap-southeast-1.compute.amazonaws.com"' | sudo tee -a /etc/opscode/chef-server.rb
echo 'opscode_erchef["max_request_size"] = 2000000' | sudo tee -a /etc/opscode/chef-server.rb
echo 'insecure_addon_compat false' | sudo tee -a /etc/opscode/chef-server.rb
sudo chef-server-ctl reconfigure
