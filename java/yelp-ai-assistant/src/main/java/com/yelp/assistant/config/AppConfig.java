package com.yelp.assistant.config;

import com.yelp.assistant.model.*;
import com.yelp.assistant.resilience.CircuitBreaker;
import com.yelp.assistant.search.*;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.HandlerInterceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Configuration
public class AppConfig implements WebMvcConfigurer {

    // Named circuit breakers as prototype-style beans held in the controller
    @Bean("cbStructured")
    public CircuitBreaker cbStructured() { return new CircuitBreaker(5, 30); }

    @Bean("cbReview")
    public CircuitBreaker cbReview() { return new CircuitBreaker(5, 30); }

    @Bean("cbPhoto")
    public CircuitBreaker cbPhoto() { return new CircuitBreaker(5, 30); }

    @Bean
    public ApplicationRunner seedDemoData(
        StructuredSearchService structuredService,
        ReviewVectorSearchService reviewService,
        PhotoHybridRetrievalService photoService
    ) {
        return args -> {
            BusinessData biz = new BusinessData(
                "12345", "The Rustic Table",
                "123 Main St, New York, NY 10001",
                "+1-212-555-0100", "$$",
                List.of(
                    new BusinessHours("monday",    "09:00", "22:00"),
                    new BusinessHours("tuesday",   "09:00", "22:00"),
                    new BusinessHours("wednesday", "09:00", "22:00"),
                    new BusinessHours("thursday",  "09:00", "22:00"),
                    new BusinessHours("friday",    "09:00", "23:00"),
                    new BusinessHours("saturday",  "10:00", "23:00"),
                    new BusinessHours("sunday",    "10:00", "21:00")
                ),
                Map.of(
                    "heated_patio", true,
                    "parking", false,
                    "wifi", true,
                    "wheelchair_accessible", true
                ),
                List.of("American", "Brunch", "Bar"),
                4.3, 215
            );
            structuredService.addBusiness(biz);

            reviewService.addReview(new Review("r1", "12345", "u1", 5.0,
                "Amazing heated patio — perfect for winter evenings. Great cocktails too!"));
            reviewService.addReview(new Review("r2", "12345", "u2", 4.0,
                "Lovely atmosphere for a date night. The food was excellent."));
            reviewService.addReview(new Review("r3", "12345", "u3", 3.5,
                "Good for groups. Parking nearby is tricky on weekends."));

            photoService.addPhoto(new Photo("p1", "12345",
                "https://example.com/photos/rustic-patio-1.jpg",
                "Outdoor heated patio with string lights in winter"));
            photoService.addPhoto(new Photo("p2", "12345",
                "https://example.com/photos/rustic-interior.jpg",
                "Cozy interior with rustic wooden decor"));
        };
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new HandlerInterceptor() {
            @Override
            public boolean preHandle(HttpServletRequest req, HttpServletResponse res, Object h) {
                String corr = req.getHeader("X-Correlation-ID");
                if (corr == null || corr.isBlank()) corr = UUID.randomUUID().toString();
                res.setHeader("X-Correlation-ID", corr);
                return true;
            }
        });
    }
}
