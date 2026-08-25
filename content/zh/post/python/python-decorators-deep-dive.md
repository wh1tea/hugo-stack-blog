---
title: Python 装饰器详解
date: 2026-04-20
description: 深入理解 Python 装饰器的核心原理与常见应用场景，涵盖带参数装饰器、functools.wraps 用法及实际开发中的最佳实践。
tags:
  - python
  - decorators
  - advanced
categories:
  - python
---

# Python 装饰器详解

Python 装饰器是一种强大的语法糖，允许你在不修改函数本身的情况下扩展函数的行为。

## 什么是装饰器？

装饰器本质上是一个接受函数作为参数的可调用对象，并返回一个替换函数。

```python
def my_decorator(func):
    def wrapper():
        print("Something is happening before the function is called.")
        func()
        print("Something is happening after the function is called.")
    return wrapper

@my_decorator
def say_hello():
    print("Hello!")

say_hello()
```

## 带参数的装饰器

当你的装饰器需要参数时，需要再嵌套一层：

```python
def repeat(n):
    def decorator(func):
        def wrapper(*args, **kwargs):
            for _ in range(n):
                func(*args, **kwargs)
        return wrapper
    return decorator

@repeat(3)
def greet(name):
    print(f"Hello, {name}!")

greet("World")
```

## 保留元信息的装饰器

使用 `functools.wraps` 来保留原始函数的元信息：

```python
from functools import wraps

def my_decorator(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        """Wrapper function"""
        print("Before call")
        return func(*args, **kwargs)
    return wrapper

@my_decorator
def my_function():
    """My function docstring"""
    pass

print(my_function.__name__)   # my_function (not wrapper)
print(my_function.__doc__)    # My function docstring
```

## 常见应用场景

- **日志记录**：自动记录函数调用
- **性能计时**：测量函数执行时间
- **权限检查**：验证用户权限
- **缓存**：缓存函数返回值
- **重试机制**：失败时自动重试
