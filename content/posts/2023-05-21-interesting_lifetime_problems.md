+++


[taxonomies]
tags = ["rust", "lifetime"]

authors = ["Jiangqiu Shen"]
+++



the lifetime checker of rust is very strict, and it is not easy to handle complicate lifetime problems

in this post, I will collect some interesting lifetime problems I encountered as long as my solutions.

# the lifetime of when capturing a variable in a closure