# prism
Paranormal Ring Information Sensing Monitorinator


Prism is set up to run in habitat. It polls the census information from it's supervisor.
It then posts that information to a configurable URL.


### Building prism in habitat

Start from the prism directory, to enter the habitat studio:

    hab studio enter

Once in the studio build prism:

    build

You can test it out inside of habitat:

    hab start <yourusername>/prism

Export to docker:

    hab pkg export docker <yourusername>/prism

Find runtime data here:

    /hab/svc/prism/*

### Setting up your docker environment to use prism
Add the following to the automate-workflow docker-compose.yml file:

    prism:
      image: kmacgugan/prism
      links:
        - nginx
      depends_on:
        - workflow_api

Start prism with

    docker-compose up -d prism

Watch logs with

    docker-compose logs -f prism nginx logstash
