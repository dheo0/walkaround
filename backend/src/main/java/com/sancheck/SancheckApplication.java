package com.sancheck;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class SancheckApplication {
    public static void main(String[] args) {
        SpringApplication.run(SancheckApplication.class, args);
    }
}
