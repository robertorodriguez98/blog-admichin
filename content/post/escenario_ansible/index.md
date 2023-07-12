---
title: "Escenario ansible y vagrant"
date: 2022-10-13T09:09:04+02:00
draft: true
---
Para hacer el `SNAT` aplicamos la siguiente regla de iptables:
```bash
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/8 -o eth1 -j MASQUERADE
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -i eth1 -j DNAT --to 10.0.0.0:80
iptables -t nat -A PREROUTING -p tcp --dport 80 -i ens4 -j DNAT --to 10.0.0.2:80
```

```bash
sudo ip route delete default
sudo ip route add default via 192.168.0.1
```