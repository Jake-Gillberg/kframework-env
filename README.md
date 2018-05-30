# kframework-env
[k5](https://github.com/kframework/k5) (kframework) installation with vim goodies

## To download from dockerhub and run:
```
docker run -u dev --entrypoint="" -v $(pwd):/home/dev/playground jakegillberg/kframework /bin/bash --login -c 'cd /home/dev/playground; echo "hello world"'
```
If it works, you should see a printed `hello world`. Replace `echo "hello world"` with a different command you would like to run, like `kompile`.

## Testing the kframework installation
### Create a k definition
Create a file called `lambda.k` and write the below lines to it:
```
module LAMBDA
  imports DOMAINS

  syntax Val ::= Id
               | "lambda" Id "." Exp
  syntax Exp ::= Val
               | Exp Exp      [left]
               | "(" Exp ")"  [bracket]
endmodule
```
Congratulations! you just wrote a K definition!

### Compile the k definition
Replace `echo "hello world"` with `kompile lambda.k` in the command above for:
```
docker run -u dev --entrypoint="" -v $(pwd):/home/dev/playground jakegillberg/kframework /bin/bash --login -c 'cd /home/dev/playground; kompile lambda.k'
```

Contratulations! You just compiled a K definition! You should see the below output:
```
40 states, 1247 transitions, table size 5228 bytes
[Warning] Compiler: Could not find main syntax module with name LAMBDA-SYNTAX
in definition.  Use --syntax-module to specify one. Using LAMBDA as default.
```

### Write a program that will be parsed with the k definition
Create a file called `identity.lambda` and write the below line to it:
```
lambda x . x
```

Congratulations! You just wrote a progam in your newly-defined language!

### Parse your program
Execute `krun identity.lambda` in your docker environment, like we did with `kompile lambda.k`:
```
docker run -u dev --entrypoint="" -v $(pwd):/home/dev/playground jakegillberg/kframework /bin/bash --login -c 'cd /home/dev/playground; krun identity.lambda'
```

Congratulations! You just parsed a program using kframework! You should see the elow output:
```
<k>
  lambda x . x
</k>
```

