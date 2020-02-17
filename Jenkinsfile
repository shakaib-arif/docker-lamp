pipeline { 
    agent webserver    
    stages {
        stage('Build') { 
            steps { 
                sh 'docker build -t shakaib/docker-lamp .'
            }
        }
        stage('Deploy') {
            steps {
                sh 'docker run -itd --name my-docker-lamp -p 8080:80 --restart always shakaib/docker-lamp'
            }
        }
    }
}