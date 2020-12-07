# Umbrella

Work in progress umbrella package

## Iron Bank Images

Per the Charter, all Big Bang packages will leverage container images from [IronBank](https://ironbank.dsop.io/).  In order to pull these images, ImagePullSecrets must be provided to BigBang.  For developers to obtain access
to the images, follow the guides below.  These steps should NOT be used for production since the API keys for a user are only valid when the user is logged into [Registry1](https://registry1.dsop.io)

1) Register for a free Ironbank account [Here](https://sso-info.il2.dsop.io/new_account.html)
2) Log into the [Iron Bank Registry](https://registry1.dsop.io), in the top right click your *Username* and then *User Profile* to get access to your *CLI secret*/API keys.
3) When installing BigBang, set the Helm Values `registryCredentials.username` and `registryCredentials.password` to match your Registry1 username and API token

## Usage

The following examples expect a cluster with fluxv2 preinstalled.  This can be done by [installing the flux cli](https://toolkit.fluxcd.io/get-started/#install-the-flux-cli) and running `flux install`.  This will install flux from the internet.  If you wish to install the Iron Bank approved images, run `hack/flux-install.sh` to install flux from the [Iron Bank Registry](https://registry1.dsop.io).

### Quickstart

A quickstart BigBang environment is provided under `examples`.  The `dev` environment is setup to only install Istio and Gatekeeper.  The `prod` environment will install all of the default packages.

Prequisites:

- Git repository for your BigBang environment
- [GNU Privacy Guard (GPG)](https://gnupg.org/index.html)
- [Secrets Operations (SOPS)](https://github.com/mozilla/sops)

1. Copy the contents of the `examples` folder to your repo.

#### Setup encryption

1. Using GPG, create a new encryption key.  GPG is one of [many supported encryption methods](https://github.com/mozilla/sops#sops-secrets-operations) for SOPS.
   - `gpg --full-generate-key`
   - Use `RSA and RSA` as the key type
   - Use `4096` as the keysize
   - Use `0` as the expiration
   - Add a name and email to identify the key
   - Enter your passphrase
   - Copy the key fingerprint displayed
1. Use sops to replace the development key with your new key
   - Replace the SOPS fingerprint: `sed -i 's/pgp:\s*\S*/pgp: <new key fingerprint>/' env/.sops.yaml`
   - Import the old key for decrypting: `gpg --import hack/sops.asc`
   - Update the encrypted file: `sops updatekeys env/common/secrets.enc.yaml -y`
1. Use sops to add your [Iron Bank](https://registry1.dsop.io) pull credentials
   - `sops env/common/secrets.enc.yaml`.
      - If you get an error decrypting, run `GPG_TTY=$(tty) && export GPG_TTY` and try to open the file again.
   - Setup `registryCredentials.username` and `registryCredentials.password` with your credentials
   - Save and exit
1. Commit and push `.sops.yaml` and `env/common/secrets.enc.yaml` to Git

#### Configure BigBang

1. Edit `env/dev.yaml`
   - In the `GitRepository` resource, update `spec.url` and `spec.branch` to point to your environment's Git repository.
   - In the `Kustomization` resource, update `spec.path` to point to the folder containing the dev environment
   - Save and exit
1. Commit and push `env/dev.yaml` to Git

#### Deploy BigBang

1. Create the `bigbang` namespace
   - `kubectl create namespace bigbang`
1. Deploy the SOPS private key to a secret.  We do this manually instead of storing our private key in Git insecurely.
   - `gpg --export-secret-keys --armor <new key fingerprint> | kubectl create secret generic sops-gpg -n bigbang --from-file=bigbangkey=/dev/stdin`
1. Apply the `env/dev.yaml` manifest to your Kubernetes cluster
   - `kubectl apply -f env/dev.yaml`
1. Watch the deployment with `watch kubectl get po,hr,kustomizations,gitrepositories -A`
   - Be patient, the deployment can take a 10-15 minutes for a minimal configuration, and more for the full Big Bang set of packages.
   - It is not recommended that you run the full Big Bang on a local desktop unless you have 32GB of RAM and a fast processor.  However, the `dev` configuration should work reasonably well.

### Multiple Environments

Big Bang allows full flexibility in configuring for multiple environments.  The environments share the
While simple to use, Big Bang also allows full flexibility in configuring individual packages, using encrypted secrets, and deploying to multiple environments with the same configuration base.

See the [Big Bang template readme](https://repo1.dsop.io/platform-one/big-bang/customers/bigbang/-/tree/master/bigbang/README.md) for more information.

### Developers

Developers can use the [Developer Setup](./docs/developer_setup.md) to faciliate a local setup for developing improvements to Big Bang.

### Contributing

Please see our [contributing guide](./CONTRIBUTING.md) if you are interested in contributing to Big Bang.