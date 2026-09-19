# nix-lab secerets template

In my own setup, I keep this in a private repository. Everything in here is
encrypted with age and sops. These secrets will be pulled by nixos-rpi-lab

To init,

```
sops secrets/homelab.yaml
```

add your keys to `.sops.yaml`, for instance:

```yaml
# This example uses YAML anchors which allows reuse of multiple keys
# without having to repeat yourself.
# Also see https://github.com/Mic92/dotfiles/blob/d6114726d859df36ccaa32891c4963ae5717ef7f/nixos/.sops.yaml
# for a more complex example.
keys:
  - &admin age1yubikey1qw0ux80u4fpkrl7xuqap8hufkjey3tfrnhcwge5dmzwnrstlv4g8u9ztmdj
  - &node_1 age1nzefcfqa5kzjz47paehsqqxpcm4lmpe7902kzevcva546v8x95hqf540wg
creation_rules:
  - path_regex: secrets/[^/]+\.(yaml|json|env|ini)$
    key_groups:
      - age:
          - *admin
          - *node_1
```

homelab.yaml contents for k3s:

```yaml
k3s_token: your_k3s_token
```

# Keyscan

the devshell of this repository contains a small `keyscan` command/script. This
scans a remote host for its ssh public key and converts it to age, to make it
easier to add to `.sops.yaml`

For instance, if i wanted the age public key of a host at `192.168.1.100`:

```
nix run .#keyscan -- 192.168.1.100
```

which would output

```
➜ nix run .#keyscan -- 192.168.1.100
skipped key: got ssh-rsa key type, but only ed25519 keys are supported
age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
```
