pipeline {
	agent any

	options {
		timestamps()
		disableConcurrentBuilds()
	}

	parameters {
		string(name: 'EC2_HOST', defaultValue: '98.87.155.33', description: 'EC2 public IP or public DNS')
		string(name: 'EC2_USER', defaultValue: 'ec2-user', description: 'SSH username on EC2')
		string(name: 'SSH_CREDENTIALS_ID', defaultValue: 'ec2-ssh-key', description: 'Jenkins SSH private key credentials ID')
		string(name: 'APP_PORT', defaultValue: '80', description: 'Host port to expose app on EC2')
	}

	environment {
		APP_NAME = 'gitops-lite'
		APP_DIR = '/opt/gitops-lite'
	}

	stages {
		stage('Validate Parameters') {
			steps {
				script {
					if (!params.EC2_HOST?.trim()) {
						error('EC2_HOST is required. Add EC2 public IP or DNS in build parameters.')
					}
				}
			}
		}

		stage('Checkout') {
			steps {
				checkout scm
			}
		}

		stage('Build Docker Image') {
			steps {
				sh '''
					set -euo pipefail
					docker --version
					docker build -t ${APP_NAME}:${BUILD_NUMBER} -t ${APP_NAME}:latest .
				'''
			}
		}

		stage('Deploy to EC2') {
			steps {
				sshagent(credentials: [params.SSH_CREDENTIALS_ID]) {
					sh '''
						set -euo pipefail

						SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

						ssh ${SSH_OPTS} ${EC2_USER}@${EC2_HOST} "sudo mkdir -p ${APP_DIR} && sudo chown -R ${EC2_USER}:${EC2_USER} ${APP_DIR}"

						tar --exclude='.git' \
								--exclude='.venv' \
								--exclude='terraform/.terraform' \
								--exclude='terraform/terraform.tfstate' \
								--exclude='terraform/terraform.tfstate.backup' \
								-czf - . | ssh ${SSH_OPTS} ${EC2_USER}@${EC2_HOST} "tar -xzf - -C ${APP_DIR}"

						ssh ${SSH_OPTS} ${EC2_USER}@${EC2_HOST} "\
							set -euo pipefail; \
							cd ${APP_DIR}; \
							sudo docker build -t ${APP_NAME}:latest .; \
							sudo docker rm -f ${APP_NAME} || true; \
							sudo docker run -d --name ${APP_NAME} --restart unless-stopped -p ${APP_PORT}:5000 ${APP_NAME}:latest\
						"
					'''
				}
			}
		}

		stage('Smoke Test') {
			steps {
				sh '''
					set -euo pipefail
					curl --retry 5 --retry-delay 3 --fail http://${EC2_HOST}:${APP_PORT}
				'''
			}
		}
	}

	post {
		success {
			echo "Deployment successful: http://${params.EC2_HOST}:${params.APP_PORT}"
		}
		failure {
			echo 'Pipeline failed. Check stage logs for details.'
		}
	}
}
