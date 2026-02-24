package com.yelp.assistant.routing;

import com.yelp.assistant.model.QueryIntent;
import com.yelp.assistant.model.RoutingDecision;
import org.springframework.stereotype.Component;

@Component
public class QueryRouter {

    public RoutingDecision decide(QueryIntent intent) {
        return switch (intent) {
            case OPERATIONAL -> new RoutingDecision(intent, true, false, false);
            case AMENITY     -> new RoutingDecision(intent, true, true, true);
            case QUALITY     -> new RoutingDecision(intent, false, true, false);
            case PHOTO       -> new RoutingDecision(intent, false, false, true);
            default          -> new RoutingDecision(intent, true, true, false);
        };
    }
}
