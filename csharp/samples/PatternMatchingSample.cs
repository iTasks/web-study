namespace RestFixClient.Samples
{
    /// <summary>
    /// Demonstrates modern pattern matching features in C# 7.0+
    /// </summary>
    public class PatternMatchingSample
    {
        /// <summary>
        /// Type patterns
        /// </summary>
        public void TypePatternExample(object obj)
        {
            if (obj is string str)
            {
                Console.WriteLine($"String of length {str.Length}");
            }
            else if (obj is int number)
            {
                Console.WriteLine($"Integer value: {number}");
            }
            else if (obj is null)
            {
                Console.WriteLine("Null value");
            }
        }

        /// <summary>
        /// Switch expressions (C# 8.0)
        /// </summary>
        public string GetShapeDescription(object shape) => shape switch
        {
            Circle c => $"Circle with radius {c.Radius}",
            Rectangle r => $"Rectangle {r.Width}x{r.Height}",
            Triangle t => $"Triangle with base {t.Base}",
            null => "No shape",
            _ => "Unknown shape"
        };

        /// <summary>
        /// Property patterns
        /// </summary>
        public decimal CalculateDiscount(Order order) => order switch
        {
            { Total: > 1000, Customer.IsPremium: true } => order.Total * 0.20m,
            { Total: > 1000 } => order.Total * 0.10m,
            { Customer.IsPremium: true } => order.Total * 0.05m,
            _ => 0
        };

        /// <summary>
        /// Positional patterns with deconstruction
        /// </summary>
        public string ClassifyPoint(Point point) => point switch
        {
            (0, 0) => "Origin",
            (var x, 0) => $"On X-axis at {x}",
            (0, var y) => $"On Y-axis at {y}",
            (var x, var y) when x == y => $"On diagonal at ({x}, {y})",
            (var x, var y) => $"Point at ({x}, {y})"
        };

        /// <summary>
        /// Tuple patterns
        /// </summary>
        public string RockPaperScissors(string player1, string player2) => (player1, player2) switch
        {
            ("rock", "paper") => "Player 2 wins",
            ("rock", "scissors") => "Player 1 wins",
            ("paper", "rock") => "Player 1 wins",
            ("paper", "scissors") => "Player 2 wins",
            ("scissors", "rock") => "Player 2 wins",
            ("scissors", "paper") => "Player 1 wins",
            _ => "Draw"
        };

        /// <summary>
        /// Relational patterns (C# 9.0)
        /// </summary>
        public string GetTemperatureDescription(int temperature) => temperature switch
        {
            < 0 => "Freezing",
            >= 0 and < 10 => "Cold",
            >= 10 and < 20 => "Cool",
            >= 20 and < 30 => "Warm",
            >= 30 => "Hot"
        };

        /// <summary>
        /// Logical patterns (and, or, not)
        /// </summary>
        public bool IsValidAge(int age) => age switch
        {
            >= 0 and <= 120 => true,
            _ => false
        };

        public string ClassifyLetter(char c) => c switch
        {
            >= 'a' and <= 'z' => "Lowercase",
            >= 'A' and <= 'Z' => "Uppercase",
            >= '0' and <= '9' => "Digit",
            _ => "Other"
        };

        /// <summary>
        /// List patterns (C# 11.0)
        /// </summary>
        public string AnalyzeArray(int[] numbers) => numbers switch
        {
            [] => "Empty array",
            [var single] => $"Single element: {single}",
            [var first, var second] => $"Two elements: {first}, {second}",
            [var first, .., var last] => $"Multiple elements, first: {first}, last: {last}",
        };

        /// <summary>
        /// Extended property patterns
        /// </summary>
        public decimal GetShippingCost(Order order) => order switch
        {
            { ShippingAddress.Country: "USA", Total: > 100 } => 0,
            { ShippingAddress.Country: "USA" } => 10,
            { ShippingAddress.Country: "Canada", Total: > 100 } => 5,
            { ShippingAddress.Country: "Canada" } => 15,
            _ => 25
        };

        /// <summary>
        /// Pattern matching with when clauses
        /// </summary>
        public string ProcessTransaction(Transaction transaction) => transaction switch
        {
            { Type: "Deposit", Amount: var amt } when amt > 10000 => "Large deposit - requires approval",
            { Type: "Deposit" } => "Deposit processed",
            { Type: "Withdrawal", Amount: var amt } when amt > 5000 => "Large withdrawal - requires verification",
            { Type: "Withdrawal" } => "Withdrawal processed",
            _ => "Unknown transaction type"
        };

        /// <summary>
        /// Recursive patterns
        /// </summary>
        public bool IsEmptyTree(TreeNode? node) => node switch
        {
            null => true,
            { Left: null, Right: null, Value: 0 } => true,
            _ => false
        };

        #region Supporting Types

        public class Circle
        {
            public double Radius { get; set; }
        }

        public class Rectangle
        {
            public double Width { get; set; }
            public double Height { get; set; }
        }

        public class Triangle
        {
            public double Base { get; set; }
        }

        public class Order
        {
            public decimal Total { get; set; }
            public Customer Customer { get; set; } = new Customer();
            public Address ShippingAddress { get; set; } = new Address();
        }

        public class Customer
        {
            public bool IsPremium { get; set; }
        }

        public class Address
        {
            public string Country { get; set; } = string.Empty;
        }

        public record Point(int X, int Y);

        public class Transaction
        {
            public string Type { get; set; } = string.Empty;
            public decimal Amount { get; set; }
        }

        public class TreeNode
        {
            public int Value { get; set; }
            public TreeNode? Left { get; set; }
            public TreeNode? Right { get; set; }
        }

        #endregion

        /// <summary>
        /// Demonstrates running pattern matching samples
        /// </summary>
        public static void RunSamples()
        {
            var sample = new PatternMatchingSample();
            
            Console.WriteLine("=== Pattern Matching Sample ===\n");
            
            // Type patterns
            Console.WriteLine("1. Type patterns:");
            sample.TypePatternExample("Hello");
            sample.TypePatternExample(42);
            Console.WriteLine();
            
            // Switch expressions
            Console.WriteLine("2. Switch expressions:");
            Console.WriteLine(sample.GetShapeDescription(new Circle { Radius = 5 }));
            Console.WriteLine(sample.GetShapeDescription(new Rectangle { Width = 10, Height = 20 }));
            Console.WriteLine();
            
            // Property patterns
            Console.WriteLine("3. Property patterns (discount calculation):");
            var order1 = new Order { Total = 1500, Customer = new Customer { IsPremium = true } };
            Console.WriteLine($"   Discount: ${sample.CalculateDiscount(order1)}");
            Console.WriteLine();
            
            // Positional patterns
            Console.WriteLine("4. Positional patterns:");
            Console.WriteLine(sample.ClassifyPoint(new Point(0, 0)));
            Console.WriteLine(sample.ClassifyPoint(new Point(5, 5)));
            Console.WriteLine();
            
            // Tuple patterns
            Console.WriteLine("5. Tuple patterns (Rock-Paper-Scissors):");
            Console.WriteLine(sample.RockPaperScissors("rock", "scissors"));
            Console.WriteLine();
            
            // Relational patterns
            Console.WriteLine("6. Relational patterns:");
            Console.WriteLine($"   15°C is {sample.GetTemperatureDescription(15)}");
            Console.WriteLine($"   35°C is {sample.GetTemperatureDescription(35)}");
            Console.WriteLine();
            
            // Logical patterns
            Console.WriteLine("7. Logical patterns:");
            Console.WriteLine($"   'a' is {sample.ClassifyLetter('a')}");
            Console.WriteLine($"   '5' is {sample.ClassifyLetter('5')}");
            Console.WriteLine();
            
            // List patterns
            Console.WriteLine("8. List patterns:");
            Console.WriteLine(sample.AnalyzeArray(Array.Empty<int>()));
            Console.WriteLine(sample.AnalyzeArray(new[] { 1, 2, 3, 4, 5 }));
            Console.WriteLine();
        }
    }
}
