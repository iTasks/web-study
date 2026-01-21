#nullable enable

namespace RestFixClient.Samples
{
    /// <summary>
    /// Demonstrates nullable reference types (C# 8.0+)
    /// </summary>
    public class NullabilityFeaturesSample
    {
        /// <summary>
        /// Nullable vs non-nullable reference types
        /// </summary>
        public void NullableReferenceTypesExample()
        {
            // Non-nullable reference type
            string nonNullableString = "Hello";
            Console.WriteLine($"Non-nullable: {nonNullableString}");
            
            // Nullable reference type
            string? nullableString = null;
            
            // Compiler warning if you try to dereference without checking
            // Console.WriteLine(nullableString.Length); // Warning!
            
            // Safe access with null check
            if (nullableString != null)
            {
                Console.WriteLine($"Length: {nullableString.Length}");
            }
        }

        /// <summary>
        /// Null-conditional operator
        /// </summary>
        public void NullConditionalOperatorExample()
        {
            string? nullableString = null;
            
            // Null-conditional operator (?.)
            int? length = nullableString?.Length;
            Console.WriteLine($"Length: {length ?? -1}");
            
            // Null-conditional with indexer
            string?[] array = new string?[] { "Hello", null, "World" };
            var firstLength = array[0]?.Length;
            var secondLength = array[1]?.Length;
            
            Console.WriteLine($"First length: {firstLength}");
            Console.WriteLine($"Second length: {secondLength ?? -1}");
        }

        /// <summary>
        /// Null-coalescing operator
        /// </summary>
        public void NullCoalescingOperatorExample()
        {
            string? nullableString = null;
            
            // Null-coalescing operator (??)
            string result = nullableString ?? "Default value";
            Console.WriteLine($"Result: {result}");
            
            // Null-coalescing assignment (??=)
            string? value = null;
            value ??= "Assigned value";
            Console.WriteLine($"Value: {value}");
            
            value ??= "This won't be assigned";
            Console.WriteLine($"Value: {value}");
        }

        /// <summary>
        /// Null-forgiving operator
        /// </summary>
        public void NullForgivingOperatorExample()
        {
            string? possiblyNull = GetStringValue();
            
            // Null-forgiving operator (!) - use with caution
            // Only use when you're certain the value is not null
            if (possiblyNull != null)
            {
                string definitelyNotNull = possiblyNull!;
                Console.WriteLine($"Length: {definitelyNotNull.Length}");
            }
        }

        /// <summary>
        /// Method parameters with nullable annotations
        /// </summary>
        public void ProcessUser(string name, string? middleName, string? email)
        {
            Console.WriteLine($"Name: {name}"); // name is never null
            
            // middleName might be null
            if (middleName != null)
            {
                Console.WriteLine($"Middle name: {middleName}");
            }
            
            // Using null-coalescing
            Console.WriteLine($"Email: {email ?? "Not provided"}");
        }

        /// <summary>
        /// Return types with nullable annotations
        /// </summary>
        public string? FindUser(int userId)
        {
            // Returns null if user not found
            if (userId == 0)
            {
                return null;
            }
            
            return $"User_{userId}";
        }

        public string GetUserOrThrow(int userId)
        {
            // Never returns null - throws exception instead
            if (userId == 0)
            {
                throw new ArgumentException("Invalid user ID", nameof(userId));
            }
            
            return $"User_{userId}";
        }

        /// <summary>
        /// Properties with nullable types
        /// </summary>
        public class User
        {
            public string Username { get; set; } = string.Empty; // Required
            public string? Email { get; set; } // Optional
            public string? PhoneNumber { get; set; } // Optional
            public DateTime CreatedAt { get; set; } = DateTime.Now;
        }

        public void NullablePropertiesExample()
        {
            var user = new User
            {
                Username = "john_doe",
                Email = "john@example.com"
                // PhoneNumber is null
            };
            
            Console.WriteLine($"Username: {user.Username}");
            Console.WriteLine($"Email: {user.Email ?? "Not set"}");
            Console.WriteLine($"Phone: {user.PhoneNumber ?? "Not set"}");
        }

        /// <summary>
        /// Nullable annotations with collections
        /// </summary>
        public void NullableCollectionsExample()
        {
            // List that cannot be null, containing non-null strings
            List<string> nonNullableList = new List<string>();
            
            // List that can be null, containing non-null strings
            List<string>? nullableList = null;
            
            // List that cannot be null, containing nullable strings
            List<string?> listOfNullables = new List<string?> { "Hello", null, "World" };
            
            // List that can be null, containing nullable strings
            List<string?>? fullyNullable = null;
            
            foreach (var item in listOfNullables)
            {
                Console.WriteLine($"Item: {item ?? "null"}");
            }
        }

        /// <summary>
        /// Nullable annotations with generics
        /// </summary>
        public class Container<T>
        {
            private T? _value;
            
            public void SetValue(T? value)
            {
                _value = value;
            }
            
            public T? GetValue()
            {
                return _value;
            }
            
            public bool HasValue => _value != null;
        }

        public void NullableGenericsExample()
        {
            var stringContainer = new Container<string>();
            stringContainer.SetValue("Hello");
            Console.WriteLine($"Value: {stringContainer.GetValue()}");
            
            var intContainer = new Container<int>();
            intContainer.SetValue(42);
            Console.WriteLine($"Value: {intContainer.GetValue()}");
        }

        /// <summary>
        /// Null checks and smart casts
        /// </summary>
        public void NullCheckExample(string? input)
        {
            if (input == null)
            {
                Console.WriteLine("Input is null");
                return;
            }
            
            // After null check, input is treated as non-nullable
            Console.WriteLine($"Length: {input.Length}");
            Console.WriteLine($"Upper: {input.ToUpper()}");
        }

        /// <summary>
        /// Using pattern matching for null checks
        /// </summary>
        public void PatternMatchingNullCheckExample(object? obj)
        {
            if (obj is string str)
            {
                // str is definitely not null here
                Console.WriteLine($"String: {str}");
            }
            else if (obj is null)
            {
                Console.WriteLine("Object is null");
            }
            else
            {
                Console.WriteLine($"Object type: {obj.GetType().Name}");
            }
        }

        /// <summary>
        /// Required properties (C# 11.0) - requires .NET 7+
        /// Commented out as this project uses .NET 6
        /// </summary>
        /*
        public class Product
        {
            public required string Name { get; init; }
            public required decimal Price { get; init; }
            public string? Description { get; init; }
        }

        public void RequiredPropertiesExample()
        {
            // Must initialize required properties
            var product = new Product
            {
                Name = "Widget",
                Price = 29.99m
                // Description is optional
            };
            
            Console.WriteLine($"Product: {product.Name}, Price: ${product.Price}");
        }
        */

        private string? GetStringValue()
        {
            return Random.Shared.Next(0, 2) == 0 ? "Value" : null;
        }

        /// <summary>
        /// Demonstrates running nullability features samples
        /// </summary>
        public static void RunSamples()
        {
            var sample = new NullabilityFeaturesSample();
            
            Console.WriteLine("=== Nullability Features Sample ===\n");
            
            // Nullable reference types
            Console.WriteLine("1. Nullable vs non-nullable reference types:");
            sample.NullableReferenceTypesExample();
            Console.WriteLine();
            
            // Null-conditional operator
            Console.WriteLine("2. Null-conditional operator (?.):");
            sample.NullConditionalOperatorExample();
            Console.WriteLine();
            
            // Null-coalescing operator
            Console.WriteLine("3. Null-coalescing operator (?? and ??=):");
            sample.NullCoalescingOperatorExample();
            Console.WriteLine();
            
            // Method parameters
            Console.WriteLine("4. Method with nullable parameters:");
            sample.ProcessUser("John", null, "john@example.com");
            Console.WriteLine();
            
            // Nullable properties
            Console.WriteLine("5. Nullable properties:");
            sample.NullablePropertiesExample();
            Console.WriteLine();
            
            // Nullable collections
            Console.WriteLine("6. Nullable collections:");
            sample.NullableCollectionsExample();
            Console.WriteLine();
            
            // Pattern matching null checks
            Console.WriteLine("7. Pattern matching for null checks:");
            sample.PatternMatchingNullCheckExample("Hello");
            sample.PatternMatchingNullCheckExample(null);
            Console.WriteLine();
        }
    }
}

#nullable restore
