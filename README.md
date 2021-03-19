# Provenance for SPARQL queries via Query Rewiring: Benchmar on the Wikidata dataset

This is the source code repository of a experiment to study a method
for computing how-provenance for SPARQL via query rewriting.  This
experiment define a set of queries on the Wikidata dataset.

## Structure of this repository

```
lib            # Libraries required for the experiments
machines       # Configuration files for our machine
queries        # Benchmark queries
rakelib        # Task definitions
results        # Obtained results
task_status    # Status of the executed tasks
test_queries   # Some auxiliar queries
```

### Recording configurations for multiple machines

These experiments are designed to run in different machines.  Machine
configuration, benchmark results, and information about the status of
tasks are saved and tracked in the `machines` directory. Each machine
has a separate folder. In the current version we have the following
structure:

```
machines/
├── a256
│   ├── config
│   ├── results
│   └── task_status
└── a64
    ├── config
    ├── results
    └── task_status
```

To start runing the benchmark tasks you have to activate the machine
you will use.  This is done by creating a symbolic link to the
machine. For instance, we can activate machine `a256` as follows:

```
ln -s machines/a256 active_machine
```

## Preparing the environment

In this experiment we need three tools: LXD to install engines inside
containers, Ruby to automatize the execution of benchmarks, and
TripleProv.

### Setup LXD

We use LXD containers to facilitate the reproducibility of this
experiment.  Each of the multiple database instances is enclosed into
a separate container.

In our experiment we use a machine with Ubuntu 18.04 and install LXD
using `snap` (the recomended way these days).  Instructions to setup
LXD can be found in the [LXD
documentation](https://linuxcontainers.org/lxd/getting-started-cli/#installation).

### Setup Ruby

We use the Ruby programing language to automatize the execution of the
experiments.  We use the version 3.0.0 that can be installed with
`rbenv` and `rbenv-install`.  The following commands install Ruby 3.0.0.

```bash
sudo apt install -y \
  autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev \
  zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev \
  pigz
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
. ~/.bashrc
mkdir -p "$(rbenv root)"/plugins
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
rbenv install 3.0.0
```

After installing Ruby 3.0.0 it is needed to install some Ruby
packages.  This is done by running `bundle install` inside the root
folder of this repository.

## Preparing the data

We use the [Wikidata dump of january 27,
2021](https://doi.org/10.5281/zenodo.3746598).  This dataset is
partitioned in several tar files.  Dowload all parts in the folder
`dataset` and then run the following commands:

```bash
cd dataset

ls *.tar | parallel 'tar -xf {} ; rm {}'
ls *.xz | parallel 'xz -d -c {} | gzip --best > {.}.gz'
```

The last command is executed because most engines support the `gz`
file format, but not `xz`.  We use the latter for preservation only,
because it has a higher compression rate.

## Creating containers for the triple stores

We consider two triple store engines: Fuseki 3 (using TDB1) and
Virtuoso 7.  Datasets are loaded using [rake
tasks](https://github.com/ruby/rake) that are defined in `rakelib`.
Before loading the datasets, we need to create a container for each
engine.

```bash
rake task_status/done_create_fuseki_3_container
rake taks_status/done_create_virtuoso_7_container
```

This create to containers, namely `fuseki3-ubuntu2004` and `virtuoso7-debian9`. 
Then we clone these containers to load the data on them:

```bash
lxc copy fuseki3-ubuntu2004 wikidata-20200127-fuseki3-ubuntu2004
lxc copy virtuoso7-debian9 wikidata-20200127-virtuoso7-debian9
```

We then copy the dataset into the containers and load the data as
usual in both engines.

## Running the benchmark

An experiment workload is defined by a combination of a query template
and a triple store engine.  The execution of each query workload
generates a corresponding CSV file in the folder `results`.  All
experiment workloads are executed with the following rake task:

```bash
rake bench
```

Workloads can also be executed individually.  To list all experiment
workloads you can execute the following command:

```bash
rake --tasks task_status/done_run_bench
```
