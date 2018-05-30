# kframework-env
k5 (kframework) installation with vim goodies

## To download from dockerhub and run:
```
sudo docker run -u dev --entrypoint="" -v $(pwd):/home/dev/playground jakegillberg/kframework /bin/bash --login -c 'cd /home/dev/playground; echo "hello world"'
```
If it works, you should see a printed `hello world`. Replace `echo "hello world"` with a different command you would like to run, like `kompile`.
