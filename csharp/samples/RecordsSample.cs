namespace RestFixClient.Samples
{
    /// <summary>
    /// Demonstrates C# 9.0+ record types and related features
    /// </summary>
    public class RecordsSample
    {
        /// <summary>
        /// Basic record declaration
        /// </summary>
        public record Person(string FirstName, string LastName, int Age);

        /// <summary>
        /// Record with additional properties
        /// </summary>
        public record Employee(string FirstName, string LastName, int Age, string Department)
            : Person(FirstName, LastName, Age)
        {
            public decimal Salary { get; init; }
            public DateTime HireDate { get; init; } = DateTime.Now;
        }

        /// <summary>
        /// Record with custom methods
        /// </summary>
        public record Product(string Name, decimal Price, string Category)
        {
            public decimal GetDiscountedPrice(decimal discountPercent)
            {
                return Price * (1 - discountPercent / 100);
            }

            public override string ToString()
            {
                return $"{Name} ({Category}): ${Price:F2}";
            }
        }

        /// <summary>
        /// Record structs (C# 10.0)
        /// </summary>
        public readonly record struct Point3D(double X, double Y, double Z);

        /// <summary>
        /// Basic record usage
        /// </summary>
        public void BasicRecordExample()
        {
            var person = new Person("John", "Doe", 30);
            
            Console.WriteLine($"Name: {person.FirstName} {person.LastName}, Age: {person.Age}");
            Console.WriteLine($"ToString: {person}");
        }

        /// <summary>
        /// Value equality with records
        /// </summary>
        public void RecordEqualityExample()
        {
            var person1 = new Person("John", "Doe", 30);
            var person2 = new Person("John", "Doe", 30);
            var person3 = new Person("Jane", "Doe", 25);
            
            Console.WriteLine($"person1 == person2: {person1 == person2}"); // True
            Console.WriteLine($"person1 == person3: {person1 == person3}"); // False
            Console.WriteLine($"ReferenceEquals: {ReferenceEquals(person1, person2)}"); // False
        }

        /// <summary>
        /// With expressions for non-destructive mutation
        /// </summary>
        public void WithExpressionsExample()
        {
            var person1 = new Person("John", "Doe", 30);
            
            // Create a new record with modified Age
            var person2 = person1 with { Age = 31 };
            
            Console.WriteLine($"Original: {person1}");
            Console.WriteLine($"Modified: {person2}");
            Console.WriteLine($"Are they equal? {person1 == person2}");
        }

        /// <summary>
        /// Deconstruction with records
        /// </summary>
        public void RecordDeconstructionExample()
        {
            var person = new Person("John", "Doe", 30);
            
            // Deconstruct the record
            var (firstName, lastName, age) = person;
            
            Console.WriteLine($"Deconstructed: {firstName} {lastName}, {age} years old");
        }

        /// <summary>
        /// Record inheritance
        /// </summary>
        public void RecordInheritanceExample()
        {
            var employee = new Employee("Jane", "Smith", 28, "IT")
            {
                Salary = 75000,
                HireDate = new DateTime(2020, 1, 15)
            };
            
            Console.WriteLine($"Employee: {employee.FirstName} {employee.LastName}");
            Console.WriteLine($"Department: {employee.Department}");
            Console.WriteLine($"Salary: ${employee.Salary:N0}");
            
            // With expression on derived record
            var promoted = employee with { Salary = 85000, Department = "Senior IT" };
            Console.WriteLine($"Promoted: {promoted.Department}, ${promoted.Salary:N0}");
        }

        /// <summary>
        /// Record struct example
        /// </summary>
        public void RecordStructExample()
        {
            var point1 = new Point3D(1.0, 2.0, 3.0);
            var point2 = new Point3D(1.0, 2.0, 3.0);
            
            Console.WriteLine($"Point1: {point1}");
            Console.WriteLine($"Point1 == Point2: {point1 == point2}");
            
            var point3 = point1 with { Z = 5.0 };
            Console.WriteLine($"Modified point: {point3}");
        }

        /// <summary>
        /// Init-only properties (C# 9.0)
        /// </summary>
        public class PersonClass
        {
            public string FirstName { get; init; } = string.Empty;
            public string LastName { get; init; } = string.Empty;
            public int Age { get; init; }
        }

        public void InitOnlyPropertiesExample()
        {
            var person = new PersonClass
            {
                FirstName = "John",
                LastName = "Doe",
                Age = 30
            };
            
            // person.Age = 31; // This would cause a compile error
            
            Console.WriteLine($"Person: {person.FirstName} {person.LastName}, {person.Age}");
        }

        /// <summary>
        /// Positional records with validation
        /// </summary>
        public record Email
        {
            public string Address { get; }
            
            public Email(string address)
            {
                if (string.IsNullOrWhiteSpace(address) || !address.Contains('@'))
                {
                    throw new ArgumentException("Invalid email address", nameof(address));
                }
                
                Address = address;
            }
        }

        public void RecordWithValidationExample()
        {
            try
            {
                var email1 = new Email("user@example.com");
                Console.WriteLine($"Valid email: {email1.Address}");
                
                var email2 = new Email("invalid");
            }
            catch (ArgumentException ex)
            {
                Console.WriteLine($"Validation error: {ex.Message}");
            }
        }

        /// <summary>
        /// Using records as DTOs (Data Transfer Objects)
        /// </summary>
        public record UserDto(
            int Id,
            string Username,
            string Email,
            DateTime CreatedAt,
            bool IsActive);

        public record OrderDto(
            Guid OrderId,
            int CustomerId,
            DateTime OrderDate,
            decimal Total,
            string Status,
            List<OrderItemDto> Items);

        public record OrderItemDto(
            int ProductId,
            string ProductName,
            int Quantity,
            decimal UnitPrice);

        public void RecordsAsDtosExample()
        {
            var order = new OrderDto(
                OrderId: Guid.NewGuid(),
                CustomerId: 123,
                OrderDate: DateTime.Now,
                Total: 199.98m,
                Status: "Processing",
                Items: new List<OrderItemDto>
                {
                    new(1, "Widget", 2, 49.99m),
                    new(2, "Gadget", 1, 99.99m)
                });
            
            Console.WriteLine($"Order {order.OrderId}:");
            Console.WriteLine($"  Customer: {order.CustomerId}");
            Console.WriteLine($"  Total: ${order.Total}");
            Console.WriteLine($"  Items: {order.Items.Count}");
        }

        /// <summary>
        /// Demonstrates running records samples
        /// </summary>
        public static void RunSamples()
        {
            var sample = new RecordsSample();
            
            Console.WriteLine("=== Records Sample ===\n");
            
            // Basic record
            Console.WriteLine("1. Basic record:");
            sample.BasicRecordExample();
            Console.WriteLine();
            
            // Value equality
            Console.WriteLine("2. Value equality:");
            sample.RecordEqualityExample();
            Console.WriteLine();
            
            // With expressions
            Console.WriteLine("3. With expressions:");
            sample.WithExpressionsExample();
            Console.WriteLine();
            
            // Deconstruction
            Console.WriteLine("4. Deconstruction:");
            sample.RecordDeconstructionExample();
            Console.WriteLine();
            
            // Inheritance
            Console.WriteLine("5. Record inheritance:");
            sample.RecordInheritanceExample();
            Console.WriteLine();
            
            // Record struct
            Console.WriteLine("6. Record struct:");
            sample.RecordStructExample();
            Console.WriteLine();
            
            // Init-only properties
            Console.WriteLine("7. Init-only properties:");
            sample.InitOnlyPropertiesExample();
            Console.WriteLine();
            
            // Records as DTOs
            Console.WriteLine("8. Records as DTOs:");
            sample.RecordsAsDtosExample();
            Console.WriteLine();
        }
    }
}
