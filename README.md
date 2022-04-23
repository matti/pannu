# pannu-aws

creates a pannu in aws

## jump

```
./pannu aws ensure eu-west-1 jump-1 \
  --instance-type=t3.micro \
  --volume-size=24
./pannu aws ssh eu-west-1 jump-1 sudo apt-get update
./pannu aws ssh eu-west-1 jump-1 sudo apt-get install -y postgresql-client
```

## k0s

```
./pannu aws delete-instance eu-north-1 k0s-1
./pannu aws ensure eu-north-1 k0s-1
./pannu aws ensure-ingress eu-north-1 k0s-1 --protocol=tcp --from=6443 --to=6443 --cidr=0.0.0.0/0
./pannu aws install:k0s eu-north-1 k0s-1
```
