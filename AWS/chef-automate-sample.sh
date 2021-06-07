sudo yum update -y
sudo yum install -y ntp unzip

sudo hostnamectl set-hostname ec2-13-212-21-38.ap-southeast-1.compute.amazonaws.com
curl https://packages.chef.io/files/current/latest/chef-automate-cli/chef-automate_linux_amd64.zip | gunzip - > chef-automate && chmod +x chef-automate
echo vm.max_map_count=262144 | sudo tee -a /etc/sysctl.conf
echo vm.dirty_expire_centisecs=20000 | sudo tee -a /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf

sudo ./chef-automate init-config
sudo ./chef-automate deploy --channel current --product builder --product automate --product desktop --accept-terms-and-mlsa config.toml
sudo chef-automate license apply "your_automate_license"
sudo chown ec2-user:ec2-user automate-credentials.toml

export ADMIN_TOKEN=$(sudo chef-automate iam token create admin --admin)
echo admin-token = "$ADMIN_TOKEN" >> automate-credentials.toml
export INGEST_TOKEN=$(sudo ./chef-automate iam token create ingest)
echo ingest-token = "$INGEST_TOKEN" >> automate-credentials.toml

curl -sk -H "api-token: $ADMIN_TOKEN" -H "Content-Type: application/json" https://localhost/apis/iam/v2/policies
curl -sk -H "api-token: $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"members":["token:ingest"]}' https://localhost/apis/iam/v2/policies/ingest-access/members:add
curl -sk -H "api-token: $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"id": "development", "name": "Development"}' https://localhost/apis/iam/v2/projects
curl -sk -H "api-token: $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"id": "test", "name": "Test"}' https://localhost/apis/iam/v2/projects
curl -sk -H "api-token: $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"id": "production", "name": "Production"}' https://localhost/apis/iam/v2/projects

curl -sk -H "api-token: $ADMIN_TOKEN" -H "Content-Type: application/json" -d @project-development-rule.json https://localhost/apis/iam/v2/projects/development/rules
curl -sk -H "api-token: $ADMIN_TOKEN" -H "Content-Type: application/json" -d @project-test-rule.json https://localhost/apis/iam/v2/projects/test/rules
curl -sk -H "api-token: $ADMIN_TOKEN" -H "Content-Type: application/json" -d @project-production-rule.json https://localhost/apis/iam/v2/projects/production/rules
curl -sk -H "api-token: $ADMIN_TOKEN" -H "Content-Type: application/json" https://localhost/apis/iam/v2/apply-rules -X POST
curl -sk -H "api-token: $ADMIN_TOKEN" https://localhost/apis/iam/v2/apply-rules -X POST
