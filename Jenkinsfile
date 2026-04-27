pipeline {
  agent any

  environment {
    EC2_HOST = "44.221.50.186"
    REPO_URL = "https://github.com/AkulTyagi11/GitOps-Lite.git"
    BRANCH = "main"
    APP_DIR  = "/opt/gitops-lite-app"
    CONTAINER_NAME = "gitops-lite-container"
    IMAGE_NAME = "gitops-lite-app:latest"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Deploy To EC2') {
      steps {
        sshagent(credentials: ['ec2-ssh-key']) {
          sh '''
            set -e
            ssh -o StrictHostKeyChecking=no ec2-user@$EC2_HOST "
              set -e
              sudo mkdir -p $APP_DIR
              sudo chown ec2-user:ec2-user $APP_DIR

              if [ ! -d $APP_DIR/.git ]; then
                git clone -b $BRANCH $REPO_URL $APP_DIR
              else
                cd $APP_DIR
                git fetch origin
                git reset --hard origin/$BRANCH
              fi

              cd $APP_DIR
              sudo docker rm -f $CONTAINER_NAME || true
              sudo docker build -t $IMAGE_NAME .
              sudo docker run -d --name $CONTAINER_NAME -p 80:5000 --restart unless-stopped $IMAGE_NAME
            "
          '''
        }
      }
    }

    stage('Smoke Test') {
      steps {
        sh 'curl -fsS http://$EC2_HOST | grep -q "Deployed via GitOps Lite"'
      }
    }
  }
}
