# Crea dinamicamente servers 

Terraform para crear dinamicamente una cantidad de servidores en una cantidad de subnets que se pueden ingresar por variables

Se dejan los servidores publicos con el security group **sg_server_public** para pruebas pero este debe eliminarse en produccion

```bash
terraform apply -auto-approve -var='number_servers=2' -var='amount_subnets=2'
```
