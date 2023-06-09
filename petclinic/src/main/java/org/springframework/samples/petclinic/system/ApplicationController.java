package org.springframework.samples.petclinic.system;


import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@RestController
class ApplicationController {

    @RequestMapping(value = "/", method = RequestMethod.GET)
    public String home() {
        return "Welcome to PetClinic. Try the various path /pet/, /visit/, /vet/, /owner/ for the various microservices";
    }

    private static final Logger logger = LoggerFactory.getLogger(ApplicationController.class);

}
