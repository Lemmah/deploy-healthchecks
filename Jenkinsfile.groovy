#!groovy
// This deployment script assumes that there is only a single Jenkins server (master) and there are no agents.

node {
    // First load the deployment scripts into the server
    stage("Get the Latest Deployment Scripts"){
        sh 'sudo rm -rf *'
        git url: 'https://github.com/Lemmah/deploy-healthchecks.git'
        sh 'ls'
    }
    // Just incase the machine is not configured for python testing and dev
    stage("Setup Project Env") {
        sh '''
            sudo apt-get -y install python-virtualenv
            sudo apt-get -y install python3-pip
            '''
    }
    // It's often recommended to run a django project from a virtual environment.
    // This way you can manage all of your depedencies without affecting the rest of your system.
    stage("Create Project Virtual Env") {
        sh '''
            virtualenv --python=python3 hc-venv
            . hc-venv/bin/activate
            python --version
            which python
            deactivate
            '''
    }  
    
    // The stage below is attempting to get the latest version of our application code.
    stage ("Get Latest Code") {
       sh '''
        git clone https://github.com/lemmah/healthchecks-clone.git
        ls
        '''
    }
    
    // Then we install our requirements
    stage ("Install Application Dependencies") {
        sh '''
            ./setup.sh
            . hc-venv/bin/activate
            export DJANGO_SETTINGS_MODULE=
            ls
            python --version
            pip install -r requirements.txt
            pip install mock
            deactivate
            '''
    }
    
    // Typically, django recommends that all the static assets such as images and css are to be collected to a single folder and
    // served separately outside the django application via apache or a CDN. This command will gather up all the static assets and
    // ready them for deployment.
    stage ("Setup Project database") {
        sh '''
            . hc-venv/bin/activate
            export DJANGO_SETTINGS_MODULE=
            cp hc/local_settings.py.example hc/local_settings.py
            django-admin.py makemigrations accounts admin api auth contenttypes payments sessions
            django-admin.py migrate
            deactivate
            '''
    }
  
    // After all of the dependencies are installed, we now start running our tests.
    stage ("Run Unit/Integration Tests") {
        def testsError = null
        try {
            sh '''
                . hc-venv/bin/activate
                export DJANGO_SETTINGS_MODULE=
                django-admin.py test
                deactivate
               '''
        }
        catch(err) {
            testsError = err
            currentBuild.result = 'FAILURE'
        }
        finally {
            junit 'reports/junit.xml'

            if (testsError) {
                throw testsError
            }
        }
    }


    stage("Create Artifact") {

    }
}

node {
    stage("Deploy Artifact") {

    }
}

node {
    stage("Run End-To-End Tests") {

    }
}