---
title: Convert to try-with-resources (Java Scanner)
date: 2026-03-15
description: How to convert a Java Scanner to a try-with-resources statement for cleaner, safer resource management.
tags:
  - java
  - exception-handling
  - best-practices
categories: java
---

To convert a Java Scanner to a try-with-resources statement, declare the Scanner object within the parentheses of the try statement. Java will then automatically close the resource when the block finishes, eliminating the need for a finally block to close it manually.

## **Traditional try-catch-finally**

In the traditional approach (pre-Java 7), you had to ensure the Scanner was closed in a finally block to prevent resource leaks.

```java
import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;

public class TraditionalScannerExample {
    public static void main(String[] args) {
        Scanner scanner = null;
        try {
            // Using a file for demonstration; works similarly for System.in
            scanner = new Scanner(new File("data.txt"));
            while (scanner.hasNextLine()) {
                System.out.println(scanner.nextLine());
            }
        } catch (FileNotFoundException e) {
            System.out.println("File not found.");
            e.printStackTrace();
        } finally {
            // Manually closing the scanner
            if (scanner != null) {
                scanner.close();
            }
        }
    }
}
```

**Modern try-with-resources**

With Java 7 and later, any object that implements the AutoCloseable interface (which Scanner does) can be used in a try-with-resources statement.

```java
import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;

public class TryWithResourcesExample {
    public static void main(String[] args) {
        // Declare the Scanner inside the parentheses
        try (Scanner scanner = new Scanner(new File("data.txt"))) {
            while (scanner.hasNextLine()) {
                System.out.println(scanner.nextLine());
            }
        } catch (FileNotFoundException e) {
            // No need for a finally block; Java automatically closes the scanner
            System.out.println("File not found.");
            e.printStackTrace();
        }
    }
}
```

**Key Benefits**

- **Automatic Closure**: The resource is guaranteed to be closed when the try block is exited, even if an exception occurs.
- **Cleaner Code**: It significantly reduces the amount of boilerplate code compared to a finally block.
- **Improved Readability**: It makes the code more concise and easier to manage, especially with multiple resources.
