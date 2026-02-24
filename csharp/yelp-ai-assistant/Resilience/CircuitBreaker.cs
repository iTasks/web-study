namespace YelpAiAssistant.Resilience;

public class CircuitBreaker
{
    private enum State { Closed, Open, HalfOpen }

    private readonly int _failureThreshold;
    private readonly int _recoverySeconds;
    private State _state = State.Closed;
    private int _failures;
    private DateTimeOffset _lastFailure;
    private readonly object _lock = new();

    public CircuitBreaker(int failureThreshold = 5, int recoverySeconds = 30)
    {
        _failureThreshold = failureThreshold;
        _recoverySeconds  = recoverySeconds;
    }

    public bool IsOpen
    {
        get
        {
            lock (_lock)
            {
                if (_state == State.Open)
                {
                    if (DateTimeOffset.UtcNow - _lastFailure >= TimeSpan.FromSeconds(_recoverySeconds))
                    { _state = State.HalfOpen; return false; }
                    return true;
                }
                return false;
            }
        }
    }

    public void RecordSuccess() { lock (_lock) { _failures = 0; _state = State.Closed; } }

    public void RecordFailure()
    {
        lock (_lock)
        {
            _lastFailure = DateTimeOffset.UtcNow;
            if (++_failures >= _failureThreshold) _state = State.Open;
        }
    }

    public string StateName { get { lock (_lock) return _state.ToString().ToLowerInvariant(); } }
}

// Holds named circuit breakers for DI
public class AppCircuitBreakers
{
    public CircuitBreaker Structured { get; } = new();
    public CircuitBreaker Review     { get; } = new();
    public CircuitBreaker Photo      { get; } = new();
}
