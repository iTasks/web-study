using YelpAiAssistant.Models;

namespace YelpAiAssistant.Routing;

public class QueryRouter
{
    public RoutingDecision Decide(QueryIntent intent) => intent switch
    {
        QueryIntent.Operational => new(intent, true,  false, false),
        QueryIntent.Amenity     => new(intent, true,  true,  true),
        QueryIntent.Quality     => new(intent, false, true,  false),
        QueryIntent.Photo       => new(intent, false, false, true),
        _                       => new(intent, true,  true,  false),
    };
}
