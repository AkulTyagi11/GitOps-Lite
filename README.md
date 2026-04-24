# GitOps Lite

Infrastructure as Code driven CI/CD pipeline for automated Dockerized app deployment on AWS using Terraform, Ansible, and Jenkins.

## Final Project Structure

```text
project-root/
├── app/
│   ├── app.py
│   ├── requirements.txt
│   └── templates/
│       └── index.html
├── ansible/
│   ├── ansible.cfg
│   ├── generate_inventory.sh
│   ├── inventory.ini.example
│   ├── playbook.yml
│   └── README.md
├── terraform/
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── terraform.tfvars.example
│   ├── variables.tf
│   └── README.md
├── Dockerfile
├── Jenkinsfile
├── .dockerignore
└── .gitignore
```

## Step 1: Application

Implemented in `app/`.

Expected page message: `Deployed via GitOps Lite`

Local run:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r app/requirements.txt
python app/app.py
```

Open: `http://127.0.0.1:5000`

## Step 2: Docker Setup

Implemented in `Dockerfile` and `.dockerignore`.

Build and run locally:

```bash
docker build -t gitops-lite:dev .
docker run --name gitops-lite -d -p 5000:5000 gitops-lite:dev
docker ps
curl http://localhost:5000
```

Stop container:

```bash
docker stop gitops-lite
docker rm gitops-lite
```

## Step 3: Terraform Infrastructure

Provision EC2 + Security Group + outputs + CloudWatch CPU alarm.

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars (key_name and ssh_cidr_blocks are most important)
terraform init
terraform fmt
terraform validate
terraform apply -auto-approve
terraform output -raw ec2_public_ip
```

Expected output:

- EC2 public IP and DNS
- SSH command template

## Step 4: Ansible Server Configuration

Use Terraform output to generate inventory, then configure server.

```bash
cd ..
chmod +x ansible/generate_inventory.sh
./ansible/generate_inventory.sh ~/.ssh/your-key.pem
cd ansible
ansible all -m ping
ansible-playbook playbook.yml \
  -e app_repo_url=https://github.com/<your-username>/<your-repo>.git \
  -e app_branch=main
```

Expected output recap ends with:

- `failed=0`
- `unreachable=0`

## Step 5: Jenkins CI/CD Pipeline

`Jenkinsfile` is ready and does:

1. Pull code from GitHub (`checkout scm`)
2. Build Docker image in Jenkins
3. SSH into EC2
4. Stop old container if it exists
5. Run new container on EC2
6. Smoke test endpoint

### Jenkins setup steps

1. Install Jenkins (local machine or EC2).
2. Install Docker on Jenkins host and ensure Jenkins user can run Docker.
3. Install plugins:
   - Git
   - Pipeline
   - SSH Agent
4. Add credentials in Jenkins:
   - Type: SSH Username with private key
   - ID example: `ec2-ssh-key`
   - Username: `ec2-user`
   - Private key: your EC2 `.pem` key content
5. Create Pipeline job:
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repo URL: your GitHub repo URL
   - Script Path: `Jenkinsfile`
6. Build with parameters:
   - `EC2_HOST`: Terraform output IP or DNS
   - `EC2_USER`: `ec2-user`
   - `SSH_CREDENTIALS_ID`: `ec2-ssh-key`
   - `APP_PORT`: `80`

## Step 6: GitHub Integration + Webhook

1. In Jenkins job, check `GitHub hook trigger for GITScm polling`.
2. In GitHub repo: Settings -> Webhooks -> Add webhook.
3. Payload URL:

```text
http://<jenkins-public-url>/github-webhook/
```

4. Content type: `application/json`
5. Event: `Just the push event`
6. Save webhook and test using recent deliveries.

## Step 7: Deployment Flow Validation

After webhook is configured:

1. Push code to GitHub.
2. Jenkins build triggers automatically.
3. Docker image is built.
4. EC2 container is replaced with the new version.
5. App is reachable in browser:

```text
http://<ec2-public-ip>
```

## Step 8: CloudWatch Monitoring (Basic CPU)

Already included through Terraform:

- `aws_cloudwatch_metric_alarm` in `terraform/main.tf`

To enable 1-minute detailed monitoring metrics on EC2, set in `terraform.tfvars`:

```hcl
enable_detailed_monitoring = true
```

Then apply again:

```bash
cd terraform
terraform apply -auto-approve
```

Check in AWS Console:

1. CloudWatch -> Alarms -> find `gitops-lite-high-cpu`
2. EC2 -> Instances -> Monitoring tab for CPU metrics

## Cleanup

```bash
cd terraform
terraform destroy -auto-approve
```
