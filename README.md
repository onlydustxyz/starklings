<div align="center">
  <h1 align="center">Starklings</h1>
  <p align="center">
    <a href="https://discord.gg/onlydust">
        <img src="https://img.shields.io/badge/Discord-6666FF?style=for-the-badge&logo=discord&logoColor=white">
    </a>
    <a href="https://twitter.com/intent/follow?screen_name=onlydust_xyz">
        <img src="https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white">
    </a>       
  </p>
  
  <h3 align="center">An interactive tutorial to get you up and running with Starknet</h3>
</div>

---

## Installation

Clone the repository to your local machine:

```shell
git clone --branch stable --single-branch https://github.com/onlydustxyz/starklings.git
```

Then install the tool, run:

```shell
curl -L https://raw.githubusercontent.com/onlydustxyz/starklings/master/install.sh | bash
```

## Usage

Run the tool in watch mode in the repository and follow the instructions:

```shell
cd PATH_TO_THE_CLONED_REPO
starklings --watch
```

To verify your solutions without running the watch mode run:

```shell
starklings --verify
```

To display one solution to a given exercise run:

```shell
starklings --solution path_to_the_exercise_file
```

## Update

The tool is in continuous evolution. You might want to update it regularly.

```shell
git pull
bash install.sh
```

## Inspiration

- [Protostar](https://github.com/software-mansion/protostar) for all the project tooling and setup, deployment, packaging
- [Rustlings](https://github.com/rust-lang/rustlings) for the amazing pedagogy and brilliant concept of progressive and interactive tutorial

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).
