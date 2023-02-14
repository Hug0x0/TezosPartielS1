docker run --rm --name my-sandbox --detach -p 20000:20000 \ tqtezos/flextesa:20210930 granabox start
tezos-client config reset # Cleans-up
tezos-client --endpoint http://localhost:20000 bootstrapped  #Bootsrap the sandbox
tezos-client --endpoint http://localhost:20000 config update
tezos-client --endpoint http://localhost:20000 config show

docker run --rm tqtezos/flextesa:20210930 granabox info
