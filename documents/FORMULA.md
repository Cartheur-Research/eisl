# Formula

  translater from infix to prefix, from prefix to infix.

  Written by Dr. Shimoji.
  We will use the code with the permission of Dr. Shimoji. 

# Acknowledgments
Thank you Dr. Shimoji.

# Usage

```
(import "formula)
```

# Function

| Function                          | Description                                             |
| --------------------------------- | --------------------------------------------------------|
| (formula x)                       | Translate infix-notation to prefix-notation and eval it |
| (infix-prefix x)                  | Translate infix-notation sexp to prefix-notation        |
| (prefix->infix x)                 | Translate prefix-notation sexp to infix-notation        |


# Example

```
> (import "formula")
T
> (formula 2 ^ 3 + 3 * 4 + 1)
21
> (infix->prefix '(1 + 2))
(+ 1 2)
> (prefix->infix '(+ 1 2))
(1 + 2)
> 

```